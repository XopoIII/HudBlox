--!strict
--- A count pinned to a button's corner: how many things wait behind it.
---
--- It is the small disc Roblox's own chat button wears for unread lines: a digit up to `MOST`, the
--- same digit with a plus past it, and no disc at all for nothing. It sits on the button's upper
--- trailing corner, above the icon (`Button` keeps the icon five layers over the plate for this),
--- and rides the button's press squash because it is the button's child.
---
--- Its colour is the game's to give: the kit owns no colour beyond Roblox's measured plate.
const Theme = require("./Theme")

const Badge = {}

--- The largest count written whole; a larger one reads as this with a plus.
Badge.MOST = 9
--- The disc's height in pixels; one digit makes it a circle, "9+" a short capsule.
Badge.SIZE = 18
--- The text's height in pixels.
Badge.TEXT = 13
--- How far past the button's corner the disc's centre stands in, in pixels.
Badge.INSET = 5
--- How many layers over the button the disc is: one over the icon.
Badge.LAYER = 6

export type Options = {
	--- The disc's colour.
	colour: Color3,
	--- The colour of the digit. The theme's text colour when left out.
	ink: Color3?,
	--- True puts the disc on the upper leading corner instead: the trailing corner of a button a
	--- right-to-left layout has mirrored.
	leading: boolean?,
}

export type Handle = {
	--- Shows `count`, or hides the disc for nil, zero and anything under one.
	set: (count: number?) -> (),
	--- The disc itself, for a game that wants to place or animate it.
	frame: Frame,
}

--> What a badge reads for `count`: nil for no badge (nil, not a number, under one), the whole
--> number up to `MOST`, and `MOST` with a plus past it. A fraction counts as the whole below it.
function Badge.text(count: number?): string?
	if not count or count ~= count or count < 1 then
		return nil
	end
	const whole = math.floor(count)
	if whole > Badge.MOST then
		return `{Badge.MOST}+`
	end
	return tostring(whole)
end

--> The disc's width in pixels for `text`: a circle for one character, wider by half a height for
--> each one more.
function Badge.width(text: string): number
	return Badge.SIZE + math.max(#text - 1, 0) * (Badge.SIZE // 2)
end

--> Pins a badge to `button` and returns its handle. It shows nothing until `set` is given a
--> count of one or more.
function Badge.pin(button: GuiObject, theme: Theme.Theme, options: Options): Handle
	const frame = Instance.new("Frame")
	frame.Name = "Badge"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = if options.leading
		then UDim2.fromOffset(Badge.INSET, Badge.INSET)
		else UDim2.new(1, -Badge.INSET, 0, Badge.INSET)
	frame.Size = UDim2.fromOffset(Badge.SIZE, Badge.SIZE)
	frame.BackgroundColor3 = options.colour
	frame.BorderSizePixel = 0
	frame.ZIndex = button.ZIndex + Badge.LAYER
	frame.Visible = false

	const corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, Badge.SIZE // 2)
	corner.Parent = frame

	const label = Theme.label(theme, "Count", frame, "", Badge.TEXT)
	label.Size = UDim2.fromScale(1, 1)
	label.TextColor3 = options.ink or Theme.text(theme)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.ZIndex = frame.ZIndex + 1

	frame.Parent = button

	const function set(count: number?)
		const text = Badge.text(count)
		frame.Visible = text ~= nil
		if text then
			label.Text = text
			frame.Size = UDim2.fromOffset(Badge.width(text), Badge.SIZE)
		end
	end

	return { set = set, frame = frame }
end

return Badge
