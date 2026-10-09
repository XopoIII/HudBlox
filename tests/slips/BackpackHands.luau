--!strict
--- The mutants of src/Backpack/Hands.luau: each a small slip, and the rule it breaks.
--- Every `from` must occur exactly once in its file.

const FILE = "src/Backpack/Hands.luau"
const GATE = "if not (press.open and press.pad and press.holds) then"
const SLOT = "if not press.slot or id == nil then"
const WHICH = 'return if id == press.held then "stow" else "equip"'
const ACTS = 'return outcome == "equip" or outcome == "stow"'

const MUTANTS: { { file: string, from: string, to: string, breaks: string } } = {
	{
		file = FILE,
		from = GATE,
		to = "if not (press.pad and press.holds) then",
		breaks = "with the inventory closed the button is the game's",
	},
	{
		file = FILE,
		from = GATE,
		to = "if not (press.open and press.holds) then",
		breaks = "off a gamepad the button is not the backpack's",
	},
	{
		file = FILE,
		from = GATE,
		to = "if not (press.open and press.pad) then",
		breaks = "under another panel the button is that panel's",
	},
	{
		file = FILE,
		from = GATE,
		to = "if not (press.open or press.pad or press.holds) then",
		breaks = "all three are needed, not any one",
	},
	{
		file = FILE,
		from = SLOT,
		to = "if id == nil then",
		breaks = "off the slots nothing is equipped",
	},
	{
		file = FILE,
		from = SLOT,
		to = "if not press.slot then",
		breaks = "an empty slot with empty hands is not the thing in the hands",
	},
	{
		file = FILE,
		from = SLOT .. '\n\t\treturn "none"',
		to = SLOT .. '\n\t\treturn "pass"',
		breaks = "an empty slot keeps the button from the game",
	},
	{
		file = FILE,
		from = WHICH,
		to = 'return "equip"',
		breaks = "the thing in the hands is put away",
	},
	{
		file = FILE,
		from = WHICH,
		to = 'return if id == press.held then "equip" else "stow"',
		breaks = "a thing not in the hands is equipped",
	},
	{
		file = FILE,
		from = WHICH,
		to = 'return if id == press.held then "none" else "equip"',
		breaks = "the bar's press puts the held thing away, and so does the button",
	},
	{
		file = FILE,
		from = 'return outcome ~= "pass"',
		to = "return true",
		breaks = "a passed press is left to the game",
	},
	{
		file = FILE,
		from = 'return outcome ~= "pass"',
		to = 'return outcome == "equip" or outcome == "stow"',
		breaks = "a press that does nothing is sunk too",
	},
	{
		file = FILE,
		from = ACTS,
		to = 'return outcome == "equip"',
		breaks = "a stow closes the inventory",
	},
	{
		file = FILE,
		from = ACTS,
		to = 'return outcome == "stow"',
		breaks = "an equip closes the inventory",
	},
	{
		file = FILE,
		from = ACTS,
		to = 'return outcome ~= "pass"',
		breaks = "a press that does nothing leaves the inventory open",
	},
	{
		file = FILE,
		from = "\tif option == false then\n\t\treturn nil\n\tend\n",
		to = "",
		breaks = "false binds no button",
	},
	{
		file = FILE,
		from = "return if option == nil then default else option",
		to = "return default",
		breaks = "the game's own button is the one bound",
	},
	{
		file = FILE,
		from = "return if option == nil then default else option",
		to = "return option",
		breaks = "the kit's button stands when the game says nothing",
	},
}

return MUTANTS
