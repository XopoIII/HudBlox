--!strict
--- The game's bottom furniture: what is reported, what it lifts, and who hears of it.
const Band = require("@hudblox/Band")
const Spec = require("../Spec")

Spec.test("a card that overlaps a rectangle sideways is lifted above it", function()
	Band.clear()
	Band.set("hotbar", { left = 100, right = 300, top = 60 })
	-- The bar's top at 60, 8 of air, and the card's lower edge already at 12.
	Spec.equal(Band.lift(0, 120, 12), 56, "overlapping")
	Spec.equal(Band.lift(280, 400, 12), 56, "overlapping the other side")
	Spec.equal(Band.lift(0, 120, 68), 0, "already above")
	Spec.equal(Band.lift(0, 120, 67), 1, "one pixel short")
end)

Spec.test("a card beside a rectangle keeps its corner", function()
	Band.clear()
	Band.set("hotbar", { left = 100, right = 300, top = 60 })
	Spec.equal(Band.lift(0, 100, 12), 0, "touching the left side")
	Spec.equal(Band.lift(300, 400, 12), 0, "touching the right side")
	Band.clear()
	Spec.equal(Band.lift(0, 120, 12), 0, "nothing reported")
end)

Spec.test("the highest of several rectangles sets the lift", function()
	Band.clear()
	Band.set("hotbar", { left = 100, right = 300, top = 60 })
	Band.set("inventory", { left = 50, right = 350, top = 240 })
	Spec.equal(Band.lift(0, 120, 12), 236, "both overlap")
	Spec.equal(Band.lift(0, 60, 12), 236, "only the inventory overlaps")
	Spec.equal(Band.has("inventory"), true, "has inventory")
	Band.set("inventory", nil)
	Spec.equal(Band.has("inventory"), false, "inventory taken away")
	Spec.equal(Band.lift(0, 120, 12), 56, "the hotbar alone")
end)

Spec.test("listeners hear a real change and nothing else", function()
	Band.clear()
	local heard = 0
	const stop = Band.onChange(function()
		heard += 1
	end)
	const rect: Band.Rect = { left = 100, right = 300, top = 60 }
	Band.set("hotbar", rect)
	Spec.equal(heard, 1, "a new rectangle")
	Band.set("hotbar", { left = 100, right = 300, top = 60 })
	Spec.equal(heard, 1, "the same numbers again")
	-- The reporter's own table is copied, so changing it and reporting it again is a change.
	rect.top = 90
	Band.set("hotbar", rect)
	Spec.equal(heard, 2, "the same table, moved")
	Band.set("other", nil)
	Spec.equal(heard, 2, "taking away what was never there")
	Band.set("hotbar", nil)
	Spec.equal(heard, 3, "taken away")
	stop()
	Band.set("hotbar", rect)
	Spec.equal(heard, 3, "after stop")
end)

return nil
