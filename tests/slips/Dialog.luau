--!strict
--- The mutants of src/DialogGeometry.luau: each a small slip in the arithmetic, and the rule it breaks.
--- Every `from` must occur exactly once in its file.

const MUTANTS: { { file: string, from: string, to: string, breaks: string } } = {
	{
		file = "src/DialogGeometry.luau",
		from = "const clear = math.max(strip, DialogGeometry.TOP_ROW_BOTTOM) + DialogGeometry.ROW_GAP",
		to = "const clear = strip + DialogGeometry.ROW_GAP",
		breaks = "a panel starts below the kit's own row where there is no strip",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "const clear = math.max(strip, DialogGeometry.TOP_ROW_BOTTOM) + DialogGeometry.ROW_GAP",
		to = "const clear = DialogGeometry.TOP_ROW_BOTTOM + DialogGeometry.ROW_GAP",
		breaks = "a panel starts below a strip taller than the row",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "const clear = math.max(strip, DialogGeometry.TOP_ROW_BOTTOM) + DialogGeometry.ROW_GAP",
		to = "const clear = math.max(strip, DialogGeometry.TOP_ROW_BOTTOM)",
		breaks = "a panel keeps a gap under the row",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "clearsBottom = room >= bottom.room",
		to = "clearsBottom = room > bottom.room",
		breaks = "exactly the room keeps the bar shown",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "const room = height - strip - bottom.band - DialogGeometry.MARGIN_TOP_MIN * 2",
		to = "const room = height - bottom.band - DialogGeometry.MARGIN_TOP_MIN * 2",
		breaks = "the room above the bar is counted under the strip",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "const room = height - strip - bottom.band - DialogGeometry.MARGIN_TOP_MIN * 2",
		to = "const room = height - strip - bottom.band",
		breaks = "the room above the bar leaves the two margins out",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "band = if clearsBottom then bottom.band else 0",
		to = "band = bottom.band",
		breaks = "a panel that covers the bar takes the bar's height too",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "band = if clearsBottom then bottom.band else 0",
		to = "band = 0",
		breaks = "a panel that clears the bar ends above it",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "const usableH = height - strip - band",
		to = "const usableH = height - band",
		breaks = "the usable height is under the strip",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "(width - maxW) * 0.5)",
		to = "0)",
		breaks = "a dialog is no wider than it asked to be",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "width * DialogGeometry.MARGIN_SIDE_F,",
		to = "0,",
		breaks = "a narrow screen keeps a tenth of itself on each side",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "const w = math.max(width - side * 2, DialogGeometry.CARD_W_MIN)",
		to = "const w = width - side * 2",
		breaks = "a panel is never narrower than its rows need",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "if usableH - margin * 2 < maxH then",
		to = "if usableH < maxH then",
		breaks = "a screen is roomy only when the dialog fits with its margins",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "if below >= DialogGeometry.STRIP_CLEAR_MIN then",
		to = "if true then",
		breaks = "a landscape phone takes the tight margins",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "if below >= DialogGeometry.STRIP_CLEAR_MIN then",
		to = "if false then",
		breaks = "a screen with room under the strip is centred there",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "top = strip + (viewH - strip - h) * 0.5",
		to = "top = (viewH - h) * 0.5",
		breaks = "a squeezed panel is centred under the strip",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "h = math.max(viewH - tight * 2, DialogGeometry.CARD_H_MIN)",
		to = "h = math.max(viewH - tight, DialogGeometry.CARD_H_MIN)",
		breaks = "a full-height panel ends a tight margin off the bottom",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "h = math.min(math.max(usableH - margin * 2, DialogGeometry.CARD_H_MIN), maxH)",
		to = "h = math.max(usableH - margin * 2, DialogGeometry.CARD_H_MIN)",
		breaks = "a framed panel is no taller than it asked to be",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "top = (viewH - h) * 0.5",
		to = "top = strip + (viewH - strip - h) * 0.5",
		breaks = "a framed panel is centred on the device, not under the strip",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "\tif top < clear then\n",
		to = "\tif false then\n",
		breaks = "a panel never starts over the top row",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "h = math.max(h - (clear - top), DialogGeometry.CARD_H_MIN)",
		to = "h = math.max(h, DialogGeometry.CARD_H_MIN)",
		breaks = "a panel moved under the row keeps its bottom edge",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "h = math.max(h - (clear - top), DialogGeometry.CARD_H_MIN)",
		to = "h = h - (clear - top)",
		breaks = "a panel moved under the row is never shorter than its rows need",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "DialogGeometry.TOP_ROW_BOTTOM = Measure.TOP + Measure.HEIGHT",
		to = "DialogGeometry.TOP_ROW_BOTTOM = Measure.HEIGHT",
		breaks = "the row ends where the top bar's own buttons end",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "DialogGeometry.TIGHT_MARGIN = 12",
		to = "DialogGeometry.TIGHT_MARGIN = 13",
		breaks = "the tight margin is twelve",
	},
	{
		file = "src/DialogGeometry.luau",
		from = "DialogGeometry.STRIP_CLEAR_MIN = 440",
		to = "DialogGeometry.STRIP_CLEAR_MIN = 400",
		breaks = "the height that spares the strip is as measured",
	},
}

return MUTANTS
