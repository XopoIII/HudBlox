--!strict
--- What a dialog's skin is when a game asks for one, and what the host's own panel is when it does not.
---
--- The colours come from LuneBlox's Roblox datatypes, which is the engine's own `Color3` and
--- `ColorSequence` in memory; the resolver itself builds nothing and reads nothing.
const DialogSkin = require("@hudblox/DialogSkin")
const Spec = require("../Spec")
const roblox = require("@lune/roblox")

const Colour = (roblox :: any).Color3
const Ramp = (roblox :: any).ColorSequence

const BLACK: Color3 = Colour.new(0, 0, 0)
const WOOD: Color3 = Colour.new(43 / 255, 36 / 255, 30 / 255)

const HOST: DialogSkin.Defaults = {
	panel = BLACK,
	panelTransparency = 0.06,
	corner = 10,
	backdropTransparency = 0.5,
}

const function rgb(colour: Color3): { number }
	return { colour.R, colour.G, colour.B }
end

Spec.test("no skin is the host's own panel, untouched", function()
	const skin = DialogSkin.resolve(nil, HOST)
	Spec.equal(rgb(skin.panel), rgb(BLACK), "the host's fill")
	Spec.equal(skin.panelTransparency, 0.06, "nearly solid")
	Spec.equal(skin.corner, 10, "its corner")
	Spec.equal(skin.backdropTransparency, 0.5, "the scrim the world is read through")
	Spec.equal(skin.gradient, nil, "no shading")
	Spec.equal(skin.gradientRotation, 90, "down the screen when there is one")
	Spec.equal(skin.sidePadding, 24, "the host's side padding")
	Spec.equal(skin.topPadding, 12, "the host's top padding")
	Spec.equal(skin.headerHeight, 48, "the host's header height")
	Spec.equal(skin.titleSize, 22, "the host's title size")
	Spec.equal(skin.headerGap, 0, "the host's divider hugs the header")
end)

Spec.test("a skin can compact the header, title and padding without going under the floors", function()
	const compact = DialogSkin.resolve({
		sidePadding = 12,
		topPadding = 8,
		headerHeight = 34,
		titleSize = 18,
		headerGap = 8,
	}, HOST)
	Spec.equal(compact.sidePadding, 12, "compact side padding")
	Spec.equal(compact.topPadding, 8, "compact top padding")
	Spec.equal(compact.headerHeight, 34, "compact header height")
	Spec.equal(compact.titleSize, 18, "compact title size")
	Spec.equal(compact.headerGap, 8, "air between the header and its divider")

	const clamped = DialogSkin.resolve({
		sidePadding = -6,
		topPadding = -4,
		headerHeight = 12,
		titleSize = 4,
		headerGap = -9,
	}, HOST)
	Spec.equal(clamped.sidePadding, 0, "side padding never negative")
	Spec.equal(clamped.topPadding, 0, "top padding never negative")
	Spec.equal(clamped.headerHeight, 24, "header height never under 24")
	Spec.equal(clamped.titleSize, 10, "title size never under 10")
	Spec.equal(clamped.headerGap, 0, "header gap never negative")
end)

Spec.test("a skin that asks for everything gets exactly what it asked for", function()
	const ramp = Ramp.new(Colour.new(1, 1, 1), Colour.new(0.47, 0.43, 0.39))
	const skin = DialogSkin.resolve({
		panel = WOOD,
		panelTransparency = 0,
		corner = 12,
		backdropTransparency = 0.62,
		gradient = ramp,
		gradientRotation = 0,
	}, HOST)
	Spec.equal(rgb(skin.panel), rgb(WOOD), "the fill it named")
	Spec.equal(skin.panelTransparency, 0, "opaque, and zero is not read as 'left out'")
	Spec.equal(skin.corner, 12, "its corner")
	Spec.equal(skin.backdropTransparency, 0.62, "a lighter scrim")
	Spec.equal(skin.gradient, ramp, "the ramp itself")
	Spec.equal(skin.gradientRotation, 0, "across")
end)

Spec.test("one field asked for leaves the others the host's own", function()
	const skin = DialogSkin.resolve({ panelTransparency = 0.2 }, HOST)
	Spec.equal(rgb(skin.panel), rgb(BLACK), "fill untouched")
	Spec.equal(skin.panelTransparency, 0.2, "what was asked")
	Spec.equal(skin.corner, 10, "corner untouched")
	Spec.equal(skin.backdropTransparency, 0.5, "scrim untouched")
end)

Spec.test("a share of the screen is clamped into it", function()
	Spec.equal(DialogSkin.resolve({ panelTransparency = 1.4 }, HOST).panelTransparency, 1, "above one")
	Spec.equal(DialogSkin.resolve({ panelTransparency = -0.4 }, HOST).panelTransparency, 0, "below zero")
	Spec.equal(DialogSkin.resolve({ backdropTransparency = 2 }, HOST).backdropTransparency, 1, "no scrim")
	Spec.equal(DialogSkin.resolve({ backdropTransparency = -1 }, HOST).backdropTransparency, 0, "black scrim")
end)

Spec.test("a corner is never negative", function()
	Spec.equal(DialogSkin.resolve({ corner = -10 }, HOST).corner, 0, "a square panel rather than a broken one")
	Spec.equal(DialogSkin.resolve({ corner = 0 }, HOST).corner, 0, "zero is a real corner")
end)

Spec.test("a value that is not a number falls back rather than drawing nothing", function()
	Spec.equal(DialogSkin.resolve({ panelTransparency = 0 / 0 }, HOST).panelTransparency, 0.06, "NaN")
	Spec.equal(DialogSkin.resolve({ corner = math.huge }, HOST).corner, 10, "infinity")
	Spec.equal(DialogSkin.resolve({ corner = 0 / 0 }, HOST).corner, 10, "NaN corner")
	Spec.equal(DialogSkin.resolve({ gradientRotation = 0 / 0 }, HOST).gradientRotation, 90, "NaN rotation")
	Spec.equal(DialogSkin.resolve({ backdropTransparency = 0 / 0 }, HOST).backdropTransparency, 0.5, "NaN")
end)

return nil
