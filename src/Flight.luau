--!strict
--- A reward flying to its counter: a handful of icons burst out of where a reward was given and
--- fly into the capsule that counts it.
---
---     const layer = Flight.layer(playerGui)
---     Flight.send(layer, {
---         from = Flight.centre(claimButton),
---         to = wallet.segments[1].lead,
---         count = 8,
---         draw = function(frame) theme.icon("coin", frame).Size = UDim2.fromScale(1, 1) end,
---         landed = function() Flight.pulse(walletScale) end,
---     })
---
--- Each icon leaves a moment after the one before, steps out to its own place on a ring round the
--- source, then flies to the target, shrinking, and is gone. The target is read every frame, so a
--- counter that moves is still hit.
---
--- What an icon is, how many fly and what a landing does are the game's. The times and the path
--- are `FlightPath`'s, which is arithmetic and specified.
const Dialog = require("./Dialog")
const FlightPath = require("./FlightPath")

const Flight = {}

--- How many layers over a dialog the icons fly.
Flight.OVER_DIALOG = 10
--- How far a counter swells when an icon lands, and for how long it swells and settles.
Flight.PEAK = 1.12
Flight.SWELL = 0.07
Flight.SETTLE = 0.16

export type Phase = FlightPath.Phase

export type Options = {
	--- Where the icons burst from, in the space `AbsolutePosition` is read in (`Flight.centre`).
	from: Vector2,
	--- What they fly into.
	to: GuiObject,
	--- How many fly; `FlightPath.count` of it is what does.
	count: number,
	--- Fills one icon's frame. The frame is square, clear, and sized by the flight.
	draw: (frame: Frame, index: number) -> (),
	--- Called as each icon lands, in order. It must not yield.
	landed: ((index: number, count: number) -> ())?,
	--- An icon's side and how far it steps out, in pixels. `FlightPath`'s when left out.
	size: number?,
	radius: number?,
}

--> The middle of `object`, in the space `AbsolutePosition` is read in.
function Flight.centre(object: GuiObject): Vector2
	return object.AbsolutePosition + object.AbsoluteSize / 2
end

--> The ScreenGui the icons fly in, over every dialog, made once in `playerGui`. `name` is
--> "Flight" when left out.
function Flight.layer(playerGui: Instance, name: string?): ScreenGui
	const called = name or "Flight"
	const found = playerGui:FindFirstChild(called)
	if found and found:IsA("ScreenGui") then
		return found
	end
	const gui = Instance.new("ScreenGui")
	gui.Name = called
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = Dialog.DISPLAY_ORDER + Flight.OVER_DIALOG
	gui.Parent = playerGui
	return gui
end

--> Sends `options.count` icons from `options.from` into `options.to` on `layer`. Returns how
--> many fly. A target that leaves the tree mid-flight lands every icon still in the air at once.
function Flight.send(layer: ScreenGui, options: Options): number
	const count = FlightPath.count(options.count)
	if count == 0 then
		return 0
	end
	const size = options.size or FlightPath.SIZE
	const radius = options.radius or FlightPath.RADIUS
	const icons: { [number]: Frame } = {}
	for index = 1, count do
		const frame = Instance.new("Frame")
		frame.Name = `Icon{index}`
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Size = UDim2.fromOffset(size, size)
		frame.Visible = false
		options.draw(frame, index)
		frame.Parent = layer
		icons[index] = frame
	end

	local left = count
	const function land(index: number)
		const frame = icons[index]
		if not frame then
			return
		end
		icons[index] = nil
		left -= 1
		frame:Destroy()
		if options.landed then
			task.spawn(options.landed, index, count)
		end
	end

	const startedAt = os.clock()
	local step: RBXScriptConnection? = nil
	step = game:GetService("RunService").RenderStepped:Connect(function()
		const gone = not options.to:IsDescendantOf(game) or not layer:IsDescendantOf(game)
		const origin = layer.AbsolutePosition
		const target = Flight.centre(options.to) - origin
		const elapsed = os.clock() - startedAt
		for index = 1, count do
			const frame = icons[index]
			if not frame then
				continue
			end
			const x, y, scale, phase = FlightPath.place(
				elapsed,
				index,
				count,
				options.from.X - origin.X,
				options.from.Y - origin.Y,
				target.X,
				target.Y,
				radius
			)
			if gone or phase == "done" then
				land(index)
			else
				frame.Visible = phase ~= "wait"
				frame.Position = UDim2.fromOffset(x, y)
				frame.Size = UDim2.fromOffset(size * scale, size * scale)
			end
		end
		if left == 0 and step then
			step:Disconnect()
			step = nil
		end
	end)
	return count
end

--> Swells `scale` to `peak` and settles it back to one: a counter taking an icon. `PEAK` when
--> left out. A swell under way is started again, so a run of landings reads as one quick beat.
function Flight.pulse(scale: UIScale, peak: number?)
	const tweens = game:GetService("TweenService")
	const up = tweens:Create(
		scale,
		TweenInfo.new(Flight.SWELL, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Scale = peak or Flight.PEAK }
	)
	up.Completed:Once(function(state: Enum.PlaybackState)
		if state == Enum.PlaybackState.Completed then
			tweens
				:Create(
					scale,
					TweenInfo.new(Flight.SETTLE, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Scale = 1 }
				)
				:Play()
		end
	end)
	up:Play()
end

return Flight
