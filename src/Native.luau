--!strict
--- Roblox's own look for what a game draws as a menu: the Escape menu's see-through panel, its tall
--- buttons with the blue primary, its tiles, and the top bar's capsule.
---
--- The numbers were read off CoreGui (the alert of `PurchasePromptApp`, the top bar) and sampled
--- from a screenshot of the Escape menu on 2026-09-22. Where the alert and the menu disagree the
--- menu wins, because it is what a player opens every session. Nothing here picks a colour of its
--- own: a screen that needs an accent brings it.
const Native = {}

Native.FONT_FAMILY = "rbxasset://fonts/families/BuilderSans.json"
--- Roblox's icon font; a glyph is named, such as "x" or "three-bars-horizontal".
Native.ICON_FAMILY = "rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"

--- The Escape menu's panel: black, the world showing through it.
Native.SURFACE = Color3.new(0, 0, 0)
Native.SURFACE_T = 0.3
Native.TILE = Color3.fromRGB(25, 26, 31)
Native.PRIMARY = Color3.fromRGB(34, 51, 104)
Native.CAPSULE = Color3.fromRGB(18, 18, 21)
Native.CAPSULE_T = 0.08
Native.TEXT = Color3.fromRGB(247, 247, 248)
Native.BODY = Color3.fromRGB(213, 215, 221)
Native.DIVIDER = Color3.fromRGB(208, 217, 251)
Native.DIVIDER_T = 0.84
--- The menu leaves the world outside its panel undimmed.
Native.BACKDROP_T = 1

Native.CORNER = 10
Native.BUTTON_CORNER = 8
Native.PAD = 24
Native.GAP = 24
Native.BUTTON_H = 48
Native.ICON_BUTTON = 36
Native.TITLE_SIZE = 25
Native.BODY_SIZE = 20

export type Kind = "primary" | "secondary"

export type TextOptions = {
	--- Regular when left out; Bold for a title.
	weight: Enum.FontWeight?,
	--- `Native.TEXT` when left out.
	color: Color3?,
	--- The side a line starts on. Left when left out; a game with a right-to-left locale passes
	--- its `Rtl` reader's `start()`.
	align: Enum.TextXAlignment?,
}

const function corner(parent: Instance, radius: number)
	const round = Instance.new("UICorner")
	round.CornerRadius = UDim.new(0, radius)
	round.Parent = parent
end

--> Builder Sans at `weight`, Regular when left out.
function Native.font(weight: Enum.FontWeight?): Font
	return Font.new(Native.FONT_FAMILY, weight or Enum.FontWeight.Regular)
end

--> A line of text in the native type, as wide as its parent.
function Native.text(parent: Instance, text: string, size: number, options: TextOptions?): TextLabel
	const label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.FontFace = Native.font(options and options.weight)
	label.TextSize = size
	label.TextColor3 = (options and options.color) or Native.TEXT
	label.TextXAlignment = (options and options.align) or Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.Text = text
	label.Size = UDim2.new(1, 0, 0, size + 6)
	label.Parent = parent
	return label
end

--> The menu's button, as wide as its parent: primary is Resume's blue, secondary Leave's faint
--> white. Primary when `kind` is left out.
function Native.button(parent: Instance, text: string, kind: Kind?): TextButton
	const primary = kind ~= "secondary"
	const button = Instance.new("TextButton")
	button.AutoButtonColor = true
	button.BackgroundColor3 = if primary then Native.PRIMARY else Native.TEXT
	button.BackgroundTransparency = if primary then 0 else 0.9
	button.BorderSizePixel = 0
	button.FontFace = Native.font(Enum.FontWeight.Bold)
	button.TextSize = 20
	button.TextColor3 = Native.TEXT
	button.Text = text
	button.Size = UDim2.new(1, 0, 0, Native.BUTTON_H)
	corner(button, Native.BUTTON_CORNER)
	button.Parent = parent
	return button
end

--> A small round button in the top bar's capsule look, showing a BuilderIcons glyph: a dialog's
--> close button. `ring` is what it wears while a gamepad has it in focus (its
--> `SelectionImageObject`); the engine's own box when left out.
function Native.iconButton(parent: Instance, glyph: string, ring: GuiObject?): TextButton
	const button = Instance.new("TextButton")
	button.AutoButtonColor = true
	button.BackgroundColor3 = Native.CAPSULE
	button.BackgroundTransparency = Native.CAPSULE_T
	button.BorderSizePixel = 0
	button.FontFace = Font.new(Native.ICON_FAMILY)
	button.TextSize = 24
	button.TextColor3 = Native.TEXT
	button.Text = glyph
	button.Size = UDim2.fromOffset(Native.ICON_BUTTON, Native.ICON_BUTTON)
	if ring then
		button.SelectionImageObject = ring
	end
	corner(button, Native.ICON_BUTTON // 2)
	button.Parent = parent
	return button
end

return Native
