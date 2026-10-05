--!strict
--- Builds the `icon` a theme needs from a game's own table of images.
---
--- The ids stay in the game. A name with no id draws a plain disc in its place, so a missing
--- picture never breaks a screen: a half-drawn art set still produces a readable HUD. A fresh
--- upload can also render blank for a few minutes while Roblox moderates it.
const Theme = require("./Theme")

const Icons = {}

export type Options = {
	--- The image of each name ("rbxassetid://..."): a table, or a function that answers nil for a
	--- name it does not know.
	ids: { [string]: string } | (name: string) -> string?,
	--- The disc's colour for a name with no image. Light grey when left out.
	tints: { [string]: Color3 }?,
	--- True for pixel art, which must not be filtered when it is scaled. Off when left out.
	pixelated: boolean?,
	--- Names that are filtered even when `pixelated` is on: line glyphs among pixel art.
	smooth: { [string]: boolean }?,
	--- A colour laid over every image: white art drawn in the theme's ink. None when left out.
	color: Color3?,
}

const function idOf(options: Options, name: string): string?
	const ids = options.ids
	if type(ids) == "function" then
		return ids(name)
	end
	return ids[name]
end

--> The icon function for `Theme.icon`.
function Icons.resolver(options: Options): Theme.Icon
	return function(name: string, parent: Instance): GuiObject
		const id = idOf(options, name)
		if id then
			const image = Instance.new("ImageLabel")
			image.Name = `Icon_{name}`
			image.BackgroundTransparency = 1
			image.BorderSizePixel = 0
			image.Image = id
			image.ScaleType = Enum.ScaleType.Fit
			const smooth = options.smooth
			const crisp = options.pixelated == true and not (smooth and smooth[name])
			image.ResampleMode = if crisp then Enum.ResamplerMode.Pixelated else Enum.ResamplerMode.Default
			const color = options.color
			if color then
				image.ImageColor3 = color
			end
			image.Parent = parent
			return image
		end
		const disc = Instance.new("Frame")
		disc.Name = `Icon_{name}`
		const tints = options.tints
		disc.BackgroundColor3 = (tints and tints[name]) or Color3.fromRGB(200, 200, 200)
		disc.BorderSizePixel = 0
		const round = Instance.new("UICorner")
		round.CornerRadius = UDim.new(1, 0)
		round.Parent = disc
		disc.Parent = parent
		return disc
	end
end

return Icons
