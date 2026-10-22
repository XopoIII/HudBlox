--!strict
--- Which key a held bumper's chord means.
const PadChord = require("@hudblox/PadChord")
const Spec = require("../Spec")

const function shapes(rightLive: boolean): { PadChord.Shape }
	return {
		{ bumper = "ButtonL1", keys = { "ButtonA", "DPadDown" }, live = true },
		{ bumper = "ButtonR1", keys = { "ButtonA" }, live = rightLive },
	}
end

Spec.test("a held bumper's key is its own chord's", function()
	Spec.equal({ PadChord.match(shapes(true), "ButtonL1", "ButtonA") }, { 1, 1 }, "the left one's A")
	Spec.equal({ PadChord.match(shapes(true), "ButtonR1", "ButtonA") }, { 2, 1 }, "the right one's A")
	Spec.equal({ PadChord.match(shapes(true), "ButtonL1", "DPadDown") }, { 1, 2 }, "the D-pad too")
end)

Spec.test("nothing held, a key the chord has not, or a chord not live means nothing", function()
	Spec.equal({ PadChord.match(shapes(true), nil, "ButtonA") }, { nil, nil }, "no bumper held")
	Spec.equal({ PadChord.match(shapes(true), "ButtonL1", "ButtonX") }, { nil, nil }, "a key it has not")
	Spec.equal({ PadChord.match(shapes(true), "ButtonR1", "DPadDown") }, { nil, nil }, "the other one's key")
	Spec.equal({ PadChord.match(shapes(false), "ButtonR1", "ButtonA") }, { nil, nil }, "not live")
end)

return nil
