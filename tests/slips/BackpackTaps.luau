--!strict
--- The mutants of the backpack's taps and presses and of src/HotbarCover.luau: each a small slip, and
--- the rule it breaks.
--- Every `from` must occur exactly once in its file.

const MUTANTS: { { file: string, from: string, to: string, breaks: string } } = {
	{
		file = "src/Backpack/Moves.luau",
		from = 'return if id and place.zone == "bar" then "equip" else "none"',
		to = 'return if id then "equip" else "none"',
		breaks = "a closed backpack equips from the bar only",
	},
	{
		file = "src/Backpack/Moves.luau",
		from = 'return if id and place.zone == "bar" then "equip" else "none"',
		to = 'return if place.zone == "bar" then "equip" else "none"',
		breaks = "an empty slot equips nothing",
	},
	{
		file = "src/Backpack/Moves.luau",
		from = "\tif not editing then\n\t\tMoves.clear(m)\n",
		to = "\tif not editing then\n",
		breaks = "a closed backpack lets a pick go",
	},
	{
		file = "src/Backpack/Moves.luau",
		from = "now - last.at <= Press.DOUBLE_S then",
		to = "now - last.at < Press.DOUBLE_S then",
		breaks = "a second tap at the window's end is a double tap",
	},
	{
		file = "src/Backpack/Moves.luau",
		from = "last.id == id and now",
		to = "now",
		breaks = "a double tap is two taps on one thing",
	},
	{
		file = "src/Backpack/Moves.luau",
		from = "\t\tm.picked = nil\n\t\tm.last = nil\n\t\treturn if",
		to = "\t\tm.picked = nil\n\t\treturn if",
		breaks = "a tap after a double tap starts over",
	},
	{
		file = "src/Backpack/Moves.luau",
		from = "\t\tif id and id ~= o.pinned then\n",
		to = "\t\tif id then\n",
		breaks = "the pinned thing is never picked up",
	},
	{
		file = "src/Backpack/Moves.luau",
		from = '\tif picked == id then\n\t\tm.picked = nil\n\t\treturn "unpicked"\n\tend\n',
		to = "",
		breaks = "a pick tapped again slowly is let go",
	},
	{
		file = "src/Backpack/Moves.luau",
		from = "): Outcome\n\tMoves.clear(m)\n\treturn if Order.sendAcross",
		to = "): Outcome\n\treturn if Order.sendAcross",
		breaks = "a gamepad's send lets a pick go",
	},
	{
		file = "src/Backpack/Moves.luau",
		from = "\tMoves.clear(m)\n\tif not target then\n",
		to = "\tif not target then\n",
		breaks = "a drop lets a pick go",
	},
	{
		file = "src/Backpack/Moves.luau",
		from = "m.last = if id then { id = id, at = now } else nil",
		to = "m.last = nil",
		breaks = "a tap is remembered for the next",
	},
	{
		file = "src/Backpack/Press.luau",
		from = ">= Press.DRAG_PX",
		to = "> Press.DRAG_PX",
		breaks = "six pixels exactly is a drag",
	},
	{
		file = "src/Backpack/Press.luau",
		from = 'if pointer == "mouse" or zone == "bar" then',
		to = 'if pointer == "mouse" then',
		breaks = "a finger on the bar drags like a mouse",
	},
	{
		file = "src/Backpack/Press.luau",
		from = 'if pointer == "mouse" or zone == "bar" then',
		to = 'if zone == "bar" then',
		breaks = "a mouse in the inventory drags, it never scrolls",
	},
	{
		file = "src/Backpack/Press.luau",
		from = "\tif held >= Press.HOLD_S then\n",
		to = "\tif held > Press.HOLD_S then\n",
		breaks = "a hold of exactly the time picks up",
	},
	{
		file = "src/Backpack/Press.luau",
		from = '\tif held >= Press.HOLD_S then\n\t\treturn "drag"\n\tend\n',
		to = "",
		breaks = "a finger held still picks the slot up",
	},
	{
		file = "src/Backpack/Press.luau",
		from = "math.abs(dx) > math.abs(dy)",
		to = "math.abs(dx) >= math.abs(dy)",
		breaks = "a tie between sideways and down is a scroll",
	},
	{
		file = "src/Backpack/Press.luau",
		from = "math.abs(dx) > math.abs(dy)",
		to = "dx > dy",
		breaks = "sideways and down are measured both ways",
	},
	{
		file = "src/Backpack/Press.luau",
		from = "math.sqrt(dx * dx + dy * dy)",
		to = "(math.abs(dx) + math.abs(dy))",
		breaks = "the distance is the straight one",
	},
	{
		file = "src/Backpack/Press.luau",
		from = "Press.DRAG_PX = 6\n",
		to = "Press.DRAG_PX = 5\n",
		breaks = "the drag distance is six pixels",
	},
	{
		file = "src/Backpack/Press.luau",
		from = "Press.HOLD_S = 0.2\n",
		to = "Press.HOLD_S = 0.3\n",
		breaks = "the hold is a fifth of a second",
	},
	{
		file = "src/Backpack/Press.luau",
		from = "Press.DOUBLE_S = 0.5\n",
		to = "Press.DOUBLE_S = 0.4\n",
		breaks = "the double-tap window is half a second",
	},
	{
		file = "src/HotbarCover.luau",
		from = "reasons[reason] = if hide then true else nil",
		to = "reasons[reason] = true",
		breaks = "a reason that stops asking is gone",
	},
	{
		file = "src/HotbarCover.luau",
		from = "\tif want == hidden then\n\t\treturn\n\tend\n",
		to = "",
		breaks = "a listener hears a change, not every asking",
	},
	{
		file = "src/HotbarCover.luau",
		from = "const want = next(reasons) ~= nil",
		to = "const want = hide",
		breaks = "the hotbar comes back when the last reason goes",
	},
	{
		file = "src/HotbarCover.luau",
		from = "\thidden = want\n",
		to = "",
		breaks = "the state follows the reasons",
	},
	{
		file = "src/HotbarCover.luau",
		from = "\t\tlisteners[listener] = nil\n",
		to = "",
		breaks = "a stopped listener hears nothing more",
	},
	{
		file = "src/HotbarCover.luau",
		from = "\tlisteners[listener] = true\n",
		to = "\tlisteners[changed] = true\n",
		breaks = "the same function listening twice is two listeners",
	},
}

return MUTANTS
