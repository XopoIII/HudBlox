--!strict
--- The square frames a flight's icons are drawn in: dressed, pooled per layer, and handed back.
---
--- A frame is kept once it has flown: it is emptied and given back to its layer's pool, so a rain of
--- rewards makes a frame only when more icons are in the air than ever were before. The pool itself
--- is `FlightBook`'s; this is the part that touches an Instance.
const FlightBook = require("./FlightBook")

const FlightIcons = {}

-- An icon frame's look, the same for a new frame and for one that has flown: what a `draw` set on
-- the frame itself does not reach the next flight.
const function dress(frame: Frame, index: number, size: number)
	frame.Name = `Icon{index}`
	frame.Visible = false
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromOffset(0, 0)
	frame.Size = UDim2.fromOffset(size, size)
	frame.Rotation = 0
	frame.ZIndex = 1
	frame.LayoutOrder = 0
	frame.ClipsDescendants = false
	frame.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
end

--> A frame for `index`, dressed and not in the layer yet: the pool's when it has one to spare.
function FlightIcons.take(
	pools: FlightBook.Pools<ScreenGui, Frame>,
	layer: ScreenGui,
	index: number,
	size: number
): Frame
	const frame = FlightBook.take(pools, layer) or Instance.new("Frame")
	dress(frame, index, size)
	return frame
end

--> Empties `frame` and gives it back to `layer`'s pool. Only ever called with the layer alive: a
--> destroyed layer took its icons with it.
function FlightIcons.free(pools: FlightBook.Pools<ScreenGui, Frame>, layer: ScreenGui, frame: Frame)
	frame.Visible = false
	frame:ClearAllChildren()
	frame.Parent = nil
	if FlightBook.give(pools, layer, frame) then
		layer.Destroying:Once(function()
			FlightBook.drop(pools, layer)
		end)
	end
end

return FlightIcons
