--!strict
--- The text engine's answers, kept: how wide the widest of some strings is in a font at a size.
--- Plain data, so every rule is specified without Roblox; `Pill.measure` keeps its answers by it.
---
--- An answer is kept by exactly what decides it, and a memo holds at most `LIMIT` of them: a game
--- that measures strings it makes up as it runs (a name, a number) cannot grow it without end.
const TextMemo = {}

--- The most answers a memo holds. A HUD pins a few dozen labels; a memo that reaches this is being
--- fed made-up strings, and starts again from nothing.
TextMemo.LIMIT = 256

export type Memo = { answers: { [string]: number }, count: number }

-- Between the parts of a key: a character no font's name and no text a player reads holds.
const SEPARATOR = "\0"

--> An empty memo.
function TextMemo.new(): Memo
	return { answers = {}, count = 0 }
end

--> The key of a measurement: the font (`family`, `weight`, `style`), the `size`, and the
--> `candidates` in any order. `candidates` is not changed.
function TextMemo.key(family: string, weight: string, style: string, size: number, candidates: { string }): string
	const sorted = table.clone(candidates)
	table.sort(sorted)
	return table.concat({ family, weight, style, tostring(size), table.concat(sorted, SEPARATOR) }, SEPARATOR)
end

--> The answer kept under `key`, or nil.
function TextMemo.get(memo: Memo, key: string): number?
	return memo.answers[key]
end

--> Keeps `widest` under `key`. Only a width is kept: a zero, a negative or what is not a number is
--> a failed pass, to be asked again. A full memo forgets everything first.
function TextMemo.keep(memo: Memo, key: string, widest: number)
	if not (widest > 0) then
		return
	end
	if memo.answers[key] == nil then
		if memo.count >= TextMemo.LIMIT then
			table.clear(memo.answers)
			memo.count = 0
		end
		memo.count += 1
	end
	memo.answers[key] = widest
end

return TextMemo
