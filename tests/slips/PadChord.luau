--!strict
--- The chords' slips: each a small error in which key a held bumper means, and the rule it breaks.
const MUTANTS = {
	{
		file = "src/PadChord.luau",
		from = "if shape.bumper == bumper and shape.live then",
		to = "if shape.live then",
		breaks = "a held bumper's key is its own chord's",
	},
	{
		file = "src/PadChord.luau",
		from = "if shape.bumper == bumper and shape.live then",
		to = "if shape.bumper == bumper then",
		breaks = "a chord not live means nothing",
	},
	{
		file = "src/PadChord.luau",
		from = "if name == key then",
		to = "if true then",
		breaks = "a key the chord has not means nothing",
	},
	{
		file = "src/PadChord.luau",
		from = "live = not chord.live or chord.live() })",
		to = "live = true })",
		breaks = "find: a chord not live means nothing",
	},
	{
		file = "src/PadChord.luau",
		from = "return if i and j then chords[i].keys[j] else nil",
		to = "return chords[1].keys[1]",
		breaks = "find: the entry is the held bumper's key's",
	},
}

return MUTANTS
