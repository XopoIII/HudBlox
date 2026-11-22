--!strict
--- A tab strip's arithmetic: how wide each tab is in a horizontal strip, how tall each tab is in a
--- vertical rail, and where a rail and its page sit inside a dialog's body. Plain numbers, so the
--- rules are specified without Roblox; `Tabs` builds the strip or rail by them.
const TabFit = {}

--- A tab's height and widest width, the gap between two, and the size of its word, in pixels:
--- the menu's own button, a little lower.
TabFit.HEIGHT = 40
TabFit.WIDTH = 150
TabFit.RAIL_WIDTH = 88
TabFit.GAP = 8
TabFit.TEXT = 20
--- A tab's picture, and the word under one: pixels. A tab with a picture is taller by `ICON`.
TabFit.ICON = 20
TabFit.ICON_TEXT = 11
--- The narrowest a horizontal tab is squeezed to, and the shortest a vertical tab is squeezed to.
TabFit.NARROWEST = 44
TabFit.SHORTEST = 40

export type RailSplit = {
	railX: number,
	contentX: number,
	contentWidth: number,
}

--> How wide each of `count` tabs is in a strip `span` wide: `most` when they all fit with `gap`
--> between two, else an even share of the strip, a whole number of pixels, and never under
--> `NARROWEST`. `most` for no tabs.
function TabFit.width(span: number, count: number, gap: number, most: number): number
	if count < 1 then
		return most
	end
	const share = (span - gap * (count - 1)) // count
	return math.max(math.min(most, share), math.min(most, TabFit.NARROWEST))
end

--> How tall each of `count` tabs is in a vertical rail `span` tall: `most` when they all fit with
--> `gap` between two, else an even share of the rail, a whole number of pixels, and never under
--> `SHORTEST`. `most` for no tabs.
function TabFit.height(span: number, count: number, gap: number, most: number): number
	if count < 1 then
		return most
	end
	const each = (span - (count - 1) * gap) // count
	return math.max(math.min(each, most), math.min(TabFit.SHORTEST, most))
end

--> Where a vertical rail `railWidth` wide and the page beside it sit inside a body `bodyWidth`
--> wide, with `gap` between them: on the left for left-to-right readers and on the right when
--> `rtl` is true. The page's width is never negative.
function TabFit.rail(bodyWidth: number, railWidth: number, gap: number, rtl: boolean): RailSplit
	const contentWidth = math.max(0, bodyWidth - railWidth - gap)
	if rtl then
		return {
			railX = math.max(0, bodyWidth - railWidth),
			contentX = 0,
			contentWidth = contentWidth,
		}
	end
	return {
		railX = 0,
		contentX = railWidth + gap,
		contentWidth = contentWidth,
	}
end

--> The place a gamepad's bumper takes the strip to: `by` places on from place `on` of `count`, in
--> reading order, and no further than either end. A strip read from the right is stepped the other
--> way by its caller, so the left bumper always goes left.
function TabFit.step(count: number, on: number, by: number): number
	if count < 1 then
		return on
	end
	return math.clamp(on + by, 1, count)
end

return TabFit
