--!strict
--- The mutants tests/Mutate runs: each a small slip in the arithmetic, and the rule it breaks.
--- Every `from` must occur exactly once in its file.

export type Mutant = { file: string, from: string, to: string, breaks: string }

const MUTANTS: { Mutant } = {
	{
		file = "src/Layout.luau",
		from = "then free + Measure.GAP else",
		to = "then free else",
		breaks = "the first left button keeps Roblox's own gap past Roblox's buttons",
	},
	{
		file = "src/Layout.luau",
		from = "else Measure.EDGE\n",
		to = "else 0\n",
		breaks = "below the chrome line the first left button starts at the edge margin",
	},
	{
		file = "src/Layout.luau",
		from = "return guiTop + rowTop < 0",
		to = "return guiTop + rowTop <= 0",
		breaks = "a row whose top is exactly at the strip's end is below the chrome line",
	},
	{
		file = "src/Layout.luau",
		from = "\tif not Layout.onChromeLine(screen.top, rowTop) then\n\t\treturn 0\n\tend\n",
		to = "",
		breaks = "a row below the chrome line reserves nothing for Roblox's buttons",
	},
	{
		file = "src/Layout.luau",
		from = "return math.max(0, insetMinX - guiLeft)",
		to = "return insetMinX - guiLeft",
		breaks = "the free span is never negative",
	},
	{
		file = "src/Layout.luau",
		from = "return math.max(0, insetMinX - guiLeft)",
		to = "return math.max(0, insetMinX)",
		breaks = "the free span is in the gui's own coordinates",
	},
	{
		file = "src/Layout.luau",
		from = "x += Measure.HEIGHT + Measure.GAP",
		to = "x += Measure.HEIGHT",
		breaks = "left buttons stand a gap apart, and the row a gap past the last",
	},
	{
		file = "src/Layout.luau",
		from = "const bound = if leftCount > 0 then x else free",
		to = "const bound = free",
		breaks = "the right row never overlaps the left buttons",
	},
	{
		file = "src/Layout.luau",
		from = "const rowWidth = math.max(0, screen.width - Measure.EDGE - bound)",
		to = "const rowWidth = screen.width - Measure.EDGE - bound",
		breaks = "a screen with no room gives the row no width, not a negative one",
	},
	{
		file = "src/Layout.luau",
		from = "const rowWidth = math.max(0, screen.width - Measure.EDGE - bound)",
		to = "const rowWidth = math.max(0, screen.width - bound)",
		breaks = "the row's width leaves the edge margin on the right",
	},
	{
		file = "src/Layout.luau",
		from = "\t\t\twidth += Measure.SEGMENT_GAP\n",
		to = "\t\t\twidth += Measure.PART_GAP\n",
		breaks = "segments of a capsule stand the segment gap apart",
	},
	{
		file = "src/Layout.luau",
		from = "\t\tif segment.lead then\n",
		to = "\t\tif true then\n",
		breaks = "a segment without a lead is narrower by the lead and its gap",
	},
	{
		file = "src/Layout.luau",
		from = "\t\t\ttotal += Measure.GAP\n",
		to = "",
		breaks = "things in the row stand a gap apart",
	},
	{
		file = "src/Layout.luau",
		from = "return needs <= top.rowWidth",
		to = "return needs < top.rowWidth",
		breaks = "contents exactly as wide as the row fit",
	},
	{
		file = "src/Layout.luau",
		from = "return math.ceil(widest) + 2",
		to = "return math.floor(widest) + 2",
		breaks = "a pinned label is rounded up",
	},
	{
		file = "src/Layout.luau",
		from = "return 1 - anchorX, 1 - scale, -offset",
		to = "return 1 - anchorX, 1 - scale, offset",
		breaks = "a mirrored element keeps its distance from the edge",
	},
	{
		file = "src/Layout.luau",
		from = "return math.floor(Layout.topStrip(guiTop) * (1 - fraction))",
		to = "return math.floor(Layout.topStrip(guiTop) * fraction)",
		breaks = "a fraction of the height is a fraction of what is below the strip",
	},
	{
		file = "src/Layout.luau",
		from = "return guiHeight - Layout.topStrip(guiTop)",
		to = "return guiHeight",
		breaks = "the usable height leaves the strip out",
	},
	{
		file = "src/Clearance.luau",
		from = "\t\tif control.visible then\n\t\t\ttop = math.min(top, control.top)\n\t\tend\n",
		to = "\t\ttop = math.min(top, control.top)\n",
		breaks = "a hidden control lifts nothing",
	},
	{
		file = "src/Clearance.luau",
		from = "top = math.min(top, control.top)",
		to = "top = control.top",
		breaks = "the HIGHEST visible control sets the clearance",
	},
	{
		file = "src/Clearance.luau",
		from = "return math.max(0, bottom - top)",
		to = "return bottom - top - 1",
		breaks = "the clearance reaches the control's top",
	},
	{
		file = "src/Clearance.luau",
		from = "return margin + height",
		to = "return height",
		breaks = "a read-out stands a margin above the controls",
	},
	{
		file = "src/Clearance.luau",
		from = "return base + (index - 1) * (size + gap)",
		to = "return base + (index - 1) * size",
		breaks = "a corner stack keeps its gap",
	},
	{
		file = "src/Band.luau",
		from = "if left < rect.right and right > rect.left then",
		to = "if left <= rect.right and right >= rect.left then",
		breaks = "a card beside a rectangle keeps its corner",
	},
	{
		file = "src/Band.luau",
		from = "need = math.max(need, rect.top + Band.GAP)",
		to = "need = math.max(need, rect.top)",
		breaks = "a lifted card keeps air above what it clears",
	},
	{
		file = "src/Band.luau",
		from = "need = math.max(need, rect.top + Band.GAP)",
		to = "need = rect.top + Band.GAP",
		breaks = "the highest of several rectangles sets the lift",
	},
	{
		file = "src/Band.luau",
		from = "return math.max(0, need - bottom)",
		to = "return need - bottom",
		breaks = "a card already above lifts by nothing",
	},
	{
		file = "src/Band.luau",
		from = "\tif old and rect and old.left == rect.left and old.right == rect.right and old.top == rect.top then\n\t\treturn\n\tend\n",
		to = "",
		breaks = "listeners do not hear the same rectangle twice",
	},
	{
		file = "src/Band.luau",
		from = "rects[key] = { left = rect.left, right = rect.right, top = rect.top }",
		to = "rects[key] = rect",
		breaks = "a reporter that moves its own table and reports it again is heard",
	},
	{
		file = "src/Band.luau",
		from = "\tif old == rect then\n\t\treturn\n\tend\n",
		to = "",
		breaks = "taking away what was never there is not a change",
	},
	{
		file = "src/Band.luau",
		from = "\t\tlisteners[listener] = nil\n",
		to = "",
		breaks = "a stopped listener hears nothing more",
	},
}

-- The dialog's geometry, the gamepad's focus and the backpack keep theirs in files of their own.
const MORE: { { Mutant } } = {
	require("./slips/Dialog"),
	require("./slips/Focus"),
	require("./slips/BackpackOrder"),
	require("./slips/BackpackOrderMoves"),
	require("./slips/BackpackTaps"),
	require("./slips/BackpackRest"),
	require("./slips/Badge"),
	require("./slips/Tabs"),
	require("./slips/Flight"),
}
for _, list in MORE do
	table.move(list, 1, #list, #MUTANTS + 1, MUTANTS)
end

return MUTANTS
