--!strict
--- What a tap means, on top of `Order`. Pure, with the clock passed in, so the whole tap language is a
--- spec (`tests/unit/BackpackMoves.luau`).
---
--- With the inventory **closed**, a tap on a filled bar slot equips it (or puts it away), as the stock
--- hotbar does.
---
--- With it **open**, taps move things, three ways, each working both ways between the bar and the
--- inventory:
---
--- - **tap, then tap**: the first tap picks a thing up (its slot pulses), the second moves it to
---   wherever was tapped: another slot swaps, the inventory's background takes it in. Tapping the
---   picked slot again (after the double-tap window) lets it go.
--- - **double tap**: sends a thing across, bar to inventory or back (`Order.sendAcross`).
--- - **drag** is `Gesture`'s, and lands through `drop` here.
---
--- A gamepad has no double tap: its X is `send`, the same crossing in one press (`Pad`).
const Order = require("./Order")
const Press = require("./Press")

const Moves = {}

export type Outcome = "equip" | "picked" | "unpicked" | "moved" | "sent" | "none"

export type Moves = {
	picked: string?,
	last: { id: string, at: number }?,
}

function Moves.new(): Moves
	return { picked = nil, last = nil }
end

function Moves.clear(m: Moves)
	m.picked = nil
	m.last = nil
end

--> A tap on `place`, which holds `id` or nothing, at `now` seconds; `editing` while the inventory is
--> open.
function Moves.tap(m: Moves, o: Order.Order, now: number, id: string?, place: Order.Place, editing: boolean): Outcome
	if not editing then
		Moves.clear(m)
		return if id and place.zone == "bar" then "equip" else "none"
	end
	const last = m.last
	m.last = if id then { id = id, at = now } else nil
	if id and last and last.id == id and now - last.at <= Press.DOUBLE_S then
		m.picked = nil
		m.last = nil
		return if Order.sendAcross(o, id) then "sent" else "none"
	end
	const picked = m.picked
	if not picked then
		if id and id ~= o.pinned then
			m.picked = id
			return "picked"
		end
		return "none"
	end
	if picked == id then
		m.picked = nil
		return "unpicked"
	end
	m.picked = nil
	return if Order.move(o, picked, place) then "moved" else "none"
end

--> A thing sent across by one press; whatever was picked up is let go.
function Moves.send(m: Moves, o: Order.Order, id: string): Outcome
	Moves.clear(m)
	return if Order.sendAcross(o, id) then "sent" else "none"
end

--> A drag let go over `target` (nil: over nothing that takes it).
function Moves.drop(m: Moves, o: Order.Order, id: string, target: Order.Place?): Outcome
	Moves.clear(m)
	if not target then
		return "none"
	end
	return if Order.move(o, id, target) then "moved" else "none"
end

return Moves
