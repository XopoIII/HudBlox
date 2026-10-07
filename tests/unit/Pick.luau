--!strict
--- Which control a gamepad's focus lands on: where it starts in a panel, and where it goes when the
--- focused control is gone.
const Pick = require("@hudblox/Pick")
const Spec = require("../Spec")

const function target(x: number, y: number, order: number?, shown: boolean?, selectable: boolean?): Pick.Target
	return {
		x = x,
		y = y,
		order = order or 0,
		shown = shown ~= false,
		selectable = selectable ~= false,
	}
end

Spec.test("focus starts on the top row, at its left", function()
	const targets = { target(300, 200), target(100, 200), target(100, 100), target(300, 100) }
	Spec.equal(Pick.first(targets, false), 3)
end)

Spec.test("focus starts at the right of the top row in a right-to-left locale", function()
	const targets = { target(300, 200), target(100, 200), target(100, 100), target(300, 100) }
	Spec.equal(Pick.first(targets, true), 4)
end)

Spec.test("centres within a row's height of each other are one row", function()
	Spec.equal(Pick.ROW, 4, "the height")
	-- The left one stands 4 lower: still the same row, so it leads.
	Spec.equal(Pick.first({ target(300, 100), target(100, 104) }, false), 2, "4 lower")
	-- 5 lower is the next row: the higher one leads.
	Spec.equal(Pick.first({ target(300, 100), target(100, 105) }, false), 1, "5 lower")
	-- And 5 higher is the row above.
	Spec.equal(Pick.first({ target(100, 100), target(300, 95) }, false), 2, "5 higher")
end)

Spec.test("a lower SelectionOrder comes before position: the close button is last", function()
	const close = target(700, 20, 1000)
	const row = target(400, 300, 0)
	const footer = target(400, 560, 0)
	Spec.equal(Pick.first({ close, footer, row }, false), 3, "the body's row")
	Spec.equal(Pick.first({ close, footer }, false), 2, "then the footer")
	Spec.equal(Pick.first({ close }, false), 1, "the close button alone")
end)

Spec.test("of two controls standing at one point the earlier is kept", function()
	Spec.equal(Pick.first({ target(100, 100), target(100, 100) }, false), 1, "left to right")
	Spec.equal(Pick.first({ target(100, 100), target(100, 100) }, true), 1, "right to left")
end)

Spec.test("a hidden or an unselectable control is never picked", function()
	const hidden = target(10, 10, 0, false, true)
	const dead = target(20, 10, 0, true, false)
	const live = target(900, 900, 5)
	Spec.equal(Pick.first({ hidden, dead, live }, false), 3, "the live one, far and late as it is")
	Spec.equal(Pick.first({ hidden, dead }, false), nil, "none left")
end)

Spec.test("an empty panel picks nothing", function()
	Spec.equal(Pick.first({}, false), nil)
	Spec.equal(Pick.first({}, true), nil)
	Spec.equal(Pick.nearest({}, 0, 0, false), nil)
end)

Spec.test("the focus goes to the closest control left", function()
	const targets = { target(100, 100), target(260, 100), target(100, 400) }
	Spec.equal(Pick.nearest(targets, 250, 110, false), 2)
	Spec.equal(Pick.nearest(targets, 110, 390, false), 3)
	Spec.equal(Pick.nearest(targets, 100, 100, false), 1)
end)

Spec.test("SelectionOrder does not matter while one control is closer", function()
	const close = target(700, 20, 1000)
	const row = target(400, 300, 0)
	Spec.equal(Pick.nearest({ close, row }, 690, 30, false), 1)
	-- Nor does it matter which stands first in the list.
	Spec.equal(Pick.nearest({ row, close }, 690, 30, false), 2)
end)

Spec.test("an exact tie is broken as the start would be: by order, then by the reading side", function()
	const left, right = target(100, 100), target(300, 100)
	Spec.equal(Pick.nearest({ right, left }, 200, 100, false), 2, "the left one, left to right")
	Spec.equal(Pick.nearest({ right, left }, 200, 100, true), 1, "the right one, right to left")
	Spec.equal(Pick.nearest({ target(100, 100, 7), target(300, 100, 2) }, 200, 100, false), 2, "the lower order")
end)

Spec.test("a nearer control that is hidden or unselectable is skipped", function()
	const hidden = target(200, 100, 0, false, true)
	const dead = target(201, 100, 0, true, false)
	const far = target(900, 900)
	Spec.equal(Pick.nearest({ hidden, dead, far }, 200, 100, false), 3)
	Spec.equal(Pick.nearest({ hidden, dead }, 200, 100, false), nil)
end)

return nil
