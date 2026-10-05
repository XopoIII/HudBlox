--!strict
--- How high a bottom-corner read-out stands to clear the thumbstick and the jump button: the
--- arithmetic, without the Instances. `TouchClearance` reads the controls and hands them in.
---
--- Measured from the controls themselves rather than guessed from the device type: their size and
--- place change with the screen, and Studio's device emulation keeps a keyboard, so a
--- `TouchEnabled and not KeyboardEnabled` switch leaves a read-out under the jump button there.
const Clearance = {}

--- One touch control as the engine reports it: its `AbsolutePosition.Y`, and whether it is shown.
export type Control = { top: number, visible: boolean }

--> Pixels from `bottom` (the lower edge of the touch-control frame, which is the screen's) up to
--> the top of the highest VISIBLE control. 0 when none is visible. The tallest sets one height for
--> both corners.
function Clearance.height(bottom: number, controls: { Control }): number
	local top = bottom
	for _, control in controls do
		if control.visible then
			top = math.min(top, control.top)
		end
	end
	return math.max(0, bottom - top)
end

--> How far above the screen's bottom edge a read-out's lower edge belongs: `margin` above the
--> controls, or `margin` above the edge when there are none.
function Clearance.base(margin: number, height: number): number
	return margin + height
end

--> The same for the `index`-th read-out of a corner stack (1 is the lowest), each `size` tall and
--> `gap` apart.
function Clearance.stacked(base: number, index: number, size: number, gap: number): number
	return base + (index - 1) * (size + gap)
end

return Clearance
