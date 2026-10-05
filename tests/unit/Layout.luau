--!strict
--- The top line's arithmetic. The screens are the ones the numbers were measured on in Grabby Pit:
--- a phone on its side at 801 x 392 and at 705 x 338, where Roblox's strip is 58 tall and its own
--- buttons end at x = 208.
const Layout = require("@hudblox/Layout")
const Spec = require("../Spec")

const STRIP = 58
const INSET = 208

-- An edge-to-edge gui (it ignores the inset) and one that respects it.
const function over(width: number): Layout.Screen
	return { width = width, left = 0, top = -STRIP }
end
const function below(width: number): Layout.Screen
	return { width = width, left = 0, top = 0 }
end

Spec.test("a row is on the chrome line only when its top lands in Roblox's strip", function()
	Spec.equal(Layout.onChromeLine(-STRIP, 12), true, "edge to edge")
	Spec.equal(Layout.onChromeLine(0, 12), false, "inset gui")
	-- The strip is y < 0: a row whose top is exactly at 0 starts below it.
	Spec.equal(Layout.onChromeLine(-12, 12), false, "exactly at the boundary")
	Spec.equal(Layout.onChromeLine(-13, 12), true, "one pixel into the strip")
end)

Spec.test("the first left button starts past Roblox's buttons on the chrome line", function()
	const top = Layout.top(over(801), INSET, 1)
	Spec.equal(top.onChromeLine, true, "onChromeLine")
	-- 208 where Roblox's buttons end, and the 8 Roblox keeps between its own.
	Spec.equal(top.lefts, { 216 }, "lefts")
	Spec.equal(Layout.top(over(801), INSET, 3).lefts, { 216, 268, 320 }, "three lefts")
end)

Spec.test("the first left button starts at the edge margin below the chrome line", function()
	const top = Layout.top(below(801), INSET, 1)
	Spec.equal(top.onChromeLine, false, "onChromeLine")
	Spec.equal(top.lefts, { 16 }, "lefts")
	-- And on the chrome line of a screen where Roblox reports no buttons at all.
	Spec.equal(Layout.top(over(801), 0, 2).lefts, { 16, 68 }, "no inset")
end)

Spec.test("the free span is measured in the gui's own coordinates", function()
	Spec.equal(Layout.freeX(208, 0), 208, "gui at the screen's edge")
	Spec.equal(Layout.freeX(208, 44), 164, "gui pushed in by a notch")
	Spec.equal(Layout.freeX(30, 44), 0, "never negative")
	Spec.equal(Layout.chromeFreeX(over(801), 208, 12), 208, "on the line")
	Spec.equal(Layout.chromeFreeX(below(801), 208, 12), 0, "below the line")
end)

Spec.test("the right row takes what the chrome and the left buttons leave", function()
	-- No left buttons: the two widths recorded in Grabby Pit, 577 and 481.
	Spec.equal(Layout.top(over(801), INSET, 0), { onChromeLine = true, lefts = {}, rowLeft = 208, rowWidth = 577 })
	Spec.equal(Layout.top(over(705), INSET, 0).rowWidth, 481, "705 wide")
	-- One left button, 216..260, and the row begins 8 past it.
	Spec.equal(Layout.top(over(801), INSET, 1), { onChromeLine = true, lefts = { 216 }, rowLeft = 268, rowWidth = 517 })
	-- Below the chrome line nothing is reserved for Roblox.
	Spec.equal(Layout.top(below(705), INSET, 0).rowWidth, 689, "inset gui, no lefts")
	Spec.equal(Layout.top(below(705), INSET, 1), { onChromeLine = false, lefts = { 16 }, rowLeft = 68, rowWidth = 621 })
	-- A row the host moved below the strip of an edge-to-edge gui is off the line too.
	Spec.equal(Layout.top(over(705), INSET, 0, 70).rowWidth, 689, "row at 70")
end)

Spec.test("the right row never overlaps the left buttons, down to an upright phone", function()
	local checked = 0
	const screens: { (width: number) -> Layout.Screen } = { over, below }
	for _, screen in screens do
		for inset = 0, 320, 16 do
			for count = 0, 3 do
				for width = 320, 1920 do
					const top = Layout.top(screen(width), inset, count)
					if top.rowLeft + top.rowWidth ~= width - 16 then
						error(`the row does not end 16 from the edge at {width}, inset {inset}, {count} lefts`)
					end
					if top.rowWidth > 0 and count > 0 then
						const lastRight = top.lefts[count] + 44
						if top.rowLeft < lastRight + 8 then
							error(
								`the row starts at {top.rowLeft}, the last left ends at {lastRight}: {width}, {inset}`
							)
						end
					end
					if top.rowWidth > 0 and top.onChromeLine and top.rowLeft < inset then
						error(`the row starts at {top.rowLeft}, under Roblox's buttons: {width}, {inset}`)
					end
					checked += 1
				end
			end
		end
	end
	Spec.equal(checked, 2 * 21 * 4 * 1601, "placements checked")
	-- The narrowest upright phone still has a row beside one left button, 36 wide.
	Spec.equal(Layout.top(over(320), INSET, 1).rowWidth, 36, "320 wide, one left")
end)

Spec.test("a screen with no room gives the row no width rather than a negative one", function()
	-- Two left buttons end at 312 and the row would begin at 320: nothing is left of a 320 screen.
	const top = Layout.top(over(320), INSET, 2)
	Spec.equal(top.rowWidth, 0, "rowWidth")
	Spec.equal(top.rowLeft, 304, "rowLeft")
	Spec.equal(Layout.fits(top, 44), false, "one button does not fit")
	Spec.equal(Layout.top(over(100), INSET, 0).rowWidth, 0, "narrower than the chrome")
end)

Spec.test("a capsule's width is its padding, leads, texts and segment rhythm", function()
	-- 10 + 24 + 6 + 40 + 12.
	Spec.equal(Layout.pillWidth({ { ink = 40, lead = true } }), 92, "one segment")
	-- No lead: 10 + 40 + 12.
	Spec.equal(Layout.pillWidth({ { ink = 40, lead = false } }), 62, "no lead")
	-- Two: 10 + (24 + 6 + 44) + 16 + (24 + 6 + 44) + 12.
	const two = Layout.pillWidth({ { ink = 44, lead = true }, { ink = 44, lead = true } })
	Spec.equal(two, 186, "two segments")
	Spec.equal(Layout.pillWidth({}), 22, "an empty capsule is its padding")
	Spec.equal(Layout.rowNeeds({ two, 44, 44 }), 290, "a capsule and two buttons")
	Spec.equal(Layout.rowNeeds({ 44 }), 44, "one button has no gap")
	Spec.equal(Layout.rowNeeds({}), 0, "nothing")
end)

Spec.test("a worst case fits a phone on its side and does not fit one held upright", function()
	const needs = 290
	Spec.equal(Layout.fits(Layout.top(over(801), INSET, 1), needs), true, "801 wide")
	Spec.equal(Layout.fits(Layout.top(over(558 + 16), INSET, 1), needs), true, "exactly enough")
	Spec.equal(Layout.fits(Layout.top(over(558 + 15), INSET, 1), needs), false, "one pixel short")
	Spec.equal(Layout.fits(Layout.top(over(390), INSET, 1), needs), false, "390 wide")
end)

Spec.test("fractions of the height are fractions of what is below Roblox's strip", function()
	Spec.equal(Layout.topStrip(-STRIP), 58, "strip, edge to edge")
	Spec.equal(Layout.topStrip(0), 0, "strip, inset gui")
	Spec.equal(Layout.usableHeight(392, -STRIP), 334, "usable, edge to edge")
	Spec.equal(Layout.usableHeight(392, 0), 392, "usable, inset gui")
	-- The centre of the usable part is 58 + 167 = 225 = 0.5 * 392 + 29.
	Spec.equal(Layout.yOffset(-STRIP, 0.5), 29, "centre")
	Spec.equal(Layout.yOffset(-STRIP, 0), 58, "top")
	Spec.equal(Layout.yOffset(-STRIP, 1), 0, "bottom")
	Spec.equal(Layout.yOffset(0, 0.5), 0, "inset gui")
end)

Spec.test("a pinned label is its widest text rounded up, and two more", function()
	Spec.equal(Layout.pinned(53.2), 56, "fraction")
	Spec.equal(Layout.pinned(54), 56, "whole")
	Spec.equal(Layout.pinned(53), 55, "one narrower")
end)

Spec.test("a mirrored element sits as far from the opposite edge as it sat from its own", function()
	Spec.equal({ Layout.mirrorX(0, 0, 12) }, { 1, 1, -12 }, "left edge")
	Spec.equal({ Layout.mirrorX(1, 1, -10) }, { 0, 0, 10 }, "right edge")
	Spec.equal({ Layout.mirrorX(0.5, 0.5, 0) }, { 0.5, 0.5, 0 }, "centred")
end)

return nil
