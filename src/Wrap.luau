--!strict
--- Whether the top row has wrapped, and whether it has STAYED wrapped long enough to be worth a
--- warning. Plain data: the time is asked of the caller, so every rule is specified without Roblox,
--- and `TopBar` keeps its row's watch by it. Internal, like `FlightBook`: not in the kit's table.
---
--- A row is also wrapped for a moment that nobody sees. A landscape-only game on a phone draws its
--- first frames at the portrait width, before the engine turns the screen, and every resize passes
--- through widths on its way. Warning on each of those fills an error report with rows for a wrap
--- that was never on screen, and buries the one that stays. So a wrap is reported once it has
--- lasted `SETTLE_S`, and a row reports once.
const Measure = require("./Measure")

const Wrap = {}

--- How long a wrap must last to be reported, in seconds. The turn of the screen at startup and a
--- resize settle within a few frames to a fraction of a second; a second is several times that, so
--- a wrap still there is the row's own, and it is soon enough that the report lands in the same
--- session as the wrap. Chosen, not measured: nothing here depends on its exact value.
Wrap.SETTLE_S = 1

export type Watch = {
	--- Tells the watch the row's height now, in pixels. Called on every change of it.
	seen: (height: number) -> (),
	--- Ends the watch: a check still waiting reports nothing.
	stop: () -> (),
}

--> Whether a row `height` pixels tall holds more than one line. 1 for rounding.
function Wrap.wrapped(height: number): boolean
	return height > Measure.HEIGHT + 1
end

--> A watch over one row. When the row wraps it asks `after` to run a check in `SETTLE_S` seconds
--> (`task.delay` in a game); the check calls `report` if the row has stayed wrapped all that time.
--> A wrap that ends first says nothing, and once `report` has been called it is never called again.
function Wrap.watch(after: (seconds: number, run: () -> ()) -> (), report: () -> ()): Watch
	local wrapped = false
	-- Counts every change between wrapped and not: a check that finds another count than its own
	-- belongs to a wrap that ended, even when the row has wrapped again since.
	local changes = 0
	local reported = false
	local stopped = false

	const function seen(height: number)
		const now = Wrap.wrapped(height)
		if now == wrapped then
			return
		end
		wrapped = now
		changes += 1
		if not now or reported or stopped then
			return
		end
		const mine = changes
		after(Wrap.SETTLE_S, function()
			if stopped or changes ~= mine then
				return
			end
			reported = true
			report()
		end)
	end

	const function stop()
		stopped = true
	end

	return { seen = seen, stop = stop }
end

return Wrap
