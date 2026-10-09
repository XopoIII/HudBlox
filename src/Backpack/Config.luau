--!strict
--- What a game hands the backpack, and what it gets back. Types only.
const Grid = require("./Grid")
const Items = require("./Items")
const Slot = require("./Slot")

--- A way of moving things, for a game that counts how its backpack is used: the inventory was
--- opened, a thing was dragged, sent across by a double tap, or moved by a tap and a tap.
export type Act = "Open" | "Drag" | "Double" | "Pair"

export type Config = {
	--- What a Tool is (`Items.Describe`).
	describe: Items.Describe,
	--- Fills a slot's picture (`Slot.Draw`).
	draw: Slot.Draw,
	--- The inventory's words, in the player's language.
	text: Grid.Words,
	--- The inventory's filters, in the order their buttons stand. None when left out.
	filters: { Grid.Filter }?,
	--- The id of the thing that owns the bar's first slot, if the game pins one.
	pinned: string?,
	--- Called each time the player uses one of the ways of moving things. It must not yield.
	used: ((act: Act) -> ())?,
	--- The gamepad's button that, with the inventory open, puts the focused thing in the hands and
	--- closes the inventory (`Hands`). `Enum.KeyCode.ButtonY` when left out; `false` binds nothing.
	--- The button is the backpack's only while its inventory holds the pad's focus, and is bound
	--- where a panel's B is (`Host.set`'s `backPriority`).
	padEquip: (Enum.KeyCode | false)?,
}

export type Handle = {
	toggle: () -> (),
	--- Shades `tool`'s slot for `seconds`, emptying as they pass: a thing that cannot be used again
	--- yet. When a thing rests and for how long is the game's; nothing or less clears it.
	rest: (tool: Tool, seconds: number) -> (),
}

return {}
