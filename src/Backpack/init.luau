--!strict
--- The backpack: a hotbar and the inventory above it, in Roblox's stock layout, drawn by the game
--- instead of Roblox's CoreGui backpack, which a script cannot open.
---
---     const backpack = Backpack.mount(player, {
---         describe = describeTool, draw = drawPicture, text = words, filters = filters,
---     })
---     button.Activated:Connect(backpack.toggle)
---
--- What the things are is the game's: what a Tool is (`Config.describe`), its picture
--- (`Config.draw`), the filters and every word a player reads. The kit owns the layout, the order,
--- the gestures, the keys and the gamepad.
---
--- This file only wires the parts together:
---
--- | Part | Does |
--- |---|---|
--- | `Items` | the Tools there are, as the game describes them |
--- | `Order` | which slot each sits in; pure, specified |
--- | `Moves` | what a tap or a drop means; pure, specified |
--- | `Press`, `Gesture` | a press becoming a tap, a drag or a scroll |
--- | `Paint`, `Bar`, `Grid`, `Slot` | what is drawn |
--- | `Keys` | 1 to 0, the backquote and the bumpers |
--- | `Pad` | a gamepad's focus on the slots, its A and X |
---
--- Equipping is the engine's `EquipTool`; whatever else a game decides about a Tool, its server
--- decides.
const Bar = require("@self/Bar")
const Grid = require("@self/Grid")
const Items = require("@self/Items")
const Moves = require("@self/Moves")
const Mount = require("@self/Mount")
const Order = require("@self/Order")
const Press = require("@self/Press")
const Slot = require("@self/Slot")

export type Config = Mount.Config
export type Handle = Mount.Handle
export type Act = Mount.Act
export type Item = Items.Item
export type Words = Grid.Words
export type Filter = Grid.Filter
export type Draw = Slot.Draw
export type Order = Order.Order
export type Place = Order.Place

return {
	--- Draws a player's backpack and follows it for the session.
	mount = Mount.mount,
	--- A touch screen narrower than this gets the small layout.
	PHONE_W = Mount.PHONE_W,
	--- The pure parts: where each thing sits, what a tap means, what a press becomes.
	Order = Order,
	Moves = Moves,
	Press = Press,
	--- The measured layout: a slot's side and gap, the bar's height and the room under it.
	Slot = Slot,
	Bar = Bar,
}
