--!strict
--- What a game hands the kit so the kit reads nothing of the game: how to draw an icon by name, and
--- whatever it wants different from Roblox's own look.
---
--- Only `icon` is required. Everything else defaults to what was measured off Roblox's top bar
--- (`Measure`), which is what a HUD beside that bar wants.
const Measure = require("./Measure")

const Theme = {}

--- Draws the icon a game calls `name` into `parent` and returns it. The kit writes only the
--- object's name, size, place and order, so anything drawable satisfies it: an image, or a plain
--- disc while the art does not exist yet. `Icons.resolver` builds one from a table of asset ids.
export type Icon = (name: string, parent: Instance) -> GuiObject

export type Theme = {
	icon: Icon,
	--- The plate's colour and transparency. Roblox's own when left out.
	plate: Color3?,
	plateTransparency: number?,
	--- The face of every number and label. Builder Sans Bold, Roblox's own, when left out.
	font: Font?,
	--- The colour of text on the plate. White when left out.
	text: Color3?,
	--- Called on the frame a round button is pressed: the game's click sound. It must not throw.
	press: (() -> ())?,
}

Theme.FONT_FAMILY = "rbxasset://fonts/families/BuilderSans.json"

--> The plate's colour for `theme`.
function Theme.plate(theme: Theme): Color3
	return theme.plate or Color3.fromRGB(Measure.PLATE_R, Measure.PLATE_G, Measure.PLATE_B)
end

--> The plate's transparency for `theme`.
function Theme.plateTransparency(theme: Theme): number
	return theme.plateTransparency or Measure.PLATE_T
end

--> The font for `theme`.
function Theme.font(theme: Theme): Font
	return theme.font or Font.new(Theme.FONT_FAMILY, Enum.FontWeight.Bold)
end

--> The text colour for `theme`.
function Theme.text(theme: Theme): Color3
	return theme.text or Color3.new(1, 1, 1)
end

--> A one-line label in the theme's face. It never wraps and never scales: a longer text makes its
--> capsule wider, never a second line inside a 44-pixel plate.
function Theme.label(theme: Theme, name: string, parent: Instance, text: string, size: number): TextLabel
	const label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.FontFace = Theme.font(theme)
	label.TextColor3 = Theme.text(theme)
	label.TextSize = size
	label.TextScaled = false
	label.TextWrapped = false
	label.Text = text
	label.Parent = parent
	return label
end

return Theme
