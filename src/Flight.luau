--!strict
--- A reward flying to its counter: a handful of icons burst out of where a reward was given and
--- fly into the capsule that counts it.
---
---     const layer = Flight.layer(playerGui)
---     const flying, cancel = Flight.send(layer, {
---         from = Flight.centre(claimButton),
---         to = wallet.segments[1].lead,
---         count = 8,
---         draw = function(frame) theme.icon("coin", frame).Size = UDim2.fromScale(1, 1) end,
---         landed = function() Flight.pulse(walletScale) end,
---     })
---
--- Each icon leaves a moment after the one before, steps out to its own place on a ring round the
--- source, then flies to the target, shrinking, and is gone. The target is read every frame, so a
--- counter that moves is still hit. `cancel` calls back the icons still in the air and lands
--- nothing, for where the reason for the reward goes away before it arrives.
---
--- However many rewards are in the air at once, one RenderStepped connection steps them all, and
--- the frame each icon is drawn in comes from a per-layer pool: a rain of rewards costs one
--- connection, and makes a frame only when more icons are in the air than ever were before. What
--- `draw` puts into a frame is the game's and is made anew for every icon.
---
--- What an icon is, how many fly and what a landing does are the game's. The times and the path
--- are `FlightPath`'s, and the list of flights and the pools are `FlightBook`'s: both plain data
--- and specified.
const Dialog = require("./Dialog")
const FlightBook = require("./FlightBook")
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
	--- Fills one icon's frame, which is not in the layer yet. The frame is square, clear, and
	--- sized by the flight, and may have flown before: the pool hands it back without children
	--- and with its look as a new frame's (`dress`), for `draw` to fill again. A connection or an
	--- attribute `draw` hangs on the frame itself is not undone: hang those on what it adds.
	draw: (frame: Frame, index: number) -> (),
	--- Called as each icon lands, in order. It must not yield. It may send a flight and may
	--- cancel one, its own included.
	landed: ((index: number, count: number) -> ())?,
	--- An icon's side and how far it steps out, in pixels. `FlightPath`'s when left out.
	size: number?,
	radius: number?,
}

type Active = {
	layer: ScreenGui,
	to: GuiObject,
	from: Vector2,
	icons: { [number]: Frame },
	left: number,
	count: number,
	size: number,
	radius: number,
	startedAt: number,
	landed: ((index: number, count: number) -> ())?,
}

-- The flights in the air, and the one connection that steps them all. A flight leaves the list
-- only in the step's walk (`FlightBook.walk`): a cancel spends it and the walk drops it, so a
-- `landed` that cancels or sends mid-step moves nothing under the walk.
const flights: { Active } = {}
local stepping: RBXScriptConnection? = nil
local steppedAt = 0

-- Spent icon frames per layer, emptied and handed out again. A layer's pool is dropped when the
-- layer is destroyed.
const pools: FlightBook.Pools<ScreenGui, Frame> = {}

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

-- An icon frame's look, the same for a new frame and for one that has flown: what a `draw` set
-- on the frame itself does not reach the next flight.
const function dress(frame: Frame, index: number, size: number)
	frame.Name = `Icon{index}`
	frame.Visible = false
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromOffset(0, 0)
	frame.Size = UDim2.fromOffset(size, size)
	frame.Rotation = 0
	frame.ZIndex = 1
	frame.LayoutOrder = 0
	frame.ClipsDescendants = false
	frame.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
end

-- Not in the layer yet: `send` puts a flight's icons there once every one is drawn.
const function takeIcon(layer: ScreenGui, index: number, size: number): Frame
	const frame = FlightBook.take(pools, layer) or Instance.new("Frame")
	dress(frame, index, size)
	return frame
end

-- Only ever called with the layer alive: a destroyed layer took its icons with it.
const function freeIcon(layer: ScreenGui, frame: Frame)
	frame.Visible = false
	frame:ClearAllChildren()
	frame.Parent = nil
	if FlightBook.give(pools, layer, frame) then
		layer.Destroying:Once(function()
			FlightBook.drop(pools, layer)
		end)
	end
end

const function land(flight: Active, index: number)
	const frame = flight.icons[index]
	if frame == nil then
		return
	end
	flight.icons[index] = nil
	flight.left -= 1
	if flight.layer:IsDescendantOf(game) then
		freeIcon(flight.layer, frame)
	end
	const landed = flight.landed
	if landed then
		task.spawn(landed, index, flight.count)
	end
end

const function stopStepping()
	if stepping and #flights == 0 then
		stepping:Disconnect()
		stepping = nil
	end
end

const function spent(flight: Active): boolean
	return flight.left == 0
end

const function stepFlight(flight: Active)
	const layer = flight.layer
	const gone = not flight.to:IsDescendantOf(game) or not layer:IsDescendantOf(game)
	const origin = layer.AbsolutePosition
	const target = Flight.centre(flight.to) - origin
	const elapsed = steppedAt - flight.startedAt
	for index = 1, flight.count do
		const frame = flight.icons[index]
		if frame then
			const x, y, scale, phase = FlightPath.place(
				elapsed,
				index,
				flight.count,
				flight.from.X - origin.X,
				flight.from.Y - origin.Y,
				target.X,
				target.Y,
				flight.radius
			)
			if gone or phase == "done" then
				land(flight, index)
			else
				frame.Visible = phase ~= "wait"
				frame.Position = UDim2.fromOffset(x, y)
				frame.Size = UDim2.fromOffset(flight.size * scale, flight.size * scale)
			end
		end
	end
end

-- The flights' order between each other is not promised, the icons' within one flight is.
const function stepFlights()
	steppedAt = os.clock()
	FlightBook.walk(flights, spent, stepFlight)
	stopStepping()
end

--> Sends `options.count` icons from `options.from` into `options.to` on `layer`. Returns how
--> many fly, and the function that calls back the icons still in the air without landing them.
--> A target that leaves the tree mid-flight lands every icon still in the air at once.
function Flight.send(layer: ScreenGui, options: Options): (number, () -> ())
	const count = FlightPath.count(options.count)
	if count == 0 then
		return 0, function() end
	end
	const size = options.size or FlightPath.SIZE
	const flight: Active = {
		layer = layer,
		to = options.to,
		from = options.from,
		icons = {},
		left = count,
		count = count,
		size = size,
		radius = options.radius or FlightPath.RADIUS,
		startedAt = os.clock(),
		landed = options.landed,
	}
	-- Every icon is drawn before any is put in the layer: a `draw` that throws leaves the layer
	-- as it was, with nothing of a flight that never started in it.
	const icons = flight.icons
	for index = 1, count do
		const frame = takeIcon(layer, index, size)
		options.draw(frame, index)
		icons[index] = frame
	end
	for index = 1, count do
		icons[index].Parent = layer
	end
	table.insert(flights, flight)
	if stepping == nil then
		stepping = game:GetService("RunService").RenderStepped:Connect(stepFlights)
	end
	local cancelled = false
	return count,
		function()
			if cancelled then
				return
			end
			cancelled = true
			for index = 1, flight.count do
				const frame = flight.icons[index]
				if frame then
					flight.icons[index] = nil
					if layer:IsDescendantOf(game) then
						freeIcon(layer, frame)
					end
				end
			end
			-- Spent, not taken out: the next step's walk drops it, and stops the stepping when it
			-- was the last. A cancel may come from a `landed`, in the middle of that walk.
			flight.left = 0
		end
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
