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

-- The chords as a game binds them, keys by Roblox's own Enum (LuneBlox 0.11.0 gives the specs the
-- global): `find` answers the entry a held bumper's key presses.
const function chords(rightLive: boolean): { PadChord.Chord }
	const function key(code: Enum.KeyCode): PadChord.Key
		return {
			key = code,
			target = function(): GuiObject?
				return nil
			end,
			press = function() end,
		}
	end
	return {
		{ bumper = Enum.KeyCode.ButtonL1, keys = { key(Enum.KeyCode.ButtonA), key(Enum.KeyCode.DPadDown) } },
		{
			bumper = Enum.KeyCode.ButtonR1,
			keys = { key(Enum.KeyCode.ButtonA) },
			live = function(): boolean
				return rightLive
			end,
		},
	}
end

Spec.test("find answers the entry of a held bumper's key, by Roblox's own key codes", function()
	const bound = chords(true)
	Spec.equal(PadChord.find(bound, Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonA), bound[1].keys[1], "the left one's A")
	Spec.equal(PadChord.find(bound, Enum.KeyCode.ButtonL1, Enum.KeyCode.DPadDown), bound[1].keys[2], "its down")
	Spec.equal(PadChord.find(bound, Enum.KeyCode.ButtonR1, Enum.KeyCode.ButtonA), bound[2].keys[1], "the right one's A")
end)

Spec.test("find answers nothing with no bumper held, for a key not bound, or a chord not live", function()
	Spec.equal(PadChord.find(chords(true), nil, Enum.KeyCode.ButtonA), nil, "nothing held")
	Spec.equal(PadChord.find(chords(true), Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonX), nil, "a key not bound")
	Spec.equal(PadChord.find(chords(false), Enum.KeyCode.ButtonR1, Enum.KeyCode.ButtonA), nil, "not live")
end)

return nil
