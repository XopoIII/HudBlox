--!strict
--- The inventory, straight above the hotbar, in the stock backpack's layout: a header with the count
--- and a search box, under it a row of the game's filters, and below that a scrolling grid of the same
--- slots as the bar's.
---
--- Ten columns by four rows on a computer; on a phone the bar has three slots, too narrow for a
--- header, so the grid keeps six columns and shows two rows. The panel is as solid as a dialog
--- (`Native.MODAL_T`).
---
--- Search matches every word typed against what the game says a thing can be found by, and a filter
--- its kind; a slot that does not match both is hidden, and nothing moves in `Order`.
const Host = require("../Host")
const Items = require("./Items")
const Native = require("../Native")
const Rtl = require("../Rtl")
const Slot = require("./Slot")
const Tabs = require("../Tabs")

const Grid = {}

const TITLE_H = 40
-- The row of filters under the title.
const FILTER_H = 30
const FILTER_W = 86
const HEADER = TITLE_H + FILTER_H + 6
const PAD = Slot.GAP
const SEARCH_W = 200

--- The words the inventory shows, in the player's language. The game's.
export type Words = {
	--- The header before anything is counted.
	title: string,
	--- The search box's placeholder.
	search: string,
	--- Shown in an inventory with nothing kept at all.
	nothing: string,
	--- Shown when everything kept is on the bar.
	allOnBar: string,
	--- The header with `n` things kept.
	count: (n: number) -> string,
}

--- One filter's button: `kind` is the `Items.Item.kind` it shows alone, nil for the one that shows
--- everything. The first is the one that is on when the inventory is made.
export type Filter = { kind: string?, label: string }

export type Grid = {
	frame: Frame,
	scroller: ScrollingFrame,
	--- Columns and rows the panel shows.
	resize: (cols: number, rows: number) -> (),
	--- `n` things kept, `inside` of them in the inventory rather than the bar.
	setCount: (n: number, inside: number) -> (),
	matches: (item: Items.Item) -> boolean,
	--- The search text changed.
	searched: BindableEvent,
}

--> The inventory under `parent`, its bottom edge `bottom` above the screen's.
function Grid.new(parent: Instance, bottom: number, text: Words, filters: { Filter }): Grid
	const reader = Host.rtl()
	const rtl = reader.active()
	const frame = Instance.new("Frame")
	frame.Name = "Inventory"
	frame.AnchorPoint = Vector2.new(0.5, 1)
	frame.Position = UDim2.new(0.5, 0, 1, -bottom)
	frame.BackgroundColor3 = Native.SURFACE
	frame.BackgroundTransparency = Native.MODAL_T
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Visible = false
	frame.Parent = parent
	const corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, Native.CORNER)
	corner.Parent = frame

	const title = Native.text(frame, text.title, 18, { weight = Enum.FontWeight.Bold })
	title.Name = "Title"
	title.TextWrapped = false
	title.Position = UDim2.fromOffset(PAD + 4, 0)
	title.Size = UDim2.new(1, -SEARCH_W - PAD * 3, 0, TITLE_H)

	const box = Instance.new("TextBox")
	box.Name = "Search"
	box.AnchorPoint = Vector2.new(1, 0.5)
	box.Position = UDim2.new(1, -PAD, 0, TITLE_H / 2)
	box.Size = UDim2.fromOffset(SEARCH_W, 28)
	box.BackgroundColor3 = Native.TEXT
	box.BackgroundTransparency = 0.9
	box.ClearTextOnFocus = false
	box.FontFace = Native.font()
	box.TextSize = 16
	box.TextColor3 = Native.TEXT
	box.PlaceholderText = text.search
	box.PlaceholderColor3 = Native.BODY
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.Text = ""
	box.Parent = frame
	const boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 6)
	boxCorner.Parent = box
	const boxPad = Instance.new("UIPadding")
	boxPad.PaddingLeft = UDim.new(0, 8)
	boxPad.PaddingRight = UDim.new(0, 26)
	boxPad.Parent = box
	const clear = Instance.new("TextButton")
	clear.Name = "Clear"
	clear.AnchorPoint = Vector2.new(0, 0.5)
	clear.Position = UDim2.new(1, 2, 0.5, 0)
	clear.Size = UDim2.fromOffset(22, 22)
	clear.BackgroundTransparency = 1
	clear.FontFace = Native.font(Enum.FontWeight.Bold)
	clear.TextSize = 16
	clear.TextColor3 = Native.BODY
	clear.Text = "×"
	clear.Visible = false
	clear.Parent = box
	-- Right to left: the title on the right, the search box and its clear on the left.
	if rtl then
		Rtl.flipX(title)
		Rtl.flipX(box)
		Rtl.flipX(clear)
		boxPad.PaddingLeft, boxPad.PaddingRight = boxPad.PaddingRight, boxPad.PaddingLeft
		box.TextXAlignment = Enum.TextXAlignment.Right
	end

	-- The kind shown alone; nil shows everything.
	local filter: string? = if filters[1] then filters[1].kind else nil

	const scroller = Instance.new("ScrollingFrame")
	scroller.Name = "Slots"
	scroller.Position = UDim2.fromOffset(0, HEADER)
	scroller.Size = UDim2.new(1, 0, 1, -HEADER)
	scroller.BackgroundTransparency = 1
	scroller.BorderSizePixel = 0
	scroller.ScrollBarThickness = 4
	scroller.ScrollingDirection = Enum.ScrollingDirection.Y
	scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroller.CanvasSize = UDim2.new()
	scroller.Active = true
	scroller.Parent = frame
	const layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.fromOffset(Slot.SIZE, Slot.SIZE)
	layout.CellPadding = UDim2.fromOffset(Slot.GAP, Slot.GAP)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.StartCorner = if rtl then Enum.StartCorner.TopRight else Enum.StartCorner.TopLeft
	layout.Parent = scroller
	const pad = Instance.new("UIPadding")
	if rtl then
		pad.PaddingRight = UDim.new(0, PAD)
	else
		pad.PaddingLeft = UDim.new(0, PAD)
	end
	-- Room for a slot's outline, which the scroller would clip at its edge.
	pad.PaddingTop = UDim.new(0, 3)
	pad.PaddingBottom = UDim.new(0, PAD)
	pad.Parent = scroller

	const empty = Native.text(frame, text.nothing, 16, { color = Native.BODY })
	empty.Name = "Empty"
	empty.TextXAlignment = Enum.TextXAlignment.Center
	empty.AnchorPoint = Vector2.new(0.5, 0.5)
	empty.Position = UDim2.new(0.5, 0, 0.5, HEADER / 2)
	empty.Size = UDim2.new(1, -PAD * 4, 0, 44)
	empty.Visible = false

	local words: { string } = {}
	const searched = Instance.new("BindableEvent")
	box:GetPropertyChangedSignal("Text"):Connect(function()
		words = {}
		for word in string.gmatch(string.lower(box.Text), "%S+") do
			table.insert(words, word)
		end
		clear.Visible = box.Text ~= ""
		searched:Fire()
	end)
	clear.Activated:Connect(function()
		box.Text = ""
	end)
	-- The filters are a tab strip of the kit's own, a chip's size: a tab is called by its kind, and
	-- the one that shows everything "all".
	if #filters > 0 then
		const kindOf: { [string]: Filter } = {}
		const entries: { Tabs.Entry } = {}
		for _, entry in filters do
			const key = entry.kind or "all"
			kindOf[key] = entry
			table.insert(entries, { key = key, label = entry.label })
		end
		const chips = Tabs.mount(frame, entries, {
			name = "Filters",
			height = FILTER_H,
			width = FILTER_W,
			gap = 6,
			text = 15,
			picked = function(key: string)
				filter = kindOf[key].kind
				scroller.CanvasPosition = Vector2.zero
				searched:Fire()
			end,
		})
		chips.frame.Position = UDim2.fromOffset(PAD, TITLE_H)
		chips.frame.Size = UDim2.new(1, -PAD * 2, 0, FILTER_H)
	end

	return {
		frame = frame,
		scroller = scroller,
		resize = function(cols: number, rows: number)
			const w = PAD + cols * (Slot.SIZE + Slot.GAP)
			const h = HEADER + rows * (Slot.SIZE + Slot.GAP) + PAD
			frame.Size = UDim2.fromOffset(w, h)
			box.Size = UDim2.fromOffset(math.min(SEARCH_W, w / 2), 28)
		end,
		setCount = function(n: number, inside: number)
			title.Text = text.count(n)
			empty.Text = if n == 0 then text.nothing else text.allOnBar
			empty.Visible = inside == 0
		end,
		matches = function(item: Items.Item): boolean
			if filter ~= nil and item.kind ~= filter then
				return false
			end
			if #words == 0 then
				return true
			end
			-- string.lower folds ASCII only: a word in another script matches as typed.
			const hay = string.lower(item.search)
			for _, word in words do
				if not string.find(hay, word, 1, true) then
					return false
				end
			end
			return true
		end,
		searched = searched,
	}
end

return Grid
