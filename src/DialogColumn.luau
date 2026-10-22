--!strict
--- The one column a dialog's body scrolls in, the same in every dialog of every game: its lines in
--- `LayoutOrder`, a gap apart, the scroll bar in a strip of its own with air before it, and room
--- round the lines for the gamepad's ring (`Ring.THICKNESS`), which the column would otherwise cut
--- off the top row's and the edge column's controls. On a pad the right stick scrolls it
--- (`PadScroll`), the ring walks it each way to the nearest control (`Steer`), and a tile walked
--- whole shows its own button's A (`PadPage.whole`).
const Native = require("./Native")
const Ring = require("./Ring")

const DialogColumn = {}

--- Between two lines of the column, and between its lines and its scroll bar, in pixels.
DialogColumn.GAP = 6
DialogColumn.AIR = 12
--- The room round the lines for the ring and a picked card's own outline drawn outside it: the
--- ring's width and four points.
DialogColumn.RING_ROOM = Ring.THICKNESS + 4

export type Options = {
	--- Between two lines; `DialogColumn.GAP` when left out.
	gap: number?,
	--- Between the lines and the scroll bar; `DialogColumn.AIR` when left out.
	air: number?,
}

--> The column, filling `body`, a dialog's body.
function DialogColumn.mount(body: GuiObject, options: Options?): ScrollingFrame
	const column = Instance.new("ScrollingFrame")
	column.Name = "Column"
	column.BackgroundTransparency = 1
	column.BorderSizePixel = 0
	column.Size = UDim2.fromScale(1, 1)
	column.CanvasSize = UDim2.fromScale(0, 0)
	column.AutomaticCanvasSize = Enum.AutomaticSize.Y
	column.ScrollingDirection = Enum.ScrollingDirection.Y
	column.ScrollBarThickness = 4
	column.ScrollBarImageColor3 = Native.BODY
	-- the bar takes its own strip: drawn over the column it covered the edge of a row's button, and
	-- the first letters of a line read from the right
	column.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
	-- nothing to land on by itself: a gamepad goes to what is in it
	column.Selectable = false
	const room = DialogColumn.RING_ROOM
	const pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, room)
	pad.PaddingBottom = UDim.new(0, room)
	pad.PaddingLeft = UDim.new(0, room)
	pad.PaddingRight = UDim.new(0, math.max(if options and options.air then options.air else DialogColumn.AIR, room))
	pad.Parent = column
	const list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, if options and options.gap then options.gap else DialogColumn.GAP)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = column
	column.Parent = body
	return column
end

return DialogColumn
