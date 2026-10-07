--!strict
--- How a gamepad reaches the top bar. D-pad down puts the focus on the bar's buttons, where the
--- stick walks them, A presses one and B leaves; D-pad right opens the game's most used panel (its
--- inventory).
---
--- D-pad up is Roblox's own (bound to a core action), so it is left alone.
---
--- Both stand down while any panel holds the focus (`Focus`): there the D-pad moves the selection.
--- Each of the two entry buttons wears a small picture of its D-pad direction while the player is on
--- a pad (`PadGlyph`).
const Focus = require("./Focus")
const Host = require("./Host")
const PadGlyph = require("./PadGlyph")
const Ring = require("./Ring")

const PadMenu = {}

const SCOPE = "hud"
--- The side of a D-pad picture on its button, in pixels.
PadMenu.CAP = 18

export type Config = {
	--- What holds every button of the bar.
	gui: ScreenGui,
	buttons: { TextButton },
	--- Where the focus starts; it wears the D-pad down picture.
	first: TextButton,
	--- The button of the panel D-pad right opens, which wears the D-pad right picture.
	bag: TextButton,
	toggleBag: () -> (),
}

const function cap(button: TextButton, code: Enum.KeyCode)
	const picture = PadGlyph.cap(button, code, PadMenu.CAP)
	picture.AnchorPoint = Vector2.new(0.5, 0)
	picture.Position = UDim2.new(0.5, 0, 1, 2)
end

--> Binds the D-pad to the bar's buttons. Call once, when the bar is built.
function PadMenu.bind(config: Config)
	const function leave()
		Focus.pop(SCOPE)
	end
	for _, button in config.buttons do
		button.SelectionImageObject = Ring.round()
		-- A pressed button opens its own panel; the bar lets the focus go.
		button.Activated:Connect(leave)
	end
	cap(config.bag, Enum.KeyCode.DPadRight)
	cap(config.first, Enum.KeyCode.DPadDown)
	game:GetService("ContextActionService")
		:BindAction(
			"PadMenu",
			function(_: string, state: Enum.UserInputState, input: InputObject): Enum.ContextActionResult
				if state ~= Enum.UserInputState.Begin or Focus.open() then
					return Enum.ContextActionResult.Pass
				end
				if input.KeyCode == Enum.KeyCode.DPadRight then
					Host.padUsed("Bag")
					config.toggleBag()
				else
					Host.padUsed("Hud")
					Focus.push(SCOPE, config.gui, {
						back = leave,
						first = function(): GuiObject?
							return config.first
						end,
					})
				end
				return Enum.ContextActionResult.Sink
			end,
			false,
			Enum.KeyCode.DPadRight,
			Enum.KeyCode.DPadDown
		)
end

return PadMenu
