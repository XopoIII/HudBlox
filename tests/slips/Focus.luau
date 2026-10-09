--!strict
--- The mutants of src/Pick.luau and src/Stack.luau: each a small slip, and the rule it breaks.
--- Every `from` must occur exactly once in its file.

const MUTANTS: { { file: string, from: string, to: string, breaks: string } } = {
	{
		file = "src/Pick.luau",
		from = "return target.shown and target.selectable",
		to = "return target.shown",
		breaks = "an unselectable control is never picked",
	},
	{
		file = "src/Pick.luau",
		from = "return target.shown and target.selectable",
		to = "return target.selectable",
		breaks = "a hidden control is never picked",
	},
	{
		file = "src/Pick.luau",
		from = "\tif a.order ~= b.order then\n\t\treturn a.order < b.order\n\tend\n",
		to = "",
		breaks = "a lower SelectionOrder comes before position",
	},
	{
		file = "src/Pick.luau",
		from = "return a.order < b.order",
		to = "return a.order > b.order",
		breaks = "the lower order leads, not the higher",
	},
	{
		file = "src/Pick.luau",
		from = "if math.abs(a.y - b.y) > Pick.ROW then",
		to = "if math.abs(a.y - b.y) >= Pick.ROW then",
		breaks = "centres exactly a row's height apart are one row",
	},
	{
		file = "src/Pick.luau",
		from = "if math.abs(a.y - b.y) > Pick.ROW then",
		to = "if a.y - b.y > Pick.ROW then",
		breaks = "a control a row higher leads",
	},
	{
		file = "src/Pick.luau",
		from = "\t\treturn a.y < b.y\n",
		to = "\t\treturn a.y > b.y\n",
		breaks = "the top row leads",
	},
	{
		file = "src/Pick.luau",
		from = "return if rtl then a.x > b.x else a.x < b.x",
		to = "return a.x < b.x",
		breaks = "a right-to-left locale starts at the right",
	},
	{
		file = "src/Pick.luau",
		from = "return if rtl then a.x > b.x else a.x < b.x",
		to = "return a.x > b.x",
		breaks = "a left-to-right locale starts at the left",
	},
	{
		file = "src/Pick.luau",
		from = "Pick.ROW = 4",
		to = "Pick.ROW = 5",
		breaks = "a row is four pixels of centres",
	},
	{
		file = "src/Pick.luau",
		from = "if usable(target) and (best == nil or before(target, targets[best], rtl)) then",
		to = "if best == nil or before(target, targets[best], rtl) then",
		breaks = "where focus starts is a control that can be chosen",
	},
	{
		file = "src/Pick.luau",
		from = "const gap = (target.x - x) ^ 2 + (target.y - y) ^ 2",
		to = "const gap = (target.x - x) ^ 2",
		breaks = "the nearest is measured both ways",
	},
	{
		file = "src/Pick.luau",
		from = "if best == nil or gap < bestGap or (gap == bestGap and before(target, targets[best], rtl)) then",
		to = "if best == nil or gap < bestGap then",
		breaks = "an exact tie is broken as the start would be",
	},
	{
		file = "src/Pick.luau",
		from = "if best == nil or gap < bestGap or (gap == bestGap and before(target, targets[best], rtl)) then",
		to = "if best == nil or (gap == bestGap and before(target, targets[best], rtl)) then",
		breaks = "the closer control wins",
	},
	{
		file = "src/Pick.luau",
		from = "\t\tif usable(target) then\n",
		to = "\t\tif true then\n",
		breaks = "a nearer control that cannot be chosen is skipped",
	},
	{
		file = "src/Stack.luau",
		from = "\t\tconst old = table.remove(stack.entries, index)\n",
		to = "\t\tconst old = stack.entries[index]\n",
		breaks = "a name stands once",
	},
	{
		file = "src/Stack.luau",
		from = "\treturn replaced\n",
		to = "\treturn nil\n",
		breaks = "a push hands back what the name stood with before",
	},
	{
		file = "src/Stack.luau",
		from = "replaced = if old then old.value else nil",
		to = "replaced = value",
		breaks = "a push hands back the old value, not the new one",
	},
	{
		file = "src/Stack.luau",
		from = "table.insert(stack.entries, { name = name, value = value })",
		to = "table.insert(stack.entries, 1, { name = name, value = value })",
		breaks = "the newest scope is on top",
	},
	{
		file = "src/Stack.luau",
		from = "\tif not index then\n\t\treturn nil\n\tend\n",
		to = "\tif not index then\n\t\treturn (table.remove(stack.entries) :: any).value\n\tend\n",
		breaks = "popping a name that is not there changes nothing",
	},
	{
		file = "src/Stack.luau",
		from = "const entry = table.remove(stack.entries, index)",
		to = "const entry = table.remove(stack.entries)",
		breaks = "a scope is popped from wherever it stands",
	},
	{
		file = "src/Stack.luau",
		from = "return stack.entries[#stack.entries]",
		to = "return stack.entries[1]",
		breaks = "the top is the newest",
	},
	{
		file = "src/Stack.luau",
		from = "\t\tif entry.name == name then\n",
		to = "\t\tif true then\n",
		breaks = "a scope is found by its name",
	},
}

return MUTANTS
