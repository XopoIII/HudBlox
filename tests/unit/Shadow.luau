--!strict
--- What blur a shadow writes under a scale, and what the scales above a surface multiply to.
const Shadow = require("@hudblox/Shadow")
const Spec = require("../Spec")

Spec.test("the defaults are the ones the kit draws with", function()
	Spec.equal(Shadow.BLUR, 28, "blur")
	Spec.equal(Shadow.OFFSET[1], 0, "offset across")
	Spec.equal(Shadow.OFFSET[2], 12, "offset down")
	Spec.equal(Shadow.SPREAD[1], 0, "spread across")
	Spec.equal(Shadow.SPREAD[2], 0, "spread down")
	Spec.equal(Shadow.TRANSPARENCY, 0.18, "transparency")
end)

Spec.test("no scale above a surface leaves the authored blur alone", function()
	Spec.equal(Shadow.factor({}), 1, "no scales")
	Spec.equal(Shadow.pixels(Shadow.BLUR, Shadow.factor({})), Shadow.BLUR, "the authored blur")
end)

Spec.test("scales above a surface multiply, in any order", function()
	Spec.equal(Shadow.factor({ 2 }), 2, "one doubled")
	Spec.equal(Shadow.factor({ 1.5, 2 }), 3, "half again and a double")
	Spec.equal(Shadow.factor({ 2, 1.5 }), 3, "the same, the other way round")
	Spec.equal(Shadow.factor({ 0.5 }), 0.5, "one half")
	Spec.equal(Shadow.factor({ 1, 1, 1 }), 1, "three that change nothing")
end)

Spec.test("the blur follows the scale, so the shadow keeps its softness", function()
	Spec.equal(Shadow.pixels(28, 1), 28, "one")
	Spec.equal(Shadow.pixels(28, 2), 56, "two")
	Spec.equal(Shadow.pixels(28, 1.5), 42, "half again")
	Spec.equal(Shadow.pixels(28, 0.5), 14, "half")
	Spec.equal(Shadow.pixels(Shadow.BLUR, Shadow.factor({ 2, 1.5 })), 84, "a television's scale")
end)

Spec.test("a blur is a whole pixel count", function()
	Spec.equal(Shadow.pixels(10, 0.55), 6, "five and a half rounds up to six")
	Spec.equal(Shadow.pixels(10, 0.54), 5, "five and four tenths rounds down to five")
	Spec.equal(Shadow.pixels(3, 0.1), 0, "a third of a pixel is no pixel")
	Spec.equal(Shadow.pixels(28.4, 1), 28, "a fractional blur rounds to the nearer pixel")
	Spec.equal(Shadow.pixels(28.6, 1), 29, "and upward past the half")
end)

Spec.test("a blur is never under zero, whatever it is handed", function()
	Spec.equal(Shadow.pixels(-40, 1), 0, "a negative blur")
	Spec.equal(Shadow.pixels(28, -1), 0, "a negative scale")
	Spec.equal(Shadow.pixels(0 / 0, 1), 0, "not a number")
	Spec.equal(Shadow.pixels(28, 0), 0, "a surface shrunk to nothing")
end)

return nil
