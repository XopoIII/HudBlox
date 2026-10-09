--!strict
--- The dark top-bar capsule: a plate with one or more `[icon][number]` segments.
---
--- The shape is Roblox's own (`Measure`): 44 tall, fully round, a 24-pixel lead, a white number at
--- 22. It is one factory because two near-copies are three constants away from sitting on the same
--- line and not matching, and nobody files that bug.
const Layout = require("./Layout")
const Measure = require("./Measure")
const Theme = require("./Theme")

const Pill = {}

-- The text engine's answers, by what decides them: a font, a size and the candidate strings
-- (order-insensitive). An answer cannot change while its key does not.
const measured: { [string]: number } = {}

--- One segment as the caller asks for it.
export type Part = {
	--- The name `theme.icon` draws. Nil or "" means no lead at all: a value that carries its own
	--- unit ("1.17 km") needs no second label, and the capsule comes up narrower.
	lead: string?,
	--- True when `lead` is a text glyph to show as it is, for where no image exists.
	emoji: boolean?,
	--- The widest texts the value can ever hold. Given, the value's width is pinned to the widest
	--- of them (`Pill.pinWidth`), so a number that ticks does not shove the row sideways.
	pin: { string }?,
}

--- One segment as built: its number, and its lead when it has one (so a caller can hide it).
export type Segment = { value: TextLabel, lead: GuiObject? }

export type Capsule = { plate: GuiObject, segments: { Segment } }

--> Measures the widest of `candidates` in `font` at `size` and answers through `done`, because
--> the text engine yields. A surface that is rebuilt measures once, keeps the number and applies
--> it itself; the answer cannot change while the font and the size do not.
---
--- Answers are kept by font, size and candidates: a surface rebuilt whole (a respawn, a reopened
--- dialog) asks the text engine nothing it has already answered.
function Pill.measure(font: Font, size: number, candidates: { string }, done: (widest: number) -> ())
	const TextService = game:GetService("TextService")
	const sorted = table.clone(candidates)
	table.sort(sorted)
	const key = `{font.Family}\0{font.Weight}\0{font.Style}\0{size}\0{table.concat(sorted, "\0")}`
	const known = measured[key]
	if known ~= nil then
		task.spawn(done, known)
		return
	end
	task.spawn(function()
		local widest = 0
		const params = Instance.new("GetTextBoundsParams")
		params.Font = font
		params.Size = size
		-- Far wider than any candidate: the unwrapped, single-line width.
		params.Width = 4096
		for _, text in candidates do
			params.Text = text
			const ok, bounds = pcall(function(): Vector2
				return TextService:GetTextBoundsAsync(params)
			end)
			if ok then
				widest = math.max(widest, bounds.X)
			end
		end
		-- A zero is a failed pass (the engine was not ready), not an answer: never kept.
		if widest > 0 then
			measured[key] = widest
		end
		done(widest)
	end)
end

--> Pins `label` to the width of the widest of `candidates`, so its capsule keeps one size while
--> the text changes.
---
--- Padding the string does not do this: Builder Sans is not monospaced, so "01:24" and "02:12" are
--- the same length and different widths, and a right-aligned row jitters once a second. Nor is the
--- width read off the label: on the frame a label is born inside an auto-sizing plate its bounds
--- are those of as much text as fits a box still zero wide. So the text engine is asked, which
--- depends on the font, the size and the string only.
---
--- `candidates` are the widest strings the label can hold. Which digit is widest is a property of
--- the typeface: for a clock give every double-digit pair, not a guess.
function Pill.pinWidth(label: TextLabel, candidates: { string })
	label.TextWrapped = false
	label.TextTruncate = Enum.TextTruncate.None
	Pill.measure(label.FontFace, label.TextSize, candidates, function(widest)
		-- The capsule may be gone before the text engine answers (a respawn, a closed dialog): a
		-- destroyed label reports no parent, and writing to one errors.
		if widest > 0 and label.Parent ~= nil then
			label.AutomaticSize = Enum.AutomaticSize.None
			label.Size = UDim2.fromOffset(Layout.pinned(widest), Measure.HEIGHT)
			-- Centred in its fixed box: left-aligned, a narrow value would sit against the lead and
			-- a wide one against the capsule's edge, which is the jitter again in a smaller form.
			label.TextXAlignment = Enum.TextXAlignment.Center
		end
	end)
end

--> Adds segment number `order` (1 is the first) to `plate`.
function Pill.segment(plate: GuiObject, theme: Theme.Theme, order: number, part: Part): Segment
	const base = (order - 1) * 3

	-- Segments after the first stand `SEGMENT_GAP` apart. A spacer, not padding: the list layout
	-- already puts `PART_GAP` on either side of it, hence the subtraction.
	if order > 1 then
		const spacer = Instance.new("Frame")
		spacer.Name = "SegmentGap"
		spacer.BackgroundTransparency = 1
		spacer.BorderSizePixel = 0
		spacer.Size = UDim2.fromOffset(Measure.SEGMENT_GAP - Measure.PART_GAP * 2, 1)
		spacer.LayoutOrder = base
		spacer.Parent = plate
	end

	local lead: GuiObject? = nil
	const name = part.lead
	if name and name ~= "" then
		if part.emoji then
			const glyph = Theme.label(theme, "Lead", plate, name, Measure.LEAD)
			-- The square an image lead takes, so both kinds of capsule measure the same.
			glyph.Size = UDim2.fromOffset(Measure.LEAD, Measure.LEAD)
			lead = glyph
		else
			const icon = theme.icon(name, plate)
			icon.Size = UDim2.fromOffset(Measure.LEAD, Measure.LEAD)
			lead = icon
		end
	end
	if lead then
		lead.LayoutOrder = base + 1
	end

	const value = Theme.label(theme, "Value", plate, "0", Measure.TEXT)
	value.AutomaticSize = Enum.AutomaticSize.X
	value.Size = UDim2.fromOffset(0, Measure.HEIGHT)
	value.LayoutOrder = base + 2
	const pin = part.pin
	if pin then
		Pill.pinWidth(value, pin)
	end
	return { value = value, lead = lead }
end

--> Builds a capsule into `parent` with one segment per part; set `.Text` on each segment's value.
---
--- `tappable` makes the PLATE itself the button. A transparent button laid over it instead is a
--- scale-sized child of an auto-sizing plate, and its width feeds the plate's own: measured live,
--- that ran a capsule out to 640 pixels on an 801-pixel screen.
function Pill.build(parent: Instance, theme: Theme.Theme, parts: { Part }, tappable: boolean?): Capsule
	local plate: GuiObject
	if tappable then
		const button = Instance.new("TextButton")
		button.Text = ""
		button.AutoButtonColor = false
		plate = button
	else
		plate = Instance.new("Frame")
	end
	plate.Name = "Pill"
	plate.BackgroundColor3 = Theme.plate(theme)
	plate.BackgroundTransparency = Theme.plateTransparency(theme)
	plate.BorderSizePixel = 0
	plate.Size = UDim2.fromOffset(0, Measure.HEIGHT)
	plate.AutomaticSize = Enum.AutomaticSize.X

	const corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, Measure.HEIGHT // 2)
	corner.Parent = plate

	const pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, Measure.PAD_LEFT)
	pad.PaddingRight = UDim.new(0, Measure.PAD_RIGHT)
	pad.Parent = plate

	const list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.Padding = UDim.new(0, Measure.PART_GAP)
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = plate

	const segments: { Segment } = {}
	for order, part in parts do
		table.insert(segments, Pill.segment(plate, theme, order, part))
	end
	plate.Parent = parent
	return { plate = plate, segments = segments }
end

return Pill
