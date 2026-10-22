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

--> Rounds the square ring as `object`, the control in focus, is rounded, so the ring lies on its
--> outline: by its own UICorner, or, for an unseen button laid over a tile walked whole
--> (`PadPage.tile`), by the tile's; `Ring.CORNER` for a control not rounded.
function Ring.fit(object: GuiObject)
	const ring = square and square:FindFirstChildWhichIsA("UICorner")
	if not ring then
		return
	end
	local corner = object:FindFirstChildWhichIsA("UICorner")
	const parent = object.Parent
	if not corner and object.BackgroundTransparency >= 1 and parent and parent:IsA("GuiObject") then
		corner = parent:FindFirstChildWhichIsA("UICorner")
	end
	-- a radius in points grows with every UIScale the control is drawn under, and the ring is drawn
	-- in pixels: a round button half again as large on a television is rounded half again as much
	local drawn = 1
	local at: Instance? = object
	while at and not at:IsA("LayerCollector") do
		const scale = at:FindFirstChildWhichIsA("UIScale")
		drawn *= if scale then scale.Scale else 1
		at = at.Parent
	end
	const radius = if corner then corner.CornerRadius else UDim.new(0, Ring.CORNER)
	ring.CornerRadius = UDim.new(radius.Scale, radius.Offset * drawn)
end

--> Every control under `playerGui` wears the square ring unless it names its own.
function Ring.install(playerGui: PlayerGui)
	playerGui.SelectionImageObject = Ring.square()
end

return Ring
