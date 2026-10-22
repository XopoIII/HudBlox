--!strict
--- The shape of a key's cap: a disc for a face button, the engine's bar for a bumper or a trigger,
--- and a disc with an arrow for a D-pad's way.
const PadGlyph = require("@hudblox/PadGlyph")
const Spec = require("../Spec")

Spec.test("a face button's cap is a disc, a bumper's and a trigger's a bar", function()
	for _, name in { "ButtonA", "ButtonB", "ButtonX", "ButtonY", "ButtonStart" } do
		Spec.equal(PadGlyph.shape(name), "face", name)
	end
	for _, name in { "ButtonL1", "ButtonR1", "ButtonL2", "ButtonR2" } do
		Spec.equal(PadGlyph.shape(name), "bumper", name)
	end
end)

Spec.test("a D-pad's way is a disc with its own arrow, each way another", function()
	const arrows: { [string]: string } = {}
	for _, name in { "DPadUp", "DPadDown", "DPadLeft", "DPadRight" } do
		Spec.equal(PadGlyph.shape(name), "way", name)
		const arrow = PadGlyph.ARROWS[name]
		Spec.truthy(arrow ~= nil and arrows[arrow] == nil, `{name} has an arrow of its own`)
		arrows[arrow] = name
	end
	Spec.equal(PadGlyph.ARROWS.DPadDown, "\u{25BC}", "down points down")
	Spec.equal(PadGlyph.ARROWS.DPadUp, "\u{25B2}", "up points up")
	-- a stick is no way of the D-pad
	Spec.equal(PadGlyph.shape("Thumbstick1"), "face", "a stick")
end)

return nil
