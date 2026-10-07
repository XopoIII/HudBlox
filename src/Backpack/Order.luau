--!strict
--- Where each thing in the backpack sits: a slot on the hotbar or a place in the inventory above it.
--- Pure: ids in, ids out, no Instances, so every rule is a spec (`tests/unit/BackpackOrder.luau`).
---
--- An id names the same kept thing through a hold, a stow, a death and a respawn. The rules:
---
--- - **A pinned id owns slot 1** and never leaves it; nothing else may take it, even while the pinned
---   thing is missing. A game with nothing to pin leaves it out, and slot 1 is a slot like the rest.
--- - **A thing seen before goes back where it was.** Every removal is remembered, so a respawn, which
---   empties the Backpack and fills it again, puts each slot back as the player left it.
--- - **A fresh thing goes on the bar** (just taken). With no free slot, the thing that has been on the
---   bar longest steps down to the front of the inventory and the newcomer takes its slot.
--- - Anything else takes the first free slot, or the end of the inventory.
---
--- Every move is a swap: whatever stood on the target goes where the moved thing came from. The
--- inventory keeps its order by a rank per id rather than by index, so taking things out and putting
--- them back in any order never reshuffles it.
const Order = {}

export type Zone = "bar" | "grid"
--- A grid place's `index` 0 means "the inventory, anywhere": its front.
export type Place = { zone: Zone, index: number }

type Memory = { zone: Zone, index: number, rank: number? }

export type Order = {
	size: number,
	--- The id that owns slot 1, if the game pins one.
	pinned: string?,
	bar: { [number]: string },
	grid: { string },
	rank: { [string]: number },
	memory: { [string]: Memory },
	arrived: { [string]: number },
	seq: number,
}

--> An empty order with a bar of `size` slots. `pinned` is the id that owns slot 1.
function Order.new(size: number, pinned: string?): Order
	return {
		size = math.max(size, 1),
		pinned = pinned,
		bar = {},
		grid = {},
		rank = {},
		memory = {},
		arrived = {},
		seq = 0,
	}
end

function Order.where(o: Order, id: string): Place?
	for index, there in o.bar do
		if there == id then
			return { zone = "bar", index = index }
		end
	end
	const at = table.find(o.grid, id)
	return if at then { zone = "grid", index = at } else nil
end

-- The first slot a thing that is not pinned may stand on.
const function lowest(o: Order): number
	return if o.pinned then 2 else 1
end

const function freeBar(o: Order): number?
	for index = lowest(o), o.size do
		if o.bar[index] == nil then
			return index
		end
	end
	return nil
end

-- Puts `id` into the inventory at `rank`, keeping it sorted.
const function insertRanked(o: Order, id: string, rank: number)
	o.rank[id] = rank
	local at = #o.grid + 1
	for index, other in o.grid do
		if o.rank[other] > rank then
			at = index
			break
		end
	end
	table.insert(o.grid, at, id)
end

const function frontRank(o: Order): number
	const first = o.grid[1]
	return if first then o.rank[first] - 1 else 0
end

const function backRank(o: Order): number
	const last = o.grid[#o.grid]
	return if last then o.rank[last] + 1 else 0
end

const function oldestOnBar(o: Order): number?
	local best, bestSeq = nil, math.huge
	for index = lowest(o), o.size do
		const id = o.bar[index]
		const seq = id and o.arrived[id]
		if seq and seq < bestSeq then
			best, bestSeq = index, seq
		end
	end
	return best
end

--> A new id. False if it is already placed.
function Order.add(o: Order, id: string, fresh: boolean): boolean
	if Order.where(o, id) then
		return false
	end
	o.seq += 1
	o.arrived[id] = o.seq
	if id == o.pinned then
		const squatter = o.bar[1]
		if squatter then
			insertRanked(o, squatter, frontRank(o))
		end
		o.bar[1] = id
		return true
	end
	const mem = o.memory[id]
	if mem and mem.zone == "bar" and mem.index >= lowest(o) and mem.index <= o.size and o.bar[mem.index] == nil then
		o.bar[mem.index] = id
		return true
	elseif mem and mem.zone == "grid" and mem.rank then
		insertRanked(o, id, mem.rank)
		return true
	end
	const free = freeBar(o)
	if free then
		o.bar[free] = id
		return true
	end
	const oldest = if fresh then oldestOnBar(o) else nil
	if oldest then
		insertRanked(o, o.bar[oldest], frontRank(o))
		o.bar[oldest] = id
		return true
	end
	insertRanked(o, id, backRank(o))
	return true
end

--> The id is gone (given away, or the Backpack emptied); its place is remembered in case it comes
--> back.
function Order.remove(o: Order, id: string)
	const from = Order.where(o, id)
	if not from then
		return
	end
	if from.zone == "bar" then
		o.bar[from.index] = nil
		o.memory[id] = { zone = "bar", index = from.index }
	else
		table.remove(o.grid, from.index)
		o.memory[id] = { zone = "grid", index = from.index, rank = o.rank[id] }
		o.rank[id] = nil
	end
end

--> Moves `id` to `target`, swapping with whatever is there. A bar target is a slot that is not the
--> pinned one; a grid target is a place in the inventory's current order, or index 0 for its
--> front. False when nothing moved.
function Order.move(o: Order, id: string, target: Place): boolean
	const from = Order.where(o, id)
	if id == o.pinned or not from then
		return false
	end
	if target.zone == "bar" then
		const to = target.index
		if to < lowest(o) or to > o.size or (from.zone == "bar" and from.index == to) then
			return false
		end
		const other = o.bar[to]
		if from.zone == "bar" then
			o.bar[from.index] = other
		elseif other then
			o.grid[from.index] = other
			o.rank[other] = o.rank[id]
		else
			table.remove(o.grid, from.index)
		end
		o.rank[id] = nil
		o.bar[to] = id
		return true
	end

	const other = o.grid[target.index]
	if from.zone == "grid" then
		if other == nil or other == id then
			return false
		end
		o.grid[from.index], o.grid[target.index] = other, id
		o.rank[id], o.rank[other] = o.rank[other], o.rank[id]
		return true
	end
	if other then
		o.bar[from.index] = other
		o.grid[target.index] = id
		o.rank[id] = o.rank[other]
		o.rank[other] = nil
	else
		o.bar[from.index] = nil
		insertRanked(o, id, frontRank(o))
	end
	return true
end

--> The double tap: bar to the inventory's front, or inventory to the first free bar slot; with the
--> bar full, a swap with its last slot.
function Order.sendAcross(o: Order, id: string): boolean
	const from = Order.where(o, id)
	if not from or id == o.pinned then
		return false
	end
	if from.zone == "bar" then
		return Order.move(o, id, { zone = "grid", index = 0 })
	end
	return Order.move(o, id, { zone = "bar", index = freeBar(o) or o.size })
end

--> A gamepad's bumper: the filled bar slot `by` steps from the one holding `current` (or from
--> before the first, with nothing in hand), wrapping.
function Order.step(o: Order, current: string?, by: number): string?
	const filled: { string } = {}
	local at = 0
	for index = 1, o.size do
		const id = o.bar[index]
		if id then
			table.insert(filled, id)
			if id == current then
				at = #filled
			end
		end
	end
	if #filled == 0 then
		return nil
	end
	if at == 0 and by < 0 then
		at = 1
	end
	return filled[(at - 1 + by) % #filled + 1]
end

--> The bar grew or shrank (a phone turned, a window resized). Whatever no longer fits steps down to
--> the inventory's front, in slot order.
function Order.resize(o: Order, size: number)
	size = math.max(size, 1)
	for index = o.size, size + 1, -1 do
		const id = o.bar[index]
		if id then
			o.bar[index] = nil
			insertRanked(o, id, frontRank(o))
		end
	end
	o.size = size
end

return Order
