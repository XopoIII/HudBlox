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
--- the icon frames come from a per-layer pool rather than from `Instance.new`: a rain of rewards
--- costs one connection and no new Instances.
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
	--- Fills one icon's frame. The frame is square, clear, and sized by the flight, and may have
	--- flown before: the pool hands it back emptied, for `draw` to fill again.
	draw: (frame: Frame, index: number) -> (),
	--- Called as each icon lands, in order. It must not yield.
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

-- The flights in the air, and the one connection that steps them all.
const flights: { Active } = {}
local stepping: RBXScriptConnection? = nil

-- Spent icon frames per layer, emptied and handed out again. A layer is made once per PlayerGui
-- and lives for the session, so the pools' keys do not leak.
const pools: { [ScreenGui]: { Frame } } = {}

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

const function newIcon(): Frame
	const frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	return frame
end

const function takeIcon(layer: ScreenGui, index: number): Frame
	const pool = pools[layer]
	const frame = (if pool then table.remove(pool) else nil) or newIcon()
	frame.Name = `Icon{index}`
	frame.Visible = false
	frame.Parent = layer
	return frame
end

-- Only ever called with the layer alive: a destroyed layer took its icons with it.
const function freeIcon(layer: ScreenGui, frame: Frame)
	frame.Visible = false
	frame:ClearAllChildren()
	frame.Parent = nil
	local pool = pools[layer]
	if pool == nil then
		pool = {}
		pools[layer] = pool
	end
	table.insert(pool, frame)
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

const function stepFlights()
	const now = os.clock()
	local at = 1
	while at <= #flights do
		const flight = flights[at]
		const layer = flight.layer
		const gone = not flight.to:IsDescendantOf(game) or not layer:IsDescendantOf(game)
		const origin = layer.AbsolutePosition
		const target = Flight.centre(flight.to) - origin
		const elapsed = now - flight.startedAt
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
		if flight.left == 0 then
			-- Out by swap: the flights' order between each other is not promised, the icons'
			-- within one flight is.
			flights[at] = flights[#flights]
			flights[#flights] = nil
		else
			at += 1
		end
	end
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
	for index = 1, count do
		const frame = takeIcon(layer, index)
		frame.Size = UDim2.fromOffset(size, size)
		options.draw(frame, index)
		flight.icons[index] = frame
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
			flight.left = 0
			const at = table.find(flights, flight)
			if at then
				table.remove(flights, at)
			end
			stopStepping()
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
