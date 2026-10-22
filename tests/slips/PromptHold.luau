--!strict
--- The slips of src/PromptHold.luau: each a small error in when the world's prompts are written,
--- and the rule it breaks.
const MUTANTS = {
	{
		file = "src/PromptHold.luau",
		from = "\treturn nil\nend",
		to = "\treturn not want\nend",
		breaks = "with no hold beginning or ending, the switch is left as the game set it",
	},
	{
		file = "src/PromptHold.luau",
		from = "\t\treturn hold.before\n",
		to = "\t\treturn true\n",
		breaks = "letting go gives back what the game had, not always on",
	},
	{
		file = "src/PromptHold.luau",
		from = "hold.held, hold.before = true, now",
		to = "hold.held = true",
		breaks = "each hold remembers the switch afresh",
	},
}

return MUTANTS
