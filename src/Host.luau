--!strict
--- What a game says of itself to the kit, once, for the parts of the kit that are one for the whole
--- client: the dialog, the gamepad's focus, a line of native text.
---
---     Host.set({ rtl = Rtl.reader(isRtl), padUsed = countPadUse })
---
--- A capsule or a round button takes its theme as an argument, because a game may draw two looks.
--- Which way its reader reads and who counts a gamepad's presses are not like that: there is one
--- reader and one counter, and a dialog that forgot to be told would open the wrong way round.
---
--- Nothing is required of a game. Left unset, the reader reads left to right and nobody counts.
const Rtl = require("./Rtl")

const Host = {}

--- What a gamepad just did, for a game that counts it: a panel took the focus, B closed one, the
--- top bar was entered, the inventory was opened by its button, a thing was moved in it.
export type PadAct = "Panel" | "Back" | "Hud" | "Bag" | "Move"

export type Hooks = {
	--- The game's mirror (`Rtl.reader`). Left to right when left out.
	rtl: Rtl.Reader?,
	--- Called each time a gamepad does one of the acts above. It must not yield or throw.
	padUsed: ((act: PadAct) -> ())?,
}

const LEFT_TO_RIGHT: Rtl.Reader = Rtl.reader(function(): boolean
	return false
end)

local reader: Rtl.Reader = LEFT_TO_RIGHT
local counter: ((act: PadAct) -> ())? = nil

--> Says who the game is. What is left out goes back to its default.
function Host.set(hooks: Hooks)
	reader = hooks.rtl or LEFT_TO_RIGHT
	counter = hooks.padUsed
end

--> The game's mirror; left to right until a game says otherwise.
function Host.rtl(): Rtl.Reader
	return reader
end

--> Tells the game a gamepad did `act`. A counter that throws costs its own count, never the press.
function Host.padUsed(act: PadAct)
	const count = counter
	if count then
		pcall(count, act)
	end
end

return Host
