--!strict
--- What a press on a backpack slot that is still down has become: nothing yet, a drag, or a scroll.
--- Pure arithmetic, so every rule is a spec (`tests/unit/BackpackPress.luau`); `Gesture` follows the
--- press itself.
---
--- - A **mouse**, and a finger on the **bar**, starts a drag once it has moved `DRAG_PX`.
--- - A finger in the **inventory** shares it with scrolling: holding still `HOLD_S` picks the slot
---   up, and so does a mostly sideways move; a mostly vertical one is a scroll, and the press is let
---   go.
const Press = {}

--- How far a press moves before it is a drag, in pixels.
Press.DRAG_PX = 6
--- How long a finger holds still in the inventory before it picks a slot up, in seconds.
Press.HOLD_S = 0.2
--- The desktop's own double-click window, in seconds; tighter missed real double taps.
Press.DOUBLE_S = 0.5

export type Pointer = "mouse" | "touch"
export type Zone = "bar" | "grid"
export type Verdict = "wait" | "drag" | "scroll"

--> What a press by `pointer` on a slot of `zone` has become, having moved `dx` and `dy` pixels from
--> where it began and been down `held` seconds.
function Press.classify(pointer: Pointer, zone: Zone, dx: number, dy: number, held: number): Verdict
	const far = math.sqrt(dx * dx + dy * dy) >= Press.DRAG_PX
	if pointer == "mouse" or zone == "bar" then
		return if far then "drag" else "wait"
	end
	if held >= Press.HOLD_S then
		return "drag"
	end
	if not far then
		return "wait"
	end
	return if math.abs(dx) > math.abs(dy) then "drag" else "scroll"
end

return Press
