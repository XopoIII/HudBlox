--!strict
--- The HUD's corner read-outs: a clock, a zone, a bonus. They only tell, so they must not look like
--- the buttons of the top bar: a lower capsule, half as solid.
---
--- And they step aside rather than crowd anything. While the game says it is busy (a dialog is up),
--- or while something reported to `Band` reaches under one of them (a full hotbar on a narrow
--- screen), the whole read-out hides. Lifting it over the bar left it covering the world instead.
const Band = require("./Band")
const Measure = require("./Measure")
const Theme = require("./Theme")
const TouchClearance = require("./TouchClearance")

const Indicator = {}

Indicator.HEIGHT = 36
--- Twice as see-through as the top bar's capsule.
Indicator.TRANSPARENCY = 1 - (1 - Measure.PLATE_T) / 2
--- Between two capsules stacked in a corner.
Indicator.STACK = 6
Indicator.TEXT_SIZE = 20
Indicator.PAD = 8

export type Follow = {
	--- The gui that holds the read-out; it is switched off as a whole.
	gui: ScreenGui,
	--- Its capsules.
	frames: { GuiObject },
	--- How high the lowest stands above the screen's bottom edge.
	bottom: () -> number,
	--- Puts the capsules where they belong. Called first on every change, before they are measured.
	place: () -> (),
	--- Whether the game wants every read-out out of the way now (a dialog is up, an inventory is
	--- open). The game calls the returned `refresh` when the answer changes. Never busy if left out.
	busy: (() -> boolean)?,
}

--> One read-out capsule in `parent`: a row of icons and text, sized to what is in it. `anchor` is
--> its anchor point, (0, 1) for the bottom left corner and (1, 1) for the bottom right. Only the
--> plate's colour is taken from `theme`.
function Indicator.capsule(parent: Instance, name: string, anchor: Vector2, theme: Theme.Theme): Frame
	const card = Instance.new("Frame")
	card.Name = name
	card.AnchorPoint = anchor
	card.AutomaticSize = Enum.AutomaticSize.X
	card.Size = UDim2.fromOffset(0, Indicator.HEIGHT)
	card.BackgroundColor3 = Theme.plate(theme)
	card.BackgroundTransparency = Indicator.TRANSPARENCY
	card.BorderSizePixel = 0
	const round = Instance.new("UICorner")
	round.CornerRadius = UDim.new(0.5, 0)
	round.Parent = card
	-- The same on both sides, so a capsule's contents sit in its middle.
	const pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, Indicator.PAD)
	pad.PaddingRight = UDim.new(0, Indicator.PAD)
	pad.Parent = card
	const row = Instance.new("UIListLayout")
	row.FillDirection = Enum.FillDirection.Horizontal
	row.VerticalAlignment = Enum.VerticalAlignment.Center
	row.SortOrder = Enum.SortOrder.LayoutOrder
	row.Padding = UDim.new(0, Measure.PART_GAP)
	row.Parent = card
	card.Parent = parent
	return card
end

--> Keeps a read-out placed, and hidden whenever it should step aside. Returns `refresh`, for the
--> game to call when its own `busy` answer changes, and the function that stops the following.
function Indicator.follow(options: Follow): (() -> (), () -> ())
	const gui = options.gui
	const function refresh()
		options.place()
		const busy = options.busy
		local hide = if busy then busy() else false
		for _, frame in options.frames do
			if hide then
				break
			end
			if frame.Visible then
				const x = frame.AbsolutePosition.X
				hide = Band.lift(x, x + frame.AbsoluteSize.X, options.bottom()) > 0
			end
		end
		gui.Enabled = not hide
	end

	const connections: { RBXScriptConnection } = {}
	const stopBand = Band.onChange(refresh)
	const stopTouch = TouchClearance.follow(refresh)
	table.insert(connections, gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh))
	for _, frame in options.frames do
		table.insert(connections, frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh))
		table.insert(connections, frame:GetPropertyChangedSignal("Visible"):Connect(refresh))
	end
	refresh()

	const function stop()
		stopBand()
		stopTouch()
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
	end
	return refresh, stop
end

return Indicator
