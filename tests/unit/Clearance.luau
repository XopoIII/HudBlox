--!strict
--- The bottom corners: a read-out clears the highest visible touch control.
const Clearance = require("@hudblox/Clearance")
const Spec = require("../Spec")

-- A phone on its side, 392 tall: the jump button's top at 250, the thumbstick's at 262.
const BOTTOM = 392
const JUMP: Clearance.Control = { top = 250, visible = true }
const STICK: Clearance.Control = { top = 262, visible = true }
const MARGIN = 12

Spec.test("the clearance is measured to the highest visible control", function()
	Spec.equal(Clearance.height(BOTTOM, { STICK, JUMP }), 142, "jump is higher")
	-- Whatever order the engine lists them in.
	Spec.equal(Clearance.height(BOTTOM, { JUMP, STICK }), 142, "jump first")
	Spec.equal(Clearance.height(BOTTOM, { STICK }), 130, "the stick alone")
end)

Spec.test("a hidden control lifts nothing", function()
	const hiddenJump: Clearance.Control = { top = 250, visible = false }
	Spec.equal(Clearance.height(BOTTOM, { STICK, hiddenJump }), 130, "hidden jump")
	Spec.equal(Clearance.height(BOTTOM, { hiddenJump }), 0, "only hidden controls")
	Spec.equal(Clearance.height(BOTTOM, {}), 0, "no controls")
	-- A control reported below the frame's bottom does not make the clearance negative.
	Spec.equal(Clearance.height(BOTTOM, { { top = 400, visible = true } }), 0, "below the bottom")
end)

Spec.test("a read-out stands a margin above the highest visible control", function()
	const base = Clearance.base(MARGIN, Clearance.height(BOTTOM, { STICK, JUMP }))
	Spec.equal(base, 154, "base")
	-- Its lower edge, in device pixels, against the top of the jump button.
	Spec.equal(BOTTOM - base, 238, "lower edge")
	Spec.equal(JUMP.top - (BOTTOM - base), MARGIN, "air above the jump button")
end)

Spec.test("a read-out stands a margin above the edge where there are no controls", function()
	Spec.equal(Clearance.base(MARGIN, Clearance.height(BOTTOM, {})), 12, "base")
end)

Spec.test("a corner stack rises by a capsule and a gap each", function()
	Spec.equal(Clearance.stacked(154, 1, 36, 6), 154, "the lowest")
	Spec.equal(Clearance.stacked(154, 2, 36, 6), 196, "the second")
	Spec.equal(Clearance.stacked(154, 3, 36, 6), 238, "the third")
end)

return nil
