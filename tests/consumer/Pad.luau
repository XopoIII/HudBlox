--!strict
--- A game's use of the pad's parts of the public API (`PadCard`, `PadPage`, `PadChord`,
--- `SafeArea.follow`), beside `Game.luau`: checked by the type gate under both solvers and NOT run.
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
