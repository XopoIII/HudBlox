--!strict
--- A reward's flight as arithmetic: how many icons fly, when each leaves, and where each is on
--- its way. Plain numbers, so every rule is specified without Roblox; `Flight` draws by it.
const FlightPath = {}

--- How long an icon steps out for, and how long it flies for, in seconds.
FlightPath.OUT = 0.25
FlightPath.FLY = 0.375
--- How long after the icon before it an icon leaves, in seconds.
FlightPath.STAGGER = 0.03125
--- How far from the source an icon steps out, and an icon's side, in pixels.
FlightPath.RADIUS = 46
FlightPath.SIZE = 28
--- An icon's size as it lands, as a share of its own.
FlightPath.LANDS_AT = 0.55
--- The most icons one send flies.
FlightPath.MOST = 12

--- Where an icon is in its flight.
export type Phase = "wait" | "out" | "fly" | "done"

const WAIT: Phase = "wait"
const OUT: Phase = "out"
const FLY: Phase = "fly"
const DONE: Phase = "done"

--> How many icons fly for `wanted`: the whole number below it, at most `MOST`; none for under
--> one, a negative or what is not a number.
function FlightPath.count(wanted: number): number
	if wanted ~= wanted then
		return 0
	end
	return math.clamp(math.floor(wanted), 0, FlightPath.MOST)
end

--> How long after the send icon `index` leaves, in seconds.
function FlightPath.leaves(index: number): number
	return (index - 1) * FlightPath.STAGGER
end

--> How long a send of `count` icons lasts from its first frame to its last landing, in seconds.
function FlightPath.lasts(count: number): number
	if count < 1 then
		return 0
	end
	return FlightPath.leaves(count) + FlightPath.OUT + FlightPath.FLY
end

--> Where icon `index` of `count` stands once it has stepped out, as an offset from the source:
--> the first straight up, the rest clockwise round a ring of `radius`.
function FlightPath.ring(index: number, count: number, radius: number): (number, number)
	const angle = (index - 1) / math.max(count, 1) * 2 * math.pi - math.pi / 2
	return math.cos(angle) * radius, math.sin(angle) * radius
end

--> Where icon `index` of `count` is `elapsed` seconds after the send, flying from
--> (`fromX`, `fromY`) to (`toX`, `toY`): its place, its size as a share of its own, and its phase.
--> It waits at the source, steps out fast and slows, then flies slow and quickens, shrinking.
function FlightPath.place(
	elapsed: number,
	index: number,
	count: number,
	fromX: number,
	fromY: number,
	toX: number,
	toY: number,
	radius: number
): (number, number, number, Phase)
	const t = elapsed - FlightPath.leaves(index)
	if t < 0 then
		return fromX, fromY, 1, WAIT
	end
	const ringX, ringY = FlightPath.ring(index, count, radius)
	if t < FlightPath.OUT then
		const share = t / FlightPath.OUT
		const eased = 1 - (1 - share) * (1 - share)
		return fromX + ringX * eased, fromY + ringY * eased, 1, OUT
	end
	const share = (t - FlightPath.OUT) / FlightPath.FLY
	if share >= 1 then
		return toX, toY, FlightPath.LANDS_AT, DONE
	end
	const eased = share * share
	const startX, startY = fromX + ringX, fromY + ringY
	return startX + (toX - startX) * eased, startY + (toY - startY) * eased, 1 + (FlightPath.LANDS_AT - 1) * share, FLY
end

return FlightPath
