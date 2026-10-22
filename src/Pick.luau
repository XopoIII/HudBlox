--!strict
--- Which control the gamepad's focus lands on. Pure (`tests/unit/Pick.luau`).
---
--- A target is a control's centre on the screen, its `SelectionOrder`, and whether it can be chosen
--- at all: a hidden or unselectable one never is.
---
--- - `first` is where focus starts in a panel: the lowest order, then the top row, then the reading
---   start of that row (the right in a right-to-left locale).
--- - `nearest` is where it goes when the focused control is gone (a tile removed): the closest one
---   left, ties broken as `first` would.
const Pick = {}

--- Two centres this close in Y stand in one row.
Pick.ROW = 4

export type Target = {
	x: number,
	y: number,
	order: number,
	shown: boolean,
	selectable: boolean,
}

const function usable(target: Target): boolean
	return target.shown and target.selectable
end

const function before(a: Target, b: Target, rtl: boolean): boolean
	if a.order ~= b.order then
		return a.order < b.order
	end
	if math.abs(a.y - b.y) > Pick.ROW then
		return a.y < b.y
	end
	if a.x ~= b.x then
		return if rtl then a.x > b.x else a.x < b.x
	end
	return false
end

--> The index of the target focus starts on, or nil when none can be chosen.
function Pick.first(targets: { Target }, rtl: boolean): number?
	local best: number? = nil
	for index, target in targets do
		if usable(target) and (best == nil or before(target, targets[best], rtl)) then
			best = index
		end
	end
	return best
end

--- How much a step aside weighs against a step the way the pad points, in `toward`.
Pick.ASIDE = 2

--> The index of the usable target a press the way (`dx`, `dy`) goes to from (`x`, `y`), or nil when
--> none stands that way: of those further than a row's height that way, the one least far, a step
--> aside weighing `Pick.ASIDE` steps along, ties broken as `first` would. A target straight in line
--> wins, and when none is, the nearest one beside the line: the last row's single card is reached
--> from any column above it.
function Pick.toward(targets: { Target }, x: number, y: number, dx: number, dy: number, rtl: boolean): number?
	local best: number? = nil
	local bestScore = math.huge
	for index, target in targets do
		const along = (target.x - x) * dx + (target.y - y) * dy
		if usable(target) and along > Pick.ROW then
			const aside = math.abs((target.x - x) * dy - (target.y - y) * dx)
			const score = along + aside * Pick.ASIDE
			if best == nil or score < bestScore or (score == bestScore and before(target, targets[best], rtl)) then
				best = index
				bestScore = score
			end
		end
	end
	return best
end

--> The index of the usable target closest to (`x`, `y`), or nil when none can be chosen.
function Pick.nearest(targets: { Target }, x: number, y: number, rtl: boolean): number?
	local best: number? = nil
	local bestGap = math.huge
	for index, target in targets do
		if usable(target) then
			const gap = (target.x - x) ^ 2 + (target.y - y) ^ 2
			if best == nil or gap < bestGap or (gap == bestGap and before(target, targets[best], rtl)) then
				best = index
				bestGap = gap
			end
		end
	end
	return best
end

return Pick
