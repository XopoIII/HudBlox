--!strict
--- The rest's slips: each a small error in how long a thing rests or how much its shade covers, and
--- the rule it breaks.
const MUTANTS = {
	{
		file = "src/Backpack/Rest.luau",
		from = "rests[id] = { ends = now + seconds, total = seconds }",
		to = "rests[id] = { ends = seconds, total = seconds }",
		breaks = "a rest ends its length after the moment it was started",
	},
	{
		file = "src/Backpack/Rest.luau",
		from = "if seconds ~= seconds or seconds <= 0 then",
		to = "if seconds ~= seconds or seconds < 0 then",
		breaks = "a rest of nothing ends the one a thing has",
	},
	{
		file = "src/Backpack/Rest.luau",
		from = "if seconds ~= seconds or seconds <= 0 then",
		to = "if seconds <= 0 then",
		breaks = "a rest that is not a number ends the one a thing has",
	},
	{
		file = "src/Backpack/Rest.luau",
		from = "const left = entry.ends - now",
		to = "const left = entry.ends",
		breaks = "what is left shrinks as the clock runs",
	},
	{
		file = "src/Backpack/Rest.luau",
		from = "\tif left <= 0 then\n\t\trests[id] = nil\n\t\treturn 0, 0\n\tend\n",
		to = "\tif left <= 0 then\n\t\treturn 0, 0\n\tend\n",
		breaks = "a rest that has ended is forgotten",
	},
	{
		file = "src/Backpack/Rest.luau",
		from = "return left, entry.total",
		to = "return left, left",
		breaks = "the whole of a rest does not shrink with what is left",
	},
	{
		file = "src/Backpack/Rest.luau",
		from = "if total <= 0 or left <= 0 then",
		to = "if left <= 0 then",
		breaks = "a rest of no length shades nothing",
	},
	{
		file = "src/Backpack/Rest.luau",
		from = "return math.min(left / total, 1)",
		to = "return left / total",
		breaks = "the shade never covers more than the slot",
	},
	{
		file = "src/Backpack/Rest.luau",
		from = "return math.min(left / total, 1)",
		to = "return math.min(1 - left / total, 1)",
		breaks = "the shade is whole as the rest begins and empties toward its end",
	},
}

return MUTANTS
