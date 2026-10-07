--!strict
--- What a badge reads for a count, and how wide its disc is.
const Badge = require("@hudblox/Badge")
const Spec = require("../Spec")

Spec.test("no badge for nothing: nil, zero, a negative, under one, not a number", function()
	Spec.equal(Badge.text(nil), nil, "nil")
	Spec.equal(Badge.text(0), nil, "zero")
	Spec.equal(Badge.text(-3), nil, "negative")
	Spec.equal(Badge.text(0.99), nil, "under one")
	Spec.equal(Badge.text(0 / 0), nil, "not a number")
end)

Spec.test("a count from one to nine is written whole", function()
	Spec.equal(Badge.MOST, 9, "the most written whole")
	Spec.equal(Badge.text(1), "1", "one")
	Spec.equal(Badge.text(5), "5", "five")
	Spec.equal(Badge.text(9), "9", "nine")
end)

Spec.test("past nine it reads nine with a plus, however many", function()
	Spec.equal(Badge.text(10), "9+", "ten")
	Spec.equal(Badge.text(44), "9+", "forty-four")
	Spec.equal(Badge.text(1e9), "9+", "a billion")
	Spec.equal(Badge.text(math.huge), "9+", "infinity")
end)

Spec.test("a fraction counts as the whole below it", function()
	Spec.equal(Badge.text(1.9), "1", "one and a bit")
	Spec.equal(Badge.text(9.99), "9", "nearly ten")
	Spec.equal(Badge.text(10.01), "9+", "just past ten")
end)

Spec.test("the disc is a circle for one character and half a height wider for each one more", function()
	Spec.equal(Badge.SIZE, 18, "the height")
	Spec.equal(Badge.width("1"), 18, "one character")
	Spec.equal(Badge.width("9+"), 27, "two characters")
	Spec.equal(Badge.width("123"), 36, "three characters")
	Spec.equal(Badge.width(""), 18, "never narrower than a circle")
end)

return nil
