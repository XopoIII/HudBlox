--!strict
--- What hides a hotbar while something covers it: asked for by reason, so two can overlap.
const HotbarCover = require("@hudblox/HotbarCover")
const Spec = require("../Spec")

Spec.test("the hotbar shows until a reason hides it, and comes back when the reason goes", function()
	Spec.equal(HotbarCover.hidden(), false, "at first")
	HotbarCover.set("modal:Shop", true)
	Spec.equal(HotbarCover.hidden(), true, "hidden")
	HotbarCover.set("modal:Shop", false)
	Spec.equal(HotbarCover.hidden(), false, "back")
end)

Spec.test("two reasons overlap: the hotbar comes back when the last one goes", function()
	HotbarCover.set("a", true)
	HotbarCover.set("b", true)
	HotbarCover.set("a", false)
	Spec.equal(HotbarCover.hidden(), true, "b still covers it")
	HotbarCover.set("b", false)
	Spec.equal(HotbarCover.hidden(), false, "back")
	HotbarCover.set("never", false)
	Spec.equal(HotbarCover.hidden(), false, "a reason that never asked changes nothing")
end)

Spec.test("a listener hears each change once, with the new state, until it is stopped", function()
	const heard: { boolean } = {}
	const stop = HotbarCover.onChange(function(hidden: boolean)
		table.insert(heard, hidden)
	end)
	HotbarCover.set("a", true)
	HotbarCover.set("a", true)
	HotbarCover.set("b", true)
	Spec.equal(heard, { true }, "asking twice, or by a second reason, is no change")
	HotbarCover.set("a", false)
	Spec.equal(heard, { true }, "nor is one of two going")
	HotbarCover.set("b", false)
	Spec.equal(heard, { true, false }, "shown again")
	stop()
	HotbarCover.set("a", true)
	Spec.equal(heard, { true, false }, "stopped")
	HotbarCover.set("a", false)
end)

Spec.test("the same function listening twice is two listeners, each stopped by its own stop", function()
	local calls = 0
	const function listener(_hidden: boolean)
		calls += 1
	end
	const stopFirst = HotbarCover.onChange(listener)
	const stopSecond = HotbarCover.onChange(listener)
	HotbarCover.set("a", true)
	Spec.equal(calls, 2, "both heard")
	stopFirst()
	HotbarCover.set("a", false)
	Spec.equal(calls, 3, "one left")
	stopSecond()
	HotbarCover.set("a", true)
	Spec.equal(calls, 3, "none left")
	HotbarCover.set("a", false)
end)

return nil
