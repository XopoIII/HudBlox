--!strict
--- A thing in the backpack that cannot be used again yet: how long it has left and how much of its
--- slot the shade covers.
const Rest = require("@hudblox/Backpack/Rest")
const Spec = require("../Spec")

Spec.test("a rest runs from the moment it is started to its end, and is then forgotten", function()
	const rests: Rest.Rests = {}
	Rest.start(rests, "bat", 4, 100)
	const left, total = Rest.of(rests, "bat", 100)
	Spec.equal(left, 4, "all of it at the start")
	Spec.equal(total, 4, "how long it was")
	const later, same = Rest.of(rests, "bat", 101.5)
	Spec.equal(later, 2.5, "what is left a second and a half in")
	Spec.equal(same, 4, "the whole does not shrink")
	const done, none = Rest.of(rests, "bat", 104)
	Spec.equal(done, 0, "nothing at its end")
	Spec.equal(none, 0, "and no whole")
	Spec.equal(rests.bat, nil, "forgotten once over")
end)

Spec.test("a thing that does not rest has nothing left", function()
	const rests: Rest.Rests = {}
	const left, total = Rest.of(rests, "bat", 5)
	Spec.equal(left, 0, "no rest")
	Spec.equal(total, 0, "no whole")
	Rest.start(rests, "bat", 4, 0)
	const other, whole = Rest.of(rests, "sword", 1)
	Spec.equal(other, 0, "another thing's rest is not this one's")
	Spec.equal(whole, 0, "nor its whole")
end)

Spec.test("a new rest replaces the old, and nothing or less ends it", function()
	const rests: Rest.Rests = {}
	Rest.start(rests, "bat", 4, 0)
	Rest.start(rests, "bat", 1.5, 2)
	const left, total = Rest.of(rests, "bat", 2.5)
	Spec.equal(left, 1, "the new one's end")
	Spec.equal(total, 1.5, "the new one's length")
	Rest.start(rests, "bat", 0, 3)
	Spec.equal(rests.bat, nil, "zero ends it")
	Rest.start(rests, "bat", 4, 3)
	Rest.start(rests, "bat", -1, 3)
	Spec.equal(rests.bat, nil, "less than zero ends it")
	Rest.start(rests, "bat", 4, 3)
	Rest.start(rests, "bat", 0 / 0, 3)
	Spec.equal(rests.bat, nil, "not a number ends it")
end)

Spec.test("the shade covers the slot as the rest begins and empties in a straight line", function()
	Spec.equal(Rest.share(4, 4), 1, "all of it at the start")
	Spec.equal(Rest.share(3, 4), 0.75, "three quarters with a quarter gone")
	Spec.equal(Rest.share(1, 4), 0.25, "a quarter near the end")
	Spec.equal(Rest.share(0, 4), 0, "nothing at the end")
	Spec.equal(Rest.share(-1, 4), 0, "nothing after it")
	Spec.equal(Rest.share(0, 0), 0, "nothing for no rest")
	Spec.equal(Rest.share(2, 0), 0, "nothing for a rest of no length")
	Spec.equal(Rest.share(5, 4), 1, "never more than the slot")
end)

return nil
