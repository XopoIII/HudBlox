--!strict
--- An active, transparent GUI slot. Cameras, worlds and specimen content remain host-owned.
const Viewport = {}
function Viewport.mount(parent: Instance): ViewportFrame
	const frame = Instance.new("ViewportFrame")
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromScale(1, 1)
	frame.Active = true
	frame.Selectable = false
	frame.Parent = parent
	return frame
end
return Viewport
