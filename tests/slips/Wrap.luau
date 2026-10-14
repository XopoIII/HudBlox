--!strict
--- The slips of src/Wrap.luau: each a small error in when a top row's wrap is reported, and the
--- rule it breaks.
const MUTANTS = {
	{
		file = "src/Wrap.luau",
		from = "return height > Measure.HEIGHT + 1",
		to = "return height >= Measure.HEIGHT + 1",
		breaks = "a pixel of rounding is not a wrap",
	},
	{
		file = "src/Wrap.luau",
		from = "Wrap.SETTLE_S = 1\n",
		to = "Wrap.SETTLE_S = 0\n",
		breaks = "the settle period is one second",
	},
	{
		file = "src/Wrap.luau",
		from = "after(Wrap.SETTLE_S, function()",
		to = "after(0, function()",
		breaks = "the check waits the settle period",
	},
	{
		file = "src/Wrap.luau",
		from = "\t\tif now == wrapped then\n\t\t\treturn\n\t\tend\n",
		to = "",
		breaks = "a row that grows while wrapped is still one wrap, checked once",
	},
	{
		file = "src/Wrap.luau",
		from = "\t\tchanges += 1\n",
		to = "",
		breaks = "a check left from a wrap that ended does not report a later one",
	},
	{
		file = "src/Wrap.luau",
		from = "if stopped or changes ~= mine then",
		to = "if stopped then",
		breaks = "a wrap that ends before the settle period says nothing",
	},
	{
		file = "src/Wrap.luau",
		from = "if stopped or changes ~= mine then",
		to = "if changes ~= mine then",
		breaks = "a stopped watch reports nothing for a check already waiting",
	},
	{
		file = "src/Wrap.luau",
		from = "if not now or reported or stopped then",
		to = "if not now or stopped then",
		breaks = "after its report a row waits for nothing",
	},
	{
		file = "src/Wrap.luau",
		from = "if not now or reported or stopped then",
		to = "if not now or reported then",
		breaks = "a stopped watch waits for nothing",
	},
	{
		file = "src/Wrap.luau",
		from = "\t\t\treported = true\n",
		to = "",
		breaks = "a row reports once",
	},
	{
		file = "src/Wrap.luau",
		from = "\t\tstopped = true\n",
		to = "",
		breaks = "a stopped watch reports nothing",
	},
}

return MUTANTS
