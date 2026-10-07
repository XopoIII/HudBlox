--!strict
--- A tab strip's arithmetic: how wide each tab is in a strip of a given width. Plain numbers, so
--- the rule is specified without Roblox; `Tabs` builds the strip by it.
const TabFit = {}

--- A tab's height and widest width, the gap between two, and the size of its word, in pixels:
--- the menu's own button, a little lower.
TabFit.HEIGHT = 40
TabFit.WIDTH = 150
TabFit.GAP = 8
TabFit.TEXT = 20
--- The narrowest a tab is squeezed to. A strip narrower than that for each of its tabs overflows.
TabFit.NARROWEST = 44

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

return TabFit
