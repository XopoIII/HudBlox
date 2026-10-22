--!strict
--- The picture of a gamepad's button, as the player's own pad draws it (the engine's
--- `GetImageForKeyCode`: an Xbox pad's B, a PlayStation pad's circle), so no hint ever names a
--- button in words.
---
--- A cap is a small picture pinned to a control, there only while the player is on a gamepad
--- (`PadInput`).
const PadInput = require("./PadInput")

const PadGlyph = {}

--> A `size`-pixel picture of `code` inside `parent`, named "PadCap" and placed by the caller.
function PadGlyph.cap(parent: GuiObject, code: Enum.KeyCode, size: number): ImageLabel
	const cap = Instance.new("ImageLabel")
	cap.Name = "PadCap"
	cap.BackgroundTransparency = 1
	cap.Size = UDim2.fromOffset(size, size)
	cap.ZIndex = parent.ZIndex + 10
	const function show()
		const on = PadInput.active()
		cap.Visible = on
		if on then
			cap.Image = game:GetService("UserInputService"):GetImageForKeyCode(code)
		end
	end
	show()
	PadInput.onChange(show)
	cap.Parent = parent
	return cap
end

--- How far a corner's picture stands in from the control's corner, in pixels.
PadGlyph.INSET = 4

--> A cap pinned on the lower right corner of `parent`, its middle `PadGlyph.INSET` in from it: the
--> key that presses that control.
function PadGlyph.corner(parent: GuiObject, code: Enum.KeyCode, size: number): ImageLabel
	const cap = PadGlyph.cap(parent, code, size)
	cap.AnchorPoint = Vector2.new(0.5, 0.5)
	cap.Position = UDim2.new(1, -PadGlyph.INSET, 1, -PadGlyph.INSET)
	return cap
end

return PadGlyph
