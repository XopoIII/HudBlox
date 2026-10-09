--!strict
--- A game's use of the backpack's public API, the part of `tests/consumer/Game.luau` that outgrew
--- it. Checked by the type gate under both solvers (`scripts/type-check.sh`) and NOT run: it needs
--- a Roblox client.
---
--- When the API changes, this file changes with it, and the README's example after it.
const HudBlox = require("@hudblox")
const Players = game:GetService("Players")

-- The game's own Tools in the stock backpack: what each is, its picture, and every word.
const function describe(tool: Tool): HudBlox.BackpackItem
	return {
		tool = tool,
		id = tool.Name,
		fresh = tool:GetAttribute("Fresh") == true,
		tip = tool.Name,
		search = tool.Name,
		kind = "tool",
		rim = Color3.new(1, 1, 1),
		counted = true,
		picture = tool.Name,
	}
end
const draw: HudBlox.BackpackDraw = function(_view: ViewportFrame, _item: HudBlox.BackpackItem, done: (boolean) -> ())
	done(false)
end
const words: HudBlox.BackpackWords = {
	title = "Backpack",
	search = "Search",
	nothing = "Nothing here yet",
	allOnBar = "Everything is on the bar",
	count = function(n: number): string
		return `Backpack ({n})`
	end,
}
const filters: { HudBlox.BackpackFilter } = { { label = "All" }, { kind = "tool", label = "Tools" } }
const backpackConfig: HudBlox.BackpackConfig = {
	describe = describe,
	draw = draw,
	text = words,
	filters = filters,
	pinned = "Sword",
	used = function(_act: HudBlox.BackpackAct) end,
	padEquip = Enum.KeyCode.ButtonY,
}
-- A game that keeps the button for itself switches the backpack's use of it off.
const _withoutEquip: HudBlox.BackpackConfig = { describe = describe, draw = draw, text = words, padEquip = false }
const backpack: HudBlox.BackpackHandle = HudBlox.Backpack.mount(Players.LocalPlayer, backpackConfig)
backpack.toggle()
backpack.rest(Instance.new("Tool"), 4 * HudBlox.Backpack.Rest.share(3, 4))
const kept: HudBlox.BackpackOrder = HudBlox.Backpack.Order.new(10, "Sword")
HudBlox.Backpack.Order.add(kept, "Sword", false)
const spot: HudBlox.BackpackPlace? = HudBlox.Backpack.Order.where(kept, "Sword")
const taps = HudBlox.Backpack.Moves.new()
const _outcome = HudBlox.Backpack.Moves.tap(taps, kept, 0, "Sword", spot or { zone = "bar", index = 1 }, true)
const _verdict = HudBlox.Backpack.Press.classify("touch", "grid", 0, 12, 0.05)
const inHands: HudBlox.BackpackHands = HudBlox.Backpack.Hands.press({
	open = true,
	pad = true,
	holds = true,
	slot = true,
	id = "Sword",
	held = nil,
})
const _closes: boolean = HudBlox.Backpack.Hands.acts(inHands) and HudBlox.Backpack.Hands.sinks(inHands)
const _button: Enum.KeyCode? = HudBlox.Backpack.Hands.button(backpackConfig.padEquip, Enum.KeyCode.ButtonY)
const _barTop: number = HudBlox.Backpack.Bar.BOTTOM + HudBlox.Backpack.Bar.HEIGHT + HudBlox.Backpack.Slot.SIZE
const _small: number = HudBlox.Backpack.PHONE_W
HudBlox.HotbarCover.set("help", true)
const _covered: boolean = HudBlox.HotbarCover.hidden()
const stopCover = HudBlox.HotbarCover.onChange(function(_hidden: boolean) end)
HudBlox.HotbarCover.set("help", false)
stopCover()
