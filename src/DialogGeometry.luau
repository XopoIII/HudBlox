--!strict
--- Where a dialog's panel sits and how big it is, for a given screen. Pure arithmetic, so every rule
--- is a spec (`tests/unit/DialogGeometry.luau`); `Dialog` reads the numbers off the engine.
---
--- - **Framed** (a screen with room): the panel is capped by the caller's width and height and
---   centred on the device, with equal air above and below (`MARGIN_TOP_F` of the usable height, at
---   least `MARGIN_TOP_MIN`).
--- - **Under the strip** (too short to frame, tall enough to spare Roblox's top bar): the panel
---   starts below the platform's buttons, the same air under it.
--- - **Full height** (a landscape phone): the margins would eat the panel, so it takes the device
---   less `TIGHT_MARGIN` top and bottom.
---
--- **Never over the top row.** Whatever the mode, a panel starts below Roblox's strip and below the
--- kit's own row of buttons beside it (`TOP_ROW_BOTTOM`), and gives up that much height rather than
--- overlap: on a phone a dialog that shared that band covered the buttons at the top.
---
--- The switch is the screen's measured height, never whether it has touch, so a device emulator
--- shows exactly what a phone gets.
---
--- **The bottom band** is whatever a game keeps at the bottom of the screen (a hotbar). Where the
--- screen has room the panel keeps above it. Where it has not (a landscape phone) the panel takes
--- the height it needs and says so (`clearsBottom` false), and the game hides the band while the
--- dialog is up.
const Measure = require("./Measure")

const DialogGeometry = {}

DialogGeometry.MARGIN_TOP_F = 0.045
DialogGeometry.MARGIN_SIDE_F = 0.10
DialogGeometry.MARGIN_TOP_MIN = 12
DialogGeometry.MARGIN_SIDE_MIN = 16
--- Below these the rows of a dialog stop fitting at all.
DialogGeometry.CARD_W_MIN = 280
DialogGeometry.CARD_H_MIN = 240
DialogGeometry.TIGHT_MARGIN = 12
--- A screen this tall below Roblox's strip can give the strip away and still hold a real panel
--- (measured on an 835 x 679 desktop window).
DialogGeometry.STRIP_CLEAR_MIN = 440
--- Where the kit's own top row ends: `Measure.TOP` and a capsule's height.
DialogGeometry.TOP_ROW_BOTTOM = Measure.TOP + Measure.HEIGHT
--- Air between that row and a panel.
DialogGeometry.ROW_GAP = 8

--- What a game keeps at the bottom of the screen.
export type Bottom = {
	--- The height it takes, a gap included.
	band: number,
	--- The least a panel must keep above it for the band to stay shown.
	room: number,
}

export type Frame = {
	--- The panel's size in pixels.
	width: number,
	height: number,
	--- The panel's top edge. It is centred sideways.
	top: number,
	--- Whether the panel ends above the bottom band; if not, it covers it.
	clearsBottom: boolean,
}

--> The panel on a screen `width` by `height` (an edge-to-edge ScreenGui that ignores the gui inset)
--> under a platform strip `strip` tall; no wider than `maxW` and no taller than `maxH`. `bottom` is
--> the game's bottom band, if it has one.
-->
--> The panel always starts below the strip, so its header never shares a line with Roblox's own
--> buttons and needs no step aside.
function DialogGeometry.layout(
	width: number,
	height: number,
	strip: number,
	maxW: number,
	maxH: number,
	bottom: Bottom?
): Frame
	-- The panel never starts above this: the strip, and the kit's row beside it.
	const clear = math.max(strip, DialogGeometry.TOP_ROW_BOTTOM) + DialogGeometry.ROW_GAP
	-- Everything below works in the screen above the bottom band, when it keeps room.
	local clearsBottom = true
	local band = 0
	if bottom then
		const room = height - strip - bottom.band - DialogGeometry.MARGIN_TOP_MIN * 2
		clearsBottom = room >= bottom.room
		band = if clearsBottom then bottom.band else 0
	end
	const viewH = height - band
	const usableH = height - strip - band
	const side = math.max(DialogGeometry.MARGIN_SIDE_MIN, width * DialogGeometry.MARGIN_SIDE_F, (width - maxW) * 0.5)
	const w = math.max(width - side * 2, DialogGeometry.CARD_W_MIN)

	const margin = math.max(DialogGeometry.MARGIN_TOP_MIN, usableH * DialogGeometry.MARGIN_TOP_F)
	local h: number
	local top: number
	if usableH - margin * 2 < maxH then
		const below = viewH - strip - margin * 2
		if below >= DialogGeometry.STRIP_CLEAR_MIN then
			h = math.min(math.max(below, DialogGeometry.CARD_H_MIN), maxH)
			top = strip + (viewH - strip - h) * 0.5
		else
			const tight = DialogGeometry.TIGHT_MARGIN
			h = math.max(viewH - tight * 2, DialogGeometry.CARD_H_MIN)
			top = tight
		end
	else
		-- Centred on the device, not on the area under the strip: the strip is at the top only, and
		-- centring below it left twice the air above.
		h = math.min(math.max(usableH - margin * 2, DialogGeometry.CARD_H_MIN), maxH)
		top = (viewH - h) * 0.5
	end

	-- Below the strip and the row: the bottom edge stays where it was.
	if top < clear then
		h = math.max(h - (clear - top), DialogGeometry.CARD_H_MIN)
		top = clear
	end

	return {
		width = math.floor(w),
		height = math.floor(h),
		top = math.floor(top),
		clearsBottom = clearsBottom,
	}
end

return DialogGeometry
