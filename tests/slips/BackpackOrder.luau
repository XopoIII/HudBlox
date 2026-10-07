--!strict
--- The mutants of src/Backpack/Order.luau, first half: each a small slip, and the rule it breaks.
--- Every `from` must occur exactly once in its file.

const MUTANTS: { { file: string, from: string, to: string, breaks: string } } = {
	{
		file = "src/Backpack/Order.luau",
		from = "return if o.pinned then 2 else 1",
		to = "return 2",
		breaks = "with nothing pinned, slot 1 is a slot like the rest",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "return if o.pinned then 2 else 1",
		to = "return 1",
		breaks = "slot 1 is kept for the pinned thing",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\t\tif o.bar[index] == nil then\n",
		to = "\t\tif o.bar[index] ~= nil then\n",
		breaks = "the bar fills its free slots",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\t\tif o.rank[other] > rank then\n",
		to = "\t\tif o.rank[other] < rank then\n",
		breaks = "the inventory is kept in rank order",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "return if first then o.rank[first] - 1 else 0",
		to = "return if first then o.rank[first] + 1 else 0",
		breaks = "the front is before the first",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "return if last then o.rank[last] + 1 else 0",
		to = "return if last then o.rank[last] - 1 else 0",
		breaks = "the end is after the last",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\t\tif seq and seq < bestSeq then\n",
		to = "\t\tif seq and seq > bestSeq then\n",
		breaks = "the thing longest on the bar steps down",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\to.seq += 1\n",
		to = "",
		breaks = "each arrival is counted",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\tif Order.where(o, id) then\n\t\treturn false\n\tend\n",
		to = "",
		breaks = "a thing added twice is placed once",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\t\tif squatter then\n\t\t\tinsertRanked(o, squatter, frontRank(o))\n\t\tend\n",
		to = "",
		breaks = "what stood in slot 1 steps down for the pinned thing",
	},
	{
		file = "src/Backpack/Order.luau",
		from = " and mem.index <= o.size and o.bar[mem.index] == nil then",
		to = " and mem.index <= o.size then",
		breaks = "a remembered slot taken meanwhile is not taken back",
	},
	{
		file = "src/Backpack/Order.luau",
		from = " and mem.index <= o.size and o.bar[mem.index] == nil then",
		to = " and o.bar[mem.index] == nil then",
		breaks = "a remembered slot off a shrunk bar is not taken back",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\t\tinsertRanked(o, id, mem.rank)\n",
		to = "\t\tinsertRanked(o, id, backRank(o))\n",
		breaks = "a thing goes back to its place in the inventory",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "const oldest = if fresh then oldestOnBar(o) else nil",
		to = "const oldest = oldestOnBar(o)",
		breaks = "only a fresh thing pushes another off the bar",
	},
	{
		file = "src/Backpack/Order.luau",
		from = '\t\to.memory[id] = { zone = "bar", index = from.index }\n',
		to = "",
		breaks = "a thing goes back to its slot on the bar",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\tif id == o.pinned or not from then\n",
		to = "\tif not from then\n",
		breaks = "the pinned thing never moves",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\t\tif to < lowest(o) or to > o.size or",
		to = "\t\tif to > o.size or",
		breaks = "nothing moves into the pinned slot",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "or to > o.size or (from.zone",
		to = "or (from.zone",
		breaks = "nothing moves past the bar's end",
	},
}

return MUTANTS
