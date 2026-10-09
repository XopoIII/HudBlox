--!strict
--- The backpack under a gamepad. With the inventory open the focus walks the slots of the bar and the
--- inventory (`Focus`), and:
---
--- - **A** on a slot is a tap, the same one a finger makes: it picks the thing up, and on another slot
---   puts it there (`Moves`);
--- - **X** sends the thing across, bar to inventory or back, as a double tap does;
--- - **Y** (or the game's own choice, `Config.padEquip`) puts the thing in the hands, as a press on
---   the bar does with the inventory closed, and closes the inventory (`Hands`);
--- - **B** closes the inventory.
---
--- A slot in focus shows its tip above it, as a mouse over it does; this file wires both, so the bar's
--- and the inventory's slots share one tip.
---
--- A and X are read off `InputBegan` rather than bound as actions: a slot is a Frame, which the
--- engine does not press, and nothing else may use A or X here, since the character and the world's
--- prompts are held while a panel has the focus.
---
--- Y is a game's own button outside the inventory, so it is bound as an action, where a panel's B is
--- (`Focus`), and sunk: bound when the inventory opens and unbound when it closes, however it
--- closes, and when the gui is destroyed. An action a game binds to the same button below that
--- priority does not fire while the inventory holds the focus; one that reads raw `InputBegan`
--- still hears the press, and asks `Focus.open()` first.
const Bar = require("./Bar")
const Focus = require("../Focus")
const Gesture = require("./Gesture")
const Hands = require("./Hands")
const Host = require("../Host")
const PadInput = require("../PadInput")
const Slot = require("./Slot")

const Pad = {}

const SCOPE = "backpack"
const ACTION = "BackpackEquip"

export type Hooks = {
	gui: ScreenGui,
	bar: Bar.Bar,
	tap: (source: Gesture.Source) -> (),
	send: (id: string) -> (),
	close: () -> (),
	--- Puts the thing in the hands, or away when it is there already.
	equip: (id: string) -> (),
	--- The id of the thing in the hands, if any.
	held: () -> string?,
	--- The "in the hands" button as the game said it (`Config.padEquip`).
	button: (Enum.KeyCode | false)?,
}

export type Pad = {
	--- A new slot: a gamepad can focus it, and `hover` hears the pointer or
	--- the focus come (true) and go (false).
	slot: (slot: Slot.Slot, hover: (on: boolean) -> ()) -> (),
	--- The inventory opened or closed.
	opened: (open: boolean) -> (),
}

--> The pad's part of one backpack.
function Pad.new(hooks: Hooks): Pad
	const slots: { [GuiObject]: Slot.Slot } = {}
	const button = Hands.button(hooks.button, Enum.KeyCode.ButtonY)
	local pressed: RBXScriptConnection? = nil
	local open = false
	local gone = false

	const function focused(): Slot.Slot?
		const selected = game:GetService("GuiService").SelectedObject
		return if selected then slots[selected] else nil
	end

	const function press(input: InputObject)
		const slot = focused()
		if not slot then
			return
		end
		if input.KeyCode == Enum.KeyCode.ButtonA then
			Host.padUsed("Move")
			hooks.tap({ id = slot.id, place = slot.place })
		elseif input.KeyCode == Enum.KeyCode.ButtonX and slot.id then
			Host.padUsed("Move")
			hooks.send(slot.id)
		end
	end

	const function hands(_: string, state: Enum.UserInputState): Enum.ContextActionResult
		const slot = focused()
		const id = if slot then slot.id else nil
		const outcome = Hands.press({
			open = open,
			pad = PadInput.active(),
			holds = Focus.holds(SCOPE),
			slot = slot ~= nil,
			id = id,
			held = hooks.held(),
		})
		if state == Enum.UserInputState.Begin and Hands.acts(outcome) and id then
			Host.padUsed("Equip")
			hooks.equip(id)
			hooks.close()
		end
		return if Hands.sinks(outcome) then Enum.ContextActionResult.Sink else Enum.ContextActionResult.Pass
	end

	-- The focus starts on the bar, not on the search box above everything.
	const function first(): GuiObject?
		for _, slot in hooks.bar.slots do
			if slot.frame.Visible then
				return slot.frame
			end
		end
		return nil
	end

	-- The A and X listener, the Y action and the focus scope are there while the inventory is open
	-- and at no other time, however it closes.
	const function follow(want: boolean)
		if want == open then
			return
		end
		open = want
		if pressed then
			pressed:Disconnect()
			pressed = nil
		end
		if not want then
			if button then
				game:GetService("ContextActionService"):UnbindAction(ACTION)
			end
			Focus.pop(SCOPE)
			return
		end
		Focus.push(SCOPE, hooks.gui, { back = hooks.close, first = first })
		pressed = game:GetService("UserInputService").InputBegan:Connect(press)
		if button then
			game:GetService("ContextActionService")
				:BindActionAtPriority(ACTION, hands, false, Host.backPriority() or Focus.PRIORITY, button)
		end
	end

	-- A gui destroyed with its inventory open leaves nothing bound, and binds nothing afterwards.
	hooks.gui.Destroying:Once(function()
		follow(false)
		gone = true
	end)

	return {
		slot = function(slot: Slot.Slot, hover: (on: boolean) -> ())
			const frame = slot.frame
			frame.Selectable = true
			slots[frame] = slot
			frame.Destroying:Once(function()
				slots[frame] = nil
			end)
			const function on()
				hover(true)
			end
			const function off()
				hover(false)
			end
			frame.MouseEnter:Connect(on)
			frame.MouseLeave:Connect(off)
			frame.SelectionGained:Connect(on)
			frame.SelectionLost:Connect(off)
		end,
		opened = function(want: boolean)
			if not gone then
				follow(want)
			end
		end,
	}
end

return Pad
