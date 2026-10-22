--!strict
--- How far the right stick scrolls a panel's list: nothing in the dead zone, from nothing at its
--- edge to the full rate a second at full tilt, up towards the list's start.
const PadScroll = require("@hudblox/PadScroll")
const Spec = require("../Spec")

Spec.test("a stick inside the dead zone scrolls nothing, either way", function()
	Spec.equal(PadScroll.DEAD, 0.2, "the zone")
	Spec.equal(PadScroll.step(0, 1), 0, "at rest")
	Spec.equal(PadScroll.step(0.1, 1), 0, "inside it, up")
	Spec.equal(PadScroll.step(-0.1, 1), 0, "inside it, down")
	Spec.equal(PadScroll.step(0.2, 1), 0, "at its edge, up")
	Spec.equal(PadScroll.step(-0.2, 1), 0, "at its edge, down")
end)

Spec.test("full tilt scrolls the rate a second, down further on and up back", function()
	Spec.equal(PadScroll.SPEED, 1200, "the rate")
	Spec.equal(PadScroll.step(-1, 0.5), 600, "down, half a second")
	Spec.equal(PadScroll.step(1, 0.5), -600, "up, half a second")
	-- a stick read past its rim is read at it
	Spec.equal(PadScroll.step(-1.5, 0.5), 600, "past the rim")
end)

Spec.test("a tilt between scrolls its share past the dead zone", function()
	-- 0.6 is half the way from 0.2 to 1: half the rate, to a float's slack
	Spec.truthy(math.abs(PadScroll.step(-0.6, 1) - 600) < 1e-9, "half way down")
	Spec.truthy(math.abs(PadScroll.step(0.6, 1) + 600) < 1e-9, "half way up")
end)

return nil
