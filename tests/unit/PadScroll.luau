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

-- A list's window 300 points tall over a canvas 1000 tall (700 to scroll), its canvas at 200, and
-- a margin of 10: where the canvas goes to show a control standing from `top` to `bottom`.
Spec.test("a control in view with its margin leaves the list where it is", function()
	Spec.equal(PadScroll.MARGIN, 10, "the margin")
	Spec.equal(PadScroll.into(10, 290, 300, 200, 700, 10), 200, "just in, both ends")
	Spec.equal(PadScroll.into(100, 200, 300, 200, 700, 10), 200, "well in")
end)

Spec.test("a control above the window or its margin scrolls the list back to show it", function()
	Spec.equal(PadScroll.into(4, 100, 300, 200, 700, 10), 194, "the top row's ring cut off")
	Spec.equal(PadScroll.into(-150, -50, 300, 200, 700, 10), 40, "wholly above")
	-- and never before the canvas's start
	Spec.equal(PadScroll.into(-150, -50, 300, 100, 700, 10), 0, "the first row")
end)

Spec.test("a control below scrolls the list on, never past its own start nor the canvas's end", function()
	Spec.equal(PadScroll.into(250, 296, 300, 200, 700, 10), 206, "its end and margin in")
	Spec.equal(PadScroll.into(400, 500, 300, 200, 700, 10), 410, "wholly below")
	-- taller than the window: its start shows, with its margin
	Spec.equal(PadScroll.into(100, 600, 300, 200, 700, 10), 290, "taller than the window")
	Spec.equal(PadScroll.into(400, 500, 300, 650, 700, 10), 700, "the canvas's end")
end)

return nil
