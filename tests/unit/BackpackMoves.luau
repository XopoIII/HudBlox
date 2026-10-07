--!strict
--- What a tap, a gamepad's one press and a drop mean in the backpack, and what a press still down
--- has become.
const Moves = require("@hudblox/Backpack/Moves")
const Order = require("@hudblox/Backpack/Order")
const Press = require("@hudblox/Backpack/Press")
const Spec = require("../Spec")

--- "pin" in slot 1, a and b on the bar, c in the inventory.
const function bag(): Order.Order
	const order = Order.new(3, "pin")
	for _, id in { "pin", "a", "b", "c" } do
		Order.add(order, id, false)
	end
	return order
end

const function place(order: Order.Order, id: string): string
	const at = Order.where(order, id)
	return if at then `{at.zone}{at.index}` else "none"
end

Spec.test("a mouse drags once it has moved six pixels, wherever it is", function()
	Spec.equal(Press.DRAG_PX, 6, "the distance")
	Spec.equal(Press.classify("mouse", "grid", 2, 2, 1), "wait", "near, however long")
	Spec.equal(Press.classify("mouse", "grid", 0, 8, 0), "drag", "far, down")
	Spec.equal(Press.classify("mouse", "bar", 8, 0, 0), "drag", "far, sideways")
	Spec.equal(Press.classify("mouse", "grid", 6, 0, 0), "drag", "six exactly")
	Spec.equal(Press.classify("mouse", "grid", 5.99, 0, 0), "wait", "just short")
	Spec.equal(Press.classify("mouse", "grid", 4.5, 4.5, 0), "drag", "six across a diagonal")
	Spec.equal(Press.classify("mouse", "grid", -4, -4, 0), "wait", "short of it across a diagonal")
	Spec.equal(Press.classify("mouse", "grid", 0, -8, 0), "drag", "far, up")
end)

Spec.test("a finger in the inventory scrolls up and down and drags sideways", function()
	Spec.equal(Press.classify("touch", "grid", 1, 12, 0.05), "scroll", "mostly down")
	Spec.equal(Press.classify("touch", "grid", 1, -12, 0.05), "scroll", "mostly up")
	Spec.equal(Press.classify("touch", "grid", 12, 2, 0.05), "drag", "mostly sideways")
	Spec.equal(Press.classify("touch", "grid", -12, 2, 0.05), "drag", "sideways the other way")
	Spec.equal(Press.classify("touch", "grid", 8, 8, 0.05), "scroll", "a tie is a scroll")
	Spec.equal(Press.classify("touch", "grid", 0, 2, 0.05), "wait", "near")
end)

Spec.test("a finger held still in the inventory picks the slot up; on the bar it drags like a mouse", function()
	Spec.equal(Press.HOLD_S, 0.2, "the hold")
	Spec.equal(Press.classify("touch", "grid", 0, 0, 0.2), "drag", "held exactly that long")
	Spec.equal(Press.classify("touch", "grid", 0, 0, 0.19), "wait", "held less")
	Spec.equal(Press.classify("touch", "grid", 0, 12, 0.2), "drag", "held, then moved down: still a drag")
	Spec.equal(Press.classify("touch", "bar", 0, 9, 0), "drag", "the bar does not scroll")
	Spec.equal(Press.classify("touch", "bar", 0, 0, 5), "wait", "and a hold on the bar picks nothing up")
end)

Spec.test("with the inventory closed, a tap equips from the bar and does nothing else", function()
	const moves, order = Moves.new(), bag()
	moves.picked = "b"
	Spec.equal(Moves.tap(moves, order, 0, "a", { zone = "bar", index = 2 }, false), "equip", "a filled bar slot")
	Spec.equal(moves.picked, nil, "a pick is let go")
	Spec.equal(Moves.tap(moves, order, 0, "c", { zone = "grid", index = 1 }, false), "none", "the inventory")
	Spec.equal(Moves.tap(moves, order, 0, nil, { zone = "bar", index = 3 }, false), "none", "an empty slot")
	Spec.equal(moves.last, nil, "and no tap is remembered")
end)

Spec.test("tap, then tap moves a thing, both ways", function()
	const moves, order = Moves.new(), bag()
	Spec.equal(Moves.tap(moves, order, 0, "c", { zone = "grid", index = 1 }, true), "picked", "picked")
	Spec.equal(moves.picked, "c", "c is picked")
	Spec.equal(Moves.tap(moves, order, 1, "a", { zone = "bar", index = 2 }, true), "moved", "moved")
	Spec.equal(moves.picked, nil, "and let go")
	Spec.equal(place(order, "c"), "bar2", "c")
	Spec.equal(place(order, "a"), "grid1", "a")
	Spec.equal(Moves.tap(moves, order, 2, "b", { zone = "bar", index = 3 }, true), "picked", "picked again")
	Spec.equal(Moves.tap(moves, order, 3, nil, { zone = "grid", index = 0 }, true), "moved", "onto the background")
	Spec.equal(place(order, "b"), "grid1", "b at the front")
end)

Spec.test("a tap on nothing picks nothing, and a pick put where it cannot go is let go", function()
	const moves, order = Moves.new(), bag()
	Spec.equal(Moves.tap(moves, order, 0, nil, { zone = "bar", index = 3 }, true), "none", "an empty slot")
	Spec.equal(moves.picked, nil, "nothing picked")
	Moves.tap(moves, order, 1, "a", { zone = "bar", index = 2 }, true)
	Spec.equal(Moves.tap(moves, order, 2, "pin", { zone = "bar", index = 1 }, true), "none", "onto the pinned slot")
	Spec.equal(moves.picked, nil, "let go")
	Spec.equal(place(order, "a"), "bar2", "and not moved")
end)

Spec.test("a double tap sends a thing across", function()
	const moves, order = Moves.new(), bag()
	Spec.equal(Press.DOUBLE_S, 0.5, "the window")
	Spec.equal(Moves.tap(moves, order, 0, "a", { zone = "bar", index = 2 }, true), "picked", "the first tap")
	Spec.equal(Moves.tap(moves, order, 0.5, "a", { zone = "bar", index = 2 }, true), "sent", "the second, in time")
	Spec.equal(place(order, "a"), "grid1", "a")
	Spec.equal(moves.picked, nil, "nothing picked")
	Spec.equal(moves.last, nil, "and a third tap starts over")
end)

Spec.test("two taps on different things, or too far apart, are not a double tap", function()
	const moves, order = Moves.new(), bag()
	Moves.tap(moves, order, 0, "a", { zone = "bar", index = 2 }, true)
	Spec.equal(Moves.tap(moves, order, 0.51, "a", { zone = "bar", index = 2 }, true), "unpicked", "too late")
	Spec.equal(place(order, "a"), "bar2", "not sent")
	Moves.tap(moves, order, 5, "a", { zone = "bar", index = 2 }, true)
	Spec.equal(Moves.tap(moves, order, 5.1, "b", { zone = "bar", index = 3 }, true), "moved", "another thing")
	Spec.equal(place(order, "a"), "bar3", "a swap, not a send")
end)

Spec.test("the pinned thing is never picked up, and a double tap does not send it", function()
	const moves, order = Moves.new(), bag()
	Spec.equal(Moves.tap(moves, order, 0, "pin", { zone = "bar", index = 1 }, true), "none", "a tap")
	Spec.equal(moves.picked, nil, "not picked")
	Spec.equal(Moves.tap(moves, order, 0.1, "pin", { zone = "bar", index = 1 }, true), "none", "a double tap")
	Spec.equal(place(order, "pin"), "bar1", "still there")
end)

Spec.test("a gamepad's one press sends across both ways, and lets a pick go", function()
	const moves, order = Moves.new(), bag()
	Moves.tap(moves, order, 0, "b", { zone = "bar", index = 3 }, true)
	Spec.equal(moves.picked, "b", "b is picked")
	Spec.equal(Moves.send(moves, order, "a"), "sent", "sent")
	Spec.equal(place(order, "a"), "grid1", "a at the front")
	Spec.equal(place(order, "c"), "grid2", "c behind it")
	Spec.equal(moves.picked, nil, "the pick is let go")
	Spec.equal(moves.last, nil, "and no tap is remembered")
	Spec.equal(Moves.send(moves, order, "a"), "sent", "and back")
	Spec.equal(place(order, "a"), "bar2", "to the slot it left, the first free one")
	Spec.equal(Moves.send(moves, order, "pin"), "none", "not the pinned thing")
	Spec.equal(Moves.send(moves, order, "nobody"), "none", "nor a thing that is not there")
end)

Spec.test("a drop moves a thing, and one over nothing does not", function()
	const moves, order = Moves.new(), bag()
	moves.picked = "a"
	Spec.equal(Moves.drop(moves, order, "c", { zone = "bar", index = 3 }), "moved", "onto a slot")
	Spec.equal(place(order, "c"), "bar3", "c")
	Spec.equal(moves.picked, nil, "a pick is let go")
	Spec.equal(Moves.drop(moves, order, "c", nil), "none", "over nothing")
	Spec.equal(Moves.drop(moves, order, "c", { zone = "bar", index = 3 }), "none", "onto its own slot")
	Spec.equal(place(order, "c"), "bar3", "still there")
end)

return nil
