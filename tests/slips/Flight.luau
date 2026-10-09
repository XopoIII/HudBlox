--!strict
--- The flight's slips: each a small error in how many icons fly, when and where, or in the list of
--- flights and the pools of icons, and the rule it breaks.
const MUTANTS = {
	{
		file = "src/FlightPath.luau",
		from = "\tif wanted ~= wanted then\n\t\treturn 0\n\tend\n",
		to = "",
		breaks = "nothing flies for what is not a number",
	},
	{
		file = "src/FlightPath.luau",
		from = "math.clamp(math.floor(wanted),",
		to = "math.clamp(math.ceil(wanted),",
		breaks = "a fraction counts as the whole below it",
	},
	{
		file = "src/FlightPath.luau",
		from = "(wanted), 0, FlightPath.MOST)",
		to = "(wanted), 1, FlightPath.MOST)",
		breaks = "nothing flies for nothing",
	},
	{
		file = "src/FlightPath.luau",
		from = "return (index - 1) * FlightPath.STAGGER",
		to = "return index * FlightPath.STAGGER",
		breaks = "the first icon leaves at once",
	},
	{
		file = "src/FlightPath.luau",
		from = "return FlightPath.leaves(count) + FlightPath.OUT + FlightPath.FLY",
		to = "return FlightPath.leaves(count) + FlightPath.FLY",
		breaks = "a send lasts through the step out too",
	},
	{
		file = "src/FlightPath.luau",
		from = "\tif count < 1 then\n\t\treturn 0\n\tend\n\treturn FlightPath.leaves",
		to = "\treturn FlightPath.leaves",
		breaks = "a send of nothing lasts no time",
	},
	{
		file = "src/FlightPath.luau",
		from = " * 2 * math.pi - math.pi / 2",
		to = " * 2 * math.pi",
		breaks = "the first icon steps straight up",
	},
	{
		file = "src/FlightPath.luau",
		from = "(index - 1) / math.max(count, 1) * 2",
		to = "index / math.max(count, 1) * 2",
		breaks = "the ring starts with the first icon",
	},
	{
		file = "src/FlightPath.luau",
		from = "\tif t < 0 then\n",
		to = "\tif t <= 0 then\n",
		breaks = "an icon has left the moment its time comes",
	},
	{
		file = "src/FlightPath.luau",
		from = "const eased = 1 - (1 - share) * (1 - share)",
		to = "const eased = share",
		breaks = "an icon steps out fast and slows",
	},
	{
		file = "src/FlightPath.luau",
		from = "\tif t < FlightPath.OUT then\n",
		to = "\tif t <= FlightPath.OUT then\n",
		breaks = "the flight starts the moment the step out ends",
	},
	{
		file = "src/FlightPath.luau",
		from = "\tif share >= 1 then\n",
		to = "\tif share > 1 then\n",
		breaks = "an icon is done the moment the flight's time is up",
	},
	{
		file = "src/FlightPath.luau",
		from = "const eased = share * share",
		to = "const eased = share",
		breaks = "an icon flies slow, then quick",
	},
	{
		file = "src/FlightPath.luau",
		from = "const startX, startY = fromX + ringX, fromY + ringY",
		to = "const startX, startY = fromX, fromY",
		breaks = "the flight starts from the icon's place on the ring",
	},
	{
		file = "src/FlightPath.luau",
		from = "1 + (FlightPath.LANDS_AT - 1) * share, FLY",
		to = "1, FLY",
		breaks = "an icon shrinks as it flies",
	},
	{
		file = "src/FlightPath.luau",
		from = "return toX, toY, FlightPath.LANDS_AT, DONE",
		to = "return toX, toY, 1, DONE",
		breaks = "an icon lands at its landing size",
	},
	{
		file = "src/FlightBook.luau",
		from = "\t\tif not spent(item) then\n\t\t\tstep(item)\n\t\tend\n",
		to = "\t\tstep(item)\n",
		breaks = "an item spent by another before its turn is not stepped",
	},
	{
		file = "src/FlightBook.luau",
		from = "\t\t\tlist[last] = nil\n",
		to = "\t\t\tlist[last] = nil\n\t\t\tat += 1\n",
		breaks = "the item swapped into a spent one's place is stepped in the same walk",
	},
	{
		file = "src/FlightBook.luau",
		from = "\t\t\tlist[at] = list[last]\n",
		to = "\t\t\tlist[at] = list[last - 1]\n",
		breaks = "a spent item's place is taken by the last item, and no unspent one is lost",
	},
	{
		file = "src/FlightBook.luau",
		from = "return table.remove(pool)",
		to = "return pool[#pool]",
		breaks = "a pooled item is handed out once",
	},
	{
		file = "src/FlightBook.luau",
		from = "return table.remove(pool)",
		to = "return table.remove(pool, 1)",
		breaks = "a pool hands back the last thing given",
	},
	{
		file = "src/FlightBook.luau",
		from = "\t\tpools[key] = { item }\n\t\treturn true\n",
		to = "\t\tpools[key] = { item }\n\t\treturn false\n",
		breaks = "the give that makes a key's pool says so",
	},
	{
		file = "src/FlightBook.luau",
		from = "\ttable.insert(pool, item)\n\treturn false\n",
		to = "\ttable.insert(pool, item)\n\treturn true\n",
		breaks = "a give into a pool that is there does not say it made one",
	},
	{
		file = "src/FlightBook.luau",
		from = "\tpools[key] = nil\n",
		to = "\tpools[key] = {}\n",
		breaks = "a dropped key leaves no entry behind",
	},
}

return MUTANTS
