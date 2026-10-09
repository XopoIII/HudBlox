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
--- top bar was entered, the inventory was opened by its button, a thing was moved in it, a thing
--- was put in the hands (or put away) from the open inventory.
---
--- A counter typed to take fewer acts than these does not fit `padUsed`, so a game that pins a
--- release with a new act is told by its type checker, not by a count that goes missing.
export type PadAct = "Panel" | "Back" | "Hud" | "Bag" | "Move" | "Equip"

export type Hooks = {
	--- The game's mirror (`Rtl.reader`). Left to right when left out.
	rtl: Rtl.Reader?,
	--- Called each time a gamepad does one of the acts above. It must not yield or throw.
	padUsed: ((act: PadAct) -> ())?,
	--- The priority a panel's B ("back") is bound at (`Focus`), for a game whose own binding of B
	--- must sit above or below it. `Focus.PRIORITY` when left out. Say it before the first panel
	--- opens: it is read when the first scope is pushed.
	backPriority: number?,
}

const LEFT_TO_RIGHT: Rtl.Reader = Rtl.reader(function(): boolean
	return false
end)

local reader: Rtl.Reader = LEFT_TO_RIGHT
local counter: ((act: PadAct) -> ())? = nil
local back: number? = nil

--> Says who the game is. What is left out goes back to its default.
function Host.set(hooks: Hooks)
	reader = hooks.rtl or LEFT_TO_RIGHT
	counter = hooks.padUsed
	back = hooks.backPriority
end

--> The game's mirror; left to right until a game says otherwise.
function Host.rtl(): Rtl.Reader
	return reader
end

--> The priority a panel's "back" is bound at; nil until a game says one, and `Focus` binds at its
--> own `PRIORITY` then.
function Host.backPriority(): number?
	return back
end

--> Tells the game a gamepad did `act`. A counter that throws costs its own count, never the press.
function Host.padUsed(act: PadAct)
	const count = counter
	if count then
		pcall(count, act)
	end
end

return Host
