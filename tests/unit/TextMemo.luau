--!strict
--- The text engine's answers, kept: by exactly what decides them, never a failed pass, never
--- without end.
const Spec = require("../Spec")
const TextMemo = require("@hudblox/TextMemo")

const FAMILY = "rbxasset://fonts/families/BuilderSans.json"

const function key(candidates: { string }): string
	return TextMemo.key(FAMILY, "Bold", "Normal", 20, candidates)
end

Spec.test("a key is the font, the size and the candidates, a nought between each", function()
	Spec.equal(
		TextMemo.key("family", "Bold", "Italic", 20, { "b", "a" }),
		"family\0Bold\0Italic\00020\0a\0b",
		"the key"
	)
	Spec.equal(TextMemo.key("family", "Bold", "Italic", 17.5, {}), "family\0Bold\0Italic\00017.5\0", "no candidates")
end)

Spec.test("the candidates' order does not change the key, and the list is left as it was", function()
	const candidates = { "99", "00", "55" }
	Spec.equal(key(candidates), key({ "00", "55", "99" }), "one key")
	Spec.equal(candidates, { "99", "00", "55" }, "the caller's list")
end)

Spec.test("another family, weight, style, size or candidate is another key", function()
	const base = TextMemo.key("f", "Bold", "Normal", 20, { "00" })
	Spec.equal(TextMemo.key("g", "Bold", "Normal", 20, { "00" }) == base, false, "family")
	Spec.equal(TextMemo.key("f", "Medium", "Normal", 20, { "00" }) == base, false, "weight")
	Spec.equal(TextMemo.key("f", "Bold", "Italic", 20, { "00" }) == base, false, "style")
	Spec.equal(TextMemo.key("f", "Bold", "Normal", 21, { "00" }) == base, false, "size")
	Spec.equal(TextMemo.key("f", "Bold", "Normal", 20, { "01" }) == base, false, "candidate")
	Spec.equal(TextMemo.key("f", "Bold", "Normal", 20, { "00", "0" }) == base, false, "one candidate more")
	-- Two candidates are not their joining: the widest of "a" and "b" is not the width of "ab".
	Spec.equal(
		TextMemo.key("f", "Bold", "Normal", 20, { "a", "b" }) == TextMemo.key("f", "Bold", "Normal", 20, { "ab" }),
		false,
		"two candidates against one"
	)
end)

Spec.test("a new memo knows nothing, and a kept answer is handed back for its key alone", function()
	const memo = TextMemo.new()
	Spec.equal(TextMemo.get(memo, key({ "00" })), nil, "nothing yet")
	TextMemo.keep(memo, key({ "00" }), 23.5)
	Spec.equal(TextMemo.get(memo, key({ "00" })), 23.5, "kept")
	Spec.equal(TextMemo.get(memo, key({ "01" })), nil, "another key")
	Spec.equal(memo.count, 1, "count")
end)

Spec.test("a failed pass is never kept: zero, a negative, not a number", function()
	const memo = TextMemo.new()
	TextMemo.keep(memo, "zero", 0)
	TextMemo.keep(memo, "negative", -4)
	TextMemo.keep(memo, "nan", 0 / 0)
	Spec.equal(TextMemo.get(memo, "zero"), nil, "zero")
	Spec.equal(TextMemo.get(memo, "negative"), nil, "negative")
	Spec.equal(TextMemo.get(memo, "nan"), nil, "not a number")
	Spec.equal(memo.count, 0, "count")
	Spec.equal(next(memo.answers), nil, "nothing under any key")
end)

Spec.test("a failed pass does not take a kept answer away", function()
	const memo = TextMemo.new()
	TextMemo.keep(memo, "k", 12)
	TextMemo.keep(memo, "k", 0)
	Spec.equal(TextMemo.get(memo, "k"), 12, "still kept")
	Spec.equal(memo.count, 1, "count")
end)

Spec.test("a key kept again takes the new answer and counts once", function()
	const memo = TextMemo.new()
	TextMemo.keep(memo, "k", 12)
	TextMemo.keep(memo, "k", 14)
	Spec.equal(TextMemo.get(memo, "k"), 14, "the new answer")
	Spec.equal(memo.count, 1, "count")
end)

Spec.test("a memo holds two hundred and fifty-six answers, and the one over starts it again", function()
	Spec.equal(TextMemo.LIMIT, 256, "the limit")
	const memo = TextMemo.new()
	for index = 1, 256 do
		TextMemo.keep(memo, `k{index}`, index)
	end
	Spec.equal(memo.count, 256, "full")
	Spec.equal(TextMemo.get(memo, "k1"), 1, "the first is still there")
	Spec.equal(TextMemo.get(memo, "k256"), 256, "the last is there")
	-- A key already kept is not one more: a full memo answering what it knows forgets nothing.
	TextMemo.keep(memo, "k7", 70)
	Spec.equal(memo.count, 256, "still full")
	Spec.equal(TextMemo.get(memo, "k7"), 70, "the new answer")
	Spec.equal(TextMemo.get(memo, "k1"), 1, "nothing forgotten")
	TextMemo.keep(memo, "over", 9)
	Spec.equal(memo.count, 1, "started again")
	Spec.equal(TextMemo.get(memo, "over"), 9, "the one over is kept")
	Spec.equal(TextMemo.get(memo, "k1"), nil, "the first is forgotten")
	Spec.equal(TextMemo.get(memo, "k256"), nil, "the last is forgotten")
	local held = 0
	for _ in memo.answers do
		held += 1
	end
	Spec.equal(held, 1, "one answer held")
end)

return nil
