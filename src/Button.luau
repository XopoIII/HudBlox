--!strict
--- The bare round icon button: the capsule's plate with a centred icon and a press squash.
---
--- It is the capsule's sibling: the same plate, the same transparency, and a radius of half its
--- size, which makes a square plate a circle. `TopBar` puts these on Roblox's own line; a game can
--- put more down a screen edge.
const Measure = require("./Measure")
const Theme = require("./Theme")

const Button = {}

export type Options = {
	--- The Instance's name. "IconButton" when left out.
	name: string?,
	--- The plate's side in pixels. `Measure.HEIGHT` (44) when left out.
	size: number?,
	--- The icon's side in pixels. `Measure.LEAD` (24) when left out: a button beside Roblox's own
	--- must carry the same ink Roblox draws.
	iconPx: number?,
	--- The icon as a fraction of the plate instead, for a button that stands alone and should grow
	--- with its plate (`Measure.ICON_FRACTION`). It wins over `iconPx`.
	iconFraction: number?,
}

--> Builds a round button into `parent` showing the icon the theme calls `icon`. Connect
--> `Activated` for the action; `theme.press` is called on the frame the finger lands.
function Button.round(parent: Instance, theme: Theme.Theme, icon: string, options: Options?): TextButton
	const size = (options and options.size) or Measure.HEIGHT
	const iconPx = (options and options.iconPx) or Measure.LEAD
	const fraction = options and options.iconFraction

	const button = Instance.new("TextButton")
	button.Name = (options and options.name) or "IconButton"
	button.Text = ""
	-- Roblox's default darkening fights any plate, and there is no hover state in this family.
	button.AutoButtonColor = false
	button.BackgroundColor3 = Theme.plate(theme)
	button.BackgroundTransparency = Theme.plateTransparency(theme)
	button.BorderSizePixel = 0
	button.Size = UDim2.fromOffset(size, size)

	const corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, size // 2)
	corner.Parent = button

	const image = theme.icon(icon, button)
	image.Name = "Icon"
	image.AnchorPoint = Vector2.new(0.5, 0.5)
	image.Position = UDim2.fromScale(0.5, 0.5)
	image.Size = if fraction then UDim2.fromScale(fraction, fraction) else UDim2.fromOffset(iconPx, iconPx)
	-- Above the button's own layer, so a count or an attention dot pinned to the button later can
	-- be put above the icon rather than fight it.
	image.ZIndex = button.ZIndex + 5

	-- The squash rides a UIScale, not Size: these buttons live in list layouts, and animating the
	-- button's own geometry would re-flow every sibling on every press.
	const scale = Instance.new("UIScale")
	scale.Parent = button
	-- The two tweens are made once: a button is pressed hundreds of times a session, and a fresh
	-- Tween per press is garbage for nothing. Cancelling the other one first keeps a press that
	-- interrupts a release (or the reverse) one smooth move.
	const info = TweenInfo.new(Measure.SQUASH_SECONDS, Enum.EasingStyle.Quad)
	const tweens = game:GetService("TweenService")
	const down = tweens:Create(scale, info, { Scale = Measure.SQUASH })
	const up = tweens:Create(scale, info, { Scale = 1 })
	-- Down, not Activated: a tap is confirmed by the finger landing, and a button that waits for
	-- the release is correct and feels broken. The sound rides the squash for the same reason.
	button.MouseButton1Down:Connect(function()
		up:Cancel()
		down:Play()
		const press = theme.press
		if press then
			press()
		end
	end)
	const function release()
		down:Cancel()
		up:Play()
	end
	button.MouseButton1Up:Connect(release)
	button.MouseLeave:Connect(release)

	button.Parent = parent
	return button
end

return Button
