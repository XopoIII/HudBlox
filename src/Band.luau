--!strict
--- What the game's own furniture takes at the bottom of the screen (a hotbar, an open inventory), so
--- everything else down there steps above it instead of under it.
---
--- A bar that changes width cannot be cleared by a card placed once and forgotten. Whoever draws
--- the bar reports its rectangles here with `set`; a card asks `lift` how much higher it must stand
--- and listens with `onChange`. Only something that overlaps a rectangle sideways is lifted, so a
--- card beside a narrow bar keeps its corner.
---
--- Every number is in the space of one ScreenGui, measured up from the screen's bottom edge. The
--- rectangles are shared by everything that requires this module, which is the point.
const Band = {}

--- Air between a lifted thing and what it clears.
Band.GAP = 8

--- A reported rectangle: its sides, and how high its top stands above the screen's bottom edge.
export type Rect = { left: number, right: number, top: number }

const rects: { [string]: Rect } = {}
const listeners: { [() -> ()]: true } = {}

const function fire()
	-- A copy: a listener may stop listening while it is being called.
	for listener in table.clone(listeners) do
		if listeners[listener] then
			listener()
		end
	end
end

--> Reports the rectangle of `key`, or takes it away with nil. Listeners hear only a real change.
function Band.set(key: string, rect: Rect?)
	const old = rects[key]
	if old == rect then
		return
	end
	if old and rect and old.left == rect.left and old.right == rect.right and old.top == rect.top then
		return
	end
	if rect then
		rects[key] = { left = rect.left, right = rect.right, top = rect.top }
	else
		rects[key] = nil
	end
	fire()
end

--> Whether `key` has a rectangle now (an inventory is open, for one).
function Band.has(key: string): boolean
	return rects[key] ~= nil
end

--> How much higher than `bottom` (its lower edge, up from the screen's bottom) something spanning
--> `left`..`right` must stand to clear every rectangle it overlaps sideways. 0 when it is clear.
function Band.lift(left: number, right: number, bottom: number): number
	local need = 0
	for _, rect in rects do
		if left < rect.right and right > rect.left then
			need = math.max(need, rect.top + Band.GAP)
		end
	end
	return math.max(0, need - bottom)
end

--> Calls `changed` after every real change. Returns the function that stops it.
function Band.onChange(changed: () -> ()): () -> ()
	-- Wrapped, so the same function given twice is two listeners with two stops.
	const function listener()
		changed()
	end
	listeners[listener] = true
	return function()
		listeners[listener] = nil
	end
end

--> Forgets every rectangle, without telling anyone. For specs, and for a HUD that is torn down.
function Band.clear()
	table.clear(rects)
end

return Band
