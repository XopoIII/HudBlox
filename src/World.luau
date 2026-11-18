--!strict
--- A plate in the world: a BillboardGui held over a part, its face drawn by the kit's own surface.
---
--- The game owns what the plate says and which part carries it; the kit owns the shell and the
--- plate's look, so a sign beside a fishing pier reads as the same material as the top bar. The
--- plate is drawn by the engine at a pixel size that shrinks with distance, and it ignores the
--- world's lighting so it stays legible at night; both are the engine's measured behaviour, not a
--- number picked here. The size and the draw distance are the game's, because how big a sign must
--- be is a question about the world it stands in.
const Native = require("./Native")
const Surface = require("./Surface")

const World = {}

export type Options = {
	--- The plate's size in BillboardGui offset pixels; the engine scales it with camera distance.
	size: Vector2,
	--- The furthest camera distance it is drawn at; the engine default when left out.
	maxDistance: number?,
	--- Drawn over geometry instead of inside it; inside when left out.
	alwaysOnTop: boolean?,
	--- Camera-relative lift in studs; none when left out.
	studsOffset: Vector3?,
	--- The plate's face: `tile` is the solid plate a sign is, `panel` the see-through one, and
	--- `plain` is an empty host for the game's own rows.
	kind: ("plain" | "panel" | "tile")?,
	--- Inside padding in pixels; the game's rows provide their own when left out.
	padding: number?,
}

export type Plate = {
	--- The BillboardGui, for `Adornee`, distance and visibility the game changes later.
	gui: BillboardGui,
	--- The styled face to fill with `Native.text`, `World.image` and the kit's rows.
	frame: Frame,
	destroy: () -> (),
}

--> A plate over `adornee`, removed with it by `destroy`.
function World.mount(adornee: Instance, options: Options): Plate
	const gui = Instance.new("BillboardGui")
	gui.Name = "HudPlate"
	gui.Adornee = adornee
	gui.Size = UDim2.fromOffset(math.max(1, options.size.X), math.max(1, options.size.Y))
	gui.LightInfluence = 0
	gui.AlwaysOnTop = options.alwaysOnTop == true
	gui.ResetOnSpawn = false
	gui.ClipsDescendants = false
	-- The engine's default draws later gui under earlier siblings and a documented tap contract
	-- fails; a plate states its own order as the dialog does.
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.StudsOffset = options.studsOffset or Vector3.zero
	const limit = options.maxDistance
	if limit then
		gui.MaxDistance = math.max(0, limit)
	end
	const frame = Surface.mount(gui, { kind = options.kind or "tile", padding = options.padding })
	-- A BillboardGui that is never parented is never drawn: it hangs off the part it adorns.
	gui.Parent = adornee
	local dead = false
	const function destroy()
		if dead then
			return
		end
		-- The plate is the shell's lifetime: a face cannot outlive it, and a second call is silent.
		dead = true
		gui:Destroy()
	end
	return { gui = gui, frame = frame, destroy = destroy }
end

export type ImageOptions = {
	--- The image's frame inside its parent; the whole parent when left out.
	size: UDim2?,
	--- Corner radius in pixels, at most half the shorter side; the plate's own radius when left out.
	corner: number?,
	--- A tint over the image; none when left out.
	color: Color3?,
	--- True for pixel art, which must not be filtered when it is scaled. Off when left out.
	pixelated: boolean?,
}

--> An image slot inside `parent`, its corners cut to the kit's radius.
---
--> The game names the picture: a thumbnail url of a player, a painted map, a species portrait. A
--> slot with no asset draws nothing and the plate's own material shows through.
function World.image(parent: Instance, asset: string, options: ImageOptions?): ImageLabel
	const image = Instance.new("ImageLabel")
	image.Name = "Image"
	image.BackgroundTransparency = 1
	image.BorderSizePixel = 0
	image.Image = asset
	-- A portrait is filled by its picture: fitting it letterboxes a head shot into bands.
	image.ScaleType = Enum.ScaleType.Crop
	image.Size = if options and options.size then options.size else UDim2.fromScale(1, 1)
	if options then
		const tint = options.color
		if tint then
			image.ImageColor3 = tint
		end
		if options.pixelated == true then
			image.ResampleMode = Enum.ResamplerMode.Pixelated
		end
	end
	const corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, if options and options.corner then options.corner else Native.CORNER)
	corner.Parent = image
	image.Parent = parent
	return image
end

export type SurfaceOptions = {
	--- Which face of the part is painted; its front when left out.
	face: Enum.NormalId?,
	--- How many pixels one stud of the part's face holds; 50 when left out.
	pixelsPerStud: number?,
	--- Drawn over everything else instead of inside the world; inside when left out.
	alwaysOnTop: boolean?,
	--- How much of the world's light the paint takes, from 0 (a lit sign) to 1 (plain paint);
	--- lit when left out.
	lightInfluence: number?,
}

--> A face painted on a part, for a sign the player reads instead of a plate that follows the
--> camera. The game names the board and paints it with `Native.text` and its own frames.
function World.surface(part: BasePart, options: SurfaceOptions?): SurfaceGui
	const gui = Instance.new("SurfaceGui")
	gui.Name = "HudSurface"
	gui.Adornee = part
	gui.Face = if options and options.face then options.face else Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = math.clamp(if options and options.pixelsPerStud then options.pixelsPerStud else 50, 1, 512)
	gui.AlwaysOnTop = options ~= nil and options.alwaysOnTop == true
	gui.LightInfluence = math.clamp(if options and options.lightInfluence then options.lightInfluence else 0, 0, 1)
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = part
	return gui
end

export type PortraitOptions = {
	--- The medallion's size; the whole parent when left out.
	size: UDim2?,
	--- The rim's thickness in pixels; 3 when left out.
	rim: number?,
	--- The rim's colour; white when left out.
	rimColor: Color3?,
	--- The plate behind a picture that has not come yet; the kit's own surface when left out.
	plate: Color3?,
}

export type Portrait = {
	--- The round frame, for placing it and for handing it back to the game.
	frame: Frame,
	--- The picture; empty until `set` is called.
	image: ImageLabel,
	--- Wears `asset` from now on, or leaves the plate showing when it is empty.
	set: (string) -> (),
}

--> A round picture with a rim, the mark a game hangs over a player's own thing.
---
--> The picture is cut to a circle, a failed or missing one leaves the plate's own dark disc, and
--> the rim keeps the mark readable over any water or grass behind it.
function World.portrait(parent: Instance, options: PortraitOptions?): Portrait
	const width = math.max(0, if options and options.rim then options.rim else 3)
	const frame = Instance.new("Frame")
	frame.Name = "Portrait"
	frame.BorderSizePixel = 0
	frame.BackgroundColor3 = if options and options.rimColor then options.rimColor else Color3.new(1, 1, 1)
	frame.Size = if options and options.size then options.size else UDim2.fromScale(1, 1)
	const round = Instance.new("UICorner")
	round.CornerRadius = UDim.new(1, 0)
	round.Parent = frame
	const image = Instance.new("ImageLabel")
	image.Name = "Picture"
	image.AnchorPoint = Vector2.new(0.5, 0.5)
	image.Position = UDim2.fromScale(0.5, 0.5)
	image.Size = UDim2.new(1, -2 * width, 1, -2 * width)
	image.BackgroundColor3 = if options and options.plate then options.plate else Native.SURFACE
	image.BorderSizePixel = 0
	image.ScaleType = Enum.ScaleType.Crop
	const inner = Instance.new("UICorner")
	inner.CornerRadius = UDim.new(1, 0)
	inner.Parent = image
	image.Parent = frame
	frame.Parent = parent
	return {
		frame = frame,
		image = image,
		set = function(asset: string)
			image.Image = asset
		end,
	}
end

return World
