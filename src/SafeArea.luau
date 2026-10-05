--!strict
--- The usable part of a HUD's screen: what is left beside and below Roblox's own top bar.
---
--- A HUD ScreenGui that ignores the gui inset begins at the top of the device's safe area: a strip
--- as tall as the top bar lies ABOVE where Roblox's buttons end. That keeps the HUD out of a notch
--- and lets it draw on Roblox's own line, but a fraction of the gui's height is then not a fraction
--- of the space you can draw in. Anything centred, or placed at "0.13 of the screen", drifts up
--- under the platform's buttons.
---
--- This module reads the engine; the arithmetic is `Layout`'s, where the specs are.
const Layout = require("./Layout")

const SafeArea = {}

--> A ScreenGui for a HUD: kept across respawns, and edge to edge inside the device's safe insets
--> (never under a notch), so its top row can share the line of Roblox's own buttons.
function SafeArea.screen(parent: Instance, name: string): ScreenGui
	const gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = parent
	return gui
end

--> `gui` as `Layout` takes it.
function SafeArea.measure(gui: GuiBase2d): Layout.Screen
	return { width = gui.AbsoluteSize.X, left = gui.AbsolutePosition.X, top = gui.AbsolutePosition.Y }
end

--> Where Roblox's own buttons end on the device: `GuiService.TopbarInset.Min.X`. It is 208 on a
--> phone, narrower on a computer, and it MOVES when a voice icon appears or a language loads.
function SafeArea.insetMinX(): number
	return game:GetService("GuiService").TopbarInset.Min.X
end

--> X in `gui` where the top line's free span begins, right of Roblox's own buttons.
function SafeArea.topbarFreeX(gui: GuiBase2d): number
	return Layout.freeX(SafeArea.insetMinX(), gui.AbsolutePosition.X)
end

--> What a row at `rowTop` in `gui` must leave on its left for Roblox's buttons: 0 when the row is
--> drawn below them rather than beside them.
function SafeArea.chromeFreeX(gui: GuiBase2d, rowTop: number): number
	return Layout.chromeFreeX(SafeArea.measure(gui), SafeArea.insetMinX(), rowTop)
end

--> The height of Roblox's strip at the top of `gui`. 0 when the gui respects the inset.
function SafeArea.topStrip(gui: GuiBase2d): number
	return Layout.topStrip(gui.AbsolutePosition.Y)
end

--> The height available below that strip.
function SafeArea.usableHeight(gui: GuiBase2d): number
	return Layout.usableHeight(gui.AbsoluteSize.Y, gui.AbsolutePosition.Y)
end

--> A UDim for `fraction` of the USABLE height, in `gui`'s own coordinates: use it where
--> `UDim.new(fraction, 0)` would have gone. 0.5 is the true visual centre.
function SafeArea.y(gui: GuiBase2d, fraction: number): UDim
	return UDim.new(fraction, Layout.yOffset(gui.AbsolutePosition.Y, fraction))
end

--> Runs `place` now and whenever the area changes: a turned phone, a resized window, a platform
--> change. Returns the function that stops it, and a surface that can be unmounted must call it.
function SafeArea.bind(gui: GuiBase2d, place: () -> ()): () -> ()
	-- Both matter: the size moves the bottom edge, the position moves the top strip.
	const size = gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(place)
	const position = gui:GetPropertyChangedSignal("AbsolutePosition"):Connect(place)
	place()
	return function()
		size:Disconnect()
		position:Disconnect()
	end
end

return SafeArea
