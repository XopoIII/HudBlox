--!strict
--- One square of the backpack, on the bar or in the inventory.
---
--- Laid out as the stock backpack's: a `SIZE` square on a see-through dark tile, the slot's number in
--- its corner while a keyboard is there. It shows the thing itself in a ViewportFrame, which the game
--- fills (`Draw`), inside a rim of the colour the game gives the thing. No name under it: the tile
--- stays a true square, and the name is the bar's tip.
---
--- Two outlines sit over it, both white: solid while the thing is in hand, pulsing while it is picked
--- up to be moved.
const Items = require("./Items")
const Native = require("../Native")
const Order = require("./Order")

const Slot = {}

-- The tile's side; a slot is a square.
Slot.SIZE = 60
Slot.GAP = 5

const TILE_T = 0.35
const EMPTY_T = 0.6
const RING = Color3.new(1, 1, 1)
const PULSE = TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)

--- Puts `item`'s picture in `view` and calls `done(true)` once it is there, or `done(false)` if it
--- never came. The game's.
export type Draw = (view: ViewportFrame, item: Items.Item, done: (boolean) -> ()) -> ()

export type Slot = {
	frame: Frame,
	--- Where it stands now; the gesture reads it at the moment of a press.
	place: Order.Place,
	id: string?,
	set: (item: Items.Item?) -> (),
	setHeld: (on: boolean) -> (),
	setPicked: (on: boolean) -> (),
	setLifted: (on: boolean) -> (),
	setNumber: (text: string?) -> (),
	--- A copy to follow the pointer during a drag.
	ghost: () -> GuiObject,
	destroy: () -> (),
}

--> An empty slot under `parent`, standing at `place`; `draw` fills its picture.
function Slot.new(parent: Instance, place: Order.Place, draw: Draw): Slot
	const frame = Instance.new("Frame")
	frame.Name = "Slot"
	frame.Size = UDim2.fromOffset(Slot.SIZE, Slot.SIZE)
	frame.BackgroundColor3 = Native.TILE
	frame.BackgroundTransparency = EMPTY_T
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Parent = parent
	const corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, Native.BUTTON_CORNER)
	corner.Parent = frame
	const rim = Instance.new("UIStroke")
	rim.Thickness = 1.5
	rim.Transparency = 1
	rim.Parent = frame

	const view = Instance.new("ViewportFrame")
	view.Name = "View"
	view.BackgroundTransparency = 1
	view.Position = UDim2.fromOffset(4, 4)
	view.Size = UDim2.fromOffset(Slot.SIZE - 8, Slot.SIZE - 8)
	view.Ambient = Color3.fromRGB(170, 170, 170)
	view.LightColor = Color3.new(1, 1, 1)
	view.LightDirection = Vector3.new(-0.4, -1, -0.6)
	view.Parent = frame

	const number = Native.text(frame, "", 13, { weight = Enum.FontWeight.Bold })
	number.Name = "Number"
	number.TextWrapped = false
	number.Size = UDim2.fromOffset(14, 16)
	number.Position = UDim2.fromOffset(5, 2)
	number.ZIndex = 3

	const ring = Instance.new("Frame")
	ring.Name = "Ring"
	ring.BackgroundTransparency = 1
	ring.Size = UDim2.fromScale(1, 1)
	ring.ZIndex = 4
	ring.Parent = frame
	const ringCorner = corner:Clone()
	ringCorner.Parent = ring
	const stroke = Instance.new("UIStroke")
	stroke.Color = RING
	stroke.Thickness = 3
	stroke.Transparency = 1
	stroke.Parent = ring

	local held, picked = false, false
	local pulse: Tween? = nil

	const function outline()
		if pulse then
			pulse:Cancel()
			pulse = nil
		end
		if picked then
			stroke.Transparency = 0
			const tween = game:GetService("TweenService"):Create(stroke, PULSE, { Transparency = 0.75 })
			tween:Play()
			pulse = tween
		else
			stroke.Transparency = if held then 0 else 1
		end
	end

	local shown: Items.Item? = nil
	local pictured: string? = nil
	local slot: Slot
	slot = {
		frame = frame,
		place = place,
		id = nil :: string?,
		set = function(item: Items.Item?)
			if item == shown then
				return
			end
			shown = item
			slot.id = if item then item.id else nil
			frame.BackgroundTransparency = if item then TILE_T else EMPTY_T
			const color = if item then item.rim else nil
			rim.Transparency = if color then 0 else 1
			if color then
				rim.Color = color
			end
			-- The same thing again keeps the picture it has.
			const key = if item then item.picture else nil
			if key ~= nil and key == pictured and view:FindFirstChildOfClass("Model") then
				return
			end
			pictured = key
			const old = view:FindFirstChildOfClass("Model")
			if old then
				old:Destroy()
			end
			if item then
				draw(view, item, function() end)
			end
		end,
		setHeld = function(on: boolean)
			if held ~= on then
				held = on
				outline()
			end
		end,
		setPicked = function(on: boolean)
			if picked ~= on then
				picked = on
				outline()
			end
		end,
		setLifted = function(on: boolean)
			view.ImageTransparency = if on then 0.7 else 0
		end,
		setNumber = function(text: string?)
			number.Text = text or ""
			number.Visible = text ~= nil
		end,
		ghost = function(): GuiObject
			const copy = frame:Clone()
			copy.Name = "Ghost"
			copy.Active = false
			const view2 = copy:FindFirstChild("View")
			const model = view:FindFirstChildOfClass("Model")
			if view2 and view2:IsA("ViewportFrame") and model then
				const cam = Instance.new("Camera")
				cam.CFrame = (view.CurrentCamera :: Camera).CFrame
				cam.FieldOfView = (view.CurrentCamera :: Camera).FieldOfView
				cam.Parent = view2
				view2.CurrentCamera = cam
				view2.ImageTransparency = 0
			end
			return copy
		end,
		destroy = function()
			if pulse then
				pulse:Cancel()
			end
			frame:Destroy()
		end,
	}
	return slot
end

return Slot
