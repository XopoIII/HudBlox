--!strict
--- Native surfaces with owned padding and row layout, not a constructor/property passthrough.
---
--- A surface can be painted as a game's own plate rather than Roblox's: a fill, how much shows
--- through it, a corner radius and a shading gradient. What is left out keeps the kit's own
--- measured look, so a game that asks for nothing draws exactly what it drew before.
const Native = require("./Native")
const Surface = {}
export type Options = {
	kind: ("plain" | "panel" | "tile")?,
	size: UDim2?,
	position: UDim2?,
	anchor: Vector2?,
	padding: number?,
	--- The plate's own colour, instead of what `kind` implies. A fill makes the frame opaque unless
	--- `fillTransparency` says otherwise.
	fill: Color3?,
	--- How much shows through the fill, 0..1.
	fillTransparency: number?,
	--- The corner radius in pixels. 0 is a square plate; left out, a panel or a tile keeps the kit's.
	corner: number?,
	--- A ramp multiplied over the fill, so a large plate answers "where is the light".
	gradient: ColorSequence?,
	--- The ramp's direction in degrees, as `UIGradient` reads it. Down the screen when left out.
	gradientRotation: number?,
}
export type RowOptions = { height: number?, gap: number? }
function Surface.mount(parent: Instance, options: Options?): Frame
	const o: Options = options or {}
	const frame = Instance.new("Frame")
	frame.BorderSizePixel = 0
	frame.Size = o.size or UDim2.fromScale(1, 1)
	frame.Position = o.position or UDim2.fromOffset(0, 0)
	frame.AnchorPoint = o.anchor or Vector2.zero
	const plate = o.kind == "panel" or o.kind == "tile"
	const painted = o.fill ~= nil
	frame.BackgroundColor3 = if o.fill then o.fill elseif o.kind == "tile" then Native.TILE else Native.SURFACE
	frame.BackgroundTransparency = if o.fillTransparency
		then math.clamp(o.fillTransparency, 0, 1)
		elseif painted then 0
		elseif o.kind == "panel" then Native.MODAL_T
		elseif o.kind == "tile" then 0
		else 1
	const radius = o.corner
	if radius ~= nil then
		if radius > 0 then
			const corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, radius)
			corner.Parent = frame
		end
	elseif plate then
		const corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, Native.CORNER)
		corner.Parent = frame
	end
	if o.gradient then
		const shade = Instance.new("UIGradient")
		shade.Color = o.gradient
		shade.Rotation = o.gradientRotation or 90
		shade.Parent = frame
	end
	if o.padding then
		const pad = Instance.new("UIPadding")
		const amount = UDim.new(0, math.max(0, o.padding))
		pad.PaddingLeft, pad.PaddingRight, pad.PaddingTop, pad.PaddingBottom = amount, amount, amount, amount
		pad.Parent = frame
	end
	frame.Parent = parent
	return frame
end
function Surface.row(parent: Instance, options: RowOptions?): Frame
	const frame = Surface.mount(
		parent,
		{ size = UDim2.new(1, 0, 0, if options and options.height then options.height else Native.BUTTON_H) }
	)
	const list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.HorizontalFlex = Enum.UIFlexAlignment.Fill
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, if options and options.gap then options.gap else 12)
	list.Parent = frame
	return frame
end
return Surface
