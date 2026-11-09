--!strict
const Native = require("./Native")
const PadGlyph = require("./PadGlyph")
const Rtl = require("./Rtl")
const UiRules = require("./UiRules")
const DialogHeader = {}
function DialogHeader.mount(panel: Frame, title: string, minimumHit: number?): (TextLabel, TextButton)
	const Dialog = { HEAD_H = 48, CAP = 20 }
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

	return head, close
end
return DialogHeader
