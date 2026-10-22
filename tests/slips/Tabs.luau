--!strict
--- The tab strip's slips: each a small error in how wide a tab is, and the rule it breaks.
const MUTANTS = {
	{
		file = "src/TabFit.luau",
		from = "gap * (count - 1)",
		to = "gap * count",
		breaks = "the gaps are between tabs: one tab has none",
	},
	{
		file = "src/TabFit.luau",
		from = ")) // count",
		to = ")) / count",
		breaks = "a tab is a whole number of pixels wide",
	},
	{
		file = "src/TabFit.luau",
		from = "math.max(math.min(most, share),",
		to = "math.max(share,",
		breaks = "tabs that fit are no wider than a tab may be",
	},
	{
		file = "src/TabFit.luau",
		from = "math.min(most, TabFit.NARROWEST))",
		to = "TabFit.NARROWEST)",
		breaks = "a widest under the narrowest is kept",
	},
	{
		file = "src/TabFit.luau",
		from = "math.min(most, share), math.min(most, TabFit.NARROWEST))",
		to = "math.min(most, share), 0)",
		breaks = "a tab is never squeezed under the narrowest",
	},
	{
		file = "src/TabFit.luau",
		from = "math.clamp(on + by, 1, count)",
		to = "on + by",
		breaks = "a bumper stops at either end",
	},
	{
		file = "src/TabFit.luau",
		from = "\tif count < 1 then\n\t\treturn on\n\tend\n\treturn math.clamp",
		to = "\treturn math.clamp",
		breaks = "no tabs: where it was",
	},
}

return MUTANTS
