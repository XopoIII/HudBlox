--!strict
--- A dialog's footer: a row for its buttons, empty and taking no room until one is added, and the
--- button a gamepad's A accepts with. A page has no footer at all, and a button added to one takes
--- no room from the page's body.
const Native = require("./Native")
const PadGlyph = require("./PadGlyph")

const DialogFooter = {}

--- The picture of A on an accepting button, in pixels.
DialogFooter.CAP = 20

export type Footer = {
	frame: Frame,
	--- Names the button A accepts with, or takes the name off again for nil.
	primary: (button: GuiButton?) -> (),
	--- The button A accepts with now, which a gamepad's focus starts on.
	accept: () -> GuiButton?,
}

--> Builds the footer under `body` in `panel`, `body` giving up the footer's height once a button
--> stands in it, and answers the footer and the accepting button's handle. A `page` has no footer:
--> its body is the whole panel, and a button added to the row takes nothing from it.
function DialogFooter.mount(panel: Frame, body: Frame, top: number, page: boolean, rtl: boolean): Footer
	const footer = Instance.new("Frame")
	footer.Name = "Footer"
	footer.BackgroundTransparency = 1
	footer.AnchorPoint = Vector2.new(0, 1)
	footer.Position = UDim2.fromScale(0, 1)
	footer.Size = UDim2.fromScale(1, 0)
	footer.Parent = panel
	const row = Instance.new("UIListLayout")
	row.FillDirection = Enum.FillDirection.Horizontal
	-- Buttons are added in reading order; in a right-to-left locale that runs from the right.
	row.HorizontalAlignment = if rtl then Enum.HorizontalAlignment.Right else Enum.HorizontalAlignment.Left
	row.HorizontalFlex = Enum.UIFlexAlignment.Fill
	row.Padding = UDim.new(0, 12)
	row.Parent = footer

	footer.ChildAdded:Connect(function(child: Instance)
		if child:IsA("GuiButton") and not page then
			footer.Size = UDim2.new(1, 0, 0, Native.BUTTON_H)
			body.Size = UDim2.new(1, 0, 1, -top - Native.BUTTON_H - Native.GAP)
		end
	end)

	local accepted: GuiButton? = nil
	local cap: Frame? = nil
	return {
		frame = footer,
		primary = function(button: GuiButton?)
			if cap then
				cap:Destroy()
				cap = nil
			end
			accepted = button
			cap = if button then PadGlyph.corner(button, Enum.KeyCode.ButtonA, DialogFooter.CAP) else nil
		end,
		accept = function(): GuiButton?
			return accepted
		end,
	}
end

return DialogFooter
