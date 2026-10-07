--!strict
--- The backpack's keys, as the stock one has them: 1 to 9 and 0 for the bar's slots, the backquote to
--- open the inventory, and a gamepad's bumpers to step through the bar.
---
--- Bound through ContextActionService, which stays quiet while a text box (the chat, the backpack's
--- own search) has the keyboard.
const Keys = {}

const SLOT_KEYS: { [Enum.KeyCode]: number } = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
	[Enum.KeyCode.Eight] = 8,
	[Enum.KeyCode.Nine] = 9,
	[Enum.KeyCode.Zero] = 10,
}

export type Hooks = {
	slot: (index: number) -> (),
	toggle: () -> (),
	--- +1 or -1 along the bar.
	step: (by: number) -> (),
}

--> Binds the three actions for the session.
function Keys.bind(hooks: Hooks)
	const codes: { Enum.KeyCode } = {}
	for code in SLOT_KEYS do
		table.insert(codes, code)
	end
	game:GetService("ContextActionService")
		:BindAction("BackpackSlot", function(_, state: Enum.UserInputState, input: InputObject)
			const index = SLOT_KEYS[input.KeyCode]
			if state ~= Enum.UserInputState.Begin or not index then
				return Enum.ContextActionResult.Pass
			end
			hooks.slot(index)
			return Enum.ContextActionResult.Sink
		end, false, table.unpack(codes))

	game:GetService("ContextActionService"):BindAction("BackpackToggle", function(_, state: Enum.UserInputState)
		if state ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end
		hooks.toggle()
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.Backquote)

	game:GetService("ContextActionService")
		:BindAction("BackpackStep", function(_, state: Enum.UserInputState, input: InputObject)
			if state ~= Enum.UserInputState.Begin then
				return Enum.ContextActionResult.Pass
			end
			hooks.step(if input.KeyCode == Enum.KeyCode.ButtonR1 then 1 else -1)
			return Enum.ContextActionResult.Sink
		end, false, Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonR1)
end

return Keys
