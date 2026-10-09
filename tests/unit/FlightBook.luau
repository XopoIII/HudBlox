--!strict
--- The flights in the air and the pools of spent icons: nothing skipped, nothing dropped unspent,
--- nothing handed out twice.
const FlightBook = require("@hudblox/FlightBook")
const Spec = require("../Spec")

type Item = { name: string, left: number, steps: number, onStep: ((item: Item) -> ())? }

const function item(name: string, left: number, onStep: ((item: Item) -> ())?): Item
	return { name = name, left = left, steps = 0, onStep = onStep }
end

const function spent(it: Item): boolean
	return it.left == 0
end

-- One frame of a flight: an icon lands, and what the game does on a landing runs inside the step.
const function step(it: Item)
	it.steps += 1
	it.left -= 1
	if it.onStep then
		it.onStep(it)
	end
end

const function names(list: { Item }): string
	const out: { string } = {}
	for _, it in list do
		table.insert(out, it.name)
	end
	table.sort(out)
	return table.concat(out, ",")
end

Spec.test("a walk steps every item once and keeps the unspent", function()
	const a, b, c = item("a", 2), item("b", 3), item("c", 2)
	const list = { a, b, c }
	FlightBook.walk(list, spent, step)
	Spec.equal({ a.steps, b.steps, c.steps }, { 1, 1, 1 }, "steps")
	Spec.equal(#list, 3, "length")
	Spec.equal(names(list), "a,b,c", "kept")
end)

Spec.test("a walk over nothing steps nothing", function()
	const list: { Item } = {}
	local stepped = 0
	FlightBook.walk(list, spent, function()
		stepped += 1
	end)
	Spec.equal(stepped, 0, "steps")
	Spec.equal(#list, 0, "length")
end)

Spec.test("an item spent by its step is dropped, and the one swapped into its place is stepped", function()
	const a, b, c = item("a", 1), item("b", 2), item("c", 2)
	const list = { a, b, c }
	FlightBook.walk(list, spent, step)
	Spec.equal({ a.steps, b.steps, c.steps }, { 1, 1, 1 }, "steps")
	Spec.equal(#list, 2, "length")
	Spec.equal(names(list), "b,c", "kept")
end)

Spec.test("the last item spent leaves no hole, and the only one leaves an empty list", function()
	const a, b = item("a", 2), item("b", 1)
	const list = { a, b }
	FlightBook.walk(list, spent, step)
	Spec.equal(#list, 1, "length")
	Spec.equal(list[1], a, "kept")
	Spec.equal(list[2], nil, "no hole")
	const only = { item("only", 1) }
	FlightBook.walk(only, spent, step)
	Spec.equal(#only, 0, "empty")
	Spec.equal(next(only), nil, "nothing left under any key")
end)

Spec.test("every item spent in one walk leaves an empty list, each stepped once", function()
	const a, b, c = item("a", 1), item("b", 1), item("c", 1)
	const list = { a, b, c }
	FlightBook.walk(list, spent, step)
	Spec.equal({ a.steps, b.steps, c.steps }, { 1, 1, 1 }, "steps")
	Spec.equal(#list, 0, "length")
end)

Spec.test("an item that spends itself again inside its step costs its neighbour nothing", function()
	-- A flight whose last landing cancels that same flight: the one after it flies on.
	const a = item("a", 1, function(it: Item)
		it.left = 0
	end)
	const b = item("b", 5)
	const list = { a, b }
	FlightBook.walk(list, spent, step)
	Spec.equal(b.steps, 1, "the neighbour was stepped")
	Spec.equal(b.left, 4, "the neighbour's count")
	Spec.equal(#list, 1, "length")
	Spec.equal(list[1], b, "the neighbour is kept")
end)

Spec.test("an item spent by another before its turn is dropped without a step", function()
	local b: Item
	const a = item("a", 3, function()
		b.left = 0
	end)
	b = item("b", 5)
	const c = item("c", 2)
	const list = { a, b, c }
	FlightBook.walk(list, spent, step)
	Spec.equal({ a.steps, b.steps, c.steps }, { 1, 0, 1 }, "steps")
	Spec.equal(names(list), "a,c", "kept")
end)

Spec.test("an item spent by another after its turn is dropped by the next walk, unstepped", function()
	const a = item("a", 5)
	const b = item("b", 3, function()
		a.left = 0
	end)
	const c = item("c", 4)
	const list = { a, b, c }
	FlightBook.walk(list, spent, step)
	Spec.equal({ a.steps, b.steps, c.steps }, { 1, 1, 1 }, "the first walk's steps")
	Spec.equal(#list, 3, "the first walk leaves it in")
	b.onStep = nil
	FlightBook.walk(list, spent, step)
	Spec.equal({ a.steps, b.steps, c.steps }, { 1, 2, 2 }, "the second walk's steps")
	Spec.equal(names(list), "b,c", "kept")
end)

Spec.test("an item added during a walk is stepped in that walk", function()
	const list: { Item } = {}
	const late = item("late", 2)
	const a = item("a", 2, function()
		table.insert(list, late)
	end)
	table.insert(list, a)
	FlightBook.walk(list, spent, step)
	Spec.equal({ a.steps, late.steps }, { 1, 1 }, "steps")
	Spec.equal(names(list), "a,late", "kept")
end)

Spec.test("an item added by the step that spends its own is kept and stepped", function()
	-- A flight whose last landing sends the next one.
	const list: { Item } = {}
	const late = item("late", 2)
	const a = item("a", 1, function()
		table.insert(list, late)
	end)
	const b = item("b", 2)
	table.insert(list, a)
	table.insert(list, b)
	FlightBook.walk(list, spent, step)
	Spec.equal({ a.steps, b.steps, late.steps }, { 1, 1, 1 }, "steps")
	Spec.equal(#list, 2, "length")
	Spec.equal(names(list), "b,late", "kept")
end)

Spec.test("a pool hands back the last thing given, and nothing when it has none", function()
	const pools: FlightBook.Pools<string, number> = {}
	Spec.equal(FlightBook.take(pools, "layer"), nil, "no pool yet")
	FlightBook.give(pools, "layer", 1)
	FlightBook.give(pools, "layer", 2)
	Spec.equal(FlightBook.take(pools, "layer"), 2, "the last given")
	Spec.equal(FlightBook.take(pools, "layer"), 1, "the one before")
	Spec.equal(FlightBook.take(pools, "layer"), nil, "each is handed out once")
end)

Spec.test("only the give that makes a key's pool says so", function()
	const pools: FlightBook.Pools<string, number> = {}
	Spec.equal(FlightBook.give(pools, "layer", 1), true, "the first")
	Spec.equal(FlightBook.give(pools, "layer", 2), false, "the second")
	Spec.equal(FlightBook.take(pools, "layer"), 2, "taken")
	Spec.equal(FlightBook.take(pools, "layer"), 1, "taken")
	Spec.equal(FlightBook.give(pools, "layer", 3), false, "an emptied pool is still the key's pool")
	Spec.equal(FlightBook.give(pools, "other", 4), true, "another key's first")
end)

Spec.test("a key's pool is its own", function()
	const pools: FlightBook.Pools<string, number> = {}
	FlightBook.give(pools, "one", 1)
	FlightBook.give(pools, "two", 2)
	Spec.equal(FlightBook.take(pools, "two"), 2, "two's")
	Spec.equal(FlightBook.take(pools, "two"), nil, "two has no more")
	Spec.equal(FlightBook.take(pools, "one"), 1, "one's")
end)

Spec.test("a dropped key's pool is forgotten, and the next give makes it again", function()
	const pools: FlightBook.Pools<string, number> = {}
	FlightBook.give(pools, "gone", 1)
	FlightBook.give(pools, "stays", 2)
	FlightBook.drop(pools, "gone")
	Spec.equal(pools["gone"], nil, "no entry is left under the key")
	Spec.equal(FlightBook.take(pools, "gone"), nil, "nothing to take")
	Spec.equal(FlightBook.take(pools, "stays"), 2, "another key keeps its own")
	Spec.equal(FlightBook.give(pools, "gone", 3), true, "the pool is made again")
	FlightBook.drop(pools, "never")
	local keys = 0
	for _ in pools do
		keys += 1
	end
	Spec.equal(keys, 2, "dropping an unknown key adds nothing")
end)

return nil
