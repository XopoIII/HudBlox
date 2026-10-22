--!strict
--- A game's use of the pad's parts of the public API (`PadCard`, `PadPage`, `PadChord`,
--- `DialogColumn`, `PadScroll`, `SafeArea.follow`), beside `Game.luau`: checked by the type gate under both solvers and NOT run.
const HudBlox = require("@hudblox")
const Players = game:GetService("Players")

const playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
const gui = HudBlox.SafeArea.screen(playerGui, "Rails")

-- a column of the game's own down the edge, at Roblox's scale of its bar
const stopColumn: () -> () = HudBlox.SafeArea.follow(gui)
stopColumn()
-- a card of the game's own that holds the pad, a tile walked whole, and a page's first control
const cardGui = Instance.new("ScreenGui")
const accept = HudBlox.Native.button(cardGui, "Take", "primary")
const later = HudBlox.Native.button(cardGui, "Later")
const cardOptions: HudBlox.PadCardOptions = { back = function() end, cancel = later }
HudBlox.PadCard.hold("reward", cardGui, accept, cardOptions)
const tile = Instance.new("Frame")
const _whole: TextButton = HudBlox.PadPage.whole(tile, accept, function() end)
-- a tile that buys with stars on A or Robux on X, whichever it shows
const tileKeys: { HudBlox.PadPageKey } = {
	{ key = Enum.KeyCode.ButtonA, button = accept, press = function() end },
	{ key = Enum.KeyCode.ButtonX, button = later, press = function() end },
}
const _tile: TextButton = HudBlox.PadPage.tile(tile, tileKeys)
-- a dialog's one column, and the pad's walk and scroll the kit does by itself
const dialog = HudBlox.Dialog.new(playerGui, "List", "List", 400, 300)
const columnOptions: HudBlox.DialogColumnOptions = { gap = 6, air = 12 }
const _column: ScrollingFrame = HudBlox.DialogColumn.mount(dialog.body, columnOptions)
const _moved: number = HudBlox.PadScroll.step(-1, 1 / 60)
const _toward: number? = HudBlox.Pick.toward({}, 0, 0, 0, 1, false)
const _firstControl: GuiObject? = HudBlox.PadPage.first(cardGui, nil)
HudBlox.PadPage.ring(cardGui)
-- the left bumper held opens the shop with X, its picture on the shop's button
const chordKey: HudBlox.PadChordKey = {
	key = Enum.KeyCode.ButtonX,
	target = function(): GuiObject?
		return accept
	end,
	press = function() end,
}
const chord: HudBlox.PadChordChord = {
	bumper = Enum.KeyCode.ButtonL1,
	keys = { chordKey },
	live = function(): boolean
		return true
	end,
	hint = function(): GuiObject?
		return accept
	end,
	tap = function(): boolean
		return false
	end,
}
const chords: HudBlox.PadChordHandle = HudBlox.PadChord.bind({ chord })
chords.step()
const _held: Enum.KeyCode? = chords.held()
const _found: HudBlox.PadChordKey? = HudBlox.PadChord.find({ chord }, Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonX)

return nil
