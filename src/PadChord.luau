--!strict
--- A bumper held as a chord: while the game's chosen bumper is down, the face buttons and the
--- D-pad press what the game names (a dialog, an upgrade), from anywhere, and each control a key
--- presses wears that key's picture; while it is up, the bumper's own picture stands where the
--- game says, so a player sees there is a chord to hold.
---
--- While a chord is held the world's prompts are off: a prompt hears its gamepad key (X) by
--- itself, not through ContextActionService, and a chord's X once pressed a prompt too. A panel
--- that holds the pad (`Focus`) takes every key from the chords, and lets go of one held.
---
--- Which key a held chord means is `PadChord.find`, plain data in, so the rule is a spec.
const Bindable = require("./Bindable")
const Focus = require("./Focus")
const PadGlyph = require("./PadGlyph")
const PadInput = require("./PadInput")

const PadChord = {}

--- The action bound, and its priority: under the kit's B for a panel (`Focus.PRIORITY`), over a
--- game's own binding of the same keys at the default.
PadChord.ACTION = "PadChord"
PadChord.PRIORITY = Focus.PRIORITY - 50
--- The size of a key's picture on the control it presses, in pixels, and the pictures' name.
PadChord.CAP = 22
PadChord.NAME = "PadChord"

export type Key = {
	key: Enum.KeyCode,
	--- The control the key presses, as it is drawn now, which wears its picture; nil for none.
	target: () -> GuiObject?,
	press: () -> (),
}

export type Chord = {
	--- The bumper held: `ButtonL1` or `ButtonR1`.
	bumper: Enum.KeyCode,
	keys: { Key },
	--- Whether the chord means anything now; always when left out.
	live: (() -> boolean)?,
	--- Where the bumper's own picture stands while it is up; none when left out.
	hint: (() -> GuiObject?)?,
	--- A tap of the bumper the game takes first, as a bubble caught: true when it took it.
	tap: (() -> boolean)?,
}

export type Handle = {
	--- Shows the pictures as things stand, and lets go of a chord a panel opened over. For each
	--- frame, or as often as the controls may move.
	step: () -> (),
	--- The bumper held, nil for none.
	held: () -> Enum.KeyCode?,
}

--- The chords as plain data, keys by their names: what `match` reads.
export type Shape = { bumper: string, keys: { string }, live: boolean }

--> Which chord and which of its keys `key` means with `bumper` held (nil for none), both by place,
--> nil for nothing: a held bumper's own chord, only while it is `live`, and a key it has.
function PadChord.match(shapes: { Shape }, bumper: string?, key: string): (number?, number?)
	for i, shape in shapes do
		if shape.bumper == bumper and shape.live then
			for j, name in shape.keys do
				if name == key then
					return i, j
				end
			end
		end
	end
	return nil, nil
end

--> The key entry `key` presses in the chord of `bumper` among `chords`, nil for none (`match`).
function PadChord.find(chords: { Chord }, bumper: Enum.KeyCode?, key: Enum.KeyCode): Key?
	const shapes: { Shape } = {}
	for _, chord in chords do
		const names: { string } = {}
		for _, entry in chord.keys do
			table.insert(names, entry.key.Name)
		end
		table.insert(shapes, { bumper = chord.bumper.Name, keys = names, live = not chord.live or chord.live() })
	end
	const i, j = PadChord.match(shapes, if bumper then bumper.Name else nil, key.Name)
	return if i and j then chords[i].keys[j] else nil
end

--> Binds `chords`.
function PadChord.bind(chords: { Chord }): Handle
	local held: Enum.KeyCode? = nil
	local prompts: boolean? = nil
	const made: { [string]: Frame } = {}

	const function put(id: string, target: GuiObject?, key: Enum.KeyCode, corner: Vector2)
		local picture = made[id]
		if picture and picture.Parent ~= target then
			picture:Destroy()
			made[id] = nil
			picture = nil
		end
		if not target then
			return
		end
		if not picture then
			const fresh = PadGlyph.cap(target, key, PadChord.CAP)
			fresh.Name = PadChord.NAME
			fresh.AnchorPoint = Vector2.new(0.5, 0.5)
			fresh.Position = UDim2.fromScale(corner.X, corner.Y)
			made[id] = fresh
		end
	end

	const function show()
		const pad = PadInput.active() and not Focus.open()
		for i, chord in chords do
			const live = pad and (not chord.live or chord.live())
			const hint = if live and held == nil and chord.hint then chord.hint() else nil
			put(`{i}:hint`, hint, chord.bumper, Vector2.new(0, 1))
			for _, entry in chord.keys do
				const on = live and held == chord.bumper
				put(`{i}:{entry.key.Name}`, if on then entry.target() else nil, entry.key, Vector2.new(1, 1))
			end
		end
	end

	const function hold(bumper: Enum.KeyCode?)
		held = bumper
		const service = game:GetService("ProximityPromptService")
		if bumper and prompts == nil then
			prompts = service.Enabled
			service.Enabled = false
		elseif not bumper and prompts ~= nil then
			service.Enabled = prompts
			prompts = nil
		end
		show()
	end

	const function chordOf(bumper: Enum.KeyCode): Chord?
		for _, chord in chords do
			if chord.bumper == bumper then
				return chord
			end
		end
		return nil
	end

	const function act(_: string, state: Enum.UserInputState, input: InputObject): Enum.ContextActionResult
		if Focus.open() then
			return Enum.ContextActionResult.Pass
		end
		const key = input.KeyCode
		const chord = chordOf(key)
		if chord then
			if state == Enum.UserInputState.Begin then
				if chord.tap and chord.tap() then
					return Enum.ContextActionResult.Sink
				elseif chord.live and not chord.live() then
					return Enum.ContextActionResult.Pass
				end
				hold(key)
			elseif state == Enum.UserInputState.End and held == key then
				hold(nil)
			end
			return Enum.ContextActionResult.Sink
		end
		if held == nil or state ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end
		const entry = PadChord.find(chords, held, key)
		if entry then
			entry.press()
		end
		-- a chord held is the face buttons' and the D-pad's: nothing else hears them meanwhile
		return Enum.ContextActionResult.Sink
	end

	if Bindable.here() then
		const keys: { Enum.KeyCode } = {}
		const function add(code: Enum.KeyCode)
			if not table.find(keys, code) then
				table.insert(keys, code)
			end
		end
		for _, chord in chords do
			add(chord.bumper)
			for _, entry in chord.keys do
				add(entry.key)
			end
		end
		game:GetService("ContextActionService")
			:BindActionAtPriority(PadChord.ACTION, act, false, PadChord.PRIORITY, table.unpack(keys))
	end

	return {
		step = function()
			if held and Focus.open() then
				hold(nil)
			else
				show()
			end
		end,
		held = function(): Enum.KeyCode?
			return held
		end,
	}
end

return PadChord
