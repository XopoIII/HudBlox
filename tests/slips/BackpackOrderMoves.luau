--!strict
--- The mutants of src/Backpack/Order.luau, second half: each a small slip, and the rule it breaks.
--- Every `from` must occur exactly once in its file.

const MUTANTS: { { file: string, from: string, to: string, breaks: string } } = {
	{
		file = "src/Backpack/Order.luau",
		from = '(from.zone == "bar" and from.index == to)',
		to = "false",
		breaks = "a move to the thing's own slot is no move",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\t\t\to.rank[other] = o.rank[id]\n",
		to = "",
		breaks = "what a thing swaps with takes its place in the inventory",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\t\to.rank[id] = nil\n\t\to.bar[to] = id\n",
		to = "\t\to.bar[to] = id\n",
		breaks = "a thing on the bar has no rank",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\t\tif other == nil or other == id then\n",
		to = "\t\tif other == nil then\n",
		breaks = "a move to the thing's own place is no move",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\t\to.rank[id], o.rank[other] = o.rank[other], o.rank[id]\n",
		to = "",
		breaks = "two things in the inventory swap ranks",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\t\to.rank[id] = o.rank[other]\n\t\to.rank[other] = nil\n",
		to = "\t\to.rank[other] = nil\n",
		breaks = "a thing moved off the bar takes the rank of what it swaps with",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\t\to.bar[from.index] = nil\n\t\tinsertRanked(o, id, frontRank(o))\n",
		to = "\t\to.bar[from.index] = nil\n\t\tinsertRanked(o, id, backRank(o))\n",
		breaks = "a thing dropped on the inventory goes to its front",
	},
	{
		file = "src/Backpack/Order.luau",
		from = 'return Order.move(o, id, { zone = "grid", index = 0 })',
		to = 'return Order.move(o, id, { zone = "grid", index = 1 })',
		breaks = "a thing sent off the bar goes to the front, swapping with nothing",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "index = freeBar(o) or o.size }",
		to = "index = o.size }",
		breaks = "a thing sent to the bar takes its first free slot",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\tif at == 0 and by < 0 then\n\t\tat = 1\n\tend\n",
		to = "",
		breaks = "with nothing in hand, a step back is the last slot",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "return filled[(at - 1 + by) % #filled + 1]",
		to = "return filled[at + by]",
		breaks = "a step wraps round the bar",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\t\t\tif id == current then\n\t\t\t\tat = #filled\n\t\t\tend\n",
		to = "",
		breaks = "a step starts from the thing in hand",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\tsize = math.max(size, 1)\n\tfor",
		to = "\tfor",
		breaks = "a bar has a slot at least",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\t\tsize = math.max(size, 1),\n",
		to = "\t\tsize = size,\n",
		breaks = "a new bar has a slot at least",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\tfor index = o.size, size + 1, -1 do\n",
		to = "\tfor index = size + 1, o.size do\n",
		breaks = "what leaves a shrinking bar keeps its slot order",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\t\t\to.bar[index] = nil\n",
		to = "",
		breaks = "what leaves a shrinking bar leaves it",
	},
	{
		file = "src/Backpack/Order.luau",
		from = "\t\ttable.remove(o.grid, from.index)\n\t\to.memory[id]",
		to = "\t\to.memory[id]",
		breaks = "a thing that is gone leaves the inventory",
	},
}

return MUTANTS
