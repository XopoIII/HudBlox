--!strict
--- A dialog's title row: the close button on the left as in the Escape menu, the title beside it,
--- and the divider under them. The row is where a framed dialog keeps it, or on the platform's own
--- line when the dialog is a sheet and its panel begins at the device's top edge.
const Native = require("./Native")
const PadGlyph = require("./PadGlyph")
const Rtl = require("./Rtl")
const UiRules = require("./UiRules")

const DialogHeader = {}

--- The height of a framed dialog's header, and the size of a pad's picture on its X.
const Dialog = { HEAD_H = 48, CAP = 20 }

--- Where a sheet's header goes, in the panel's own units: the platform's line, and the room kept at
--- each end for what the game does not own.
export type Line = {
	--- The header's top edge, from the panel's top.
	top: number,
	--- The header's height.
	height: number,
	--- The room kept at its left for the platform's own capsules: the header's ink begins there.
	left: number,
	--- The room kept at its right for the game's own corner.
	right: number,
}

export type Header = {
	title: TextLabel,
	close: TextButton,
	--- Puts the header and its divider on `line`, or back where a framed dialog keeps them for nil.
	--- `room` is the panel's own side padding, which the divider spans across.
	fit: (line: Line?) -> (),
}

--> Mounts the header in `panel`, whose side padding is `room`; `minimumHit` is the X's least side.
function DialogHeader.mount(panel: Frame, title: string, minimumHit: number?, room: number?): Header
	const air = room or 0
	const header = Instance.new("Frame")
	header.Name = "Header"
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1, 0, 0, Dialog.HEAD_H)
	header.Parent = panel

	const head = Native.text(header, title, Native.TITLE_SIZE, { weight = Enum.FontWeight.Bold })
	head.Name = "Title"
	head.TextWrapped = false
	head.TextTruncate = Enum.TextTruncate.AtEnd
	const hit = UiRules.hit(minimumHit)
	head.Size = UDim2.new(1, -hit - 8, 0, Dialog.HEAD_H)

	const close = Native.iconButton(header, "x")
	close.Name = "Close"
	close.Size = UDim2.fromOffset(hit, hit)
	close.AnchorPoint = Vector2.new(1, 0)
	close.Position = UDim2.new(1, 0, 0, 2)
	-- The last place a gamepad's focus starts (`Pick`).
	close.SelectionOrder = 1000
	-- Built with the close button at the right and mirrored once, whatever the locale: the X stands
	-- on the left, as the Escape menu's does, and the title takes the rest of the row.
	Rtl.mirror(header)
	PadGlyph.corner(close, Enum.KeyCode.ButtonB, Dialog.CAP)

	const divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.BackgroundColor3 = Native.DIVIDER
	divider.BackgroundTransparency = Native.DIVIDER_T
	divider.BorderSizePixel = 0
	divider.Position = UDim2.fromOffset(0, Dialog.HEAD_H)
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.Parent = panel

	const function fit(line: Line?)
		const top = if line then line.top else 0
		const height = if line then line.height else Dialog.HEAD_H
		const left = if line then line.left else 0
		const right = if line then line.right else 0
		header.Position = UDim2.fromOffset(left, top)
		header.Size = UDim2.new(1, -(left + right), 0, height)
		head.Size = UDim2.new(1, -hit - 8, 0, height)
		-- A sheet's X shares the platform's line exactly: a framed dialog keeps it 2 down in its own
		-- taller header.
		close.Position = UDim2.new(1, 0, 0, if line then 0 else 2)
		divider.Position = UDim2.fromOffset(-air, top + height)
		divider.Size = UDim2.new(1, air * 2, 0, 1)
	end

	return { title = head, close = close, fit = fit }
end

return DialogHeader
