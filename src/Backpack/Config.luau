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
}

export type Handle = {
	toggle: () -> (),
}

return {}
