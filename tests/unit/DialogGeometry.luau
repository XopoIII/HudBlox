--!strict
--- Where a dialog's panel sits and how big it is. The answers below were read off the game the
--- arithmetic came from, where it was compared over 364,800 screens (2026-10-07).
const DialogGeometry = require("@hudblox/DialogGeometry")
const Spec = require("../Spec")

-- A hotbar: 70 tall, 4 off the edge, and a gap; kept shown while 360 are left above it.
const BAR: DialogGeometry.Bottom = { band = 82, room = 360 }

-- The panel a screen gets for a wide dialog (760 x 600) over the bar.
const function panel(width: number, height: number, strip: number): DialogGeometry.Frame
	return DialogGeometry.layout(width, height, strip, 760, 600, BAR)
end

Spec.test("the row a panel keeps clear of is where the top bar's own buttons end", function()
	Spec.equal(DialogGeometry.TOP_ROW_BOTTOM, 56, "12 from the top and a capsule of 44")
	Spec.equal(DialogGeometry.ROW_GAP, 8, "the air under it")
end)

Spec.test("a roomy screen frames the panel at its own size, centred above the bar", function()
	Spec.equal(panel(1920, 1080, 58), { width = 760, height = 600, top = 199, clearsBottom = true, tight = false })
	-- A tall phone: narrower than the dialog, so it keeps a tenth of the screen on each side.
	Spec.equal(panel(390, 844, 58), { width = 312, height = 600, top = 81, clearsBottom = true, tight = false })
end)

Spec.test("a screen too short to frame it gives the panel what is left under the strip and the row", function()
	Spec.equal(panel(835, 679, 36), { width = 668, height = 507, top = 64, clearsBottom = true, tight = false })
	Spec.equal(panel(1024, 768, 0), { width = 760, height = 579, top = 64, clearsBottom = true, tight = false })
	Spec.equal(panel(870, 639, 58), { width = 696, height = 454, top = 80, clearsBottom = true, tight = false })
end)

Spec.test("a screen is roomy only when the dialog fits with its margins", function()
	-- 760 tall: 620 are usable, which holds the 600 only without the two margins of 27.9. So the
	-- panel is squeezed to what the margins leave, centred under the strip.
	Spec.equal(panel(1000, 760, 58), { width = 760, height = 564, top = 85, clearsBottom = true, tight = false })
	Spec.equal(panel(1000, 780, 58), { width = 760, height = 582, top = 86, clearsBottom = true, tight = false })
end)

Spec.test("under 440 below the strip a panel takes the tight margins and gives the row its height", function()
	-- 518 tall: 418.6 would be left under the strip between the margins, short of the 440 that
	-- makes a real panel there. It runs to 12 off the bottom and starts under the strip.
	Spec.equal(panel(1000, 518, 58), { width = 760, height = 440, top = 66, clearsBottom = false, tight = true })
	Spec.equal(DialogGeometry.STRIP_CLEAR_MIN, 440, "the height")
	-- And a little taller, where the bar still has its room, the same above the bar.
	Spec.equal(panel(1000, 560, 58), { width = 760, height = 400, top = 66, clearsBottom = true, tight = true })
	Spec.equal(panel(1000, 540, 0), { width = 760, height = 382, top = 64, clearsBottom = true, tight = true })
end)

Spec.test("a landscape phone takes the height under the row and covers the bar", function()
	-- 801 x 392 with Roblox's 58 strip: under the strip and a gap, down to 12 off the bottom.
	Spec.equal(panel(801, 392, 58), { width = 640, height = 314, top = 66, clearsBottom = false, tight = true })
	Spec.equal(panel(667, 375, 58), { width = 533, height = 297, top = 66, clearsBottom = false, tight = true })
	Spec.equal(panel(1366, 500, 70), { width = 760, height = 410, top = 78, clearsBottom = false, tight = true })
	const frame = panel(801, 392, 58)
	Spec.equal(frame.top + frame.height, 392 - DialogGeometry.TIGHT_MARGIN, "its bottom edge")
end)

Spec.test("a sheet fills exactly the screens too short to frame the dialog", function()
	-- The tight margins are the mark of a screen that cannot frame the panel: a dialog asked for a
	-- sheet fills that screen, and nothing else is filled.
	Spec.truthy(panel(801, 392, 58).tight, "a landscape phone")
	Spec.truthy(panel(1000, 518, 58).tight, "a window too short for the panel")
	Spec.truthy(DialogGeometry.layout(801, 392, 0, 760, 600).tight, "the same phone with no strip")
	Spec.equal(panel(1920, 1080, 58).tight, false, "a roomy screen")
	Spec.equal(panel(390, 844, 58).tight, false, "a tall phone")
	Spec.equal(DialogGeometry.layout(801, 392, 58, 420, 300).tight, false, "a small dialog on that phone")
end)

Spec.test("a preferred minimum yields to the physical screen below the row", function()
	Spec.equal(panel(280, 300, 58), { width = 280, height = 222, top = 66, clearsBottom = false, tight = true })
	Spec.equal(DialogGeometry.CARD_W_MIN, 280, "the least width")
	Spec.equal(DialogGeometry.CARD_H_MIN, 240, "the least height")
	Spec.equal(panel(200, 260, 58).width, 280, "a screen narrower than that still gets it")
end)

Spec.test("a panel starts below the strip and the row on every screen, and ends on it", function()
	for _, strip in { 0, 36, 58, 70 } do
		for _, size in
			{ { 390, 844 }, { 1024, 768 }, { 1366, 1024 }, { 1920, 1080 }, { 835, 679 }, { 801, 392 }, { 932, 430 } }
		do
			const frame = panel(size[1], size[2], strip)
			const label = `{size[1]}x{size[2]} strip {strip}`
			Spec.equal(frame.top >= math.max(strip, 56) + 8, true, `{label}: below the strip and the row`)
			Spec.equal(frame.top + frame.height <= size[2], true, `{label}: on the screen`)
			Spec.equal(frame.width <= size[1] - 2 * DialogGeometry.MARGIN_SIDE_MIN, true, `{label}: off the sides`)
			if frame.clearsBottom then
				Spec.equal(frame.top + frame.height <= size[2] - BAR.band, true, `{label}: above the bar`)
			end
		end
	end
end)

Spec.test("the bar stays shown exactly while the panel keeps its room above it", function()
	-- room = height - strip - band - 24; the bar asks for 360.
	Spec.equal(panel(1000, 58 + 82 + 24 + 360, 58).clearsBottom, true, "exactly the room")
	Spec.equal(panel(1000, 58 + 82 + 24 + 359, 58).clearsBottom, false, "one short")
	Spec.equal(panel(1000, 82 + 24 + 360, 0).clearsBottom, true, "no strip")
end)

Spec.test("a game with nothing at the bottom gives the panel the whole height", function()
	Spec.equal(DialogGeometry.layout(1920, 1080, 58, 760, 600, nil), {
		width = 760,
		height = 600,
		top = 240,
		clearsBottom = true,
		tight = false,
	}, "centred on the device")
	Spec.equal(DialogGeometry.layout(870, 639, 58, 760, 600), {
		width = 696,
		height = 528,
		top = 84,
		clearsBottom = true,
		tight = false,
	}, "taller by the band it does not keep")
	Spec.equal(DialogGeometry.layout(801, 392, 58, 760, 600).clearsBottom, true, "nothing to cover")
	Spec.equal(DialogGeometry.layout(1024, 768, 0, 760, 600).top, 84, "framed, not squeezed")
end)

Spec.test("a narrow dialog is centred with the air its width leaves", function()
	-- 460 wide at most on an 870 screen: 205 a side.
	const frame = DialogGeometry.layout(870, 639, 58, 460, 330, BAR)
	Spec.equal(frame, { width = 460, height = 330, top = 113, clearsBottom = true, tight = false })
	Spec.equal(DialogGeometry.layout(870, 639, 58, 620, 600, BAR).width, 620, "a wider one")
end)

Spec.test("at Roblox's scale of its bar the panel is laid out in its points and fits", function()
	-- a television: 1920 by 1080 under a strip of 87, half again a computer's 58
	const points = DialogGeometry.layout(1280, 720, 58, 760, 600, nil)
	const tv = DialogGeometry.scaled(1920, 1080, 87, 760, 600, nil, 1.5)
	Spec.equal(tv.width, points.width, "its width in points")
	Spec.equal(tv.height, points.height, "its height in points")
	Spec.equal(tv.top, math.floor(points.top * 1.5), "its top in pixels")
	Spec.truthy(tv.top + tv.height * 1.5 <= 1080, "drawn at the scale, it ends on the screen")
	-- the band is in pixels too, read in points
	const band = DialogGeometry.scaled(1920, 1080, 87, 760, 600, { band = 123, room = 540 }, 1.5)
	const read = DialogGeometry.layout(1280, 720, 58, 760, 600, BAR)
	Spec.equal(band.height, read.height, "the band read in points")
	Spec.equal(band.top, math.floor(read.top * 1.5), "and the top under it in pixels")
	Spec.equal(band.clearsBottom, read.clearsBottom, "cleared as in points")
	-- A phone drawn at the bar's scale is still a screen too short to frame the dialog, and says so.
	const phone = DialogGeometry.scaled(1200, 588, 87, 760, 600, nil, 1.5)
	Spec.truthy(phone.tight, "tight at the bar's scale too")
	Spec.equal(phone.top, math.floor(DialogGeometry.layout(800, 392, 58, 760, 600, nil).top * 1.5), "its top")
end)

Spec.test("at a computer's scale, or none read, the panel is laid out as it always was", function()
	const flat = DialogGeometry.layout(1920, 1080, 58, 760, 600, BAR)
	Spec.equal(DialogGeometry.scaled(1920, 1080, 58, 760, 600, BAR, 1), flat, "a scale of 1")
	Spec.equal(DialogGeometry.scaled(1920, 1080, 58, 760, 600, BAR, 0), flat, "none read")
end)

Spec.test("a page takes the whole screen, from its own top edge, at the bar's scale", function()
	Spec.equal(
		DialogGeometry.page(1920, 1080, 1),
		{ width = 1920, height = 1080, top = 0, clearsBottom = true, tight = true }
	)
	-- A television draws its bar half again as large, and the page is laid out in its own pixels
	Spec.equal(
		DialogGeometry.page(1920, 1080, 1.5),
		{ width = 1280, height = 720, top = 0, clearsBottom = true, tight = true }
	)
	-- A tiny phone, and a scale that is nonsense: never a page divided by nothing
	Spec.equal(
		DialogGeometry.page(666, 375, 1),
		{ width = 666, height = 375, top = 0, clearsBottom = true, tight = true }
	)
	Spec.equal(
		DialogGeometry.page(666, 375, 0),
		{ width = 666, height = 375, top = 0, clearsBottom = true, tight = true }
	)
end)

Spec.test("short scaled dialogs keep their footer on the screen and honor the caller cap", function()
	const one = DialogGeometry.scaled(812, 375, 58, 624, 382, nil, 1.5)
	Spec.equal(one.top, 96, "one and a half: top row clear")
	Spec.equal(one.height, 174, "one and a half: remaining points")
	Spec.equal(one.top + one.height * 1.5, 357, "footer above bottom margin")
	const two = DialogGeometry.scaled(812, 375, 58, 624, 382, nil, 2)
	Spec.equal(two.top, 128, "double: top row clear")
	Spec.equal(two.height, 111, "double: remaining points")
	Spec.equal(two.top + two.height * 2, 350, "double: footer above bottom margin")
	Spec.equal(DialogGeometry.layout(812, 375, 58, 624, 150).height, 150, "small caller cap")
	Spec.equal(DialogGeometry.layout(812, 375, 58, 624, 300).height, 246, "tight caller cap")
	Spec.equal(DialogGeometry.layout(280, 40, 70, 624, 382).height, 0, "no negative body")
end)

return {}
