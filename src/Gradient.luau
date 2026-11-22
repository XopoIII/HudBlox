--!strict
--- A colour ramp across a surface: the engine's `UIGradient`, with its kind said as a word.
---
--- The three kinds are the engine's own: a straight ramp, one radiating from the centre and one
--- sweeping round it. A build without `Enum.GradientType` — the radius and the sweep arrived after
--- the straight ramp — draws the straight ramp instead of failing, so a game may ask for any kind.
---
--- The ramp multiplies the surface's own colour and transparency rather than replacing them, so a
--- dark plate produces a dark ramp: a surface meant to show the authored colours is drawn white
--- first. A sweeping ramp whose two ends differ shows a seam where the sweep meets itself; give it
--- the same colour at both ends for a closed sweep.
---
--- What this module cannot prove off Roblox: the gradient is an engine Instance, so it is
--- type-checked and looked at rather than run in the suite.
const Gradient = {}

--- The kinds a game may ask for, in the order the engine grew them.
Gradient.KINDS = { "linear", "radial", "conical" }
--- The kind a gradient wears when `Spec.kind` is left out.
Gradient.DEFAULT_KIND = "linear"

export type Kind = "linear" | "radial" | "conical"

export type Spec = {
	--- The ramp's kind. `linear` when left out, and on a build that has only this one.
	kind: Kind?,
	--- The ramp's direction in degrees: 90 runs top to bottom, the default.
	rotation: number?,
	--- The colour the ramp starts with.
	from: Color3?,
	--- The colour it ends with.
	to: Color3?,
	--- A colour halfway along, for a ramp that turns rather than fades evenly.
	mid: Color3?,
	--- The ramp's transparency along its length. Solid when left out.
	transparency: NumberSequence?,
}

export type Handle = {
	--- The engine component, for a game that wants what this kit does not offer.
	object: UIGradient,
	--- Redraws the ramp between two colours, keeping the kind, the rotation and a middle stop.
	set: (from: Color3, to: Color3) -> (),
	destroy: () -> (),
}

--- The default rotation in degrees: top to bottom, as Roblox draws a header's fade.
Gradient.ROTATION = 90

local supported: boolean? = nil

--> Whether this client knows the radial and the sweeping ramp. The straight one is always here.
function Gradient.support(): boolean
	if supported == nil then
		supported = pcall(function()
			return Enum.GradientType.Conical
		end)
	end
	return supported :: boolean
end

--> The sequence a ramp is drawn from: the start, an optional middle stop, and the end.
function Gradient.sequence(from: Color3, to: Color3, mid: Color3?): ColorSequence
	if mid == nil then
		return ColorSequence.new(from, to)
	end
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, from),
		ColorSequenceKeypoint.new(0.5, mid :: Color3),
		ColorSequenceKeypoint.new(1, to),
	})
end

--> Puts a gradient on `target`, or returns nil where even the straight ramp is missing.
function Gradient.attach(target: GuiObject, spec: Spec?): Handle?
	const probe = pcall(function()
		const test = Instance.new("UIGradient")
		test:Destroy()
	end)
	if not probe then
		return nil
	end
	const o: Spec = spec or {}
	const object = Instance.new("UIGradient")
	const kind: Kind = o.kind or "linear"
	const from = o.from or Color3.new(1, 1, 1)
	const to = o.to or from
	object.Color = Gradient.sequence(from, to, o.mid)
	object.Rotation = o.rotation or Gradient.ROTATION
	if o.transparency then
		object.Transparency = o.transparency :: NumberSequence
	end
	if kind ~= "linear" and Gradient.support() then
		const kindOf: { [Kind]: Enum.GradientType } = {
			linear = Enum.GradientType.Linear,
			radial = Enum.GradientType.Radial,
			conical = Enum.GradientType.Conical,
		}
		pcall(function()
			object.Type = kindOf[kind]
		end)
	end
	object.Parent = target
	const handle: Handle = {
		object = object,
		set = function(nextFrom: Color3, nextTo: Color3)
			object.Color = Gradient.sequence(nextFrom, nextTo, o.mid)
		end,
		destroy = function()
			object:Destroy()
		end,
	}
	return handle
end

return Gradient
