--!strict
--- The backpack under a gamepad. With the inventory open the focus walks the slots of the bar and the
--- inventory (`Focus`), and:
---
--- - **A** on a slot is a tap, the same one a finger makes: it picks the thing up, and on another slot
---   puts it there (`Moves`);
--- - **X** sends the thing across, bar to inventory or back, as a double tap does;
--- - **B** closes the inventory.
---
--- A slot in focus shows its tip above it, as a mouse over it does; this file wires both, so the bar's
--- and the inventory's slots share one tip.
---
--- Read off `InputBegan` rather than bound as an action: a slot is a Frame, which the engine does not
--- press, and nothing else may use A or X here, since the character and the world's prompts are held
--- while a panel has the focus.
const Bar = require("./Bar")
const Focus = require("../Focus")
const Gesture = require("./Gesture")
const Host = require("../Host")
const Slot = require("./Slot")

const Pad = {}

const SCOPE = "backpack"

export type Hooks = {
	gui: ScreenGui,
	bar: Bar.Bar,
	tap: (source: Gesture.Source) -> (),
	send: (id: string) -> (),
	close: () -> (),
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
	local pressed: RBXScriptConnection? = nil

	const function press(input: InputObject)
		const selected = game:GetService("GuiService").SelectedObject
		const slot = if selected then slots[selected] else nil
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

	-- The focus starts on the bar, not on the search box above everything.
	const function first(): GuiObject?
		for _, slot in hooks.bar.slots do
			if slot.frame.Visible then
				return slot.frame
			end
		end
		return nil
	end

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
		opened = function(open: boolean)
			if pressed then
				pressed:Disconnect()
				pressed = nil
			end
			if open then
				Focus.push(SCOPE, hooks.gui, { back = hooks.close, first = first })
				pressed = game:GetService("UserInputService").InputBegan:Connect(press)
			else
				Focus.pop(SCOPE)
			end
		end,
	}
end

return Pad
