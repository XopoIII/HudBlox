--!strict
--- How wide a tab is in its strip.
const TabFit = require("@hudblox/TabFit")
const Spec = require("../Spec")

Spec.test("tabs that fit are each as wide as a tab may be", function()
	Spec.equal(TabFit.WIDTH, 150, "the widest")
	Spec.equal(TabFit.GAP, 8, "the gap")
	Spec.equal(TabFit.width(712, 2, 8, 150), 150, "two in a dialog's body")
	Spec.equal(TabFit.width(308, 2, 8, 150), 150, "two, with not a pixel to spare")
	Spec.equal(TabFit.width(466, 3, 8, 150), 150, "three, with not a pixel to spare")
end)

Spec.test("tabs that do not fit share the strip evenly, in whole pixels", function()
	Spec.equal(TabFit.width(307, 2, 8, 150), 149, "two, one pixel short")
	Spec.equal(TabFit.width(712, 7, 8, 150), 94, "seven in a dialog's body")
	Spec.equal(TabFit.width(300, 4, 6, 86), 70, "four chips with a gap of six")
end)

Spec.test("the gaps are between tabs: one tab has none", function()
	Spec.equal(TabFit.width(100, 1, 8, 150), 100, "one tab takes the whole strip")
	Spec.equal(TabFit.width(100, 1, 40, 150), 100, "whatever the gap")
	Spec.equal(TabFit.width(160, 2, 40, 150), 60, "two share what the one gap leaves")
end)

Spec.test("a tab is never squeezed under the narrowest, nor made wider than it may be", function()
	Spec.equal(TabFit.NARROWEST, 44, "the narrowest")
	Spec.equal(TabFit.width(100, 3, 8, 150), 44, "three in a strip for two")
	Spec.equal(TabFit.width(0, 3, 8, 150), 44, "a strip with no width")
	Spec.equal(TabFit.width(1000, 2, 8, 30), 30, "a widest under the narrowest is kept")
	Spec.equal(TabFit.width(50, 3, 8, 30), 30, "and is what a squeezed tab falls back to")
end)

Spec.test("no tabs ask for nothing: the widest", function()
	Spec.equal(TabFit.width(712, 0, 8, 150), 150, "none")
end)

return nil
