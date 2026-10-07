--!strict
--- A thing that cannot be used again yet: how long each has left, and how much of its slot the
--- shade over it covers. Pure arithmetic, so every rule is a spec (`tests/unit/BackpackRest.luau`);
--- `Slot` draws the shade and `Mount` is told of a rest by the game.
---
--- A rest is kept by the thing's id, not by its slot, so it follows the thing when it is moved, and
--- by the moment it ends, so a redraw in the middle of one shows what is left of it.
const Rest = {}

--- When a thing's rest ends, on the clock the caller keeps, and how long it was when it began.
export type Entry = { ends: number, total: number }
export type Rests = { [string]: Entry }

--> Starts a rest of `seconds` for `id` at time `now`. Nothing or less ends the one it has.
function Rest.start(rests: Rests, id: string, seconds: number, now: number)
	if seconds ~= seconds or seconds <= 0 then
		rests[id] = nil
		return
	end
	rests[id] = { ends = now + seconds, total = seconds }
end

--> How long `id` still rests at time `now`, and how long its rest was: 0 and 0 for a thing that
--> does not rest. A rest that has ended is forgotten.
function Rest.of(rests: Rests, id: string, now: number): (number, number)
	const entry = rests[id]
	if not entry then
		return 0, 0
	end
	const left = entry.ends - now
	if left <= 0 then
		rests[id] = nil
		return 0, 0
	end
	return left, entry.total
end

--> The share of its slot the shade covers with `left` of `total` seconds to go: 1 as the rest
--> begins, 0 when it is over or there is none.
function Rest.share(left: number, total: number): number
	if total <= 0 or left <= 0 then
		return 0
	end
	return math.min(left / total, 1)
end

return Rest
