--!strict
--- The mark round the control a gamepad has in focus: a white outline, the Escape menu's own, in
--- place of the engine's blue box.
---
--- Two shapes: the button's rounded rectangle, which every control under a PlayerGui gets through
--- `PlayerGui.SelectionImageObject`, and a circle for round buttons, which name it themselves.
const Ring = {}

--- The outline's width in pixels.
Ring.THICKNESS = 3
--- The rectangle's corner: `Native.BUTTON_CORNER`, written out, because `Native` requires this module.
Ring.CORNER = 8

local square: Frame? = nil
local round: Frame? = nil

const function make(radius: UDim): Frame
	const frame = Instance.new("Frame")
	frame.Name = "FocusRing"
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromScale(1, 1)
	const corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = frame
	const stroke = Instance.new("UIStroke")
	stroke.Color = Color3.new(1, 1, 1)
	stroke.Thickness = Ring.THICKNESS
	stroke.Parent = frame
	return frame
end

--> The rounded rectangle. One object for the whole client: the engine shows it on whichever control
--> has the focus.
function Ring.square(): Frame
	const ring = square or make(UDim.new(0, Ring.CORNER))
	square = ring
	return ring
end

--> The circle, for a round button's `SelectionImageObject`.
function Ring.round(): Frame
	const ring = round or make(UDim.new(0.5, 0))
	round = ring
	return ring
end

--> Every control under `playerGui` wears the square ring unless it names its own.
function Ring.install(playerGui: PlayerGui)
	playerGui.SelectionImageObject = Ring.square()
end

return Ring
