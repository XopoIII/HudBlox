--!strict
--- What a gamepad's "in the hands" button means in the backpack, row by row, and that A, X and the
--- bumpers mean what they meant before it.
const Hands = require("@hudblox/Backpack/Hands")
const Moves = require("@hudblox/Backpack/Moves")
const Order = require("@hudblox/Backpack/Order")
const Spec = require("../Spec")

--- The inventory open on a pad and holding the focus, the focus on a slot with "a", "b" in the hands.
const function on(change: { open: boolean?, pad: boolean?, holds: boolean?, slot: boolean? }?): Hands.Press
	const press: Hands.Press = { open = true, pad = true, holds = true, slot = true, id = "a", held = "b" }
	if change then
		if change.open ~= nil then
			press.open = change.open
		end
		if change.pad ~= nil then
			press.pad = change.pad
		end
		if change.holds ~= nil then
			press.holds = change.holds
		end
		if change.slot ~= nil then
			press.slot = change.slot
		end
	end
	return press
end

Spec.test("on a thing that is not in the hands, the button equips it", function()
	Spec.equal(Hands.press(on()), "equip", "another thing in the hands")
	const empty = on()
	empty.held = nil
	Spec.equal(Hands.press(empty), "equip", "empty hands")
end)

Spec.test("on the thing in the hands, the button puts it away, as a press on its bar slot does", function()
	const press = on()
	press.held = "a"
	Spec.equal(Hands.press(press), "stow", "the same thing")
	-- The bar's own rule, for the same thing: a press equips or puts away, one answer for both.
	const order = Order.new(3, nil)
	Order.add(order, "a", false)
	Spec.equal(Moves.tap(Moves.new(), order, 0, "a", { zone = "bar", index = 1 }, false), "equip", "the bar's press")
end)

Spec.test("on an empty slot, or off the slots, the button is the backpack's and does nothing", function()
	const empty = on()
	empty.id = nil
	Spec.equal(Hands.press(empty), "none", "an empty slot, a thing in the hands")
	empty.held = nil
	Spec.equal(Hands.press(empty), "none", "an empty slot and empty hands are not the same thing")
	Spec.equal(Hands.press(on({ slot = false })), "none", "the focus on the search box")
	const nowhere = on({ slot = false })
	nowhere.id = nil
	nowhere.held = nil
	Spec.equal(Hands.press(nowhere), "none", "nothing anywhere")
end)

Spec.test("the button is not the backpack's with the inventory closed, off a pad, or under a panel", function()
	Spec.equal(Hands.press(on({ open = false })), "pass", "closed")
	Spec.equal(Hands.press(on({ pad = false })), "pass", "a keyboard, a mouse or a finger")
	Spec.equal(Hands.press(on({ holds = false })), "pass", "another panel holds the focus")
	Spec.equal(Hands.press(on({ open = false, pad = false, holds = false, slot = false })), "pass", "none of it")
	const held = on({ open = false })
	held.held = "a"
	Spec.equal(Hands.press(held), "pass", "closed, on the thing in the hands: not put away")
end)

Spec.test("every press but a passed one is sunk, and only an equip or a stow closes the inventory", function()
	Spec.equal(Hands.sinks("equip"), true, "equip sinks")
	Spec.equal(Hands.sinks("stow"), true, "stow sinks")
	Spec.equal(Hands.sinks("none"), true, "nothing sinks too: the game's button stays quiet")
	Spec.equal(Hands.sinks("pass"), false, "a passed press is the game's")
	Spec.equal(Hands.acts("equip"), true, "equip acts")
	Spec.equal(Hands.acts("stow"), true, "stow acts")
	Spec.equal(Hands.acts("none"), false, "nothing does not")
	Spec.equal(Hands.acts("pass"), false, "a passed press does not")
end)

Spec.test("the button is the game's choice, the kit's when it says nothing, and none when it says false", function()
	Spec.equal(Hands.button(nil, "Y"), "Y", "left out: the default")
	Spec.equal(Hands.button("X", "Y"), "X", "the game's own")
	Spec.equal(Hands.button(false, "Y"), nil, "switched off")
	Spec.equal(Hands.button("Y", "Y"), "Y", "the default said aloud")
end)

Spec.test("the button changes nothing of the order or of a pick: A and X mean what they meant", function()
	const order = Order.new(3, "pin")
	for _, id in { "pin", "a", "b", "c" } do
		Order.add(order, id, false)
	end
	const moves = Moves.new()
	-- A on a bar slot with the inventory open still picks up; it never equips.
	Spec.equal(Moves.tap(moves, order, 0, "a", { zone = "bar", index = 2 }, true), "picked", "A picks up")
	Spec.equal(Hands.press({ open = true, pad = true, holds = true, slot = true, id = "c", held = nil }), "equip", "Y")
	Spec.equal(moves.picked, "a", "the pick is not Y's to let go: closing the inventory does that")
	Spec.equal(order.bar, { "pin", "a", "b" }, "the bar as it was")
	Spec.equal(order.grid, { "c" }, "the inventory as it was")
	-- A again on another slot still moves; X still sends across.
	Spec.equal(Moves.tap(moves, order, 1, "b", { zone = "bar", index = 3 }, true), "moved", "A puts")
	Spec.equal(order.bar, { "pin", "b", "a" }, "swapped")
	Spec.equal(Moves.send(moves, order, "a"), "sent", "X sends across")
	Spec.equal(order.grid, { "a", "c" }, "to the inventory's front")
	-- The bumpers still step along the filled bar slots, wrapping.
	Spec.equal(Order.step(order, "pin", 1), "b", "R1")
	Spec.equal(Order.step(order, "pin", -1), "b", "L1 wraps")
	Spec.equal(Order.step(order, nil, 1), "pin", "from empty hands")
end)

return nil
