--!strict
--- The pad's walk, scroll and pictures' slips: each a small error in where a press goes, how far the
--- right stick scrolls a list or what a key's cap looks like, and the rule it breaks.
const MUTANTS = {
	{
		file = "src/Pick.luau",
		from = "if usable(target) and along > Pick.ROW then",
		to = "if usable(target) and along > 0 then",
		breaks = "a control within a row's height that way is not that way",
	},
	{
		file = "src/Pick.luau",
		from = "const score = along + aside * Pick.ASIDE",
		to = "const score = along + aside",
		breaks = "a step aside weighs twice a step along",
	},
	{
		file = "src/Pick.luau",
		from = "if usable(target) and along > Pick.ROW then",
		to = "if along > Pick.ROW then",
		breaks = "a press skips what is hidden or unselectable",
	},
	{
		file = "src/PadGlyph.luau",
		from = 'return if bar[name] then "bumper" else "face"',
		to = 'return "face"',
		breaks = "a bumper's cap is the engine's bar",
	},
	{
		file = "src/PadGlyph.luau",
		from = "if PadGlyph.ARROWS[name] then",
		to = "if false then",
		breaks = "a D-pad's way is a disc with an arrow",
	},
	{
		file = "src/PadGlyph.luau",
		from = 'DPadDown = "\\u{25BC}"',
		to = 'DPadDown = "\\u{25B2}"',
		breaks = "down points down, its own arrow",
	},
	{
		file = "src/PadScroll.luau",
		from = "if size <= PadScroll.DEAD then",
		to = "if size < 0 then",
		breaks = "a stick inside the dead zone scrolls nothing",
	},
	{
		file = "src/PadScroll.luau",
		from = "math.min((size - PadScroll.DEAD) / (1 - PadScroll.DEAD), 1)",
		to = "math.min(size, 1)",
		breaks = "a tilt scrolls from nothing at the dead zone's edge",
	},
	{
		file = "src/PadScroll.luau",
		from = "return -math.sign(tilt) * share",
		to = "return math.sign(tilt) * share",
		breaks = "up scrolls back towards the list's start",
	},
}

return MUTANTS
