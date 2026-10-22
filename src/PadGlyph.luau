--!strict
--- The picture of a gamepad's button, as the player's own pad draws it (the engine's
--- `GetImageForKeyCode`: an Xbox pad's B, a PlayStation pad's circle), so no hint ever names a
--- button in words.
---
--- The engine's picture is a white disc or bar with the letter cut out of it, and what stands
--- behind showed through the letter (a game's owner, on a television: "the letter must be black, on
--- white, with an edge"). A cap fills the cut-out with black and edges the white, so it reads the
--- same on any colour. A D-pad's way is a white disc with a black arrow, as a face button is drawn,
--- not the engine's cross, whose four arms are alike at a cap's size.
---
--- A cap is a small picture pinned to a control, there only while the player is on a gamepad
--- (`PadInput`). What shape a key's cap has is `PadGlyph.shape`, plain data, so it is a spec.
const PadInput = require("./PadInput")

const PadGlyph = {}

--- The edge's colour, as red, green and blue of 255: the letter is black and the white white.
PadGlyph.EDGE = { 28, 30, 34 }
--- The arrow on a D-pad's way.
PadGlyph.ARROWS = { DPadUp = "\u{25B2}", DPadDown = "\u{25BC}", DPadLeft = "\u{25C0}", DPadRight = "\u{25B6}" }

export type Shape = "face" | "bumper" | "way"

--> The shape of the cap of the key named `name`: "way" for a D-pad's way, "bumper" for a bumper or
--> a trigger (the engine draws a bar), "face" for the rest (a disc).
function PadGlyph.shape(name: string): Shape
	if PadGlyph.ARROWS[name] then
		return "way"
	end
	const bar = { ButtonL1 = true, ButtonR1 = true, ButtonL2 = true, ButtonR2 = true }
	return if bar[name] then "bumper" else "face"
end

-- A frame of `size` share of the cap at `centre`, rounded by `round`, under the picture or over it.
const function part(cap: Frame, name: string, size: Vector2, centre: Vector2, round: UDim, z: number): Frame
	const frame = Instance.new("Frame")
	frame.Name = name
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(centre.X, centre.Y)
	frame.Size = UDim2.fromScale(size.X, size.Y)
	frame.BorderSizePixel = 0
	frame.ZIndex = z
	const corner = Instance.new("UICorner")
	corner.CornerRadius = round
	corner.Parent = frame
	frame.Parent = cap
	return frame
end

-- The edge round the white: a hair inside the picture's own outline.
const function edge(frame: Frame, size: number)
	const stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(PadGlyph.EDGE[1], PadGlyph.EDGE[2], PadGlyph.EDGE[3])
	stroke.Thickness = math.max(1, size / 18)
	stroke.Parent = frame
end

--> A `size`-pixel picture of `code` inside `parent`, named "PadCap" and placed by the caller.
function PadGlyph.cap(parent: GuiObject, code: Enum.KeyCode, size: number): Frame
	const cap = Instance.new("Frame")
	cap.Name = "PadCap"
	cap.BackgroundTransparency = 1
	cap.Size = UDim2.fromOffset(size, size)
	const z = parent.ZIndex + 10
	cap.ZIndex = z
	const shape = PadGlyph.shape(code.Name)
	const middle = Vector2.new(0.5, 0.5)
	local picture: ImageLabel? = nil
	if shape == "way" then
		const disc = part(cap, "Disc", Vector2.one, middle, UDim.new(0.5, 0), z)
		disc.BackgroundColor3 = Color3.new(1, 1, 1)
		edge(disc, size)
		const arrow = Instance.new("TextLabel")
		arrow.Name = "Arrow"
		arrow.BackgroundTransparency = 1
		arrow.AnchorPoint = middle
		arrow.Position = UDim2.fromScale(0.5, 0.5)
		arrow.Size = UDim2.fromScale(0.72, 0.72)
		arrow.Text = PadGlyph.ARROWS[code.Name]
		arrow.TextColor3 = Color3.new(0, 0, 0)
		arrow.TextScaled = true
		arrow.Font = Enum.Font.GothamBold
		arrow.ZIndex = z + 1
		arrow.Parent = disc
	else
		-- black under the cut-out letter, and the edge on the picture's outline: a disc, or the bar
		-- the engine draws a bumper as, its letters a little below its middle (read off its pictures)
		const bar = shape == "bumper"
		const ink = if bar then Vector2.new(0.5, 0.53) else middle
		const fill =
			part(cap, "Ink", if bar then Vector2.new(0.86, 0.4) else Vector2.new(0.8, 0.8), ink, UDim.new(0.3, 0), z)
		fill.BackgroundColor3 = Color3.new(0, 0, 0)
		const image = Instance.new("ImageLabel")
		image.Name = "Picture"
		image.BackgroundTransparency = 1
		image.Size = UDim2.fromScale(1, 1)
		image.ZIndex = z + 1
		image.Parent = cap
		picture = image
		const outline = part(
			cap,
			"Edge",
			if bar then Vector2.new(1, 0.7) else Vector2.one,
			middle,
			UDim.new(if bar then 0.35 else 0.5, 0),
			z + 2
		)
		outline.BackgroundTransparency = 1
		edge(outline, size)
	end
	const function show()
		const on = PadInput.active()
		cap.Visible = on
		if on and picture then
			picture.Image = game:GetService("UserInputService"):GetImageForKeyCode(code)
		end
	end
	show()
	PadInput.onChange(show)
	cap.Parent = parent
	return cap
end

--- How far a corner's picture stands in from the control's corner, in pixels.
PadGlyph.INSET = 4

--> A cap pinned on the lower right corner of `parent`, its middle `PadGlyph.INSET` in from it: the
--> key that presses that control.
function PadGlyph.corner(parent: GuiObject, code: Enum.KeyCode, size: number): Frame
	const cap = PadGlyph.cap(parent, code, size)
	cap.AnchorPoint = Vector2.new(0.5, 0.5)
	cap.Position = UDim2.new(1, -PadGlyph.INSET, 1, -PadGlyph.INSET)
	return cap
end

return PadGlyph
