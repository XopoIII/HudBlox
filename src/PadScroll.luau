--!strict
--- The right stick and the triggers while a panel holds the pad (`Focus`): the stick scrolls the
--- list the ring stands in, or the panel's first, and nothing else hears either of them meanwhile,
--- not the camera. A player who pushes the stick over a list expects it to scroll, not the view
--- behind the panel to swing and zoom.
---
--- And as the ring moves in a list, the list is scrolled to show the control in focus with
--- `PadScroll.MARGIN` round it (`reveal`): the engine scrolls to the control's own edges, and the
--- ring and a picked card's outline drawn outside them were cut off at the list's top.
---
--- How far a list moves for a tilt is `PadScroll.step`, and where it moves to show a control is
--- `PadScroll.into`, plain numbers in, so the rules are specs.
const Bindable = require("./Bindable")

const PadScroll = {}

--- The action bound, at the panel's priority (`Focus` passes its own).
PadScroll.ACTION = "FocusScroll"
--- How far a list moves a second at full tilt, in pixels, and the tilt that is no tilt at all.
PadScroll.SPEED = 1200
PadScroll.DEAD = 0.2

--> How far a list moves in `dt` seconds for the stick at `tilt` along its axis (up or right
--> positive), in pixels of canvas: nothing inside the dead zone, from nothing at its edge to
--> `SPEED` a second at full tilt; up scrolls back, towards the list's start.
function PadScroll.step(tilt: number, dt: number): number
	const size = math.abs(tilt)
	if size <= PadScroll.DEAD then
		return 0
	end
	const share = math.min((size - PadScroll.DEAD) / (1 - PadScroll.DEAD), 1)
	return -math.sign(tilt) * share * PadScroll.SPEED * dt
end

--- The room left round a control the ring stands on in a list, in the list's points.
PadScroll.MARGIN = 10

--> Where a list's canvas stands, along its axis, to show a control from `top` to `bottom` (where
--> it stands in the list's window now, in pixels, as the canvas is scrolled) with `margin` round it: moved the
--> least way, and kept between 0 and `most`. A control taller than the window shows its start.
function PadScroll.into(top: number, bottom: number, window: number, at: number, most: number, margin: number): number
	local want = at
	if top - margin < 0 then
		want = at + top - margin
	elseif bottom + margin > window then
		-- down as far as the control's end needs, and never past its start
		want = at + math.min(bottom + margin - window, top - margin)
	end
	return math.clamp(want, 0, math.max(most, 0))
end

-- How many pixels a point of `object` is: every UIScale it is drawn under, multiplied.
const function drawn(object: Instance): number
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

--> Scrolls the list `object` stands in so it shows whole with `MARGIN` round it; nothing for a
--> control in no list.
function PadScroll.reveal(object: GuiObject)
	const list = object:FindFirstAncestorWhichIsA("ScrollingFrame")
	if not list then
		return
	end
	-- the canvas is scrolled in pixels, as everything is read; the margin is in the list's points
	const margin = PadScroll.MARGIN * drawn(list)
	const across = list.ScrollingDirection == Enum.ScrollingDirection.X
	const window = list.AbsoluteWindowSize
	const room = list.AbsoluteCanvasSize - list.AbsoluteWindowSize
	const start = object.AbsolutePosition - list.AbsolutePosition
	const size = object.AbsoluteSize
	const at = list.CanvasPosition
	if across then
		const x = PadScroll.into(start.X, start.X + size.X, window.X, at.X, room.X, margin)
		list.CanvasPosition = Vector2.new(x, at.Y)
	else
		const y = PadScroll.into(start.Y, start.Y + size.Y, window.Y, at.Y, room.Y, margin)
		list.CanvasPosition = Vector2.new(at.X, y)
	end
end

-- The list the stick scrolls in `root`: the one the ring stands in, else the first one shown.
const function listIn(root: GuiBase2d): ScrollingFrame?
	const selected = game:GetService("GuiService").SelectedObject
	if selected and selected:IsDescendantOf(root) then
		const around = selected:FindFirstAncestorWhichIsA("ScrollingFrame")
		if around and around:IsDescendantOf(root) then
			return around
		end
	end
	for _, item in root:GetDescendants() do
		if item:IsA("ScrollingFrame") and item.Visible and item.ScrollingEnabled then
			return item
		end
	end
	return nil
end

-- the stick's tilt across and up, while a panel holds the pad
local stickX, stickY = 0, 0
local pulse: RBXScriptConnection? = nil

--- How often a second `start`'s `beat` is called while a panel holds the pad.
PadScroll.BEATS = 5

--> Takes the right stick and the triggers at `priority`, the stick scrolling the list in the root
--> `current` names, nil for none; `beat`, the panel's own, is called `BEATS` times a second meanwhile.
function PadScroll.start(priority: number, current: () -> GuiBase2d?, beat: (() -> ())?)
	if pulse or not Bindable.here() then
		return
	end
	stickX, stickY = 0, 0
	const function act(_: string, state: Enum.UserInputState, input: InputObject): Enum.ContextActionResult
		if input.KeyCode == Enum.KeyCode.Thumbstick2 then
			const over = state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel
			stickX, stickY = if over then 0 else input.Position.X, if over then 0 else input.Position.Y
		end
		return Enum.ContextActionResult.Sink
	end
	game:GetService("ContextActionService"):BindActionAtPriority(
		PadScroll.ACTION,
		act,
		false,
		priority,
		Enum.KeyCode.Thumbstick2,
		Enum.KeyCode.ButtonL2,
		Enum.KeyCode.ButtonR2
	)
	local since = 0
	pulse = game:GetService("RunService").Heartbeat:Connect(function(dt: number)
		since += dt
		if beat and since >= 1 / PadScroll.BEATS then
			since = 0
			beat()
		end
		const root = current()
		const list = if root and (stickX ~= 0 or stickY ~= 0) then listIn(root) else nil
		if not list then
			return
		end
		const across = list.ScrollingDirection == Enum.ScrollingDirection.X
		const move = PadScroll.step(if across then -stickX else stickY, dt)
		const room = list.AbsoluteCanvasSize - list.AbsoluteWindowSize
		const at = list.CanvasPosition
		list.CanvasPosition = if across
			then Vector2.new(math.clamp(at.X + move, 0, math.max(room.X, 0)), at.Y)
			else Vector2.new(at.X, math.clamp(at.Y + move, 0, math.max(room.Y, 0)))
	end)
end

--> Gives the right stick and the triggers back.
function PadScroll.stop()
	if not pulse then
		return
	end
	pulse:Disconnect()
	pulse = nil
	stickX, stickY = 0, 0
	game:GetService("ContextActionService"):UnbindAction(PadScroll.ACTION)
end

return PadScroll
