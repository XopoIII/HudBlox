--!strict
--- What a press on a backpack slot turns into: a tap, a drag, or (a finger in the inventory) the start
--- of a scroll that is not the backpack's.
---
--- Written by hand rather than with `GuiObject.Draggable`, which is deprecated and is what made the
--- stock backpack's drag unreliable. One press is followed from InputBegan on its slot to InputEnded
--- anywhere on the screen, by its own InputObject for a finger and by the button for a mouse, so
--- leaving the slot or the bar never loses it. While one press is live a second finger is ignored.
---
--- What a press still down has become is `Press.classify`, which is arithmetic and specified.
--- Released before it is a drag or a scroll, it is a tap.
---
--- Drags only start while the inventory is open; a closed backpack's slots only tap (equip). The ghost
--- follows the pointer in the backpack's own ScreenGui, which keeps Roblox's inset (IgnoreGuiInset
--- false), so an InputObject's position and a slot's AbsolutePosition are in the same space and no
--- inset is added anywhere.
const Order = require("./Order")
const Press = require("./Press")

const Gesture = {}

--- What was pressed: an id (nil for an empty slot or the inventory's
--- background) and where it is.
export type Source = { id: string?, place: Order.Place }

export type Config = {
	gui: ScreenGui,
	scroller: ScrollingFrame,
	editing: () -> boolean,
	tap: (source: Source) -> (),
	drop: (source: Source, point: Vector2) -> (),
	--- A copy of the pressed slot to follow the pointer, or nil for none.
	ghost: (source: Source) -> GuiObject?,
	--- The pressed slot is lifted (true) or put back (false).
	lifted: (source: Source, on: boolean) -> (),
}

export type Engine = {
	bind: (button: GuiObject, source: () -> Source?) -> RBXScriptConnection,
	cancel: () -> (),
}

type Held = {
	input: InputObject,
	pointer: Press.Pointer,
	source: Source,
	start: Vector2,
	at: number,
	dragging: boolean,
	ghost: GuiObject?,
}

const function flat(v: Vector3): Vector2
	return Vector2.new(v.X, v.Y)
end

--> Follows presses for one backpack.
function Gesture.new(config: Config): Engine
	local press: Held? = nil

	const function finish()
		const p = press
		press = nil
		if not p then
			return
		end
		if p.ghost then
			p.ghost:Destroy()
		end
		if p.dragging then
			config.scroller.ScrollingEnabled = true
			config.lifted(p.source, false)
		end
	end

	const function startDrag(p: Held, at: Vector2)
		if p.dragging or not (p.source.id and config.editing()) then
			return
		end
		p.dragging = true
		config.scroller.ScrollingEnabled = false
		config.lifted(p.source, true)
		const ghost = config.ghost(p.source)
		if ghost then
			ghost.AnchorPoint = Vector2.new(0.5, 0.5)
			ghost.Position = UDim2.fromOffset(at.X, at.Y)
			ghost.ZIndex = 50
			ghost.Parent = config.gui
			p.ghost = ghost
		end
	end

	const function mine(input: InputObject, p: Held): boolean
		if p.pointer == "touch" then
			return input == p.input
		end
		return input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.MouseButton1
	end

	game:GetService("UserInputService").InputChanged:Connect(function(input: InputObject)
		const p = press
		if not (p and mine(input, p)) then
			return
		end
		const at = flat(input.Position)
		if p.dragging then
			if p.ghost then
				p.ghost.Position = UDim2.fromOffset(at.X, at.Y)
			end
			return
		end
		if not config.editing() then
			return
		end
		const moved = at - p.start
		const verdict = Press.classify(p.pointer, p.source.place.zone, moved.X, moved.Y, os.clock() - p.at)
		if verdict == "drag" then
			startDrag(p, at)
		elseif verdict == "scroll" then
			finish()
		end
	end)

	game:GetService("UserInputService").InputEnded:Connect(function(input: InputObject)
		const p = press
		if not p then
			return
		end
		const ended = if p.pointer == "touch"
			then input == p.input
			else input.UserInputType == Enum.UserInputType.MouseButton1
		if not ended then
			return
		end
		const at = flat(input.Position)
		-- A finger held and let go where it was is a slow tap, not a drop.
		const dragging = p.dragging and (at - p.start).Magnitude >= Press.DRAG_PX
		finish()
		if dragging then
			config.drop(p.source, at)
		else
			config.tap(p.source)
		end
	end)

	-- A lost window mid-drag puts the slot back rather than dropping it.
	game:GetService("UserInputService").WindowFocusReleased:Connect(finish)

	return {
		bind = function(button: GuiObject, source: () -> Source?): RBXScriptConnection
			return button.InputBegan:Connect(function(input: InputObject)
				const kind = input.UserInputType
				if not (kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch) then
					return
				end
				const src = source()
				if not src then
					return
				end
				-- A slot and the inventory's background under it both hear
				-- the same press, in no promised order: the slot wins.
				const current = press
				if current then
					if current.input == input and current.source.id == nil and src.id ~= nil then
						current.source = src
					end
					return
				end
				const p: Held = {
					input = input,
					pointer = if kind == Enum.UserInputType.Touch then "touch" else "mouse",
					source = src,
					start = flat(input.Position),
					at = os.clock(),
					dragging = false,
				}
				press = p
				-- A finger held still: picked up with no move at all.
				if p.pointer == "touch" then
					task.delay(Press.HOLD_S, function()
						if press == p and not p.dragging and config.editing() then
							const verdict = Press.classify("touch", src.place.zone, 0, 0, Press.HOLD_S)
							if verdict == "drag" and src.place.zone == "grid" then
								startDrag(p, p.start)
							end
						end
					end)
				end
			end)
		end,
		cancel = finish,
	}
end

return Gesture
