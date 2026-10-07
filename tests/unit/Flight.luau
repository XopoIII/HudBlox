--!strict
--- How many icons fly, when each leaves, and where each is on its way.
const FlightPath = require("@hudblox/FlightPath")
const Spec = require("../Spec")

-- To a millionth: the ring is sines, and a sine of a right angle is not quite nought.
const function near(value: number): number
	return math.round(value * 1e6) / 1e6
end

const function placed(elapsed: number, index: number, count: number): { any }
	const x, y, scale, phase = FlightPath.place(elapsed, index, count, 100, 200, 500, 20, 40)
	return { near(x), near(y), near(scale), phase }
end

Spec.test("the whole number below what was asked flies, at most twelve", function()
	Spec.equal(FlightPath.MOST, 12, "the most")
	Spec.equal(FlightPath.count(1), 1, "one")
	Spec.equal(FlightPath.count(8), 8, "eight")
	Spec.equal(FlightPath.count(8.9), 8, "a fraction counts as the whole below it")
	Spec.equal(FlightPath.count(12), 12, "twelve")
	Spec.equal(FlightPath.count(13), 12, "thirteen")
	Spec.equal(FlightPath.count(math.huge), 12, "infinity")
end)

Spec.test("nothing flies for nothing: zero, under one, a negative, not a number", function()
	Spec.equal(FlightPath.count(0), 0, "zero")
	Spec.equal(FlightPath.count(0.99), 0, "under one")
	Spec.equal(FlightPath.count(-3), 0, "negative")
	Spec.equal(FlightPath.count(0 / 0), 0, "not a number")
end)

Spec.test("each icon leaves a thirty-second of a second after the one before", function()
	Spec.equal(FlightPath.STAGGER, 0.03125, "the stagger")
	Spec.equal(FlightPath.leaves(1), 0, "the first at once")
	Spec.equal(FlightPath.leaves(2), 0.03125, "the second")
	Spec.equal(FlightPath.leaves(9), 0.25, "the ninth")
end)

Spec.test("a send lasts until its last icon has stepped out and flown", function()
	Spec.equal(FlightPath.OUT, 0.25, "the step out")
	Spec.equal(FlightPath.FLY, 0.375, "the flight")
	Spec.equal(FlightPath.lasts(1), 0.625, "one icon")
	Spec.equal(FlightPath.lasts(9), 0.875, "nine")
	Spec.equal(FlightPath.lasts(0), 0, "none")
end)

Spec.test("icons step out to a ring: the first straight up, the rest clockwise", function()
	const function ring(index: number, count: number): { number }
		const x, y = FlightPath.ring(index, count, 40)
		return { near(x), near(y) }
	end
	Spec.equal(ring(1, 4), { 0, -40 }, "the first, up")
	Spec.equal(ring(2, 4), { 40, 0 }, "the second, right")
	Spec.equal(ring(3, 4), { 0, 40 }, "the third, down")
	Spec.equal(ring(4, 4), { -40, 0 }, "the fourth, left")
	Spec.equal(ring(1, 1), { 0, -40 }, "one alone, up")
	Spec.equal(ring(2, 2), { 0, 40 }, "the second of two, down")
end)

Spec.test("an icon waits at the source until it leaves", function()
	Spec.equal(placed(0, 2, 4), { 100, 200, 1, "wait" }, "the second, at the send")
	Spec.equal(placed(0.03, 2, 4), { 100, 200, 1, "wait" }, "just before it leaves")
	Spec.equal(placed(0, 1, 4), { 100, 200, 1, "out" }, "the first has left at the send")
	Spec.equal(placed(0.03125, 2, 4), { 100, 200, 1, "out" }, "the second, the moment it leaves")
end)

Spec.test("it steps out fast and slows: three quarters of the way in half the time", function()
	Spec.equal(placed(0.125, 1, 4), { 100, 170, 1, "out" }, "the first, up")
	Spec.equal(placed(0.125 + 0.03125, 2, 4), { 130, 200, 1, "out" }, "the second, right")
end)

Spec.test("it flies from its place on the ring, slow then quick, shrinking evenly", function()
	Spec.equal(placed(0.25, 1, 4), { 100, 160, 1, "fly" }, "the flight starts on the ring, full size")
	-- Half the time: a quarter of the way from (100, 160) to (500, 20), and half the shrink.
	Spec.equal(placed(0.25 + 0.1875, 1, 4), { 200, 125, 0.775, "fly" }, "half way in time")
end)

Spec.test("it is done the moment the flight's time is up, at the target, at its landing size", function()
	Spec.equal(FlightPath.LANDS_AT, 0.55, "the landing size")
	Spec.equal(placed(0.625, 1, 4), { 500, 20, 0.55, "done" }, "on time")
	Spec.equal(placed(9, 1, 4), { 500, 20, 0.55, "done" }, "long after")
	Spec.equal(placed(0.625, 2, 4)[4], "fly", "the second is still in the air")
end)

return nil
