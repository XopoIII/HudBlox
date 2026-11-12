--!strict
--- Where things go on the top line: pure arithmetic over a screen and Roblox's top-bar inset.
---
--- Nothing here touches an Instance, so every rule is a spec (`tests/unit/Layout.luau`). `TopBar` and
--- `SafeArea` read the numbers off the engine and hand them in.
---
--- THE COORDINATE SPACE IS THE WHOLE TRICK. `AbsolutePosition`'s origin is the BOTTOM of the core-UI
--- inset. A gui that respects the inset reports y = 0, a gui that ignores it reports y = -strip, and
--- Roblox's own buttons live exactly in `y < 0` of that space. Every function below is arithmetic on
--- that one fact.
const Measure = require("./Measure")

const Layout = {}

--- A ScreenGui as the engine reports it: `AbsoluteSize.X`, `AbsolutePosition.X`, `AbsolutePosition.Y`.
export type Screen = { width: number, left: number, top: number }

--- Where the top line's pieces go, in the gui's own coordinates.
export type Top = {
	--- Whether the row shares the line of Roblox's own buttons.
	onChromeLine: boolean,
	--- The left edge of each left button, first to last.
	lefts: { number },
	--- The right row: it ends `rowRightInset` from the right edge and is this wide. 0 when the
	--- screen has no room left at all.
	rowLeft: number,
	rowWidth: number,
	--- From the gui's right edge to the row's right edge: the edge margin at Roblox's scale, and
	--- the room a game keeps for what the platform draws there itself (`rightReserve`).
	rowRightInset: number,
}

--- What `Layout.top` is told besides the screen and the buttons.
export type TopOptions = {
	--- Where the row's top is, in the gui's coordinates. `Measure.TOP` at `scale` when left out.
	rowTop: number?,
	--- Roblox's own scale of its top bar (`Layout.scale`). 1 when left out.
	scale: number?,
	--- Room the platform's own furniture takes at the right of the line, in the same units as
	--- `Measure` and so drawn at `scale`: Roblox draws the player's health bar inside its top bar
	--- and `GuiService.TopbarInset` does not describe it. 0 when left out, which is a game that
	--- shows no health bar.
	rightReserve: number?,
}

--- One segment of a capsule, for the width model: the pixel width of its text, and whether a lead
--- icon stands in front of it.
export type Segment = { ink: number, lead: boolean }

--> The height of Roblox's strip at the top of a gui whose top is at `guiTop`. 0 for a gui that
--> already respects the inset.
function Layout.topStrip(guiTop: number): number
	return math.max(0, -guiTop)
end

--> The height left below that strip.
function Layout.usableHeight(guiHeight: number, guiTop: number): number
	return guiHeight - Layout.topStrip(guiTop)
end

--> The offset that goes with a scale of `fraction` to mean "this fraction of the USABLE height":
--> `UDim.new(fraction, Layout.yOffset(guiTop, fraction))`. A fraction of 0.5 is the true centre.
function Layout.yOffset(guiTop: number, fraction: number): number
	return math.floor(Layout.topStrip(guiTop) * (1 - fraction))
end

--> Whether a row whose top is `rowTop` inside a gui whose top is `guiTop` shares the line of
--> Roblox's own buttons. A gui that respects the inset begins below them, and its top row competes
--> with nothing.
function Layout.onChromeLine(guiTop: number, rowTop: number): boolean
	return guiTop + rowTop < 0
end

--> Where the free span of the top line begins, in the gui's coordinates: `TopbarInset.Min.X` is
--> where Roblox's own buttons end.
function Layout.freeX(insetMinX: number, guiLeft: number): number
	return math.max(0, insetMinX - guiLeft)
end

--> What a row at `rowTop` must leave on its left for Roblox's buttons. 0 when the row is below
--> them: reserving the span there costs a third of a phone's width for nothing.
function Layout.chromeFreeX(screen: Screen, insetMinX: number, rowTop: number): number
	if not Layout.onChromeLine(screen.top, rowTop) then
		return 0
	end
	return Layout.freeX(insetMinX, screen.left)
end

--> Roblox's own scale of its top bar on this device: the strip's height, `GuiService.TopbarInset`'s,
--> over the computer's (`Measure.STRIP`). A television draws the bar half again as large and says so
--> by a strip of 87. 1 for a strip that is not reported.
function Layout.scale(strip: number): number
	if strip <= 0 then
		return 1
	end
	return strip / Measure.STRIP
end

--> Where the first left button starts: `Measure.GAP` past Roblox's own buttons when there are any
--> on this line, as Roblox spaces its own, and at the edge margin when there are none; both at
--> Roblox's `scale`, 1 when left out.
function Layout.leftStart(free: number, scale: number?): number
	const s = scale or 1
	return if free > 0 then free + Measure.GAP * s else Measure.EDGE * s
end

--> The whole top line for `leftCount` left buttons, at Roblox's `scale` (1 when left out): every
--> measured distance and size grows with it, as Roblox's own do. The row's top is
--> `Measure.TOP` at that scale unless the host moved it. The right row begins a gap past the last
--> left button, so the two never meet; when the screen is too narrow for that, the row's width is 0
--> rather than negative. `rightReserve` is room the platform's own furniture keeps at the right
--> (`TopOptions`).
function Layout.top(screen: Screen, insetMinX: number, leftCount: number, options: TopOptions?): Top
	const s = options and options.scale or 1
	const given = options and options.rowTop
	const top = if given ~= nil then given else Measure.TOP * s
	const reserve = options and options.rightReserve or 0
	const free = Layout.chromeFreeX(screen, insetMinX, top)
	const lefts = table.create(leftCount) :: { number }
	local x = Layout.leftStart(free, s)
	for _ = 1, leftCount do
		table.insert(lefts, x)
		x += (Measure.HEIGHT + Measure.GAP) * s
	end
	const bound = if leftCount > 0 then x else free
	const inset = Measure.EDGE * s + reserve * s
	const rowWidth = math.max(0, screen.width - inset - bound)
	return {
		onChromeLine = Layout.onChromeLine(screen.top, top),
		lefts = lefts,
		rowLeft = screen.width - inset - rowWidth,
		rowRightInset = inset,
		rowWidth = rowWidth,
	}
end

--> How wide a capsule is for its segments: the padding, each lead and its gap, each text, and the
--> rhythm between segments. Derived from the properties `Pill` sets, for adding up a worst case.
function Layout.pillWidth(segments: { Segment }): number
	local width = Measure.PAD_LEFT + Measure.PAD_RIGHT
	for index, segment in segments do
		if index > 1 then
			width += Measure.SEGMENT_GAP
		end
		if segment.lead then
			width += Measure.LEAD + Measure.PART_GAP
		end
		width += segment.ink
	end
	return width
end

--> How wide the right row's contents are: each capsule or button (a button is `Measure.HEIGHT`),
--> `Measure.GAP` apart.
function Layout.rowNeeds(widths: { number }): number
	local total = 0
	for index, width in widths do
		if index > 1 then
			total += Measure.GAP
		end
		total += width
	end
	return total
end

--> Whether contents `needs` wide stay on one line of the row. A row that does not fit WRAPS, and
--> the wrapped line is drawn where nobody looks; this is the question to ask of a worst case.
--> `needs` is measured as written, and drawn at Roblox's `scale` (1 when left out).
function Layout.fits(top: Top, needs: number, scale: number?): boolean
	return needs * (scale or 1) <= top.rowWidth
end

--> The fixed width of a label pinned to its widest text: rounded up, and 2 more so a hinting
--> difference cannot clip the last glyph.
function Layout.pinned(widest: number): number
	return math.ceil(widest) + 2
end

--> An edge-anchored element moved to the opposite edge: the anchor's X, the position's X scale and
--> its X offset, mirrored. A centred element maps to itself.
function Layout.mirrorX(anchorX: number, scale: number, offset: number): (number, number, number)
	return 1 - anchorX, 1 - scale, -offset
end

return Layout
