--!strict
--- Where each thing in the backpack sits: the pinned first slot, the bar, the inventory, and every
--- move between them.
const Order = require("@hudblox/Backpack/Order")
const Spec = require("../Spec")

--- A bar of `size` with "pin" pinned and standing, then `ids` added in order, none fresh.
const function pinnedBag(size: number, ids: { string }): Order.Order
	const order = Order.new(size, "pin")
	Order.add(order, "pin", false)
	for _, id in ids do
		Order.add(order, id, false)
	end
	return order
end

const function place(order: Order.Order, id: string): string
	const at = Order.where(order, id)
	return if at then `{at.zone}{at.index}` else "none"
end

Spec.test("the pinned thing stands in slot 1; the bar fills from slot 2, then the inventory", function()
	const order = pinnedBag(3, { "a", "b", "c", "d" })
	Spec.equal(place(order, "pin"), "bar1", "pin")
	Spec.equal(place(order, "a"), "bar2", "a")
	Spec.equal(place(order, "b"), "bar3", "b")
	Spec.equal(place(order, "c"), "grid1", "c")
	Spec.equal(place(order, "d"), "grid2", "d")
	Spec.equal(place(order, "nobody"), "none", "a thing that is not there")
end)

Spec.test("slot 1 is kept for the pinned thing while it is missing", function()
	const order = Order.new(3, "pin")
	Spec.equal(Order.add(order, "a", false), true, "a is new")
	Spec.equal(Order.add(order, "b", false), true, "b is new")
	Spec.equal(Order.add(order, "c", true), true, "c is new")
	Spec.equal(place(order, "a"), "grid1", "the oldest steps down for the fresh one, not into slot 1")
	Spec.equal(place(order, "c"), "bar2", "c")
	Spec.equal(order.bar[1], nil, "slot 1 is empty")
	Spec.equal(Order.move(order, "b", { zone = "bar", index = 1 }), false, "nothing moves into it")
end)

Spec.test("with nothing pinned, slot 1 is a slot like the rest", function()
	const order = Order.new(2)
	Order.add(order, "a", false)
	Order.add(order, "b", false)
	Order.add(order, "c", false)
	Spec.equal(place(order, "a"), "bar1", "a")
	Spec.equal(place(order, "b"), "bar2", "b")
	Spec.equal(place(order, "c"), "grid1", "c")
	Spec.equal(Order.move(order, "c", { zone = "bar", index = 1 }), true, "a thing moves into slot 1")
	Spec.equal(place(order, "c"), "bar1", "c")
	Spec.equal(place(order, "a"), "grid1", "a")
	Spec.equal(Order.sendAcross(order, "c"), true, "and leaves it")
	Spec.equal(place(order, "c"), "grid1", "c at the front")
end)

Spec.test("a thing added twice is placed once", function()
	const order = pinnedBag(3, { "a" })
	Spec.equal(Order.add(order, "a", true), false, "already there")
	Spec.equal(place(order, "a"), "bar2", "where it was")
	Spec.equal(order.seq, 2, "and not counted again")
end)

Spec.test("a pinned thing that arrives late takes slot 1 from whatever stood there", function()
	const order = Order.new(2, "pin")
	Order.add(order, "a", false)
	order.bar[1] = "squatter"
	order.bar[2] = nil
	order.grid = { "a" }
	order.rank = { a = 5 }
	Order.add(order, "pin", false)
	Spec.equal(order.bar[1], "pin", "the pinned thing")
	Spec.equal(order.grid, { "squatter", "a" }, "the squatter at the inventory's front")
	Spec.equal(order.rank["squatter"], 4, "ranked just before the first")
end)

Spec.test("the pinned thing never moves, and is never sent across", function()
	const order = pinnedBag(3, { "a" })
	Spec.equal(Order.move(order, "pin", { zone = "grid", index = 0 }), false, "to the inventory")
	Spec.equal(Order.move(order, "pin", { zone = "bar", index = 3 }), false, "along the bar")
	Spec.equal(Order.sendAcross(order, "pin"), false, "sent")
	Spec.equal(place(order, "pin"), "bar1", "still there")
end)

Spec.test("a fresh thing takes the slot of the one longest on a full bar", function()
	const order = pinnedBag(3, { "a", "b" })
	Order.add(order, "new", true)
	Spec.equal(place(order, "new"), "bar2", "new")
	Spec.equal(place(order, "a"), "grid1", "the oldest steps down")
	Spec.equal(place(order, "b"), "bar3", "b stays")
	Order.add(order, "newer", true)
	Spec.equal(place(order, "newer"), "bar3", "b was the oldest then")
	Spec.equal(order.grid, { "b", "a" }, "each stepped to the front")
end)

Spec.test("a thing that is not fresh goes to the end of the inventory when the bar is full", function()
	const order = pinnedBag(2, { "a", "b" })
	Order.add(order, "c", false)
	Spec.equal(place(order, "a"), "bar2", "a keeps its slot")
	Spec.equal(order.grid, { "b", "c" }, "in the order they came")
	Spec.equal(order.rank, { b = 0, c = 1 }, "ranked upwards")
end)

Spec.test("a move between the bar and the inventory is a swap, both ways", function()
	const order = pinnedBag(3, { "a", "b", "c", "d" })
	Spec.equal(Order.move(order, "c", { zone = "bar", index = 2 }), true, "c to the bar")
	Spec.equal(place(order, "c"), "bar2", "c")
	Spec.equal(place(order, "a"), "grid1", "a took its place")
	Spec.equal(Order.move(order, "b", { zone = "grid", index = 2 }), true, "b to the inventory")
	Spec.equal(place(order, "b"), "grid2", "b")
	Spec.equal(place(order, "d"), "bar3", "d took its slot")
	Spec.equal(order.rank, { a = 0, b = 1 }, "each took the rank of what it swapped with; the bar has none")
end)

Spec.test("a move along the bar swaps two slots, and to an empty one leaves a gap", function()
	const order = pinnedBag(4, { "a", "b" })
	Spec.equal(Order.move(order, "a", { zone = "bar", index = 3 }), true, "a and b")
	Spec.equal(place(order, "a"), "bar3", "a")
	Spec.equal(place(order, "b"), "bar2", "b")
	Spec.equal(Order.move(order, "a", { zone = "bar", index = 4 }), true, "to the empty slot")
	Spec.equal(place(order, "a"), "bar4", "a")
	Spec.equal(order.bar[3], nil, "its slot is empty")
end)

Spec.test("a move to where the thing is, or off the bar's ends, is no move", function()
	const order = pinnedBag(3, { "a", "b", "c" })
	Spec.equal(Order.move(order, "a", { zone = "bar", index = 2 }), false, "its own slot")
	Spec.equal(Order.move(order, "a", { zone = "bar", index = 4 }), false, "past the bar")
	Spec.equal(Order.move(order, "c", { zone = "grid", index = 1 }), false, "its own place")
	Spec.equal(Order.move(order, "c", { zone = "grid", index = 0 }), false, "the inventory, from the inventory")
	Spec.equal(Order.move(order, "nobody", { zone = "bar", index = 2 }), false, "a thing that is not there")
	Spec.equal(Order.move(order, "a", { zone = "bar", index = 3 }), true, "the last slot is on the bar")
end)

Spec.test("a thing from the inventory fills an empty bar slot and leaves the inventory", function()
	const order = pinnedBag(3, { "a", "b", "c", "d" })
	Order.remove(order, "a")
	Spec.equal(Order.move(order, "d", { zone = "bar", index = 2 }), true, "moved")
	Spec.equal(place(order, "d"), "bar2", "d")
	Spec.equal(order.grid, { "c" }, "the inventory closed up")
end)

Spec.test("two things in the inventory swap places and ranks", function()
	const order = pinnedBag(2, { "a", "b", "c" })
	Spec.equal(order.rank, { b = 0, c = 1 }, "before")
	Spec.equal(Order.move(order, "b", { zone = "grid", index = 2 }), true, "swapped")
	Spec.equal(order.grid, { "c", "b" }, "places")
	Spec.equal(order.rank, { b = 1, c = 0 }, "ranks")
end)

Spec.test("a thing dropped on the inventory goes to its front", function()
	const order = pinnedBag(3, { "a", "b", "c", "d" })
	Spec.equal(Order.move(order, "a", { zone = "grid", index = 0 }), true, "moved")
	Spec.equal(order.grid, { "a", "c", "d" }, "at the front")
	Spec.equal(order.bar[2], nil, "its slot is empty")
	Spec.equal(order.rank["a"], -1, "ranked before the first")
end)

Spec.test("a double tap sends a thing across and back", function()
	const order = pinnedBag(4, { "a", "b" })
	Spec.equal(Order.sendAcross(order, "a"), true, "to the inventory")
	Spec.equal(place(order, "a"), "grid1", "a")
	Spec.equal(Order.sendAcross(order, "a"), true, "and back")
	Spec.equal(place(order, "a"), "bar2", "the first free slot")
	Spec.equal(Order.sendAcross(order, "nobody"), false, "a thing that is not there")
end)

Spec.test("sent to a full bar, a thing swaps with its last slot", function()
	const order = pinnedBag(3, { "a", "b", "c" })
	Spec.equal(Order.sendAcross(order, "c"), true, "sent")
	Spec.equal(place(order, "c"), "bar3", "c")
	Spec.equal(place(order, "b"), "grid1", "b")
end)

Spec.test("everything goes back where it was after the backpack is emptied and refilled", function()
	const order = pinnedBag(3, { "a", "b", "c", "d", "e" })
	Order.move(order, "e", { zone = "bar", index = 2 })
	const ids = { "pin", "a", "b", "c", "d", "e" }
	const before: { [string]: string } = {}
	for _, id in ids do
		before[id] = place(order, id)
	end
	Spec.equal(before, { pin = "bar1", e = "bar2", b = "bar3", c = "grid1", d = "grid2", a = "grid3" }, "before")
	for _, id in ids do
		Order.remove(order, id)
	end
	Spec.equal(order.grid, {}, "emptied")
	-- Refilled in another order than the player's.
	for _, id in { "pin", "a", "b", "c", "d", "e" } do
		Order.add(order, id, false)
	end
	for _, id in ids do
		Spec.equal(place(order, id), before[id], id)
	end
end)

Spec.test("a remembered bar slot that was taken meanwhile is not taken back", function()
	const order = pinnedBag(3, { "a", "b" })
	Order.remove(order, "a")
	Order.add(order, "c", false)
	Spec.equal(place(order, "c"), "bar2", "c took the free slot")
	Order.add(order, "a", false)
	Spec.equal(place(order, "a"), "grid1", "a goes to the inventory")
	Order.remove(order, "nobody")
	Spec.equal(order.memory["nobody"], nil, "a thing that was never there is not remembered")
end)

Spec.test("a remembered slot off a bar that shrank meanwhile is not taken back", function()
	const order = pinnedBag(4, { "a", "b", "c" })
	Order.remove(order, "c")
	Order.resize(order, 2)
	Order.add(order, "c", false)
	Spec.equal(place(order, "c"), "grid2", "c goes to the end of the inventory")
	Spec.equal(order.bar[4], nil, "and not to a slot that is gone")
end)

Spec.test("a bar that shrinks steps what no longer fits into the inventory, in slot order", function()
	const order = pinnedBag(4, { "a", "b", "c" })
	Order.resize(order, 2)
	Spec.equal(order.size, 2, "size")
	Spec.equal(place(order, "a"), "bar2", "a fits")
	Spec.equal(order.grid, { "b", "c" }, "b before c")
	Spec.equal(place(order, "b"), "grid1", "and off the bar")
	Spec.equal(order.bar[3], nil, "its slot is gone")
	Order.resize(order, 0)
	Spec.equal(order.size, 1, "a bar has a slot at least")
	Spec.equal(order.grid, { "a", "b", "c" }, "a at the front")
	Order.resize(order, 5)
	Spec.equal(order.size, 5, "grown")
	Spec.equal(order.grid, { "a", "b", "c" }, "and nothing moved")
	Spec.equal(Order.new(0).size, 1, "a new bar too")
end)

Spec.test("a gamepad's bumper steps along the filled slots, wrapping", function()
	const order = pinnedBag(5, { "a", "b" })
	Order.move(order, "b", { zone = "bar", index = 5 })
	Spec.equal(Order.step(order, nil, 1), "pin", "from nothing, forward: the first")
	Spec.equal(Order.step(order, nil, -1), "b", "from nothing, back: the last")
	Spec.equal(Order.step(order, "pin", 1), "a", "forward")
	Spec.equal(Order.step(order, "a", 1), "b", "over the empty slots")
	Spec.equal(Order.step(order, "b", 1), "pin", "wrapping forward")
	Spec.equal(Order.step(order, "pin", -1), "b", "wrapping back")
	Spec.equal(Order.step(order, "nobody", 1), "pin", "a thing off the bar is nothing in hand")
	Spec.equal(Order.step(Order.new(3), nil, 1), nil, "an empty bar")
end)

return nil
