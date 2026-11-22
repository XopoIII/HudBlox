--!strict
--- A soft shadow under a surface, drawn by the engine's own `UIShadow`.
---
--- The engine scales a shadow's offset and its spread by every `UIScale` above the surface, but not
--- its blur: at scale 2 a 28-pixel blur stays 28 pixels, so the shadow reads half as soft exactly
--- where a game changes scale. This module keeps the blur the game authored and rewrites it when a
--- scale above changes, so a surface looks the same at every scale. A build without `UIShadow` draws
--- nothing and raises nothing, so a game may ask for a shadow without asking which client it is on.
---
--- What this module cannot prove off Roblox: the shadow itself is an engine Instance, so only the
--- blur arithmetic (`pixels`, `factor`) runs in the suite; the rest is type-checked and looked at.
const Shadow = {}

--- The blur a shadow wears by default, in pixels at scale 1.
Shadow.BLUR = 28
--- How far under its surface the shadow falls by default, in pixels at scale 1: across, then down.
--- Two numbers rather than a `Vector2`, so the suite can read them without Roblox's datatypes.
Shadow.OFFSET = { 0, 12 }
--- The air between surface and shadow by default, in pixels at scale 1: across, then down.
Shadow.SPREAD = { 0, 0 }
--- The shadow's transparency by default: dark enough to read on a bright surface, light enough to
--- keep the surface's edge crisp.
Shadow.TRANSPARENCY = 0.18

--- What a shadow follows on a text label: the label's shape or its letters.
export type Mode = "shape" | "text"

export type Spec = {
	--- The blur, in pixels at scale 1.
	blur: number?,
	--- How far under the surface the shadow falls, in pixels at scale 1.
	offset: Vector2?,
	--- The air between surface and shadow, in pixels at scale 1.
	spread: Vector2?,
	--- The shadow's colour. Black by default: a shadow is depth, not a game's identity.
	colour: Color3?,
	transparency: number?,
	--- A rim inside the surface rather than a drop under it.
	inset: boolean?,
	--- What a text label's shadow follows. `shape` by default.
	mode: Mode?,
	--- Draws the shadow behind a parent that would otherwise cover it.
	behindParent: boolean?,
	enabled: boolean?,
}

export type Handle = {
	--- The engine component, for a game that wants what this kit does not offer.
	object: UIShadow,
	--- Reads the scales above the surface again. The kit calls it when a scale changes and when the
	--- surface moves; a game calls it after a change the kit cannot see.
	refresh: () -> (),
	--- Off draws nothing, on draws the shadow again; the blur stays the one the game authored.
	setEnabled: (on: boolean) -> (),
	--- Forgets the surface and destroys the component. Calling it twice is harmless.
	destroy: () -> (),
}

local supported: boolean? = nil
local modeOf: { [Mode]: Enum.ApplyShadowMode } = {
	shape = Enum.ApplyShadowMode.Shape,
	text = Enum.ApplyShadowMode.Text,
}

--> The blur written for an authored `blur` under a total `scale`: a whole pixel count, never under
--> zero, so a surface the engine has shrunk to nothing keeps a shadow it can still draw.
function Shadow.pixels(blur: number, scale: number): number
	const product = blur * scale
	if product ~= product then
		return 0
	end
	return math.max(0, math.floor(product + 0.5))
end

--> Every scale multiplied together: what the engine will scale the surface's offset and spread by.
--> No scale above the surface leaves the authored numbers as they were.
function Shadow.factor(scales: { number }): number
	local factor = 1
	for _, value in scales do
		factor *= value
	end
	return factor
end

--> Every `UIScale` above `target`, its own first: the scales that will be applied to it.
function Shadow.scalesOf(target: GuiObject): { UIScale }
	const found: { UIScale } = {}
	local current: Instance? = target
	while current ~= nil do
		if current:IsA("GuiObject") then
			const child = current:FindFirstChildOfClass("UIScale")
			if child ~= nil and child:IsA("UIScale") then
				table.insert(found, child)
			end
		end
		current = current.Parent
	end
	return found
end

--> Whether this client has `UIShadow` at all. Asked once, then remembered.
function Shadow.support(): boolean
	if supported == nil then
		supported = pcall(function()
			const probe = Instance.new("UIShadow")
			probe:Destroy()
		end)
	end
	return supported :: boolean
end

--> Puts a shadow on `target`, or returns nil where the client has no `UIShadow`.
function Shadow.attach(target: GuiObject, spec: Spec?): Handle?
	if not Shadow.support() then
		return nil
	end
	const o: Spec = spec or {}
	const blur = o.blur or Shadow.BLUR
	const offset = o.offset or Vector2.new(Shadow.OFFSET[1], Shadow.OFFSET[2])
	const spread = o.spread or Vector2.new(Shadow.SPREAD[1], Shadow.SPREAD[2])
	const object = Instance.new("UIShadow")
	object.BlurRadius = UDim.new(0, Shadow.pixels(blur, 1))
	object.Offset = UDim2.fromOffset(offset.X, offset.Y)
	object.Spread = UDim2.fromOffset(spread.X, spread.Y)
	object.Color = o.colour or Color3.new(0, 0, 0)
	object.Transparency = o.transparency or Shadow.TRANSPARENCY
	object.Inset = o.inset == true
	object.Mode = if o.mode then modeOf[o.mode] else Enum.ApplyShadowMode.Shape
	object.ShowBehindParent = o.behindParent == true
	object.Enabled = o.enabled ~= false
	object.Parent = target
	const connections: { RBXScriptConnection } = {}
	local dead = false
	local function refresh()
		if dead then
			return
		end
		const scales: { number } = {}
		for _, scale in Shadow.scalesOf(target) do
			table.insert(scales, scale.Scale)
		end
		object.BlurRadius = UDim.new(0, Shadow.pixels(blur, Shadow.factor(scales)))
	end
	local function watch()
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
		if dead then
			return
		end
		for _, scale in Shadow.scalesOf(target) do
			table.insert(connections, scale:GetPropertyChangedSignal("Scale"):Connect(refresh))
		end
		-- A scale added after the shadow changes the surface's absolute size, and nothing else would
		-- tell the shadow that the scales above it changed.
		table.insert(connections, target:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh))
		table.insert(
			connections,
			target.AncestryChanged:Connect(function()
				watch()
				refresh()
			end)
		)
	end
	const handle: Handle = {
		object = object,
		refresh = refresh,
		setEnabled = function(on: boolean)
			if not dead then
				object.Enabled = on
			end
		end,
		destroy = function()
			if dead then
				return
			end
			dead = true
			for _, connection in connections do
				connection:Disconnect()
			end
			table.clear(connections)
			object:Destroy()
		end,
	}
	watch()
	refresh()
	return handle
end

return Shadow
