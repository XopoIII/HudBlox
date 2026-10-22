--!strict
--- The mark round the control a gamepad has in focus: a white outline, the Escape menu's own, in
--- place of the engine's blue box.
---
--- The kit draws it itself, in a layer of its own over every gui (`Ring.DISPLAY_ORDER`), and gives
--- the engine an empty mark (`Ring.square`, `Ring.round`) to draw instead of its box: the engine
--- draws its selection mark over the control and everything on it, so the outline covered half of
--- a control's key picture, and it draws none of a mark's own children (a game's owner, on a
--- television, 2026-10-22). In the layer the pictures the control wears are drawn again over the
--- outline (`say`), and the outline is cut where the list the control stands in ends.
---
--- The outline lies on the control's own outline (`fit`): its corners, at the scale it is drawn at.
const PadGlyph = require("./PadGlyph")
const PadInput = require("./PadInput")

const Ring = {}

--- The outline's width in pixels.
Ring.THICKNESS = 3
--- The rectangle's corner: `Native.BUTTON_CORNER`, written out, because `Native` requires this module.
Ring.CORNER = 8
--- The size of A's picture on a control the ring stands on, in pixels, and its name.
Ring.CAP = 20
Ring.SAY = "PadSay"
--- The ring's layer: over every dialog and the top line.
Ring.DISPLAY_ORDER = 1000

-- the empty mark the engine draws, and the ring the kit draws, in its layer, inside a frame that
-- cuts it where a list ends
local blank: Frame? = nil
local ring: Frame? = nil
local clip: Frame? = nil

--> The engine's mark for a control: empty, as the kit draws the ring itself. One object for the
--> whole client.
function Ring.square(): Frame
	if not blank then
		const frame = Instance.new("Frame")
		frame.Name = "FocusMark"
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Size = UDim2.fromScale(1, 1)
		blank = frame
	end
	return blank :: Frame
end

--> The same for a round button's `SelectionImageObject`: the ring rounds itself as the button is
--> rounded (`fit`).
function Ring.round(): Frame
	return Ring.square()
end

-- How many pixels a point of `object` is: every UIScale it is drawn under, multiplied.
const function drawnOf(object: Instance): number
	local scale = 1
	local at: Instance? = object
	-- the gui's own UIScale too: a whole ScreenGui drawn at Roblox's scale (`SafeArea.follow`)
	while at do
		const found = at:FindFirstChildWhichIsA("UIScale")
		scale *= if found then found.Scale else 1
		if at:IsA("LayerCollector") then
			break
		end
		at = at.Parent
	end
	return scale
end

--> Rounds the ring as `object`, the control in focus, is rounded, so it lies on its outline: by
--> its own UICorner, or, for an unseen button laid over a tile walked whole (`PadPage.tile`), by
--> the tile's; `Ring.CORNER` for a control not rounded.
function Ring.fit(object: GuiObject)
	const round = ring and ring:FindFirstChildWhichIsA("UICorner")
	if not round then
		return
	end
	local corner = object:FindFirstChildWhichIsA("UICorner")
	const parent = object.Parent
	if not corner and object.BackgroundTransparency >= 1 and parent and parent:IsA("GuiObject") then
		corner = parent:FindFirstChildWhichIsA("UICorner")
	end
	-- a radius in points grows with every UIScale the control is drawn under, and the ring is drawn
	-- in pixels: a round button half again as large on a television is rounded half again as much
	const drawn = drawnOf(object)
	const radius = if corner then corner.CornerRadius else UDim.new(0, Ring.CORNER)
	round.CornerRadius = UDim.new(radius.Scale, radius.Offset * drawn)
end

-- The pictures the ring stands over, hidden while their copies stand over the outline, each with
-- its copy; the turn of the ring's moves, so a late draw for a control left already does nothing.
type Pair = { cap: Frame, copy: Frame }
local pairs_: { Pair } = {}
local said: Frame? = nil
local turn = 0

-- Whether `object` and everything between it and `area` are visible.
const function shownIn(object: Instance, area: Instance): boolean
	local at: Instance? = object
	while at and at ~= area do
		if at:IsA("GuiObject") and not at.Visible then
			return false
		end
		at = at.Parent
	end
	return at == area
end

-- The copies taken down and the pictures under them shown again.
const function clear()
	for _, pair in pairs_ do
		pair.copy:Destroy()
		pair.cap.Visible = PadInput.active()
	end
	table.clear(pairs_)
	if said then
		said.Visible = false
	end
end

--> Says over the ring which keys press `object`, the control it stands on: each picture the control
--> or its tile wears (`PadPage.tile`) is drawn again over the outline, where it stands, and hidden
--> under it meanwhile; a control that says no key of its own gets A's, the same on every control of
--> every panel. Nil takes them off. A frame late, as a tile shows its pictures as it gains the ring.
function Ring.say(object: GuiObject?)
	turn += 1
	const mine = turn
	clear()
	const into = clip
	if not object or not into then
		return
	end
	task.defer(function()
		if mine ~= turn then
			return
		end
		const parent = object.Parent
		const area: Instance = if object.Name == "Whole" and parent then parent else object
		local any = false
		for _, item in area:GetDescendants() do
			if item.Name == "PadCap" and item:IsA("Frame") and item.Visible and shownIn(item, area) then
				const name = item:GetAttribute("PadKey")
				const key = if type(name) == "string" then Enum.KeyCode:FromName(name) else nil
				if key then
					const copy = PadGlyph.cap(into, key, item.AbsoluteSize.X)
					copy.Name = Ring.SAY
					table.insert(pairs_, { cap = item, copy = copy })
					item.Visible = false
					any = true
				end
			end
		end
		if not any and object.Name ~= "Whole" then
			const s = drawnOf(object)
			if not said then
				said = PadGlyph.cap(into, Enum.KeyCode.ButtonA, Ring.CAP)
			end
			const a = said :: Frame
			a.Name = Ring.SAY
			a.Size = UDim2.fromOffset(Ring.CAP * s, Ring.CAP * s)
			a.Visible = PadInput.active()
		end
	end)
end

-- Puts the ring, its cut and the pictures over it where the control in focus is drawn now.
const function follow(object: GuiObject?)
	const shown = ring :: Frame
	const cut = clip :: Frame
	const on = object ~= nil and PadInput.active() and object.Visible and object.AbsoluteSize.X > 0
	shown.Visible = on
	if not object or not on then
		return
	end
	-- cut where the list the control stands in ends, and nowhere else
	const parentGui = cut.Parent :: GuiObject
	const origin = parentGui.AbsolutePosition
	const list = object:FindFirstAncestorWhichIsA("ScrollingFrame")
	if list then
		cut.Position = UDim2.fromOffset(list.AbsolutePosition.X - origin.X, list.AbsolutePosition.Y - origin.Y)
		cut.Size = UDim2.fromOffset(list.AbsoluteWindowSize.X, list.AbsoluteWindowSize.Y)
	else
		cut.Position = UDim2.fromScale(0, 0)
		cut.Size = UDim2.fromScale(1, 1)
	end
	-- read from where the cut stands, not from the cut, which is laid out again only later
	const base = if list then list.AbsolutePosition else origin
	shown.Position = UDim2.fromOffset(object.AbsolutePosition.X - base.X, object.AbsolutePosition.Y - base.Y)
	shown.Size = UDim2.fromOffset(object.AbsoluteSize.X, object.AbsoluteSize.Y)
	for _, pair in pairs_ do
		const at = pair.cap.AbsolutePosition
		pair.copy.Position = UDim2.fromOffset(at.X - base.X, at.Y - base.Y)
	end
	const a = said
	if a and a.Visible then
		const s = a.AbsoluteSize.X / 2
		const corner = object.AbsolutePosition + object.AbsoluteSize - base
		const inset = PadGlyph.INSET * drawnOf(object)
		a.Position = UDim2.fromOffset(corner.X - inset - s, corner.Y - inset - s)
	end
end

--> Every control under `playerGui` gets the kit's ring, drawn in its own layer and following the
--> control in focus each frame, with the keys that press it said over it (`say`).
function Ring.install(playerGui: PlayerGui)
	playerGui.SelectionImageObject = Ring.square()
	const layer = Instance.new("ScreenGui")
	layer.Name = "PadRing"
	layer.ResetOnSpawn = false
	layer.IgnoreGuiInset = true
	layer.DisplayOrder = Ring.DISPLAY_ORDER
	-- a frame at the layer's origin, which every place is read from
	const whole = Instance.new("Frame")
	whole.Name = "Origin"
	whole.BackgroundTransparency = 1
	whole.Size = UDim2.fromScale(1, 1)
	whole.Parent = layer
	const cut = Instance.new("Frame")
	cut.Name = "Cut"
	cut.BackgroundTransparency = 1
	cut.ClipsDescendants = true
	cut.Size = UDim2.fromScale(1, 1)
	cut.Parent = whole
	const shown = Instance.new("Frame")
	shown.Name = "FocusRing"
	shown.BackgroundTransparency = 1
	shown.BorderSizePixel = 0
	shown.Visible = false
	const corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, Ring.CORNER)
	corner.Parent = shown
	const stroke = Instance.new("UIStroke")
	stroke.Color = Color3.new(1, 1, 1)
	stroke.Thickness = Ring.THICKNESS
	stroke.Parent = shown
	shown.Parent = cut
	ring, clip = shown, cut
	layer.Parent = playerGui
	const guiService = game:GetService("GuiService")
	guiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
		Ring.say(guiService.SelectedObject)
	end)
	game:GetService("RunService").RenderStepped:Connect(function()
		follow(guiService.SelectedObject)
	end)
end

return Ring
