--!strict
--- Draws the backpack from its state: each bar slot's thing, the inventory's slots in `Order`'s order
--- (made and dropped as things come and go, hidden by the search), the outlines for the thing in hand
--- and the one picked up, and the count. It also answers what is under a point, for a drag let go
--- (`Gesture`).
const Band = require("../Band")
const Bar = require("./Bar")
const Grid = require("./Grid")
const Items = require("./Items")
const Order = require("./Order")
const Slot = require("./Slot")

const Paint = {}

export type State = {
	order: Order.Order,
	byId: { [string]: Items.Item },
	gridSlots: { [string]: Slot.Slot },
	bar: Bar.Bar,
	grid: Grid.Grid,
	open: boolean,
	picked: string?,
	hidden: boolean,
	inHand: () -> Tool?,
	--- Makes an inventory slot and binds its gesture.
	newSlot: (index: number) -> Slot.Slot,
}

--> The slot that shows `id` now, on the bar or in the inventory.
function Paint.slotOf(state: State, id: string?): Slot.Slot?
	if not id then
		return nil
	end
	for _, slot in state.bar.slots do
		if slot.id == id then
			return slot
		end
	end
	return state.gridSlots[id]
end

const function inside(g: GuiObject, p: Vector2): boolean
	local a, s = g.AbsolutePosition, g.AbsoluteSize
	return p.X >= a.X and p.Y >= a.Y and p.X <= a.X + s.X and p.Y <= a.Y + s.Y
end

--> Where a drag let go at `p` lands: a slot, the inventory (index 0, its front), which is also
--> where anything dropped off both goes, as in the stock backpack, or nil for the gaps of the bar
--> itself.
function Paint.hit(state: State, p: Vector2): Order.Place?
	for _, slot in state.bar.slots do
		if slot.frame.Visible and inside(slot.frame, p) then
			return slot.place
		end
	end
	if state.open and inside(state.grid.scroller, p) then
		for _, slot in state.gridSlots do
			if slot.frame.Visible and inside(slot.frame, p) then
				return slot.place
			end
		end
	end
	if inside(state.bar.frame, p) then
		return nil
	end
	return { zone = "grid", index = 0 }
end

--> Draws everything from `state`.
function Paint.all(state: State)
	local order, byId = state.order, state.byId
	for index, slot in state.bar.slots do
		const id = order.bar[index]
		slot.place = { zone = "bar", index = index }
		slot.set(if id then byId[id] else nil)
		-- A slot its thing has just left keeps no outline: the thing may have been picked up (its
		-- slot pulsing) when a double tap sent it away.
		if not (id and byId[id]) then
			slot.setHeld(false)
			slot.setPicked(false)
		end
	end
	const barWidth = state.bar.layout(state.open)

	const seen: { [string]: boolean } = {}
	for index, id in order.grid do
		const item = byId[id]
		if item then
			const slot = state.gridSlots[id] or state.newSlot(index)
			state.gridSlots[id] = slot
			slot.place = { zone = "grid", index = index }
			slot.set(item)
			slot.frame.LayoutOrder = index
			slot.frame.Visible = state.grid.matches(item)
			seen[id] = true
		end
	end
	for id, slot in state.gridSlots do
		if not seen[id] then
			slot.destroy()
			state.gridSlots[id] = nil
		end
	end

	const inHand = state.inHand()
	local kept = 0
	for id, item in byId do
		kept += if item.counted then 1 else 0
		const slot = Paint.slotOf(state, id)
		if slot then
			slot.setHeld(item.tool == inHand)
			slot.setPicked(state.open and state.picked == id)
		end
	end
	state.grid.setCount(kept, #order.grid)
	state.bar.frame.Visible = not state.hidden
	Paint.band(state, barWidth)
end

--> Tells `Band` what the bar and the open inventory take, so the corner read-outs and hints step
--> above them.
function Paint.band(state: State, barWidth: number)
	const screen = state.bar.frame.Parent
	const w = if screen and screen:IsA("GuiBase2d") then screen.AbsoluteSize.X else 0
	const shown = not state.hidden and barWidth > Slot.GAP
	Band.set(
		"hotbar",
		if shown then { left = (w - barWidth) / 2, right = (w + barWidth) / 2, top = Bar.BOTTOM + Bar.HEIGHT } else nil
	)
	const frame = state.grid.frame
	const gw = frame.Size.X.Offset
	const bottom = -frame.Position.Y.Offset
	Band.set(
		"inventory",
		if state.open then { left = (w - gw) / 2, right = (w + gw) / 2, top = bottom + frame.Size.Y.Offset } else nil
	)
end

return Paint
