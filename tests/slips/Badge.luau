--!strict
--- The badge's slips: each a small error in what a count reads as, and the rule it breaks.
const MUTANTS = {
	{
		file = "src/Badge.luau",
		from = "count < 1 then",
		to = "count < 0 then",
		breaks = "a count of zero shows no badge",
	},
	{
		file = "src/Badge.luau",
		from = "if not count or count ~= count or",
		to = "if not count or",
		breaks = "a count that is not a number shows no badge",
	},
	{
		file = "src/Badge.luau",
		from = "if whole > Badge.MOST then",
		to = "if whole >= Badge.MOST then",
		breaks = "nine is written whole",
	},
	{
		file = "src/Badge.luau",
		from = "const whole = math.floor(count)",
		to = "const whole = math.ceil(count)",
		breaks = "a fraction counts as the whole below it",
	},
	{
		file = "src/Badge.luau",
		from = "math.max(#text - 1, 0) * (Badge.SIZE // 2)",
		to = "math.max(#text, 0) * (Badge.SIZE // 2)",
		breaks = "one character makes a circle",
	},
}

return MUTANTS
