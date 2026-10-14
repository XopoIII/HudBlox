--!strict
--- The top row's wrap: reported only when it stays, and only once a row.
const Measure = require("@hudblox/Measure")
const Spec = require("../Spec")
const Wrap = require("@hudblox/Wrap")

const ONE_LINE = Measure.HEIGHT
const TWO_LINES = Measure.HEIGHT * 2 + Measure.GAP

-- A watch over a clock the spec turns by hand: `after` only queues the check, and `settle` runs
-- every queued check, as the settle period's end would.
type Fake = {
	watch: Wrap.Watch,
	waits: { number },
	reports: () -> number,
	settle: () -> (),
	pending: () -> number,
}

const function fake(): Fake
	const waits: { number } = {}
	local queued: { () -> () } = {}
	local reports = 0
	const watch = Wrap.watch(function(seconds: number, run: () -> ())
		table.insert(waits, seconds)
		table.insert(queued, run)
	end, function()
		reports += 1
	end)
	return {
		watch = watch,
		waits = waits,
		reports = function(): number
			return reports
		end,
		settle = function()
			const due = queued
			queued = {}
			for _, run in due do
				run()
			end
		end,
		pending = function(): number
			return #queued
		end,
	}
end

Spec.test("one line is not a wrap, a pixel of rounding is not, a second line is", function()
	Spec.equal(Wrap.wrapped(ONE_LINE), false, "one line")
	Spec.equal(Wrap.wrapped(ONE_LINE + 1), false, "one line and a pixel of rounding")
	Spec.equal(Wrap.wrapped(ONE_LINE + 2), true, "two pixels over")
	Spec.equal(Wrap.wrapped(TWO_LINES), true, "two lines")
	Spec.equal(Wrap.wrapped(0), false, "a row not drawn yet")
end)

Spec.test("the settle period is one second", function()
	Spec.equal(Wrap.SETTLE_S, 1, "seconds")
end)

Spec.test("a wrap that ends before the settle period says nothing; one that stays is reported", function()
	const brief = fake()
	brief.watch.seen(TWO_LINES)
	Spec.equal(brief.waits, { Wrap.SETTLE_S }, "the check waits the settle period")
	brief.watch.seen(ONE_LINE)
	brief.settle()
	Spec.equal(brief.reports(), 0, "a wrap that ended says nothing")

	const stays = fake()
	stays.watch.seen(TWO_LINES)
	Spec.equal(stays.reports(), 0, "nothing before the settle period ends")
	stays.settle()
	Spec.equal(stays.reports(), 1, "a wrap that stayed is reported")
end)

Spec.test("a row that never wraps waits for nothing and says nothing", function()
	const w = fake()
	w.watch.seen(ONE_LINE)
	w.watch.seen(ONE_LINE + 1)
	w.watch.seen(0)
	Spec.equal(w.waits, {}, "no check")
	w.settle()
	Spec.equal(w.reports(), 0, "no report")
end)

Spec.test("a wrap that ends and comes back is judged from its return, not its first start", function()
	-- The screen's turn: wrapped at a portrait width, one line again, then a resize wraps it anew.
	const w = fake()
	w.watch.seen(TWO_LINES)
	w.watch.seen(ONE_LINE)
	w.watch.seen(TWO_LINES)
	Spec.equal(w.pending(), 2, "each wrap waits for its own check")
	-- The first check's period ends while the row is wrapped again: it belongs to the wrap that
	-- ended, and only the second check may report.
	w.settle()
	Spec.equal(w.reports(), 1, "reported once, by the wrap that stayed")

	const gone = fake()
	gone.watch.seen(TWO_LINES)
	gone.watch.seen(ONE_LINE)
	gone.watch.seen(TWO_LINES)
	gone.watch.seen(ONE_LINE)
	gone.settle()
	Spec.equal(gone.reports(), 0, "two wraps that both ended say nothing")
end)

Spec.test("a row that grows while wrapped is still one wrap, checked once", function()
	const w = fake()
	w.watch.seen(TWO_LINES)
	w.watch.seen(TWO_LINES + Measure.HEIGHT)
	Spec.equal(w.waits, { Wrap.SETTLE_S }, "one check")
	w.settle()
	Spec.equal(w.reports(), 1, "reported once")
end)

Spec.test("a row reports once: a second wrap that stays says nothing and waits for nothing", function()
	const w = fake()
	w.watch.seen(TWO_LINES)
	w.settle()
	Spec.equal(w.reports(), 1, "the first wrap that stayed")
	w.watch.seen(ONE_LINE)
	w.watch.seen(TWO_LINES)
	Spec.equal(w.pending(), 0, "no check for the second")
	w.settle()
	Spec.equal(w.reports(), 1, "still once")
end)

Spec.test("a new watch, as a remounted row has, reports again", function()
	const first = fake()
	first.watch.seen(TWO_LINES)
	first.settle()
	const second = fake()
	second.watch.seen(TWO_LINES)
	second.settle()
	Spec.equal({ first.reports(), second.reports() }, { 1, 1 }, "each row its own")
end)

Spec.test("a stopped watch reports nothing, even for a check already waiting", function()
	const w = fake()
	w.watch.seen(TWO_LINES)
	w.watch.stop()
	w.settle()
	Spec.equal(w.reports(), 0, "the waiting check")
	w.watch.seen(ONE_LINE)
	w.watch.seen(TWO_LINES)
	Spec.equal(w.pending(), 0, "no new check")
	w.settle()
	Spec.equal(w.reports(), 0, "a later wrap")

	const kept = fake()
	kept.watch.seen(TWO_LINES)
	kept.settle()
	Spec.equal(kept.reports(), 1, "the same wrap on a watch not stopped")
end)

return nil
