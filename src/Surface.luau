--!strict
--- Native surfaces with owned padding and row layout, not a constructor/property passthrough.
const Native = require("./Native")
const Surface = {}
export type Options = {
	kind: ("plain" | "panel" | "tile")?,
	size: UDim2?,
	position: UDim2?,
	anchor: Vector2?,
	padding: number?,
}
export type RowOptions = { height: number?, gap: number? }
function Surface.mount(parent: Instance, options: Options?): Frame
	const o: Options = options or {}
	const frame = Instance.new("Frame")
	frame.BorderSizePixel = 0
	frame.Size = o.size or UDim2.fromScale(1, 1)
	frame.Position = o.position or UDim2.fromOffset(0, 0)
	frame.AnchorPoint = o.anchor or Vector2.zero
	frame.BackgroundColor3 = if o.kind == "tile" then Native.TILE else Native.SURFACE
	frame.BackgroundTransparency = if o.kind == "panel" then Native.MODAL_T elseif o.kind == "tile" then 0 else 1
	if o.kind == "panel" or o.kind == "tile" then
		const corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, Native.CORNER)
		corner.Parent = frame
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
