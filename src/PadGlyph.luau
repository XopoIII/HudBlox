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

return PadGlyph
