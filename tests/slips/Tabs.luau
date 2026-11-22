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
	{
		file = "src/TabFit.luau",
		from = "(span - (count - 1) * gap)",
		to = "(span - count * gap)",
		breaks = "one vertical tab has no gap",
	},
	{
		file = "src/TabFit.luau",
		from = "math.min(TabFit.SHORTEST, most)",
		to = "TabFit.SHORTEST",
		breaks = "a tallest under the shortest is kept",
	},
	{
		file = "src/TabFit.luau",
		from = "const contentWidth = math.max(0, bodyWidth - railWidth - gap)",
		to = "const contentWidth = bodyWidth - railWidth - gap",
		breaks = "page width clamped to zero",
	},
	{
		file = "src/TabFit.luau",
		from = "railX = math.max(0, bodyWidth - railWidth)",
		to = "railX = bodyWidth - railWidth",
		breaks = "rtl rail clamped to zero in a narrow body",
	},
	{
		file = "src/TabFit.luau",
		from = "contentX = railWidth + gap",
		to = "contentX = railWidth",
		breaks = "ltr page after the rail and gap",
	},
}

return MUTANTS
