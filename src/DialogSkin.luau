--!strict
--- What a game wants different about the panel a dialog draws in: its fill, how much of the world
--- shows through it, its corner, the scrim over the world, and a shading gradient across the fill.
---
--- The result is plain numbers and a colour, so the rule is a spec that runs without Roblox; the
--- panel that wears it is `DialogPanel`'s, which hands in Roblox's own measured numbers as the
--- fallback. Everything asked for is clamped: a transparency past 0 or 1, a negative corner or a
--- value that is not a number falls back to the default rather than drawing something no one can
--- read. The module itself builds no Instance and touches no engine type at load.
const DialogSkin = {}

--- The gradient's direction when a skin gives none: top to bottom, as a lit panel is read.
DialogSkin.ROTATION = 90

export type Skin = {
	--- The panel's fill. Black, the Escape menu's, when left out.
	panel: Color3?,
	--- How much of the world shows through that fill, 0..1. Nearly solid when left out.
	panelTransparency: number?,
	--- The framed panel's corner radius, in pixels. Never negative.
	corner: number?,
	--- How much the world is dimmed behind the dialog, 0..1.
	backdropTransparency: number?,
	--- A gradient multiplied over the fill: the panel answers "where is the light" without a texture.
	gradient: ColorSequence?,
	--- The gradient's direction in degrees, as `UIGradient` reads it. Down the screen when left out.
	gradientRotation: number?,
}

--- What an unanswered field falls back to: the host's own panel, measured off Roblox's menu.
export type Defaults = {
	panel: Color3,
	panelTransparency: number,
	corner: number,
	backdropTransparency: number,
}

export type Resolved = {
	panel: Color3,
	panelTransparency: number,
	corner: number,
	backdropTransparency: number,
	gradient: ColorSequence?,
	gradientRotation: number,
}

const function finite(value: number): boolean
	return value == value and value > -math.huge and value < math.huge
end

-- A share of the screen: inside 0..1, or nil for anything that is not a number.
const function fraction(value: number?): number?
	if value == nil or not finite(value) then
		return nil
	end
	return math.clamp(value, 0, 1)
end

-- Pixels: never negative, or nil for anything that is not a number.
const function length(value: number?): number?
	if value == nil or not finite(value) then
		return nil
	end
	return math.max(0, value)
end

--> `defaults`, with every field a skin gave filled in and clamped.
function DialogSkin.resolve(skin: Skin?, defaults: Defaults): Resolved
	const rotation = if skin then skin.gradientRotation else nil
	return {
		panel = if skin and skin.panel then skin.panel else defaults.panel,
		panelTransparency = (if skin then fraction(skin.panelTransparency) else nil) or defaults.panelTransparency,
		corner = (if skin then length(skin.corner) else nil) or defaults.corner,
		backdropTransparency = (if skin then fraction(skin.backdropTransparency) else nil)
			or defaults.backdropTransparency,
		gradient = if skin then skin.gradient else nil,
		gradientRotation = if rotation ~= nil and finite(rotation) then rotation else DialogSkin.ROTATION,
	}
end

return DialogSkin
