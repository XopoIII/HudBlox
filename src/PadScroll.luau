--!strict
--- The right stick and the triggers while a panel holds the pad (`Focus`): the stick scrolls the
--- list the ring stands in, or the panel's first, and nothing else hears either of them meanwhile,
--- not the camera. A player who pushes the stick over a list expects it to scroll, not the view
--- behind the panel to swing and zoom.
---
--- How far a list moves for a tilt is `PadScroll.step`, plain numbers in, so the rule is a spec.
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
local beat: RBXScriptConnection? = nil

--> Takes the right stick and the triggers at `priority`, the stick scrolling the list in the root
--> `current` names, nil for none.
function PadScroll.start(priority: number, current: () -> GuiBase2d?)
	if beat or not Bindable.here() then
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
	beat = game:GetService("RunService").Heartbeat:Connect(function(dt: number)
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
	if not beat then
		return
	end
	beat:Disconnect()
	beat = nil
	stickX, stickY = 0, 0
	game:GetService("ContextActionService"):UnbindAction(PadScroll.ACTION)
end

return PadScroll
