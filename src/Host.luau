--!strict
--- What a game says of itself to the kit, once, for the parts of the kit that are one for the whole
--- client: the dialog, the gamepad's focus, a line of native text.
---
---     Host.set({ rtl = Rtl.reader(isRtl), padUsed = countPadUse })
---
--- A capsule or a round button takes its theme as an argument, because a game may draw two looks.
--- Which way its reader reads, who counts a gamepad's presses and whether it may move are not like
--- that: there is one reader, one counter and one setting, and a surface that forgot to be told
--- would open the wrong way round or move against the player's wish.
---
--- Nothing is required of a game. Left unset, the reader reads left to right, nobody counts, and
--- whether things may move is Roblox's own accessibility setting.
const Rtl = require("./Rtl")

const Host = {}

--- What a gamepad just did, for a game that counts it: a panel took the focus, B closed one, the
--- top bar was entered, the inventory was opened by its button, a thing was moved in it, a thing
--- was put in the hands (or put away) from the open inventory.
---
--- A counter typed to take fewer acts than these does not fit `padUsed`, so a game that pins a
--- release with a new act is told by its type checker, not by a count that goes missing.
export type PadAct = "Panel" | "Back" | "Hud" | "Bag" | "Move" | "Equip"

--- Whether the kit may move things for this player. "Full" when nobody says otherwise; Roblox's
--- Reduce Motion setting says "Reduced", and so may a game.
export type Motion = "Full" | "Reduced"

export type Hooks = {
	--- The game's mirror (`Rtl.reader`). Left to right when left out.
	rtl: Rtl.Reader?,
	--- Called each time a gamepad does one of the acts above. It must not yield or throw.
	padUsed: ((act: PadAct) -> ())?,
	--- The priority a panel's B ("back") is bound at (`Focus`), for a game whose own binding of B
	--- must sit above or below it. `Focus.PRIORITY` when left out. Say it before the first panel
	--- opens: it is read when the first scope is pushed.
	backPriority: number?,
	--- What this game wants instead of Roblox's Reduce Motion setting, for a game that treats a
	--- movement as information and cannot lose it. Roblox's setting when left out. It is not
	--- cached: the player can flip it in the menu while a game runs.
	motion: Motion?,
}

const LEFT_TO_RIGHT: Rtl.Reader = Rtl.reader(function(): boolean
	return false
end)

local reader: Rtl.Reader = LEFT_TO_RIGHT
local counter: ((act: PadAct) -> ())? = nil
local back: number? = nil
local movement: Motion? = nil

--> Says who the game is. What is left out goes back to its default.
function Host.set(hooks: Hooks)
	reader = hooks.rtl or LEFT_TO_RIGHT
	counter = hooks.padUsed
	back = hooks.backPriority
	movement = hooks.motion
end

--> The game's mirror; left to right until a game says otherwise.
function Host.rtl(): Rtl.Reader
	return reader
end

--> What `forced` and the player's own setting mean together, as arithmetic: a game's word wins,
--> then the setting. `reduced` is Roblox's `GuiService.ReducedMotionEnabled`, read by `motion`.
function Host.motionOf(reduced: boolean, forced: Motion?): Motion
	if forced then
		return forced
	end
	return if reduced then "Reduced" else "Full"
end

--> Whether the kit may move things now: the game's word (`Host.set`), else Roblox's Reduce Motion
--> setting. Ask it each time something is about to move, never once: the player can flip it while a
--> game runs, and the property has no change signal.
function Host.motion(): Motion
	const gui = game:GetService("GuiService").ReducedMotionEnabled
	return Host.motionOf(gui, movement)
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
