--!strict
--- The world's prompts held off while a gamepad owns a panel, and the game's own switch given back.
const PromptHold = require("@hudblox/PromptHold")
const Spec = require("../Spec")

Spec.test("with no pad, a panel opening or closing leaves the switch as the game set it", function()
	const hold = PromptHold.new()
	-- the game has its prompts off: nothing is written either way
	Spec.equal(PromptHold.step(hold, false, false), nil, "off, a panel opens")
	Spec.equal(PromptHold.step(hold, false, false), nil, "off, it closes")
	-- nor when they are on
	Spec.equal(PromptHold.step(hold, false, true), nil, "on")
	Spec.equal(hold.held, false, "never held")
end)

Spec.test("a hold puts the prompts off once, and gives back what the game had", function()
	const hold = PromptHold.new()
	Spec.equal(PromptHold.step(hold, true, true), false, "held: off")
	Spec.equal(hold.held, true, "held")
	-- held again, as another panel opens: nothing more to write
	Spec.equal(PromptHold.step(hold, true, false), nil, "held again")
	Spec.equal(PromptHold.step(hold, false, false), true, "let go: on, as it was")
	Spec.equal(hold.held, false, "let go")
	Spec.equal(PromptHold.step(hold, false, true), nil, "let go again")
end)

Spec.test("a game that had its prompts off gets them back off", function()
	const hold = PromptHold.new()
	Spec.equal(PromptHold.step(hold, true, false), false, "held")
	Spec.equal(PromptHold.step(hold, false, false), false, "let go: off, as it was")
	-- and a hold after it remembers afresh
	Spec.equal(PromptHold.step(hold, true, true), false, "held again")
	Spec.equal(PromptHold.step(hold, false, false), true, "let go: on this time")
end)

return nil
