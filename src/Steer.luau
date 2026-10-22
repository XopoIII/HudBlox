--!strict
--- Where a gamepad's press goes from the control in focus, the same in every panel: each way, the
--- control `Pick.toward` names, written on the control in focus as the engine's `NextSelection`
--- of that way. The engine's own walk stops where nothing stands straight in line (the middle
--- column of a grid whose last row has one card); this one goes to the nearest beside the line.
---
--- A way the game wrote on a control itself is kept: only the ways written here are written again,
--- and a way with nothing that way leads to the control itself, so the ring stays.
const Pick = require("./Pick")

const Steer = {}

export type Way = "up" | "down" | "left" | "right"

const WAYS: { { way: Way, dx: number, dy: number } } = {
	{ way = "up", dx = 0, dy = -1 },
	{ way = "down", dx = 0, dy = 1 },
	{ way = "left", dx = -1, dy = 0 },
	{ way = "right", dx = 1, dy = 0 },
}

--- The attribute a control keeps the ways written here in, as their initials ("udlr"): what a game
--- wrote itself is never among them.
Steer.ATTRIBUTE = "PadSteer"

const function get(object: GuiObject, way: Way): GuiObject?
	return if way == "up"
		then object.NextSelectionUp
		elseif way == "down" then object.NextSelectionDown
		elseif way == "left" then object.NextSelectionLeft
		else object.NextSelectionRight
end

-- `to` the control itself where nothing stands that way: the ring stays, as at a panel's edge
const function put(object: GuiObject, way: Way, to: GuiObject)
	if way == "up" then
		object.NextSelectionUp = to
	elseif way == "down" then
		object.NextSelectionDown = to
	elseif way == "left" then
		object.NextSelectionLeft = to
	else
		object.NextSelectionRight = to
	end
end

--> Writes on `object`, the control in focus, where each way goes among `controls`, those `usable`
--> (shown in the panel and selectable) counted, in a locale read from the right when `rtl`.
function Steer.aim(object: GuiObject, controls: { GuiObject }, usable: (GuiObject) -> boolean, rtl: boolean)
	const candidates: { GuiObject } = {}
	const targets: { Pick.Target } = {}
	for _, control in controls do
		if control ~= object and control.Selectable then
			const corner, size = control.AbsolutePosition, control.AbsoluteSize
			table.insert(candidates, control)
			table.insert(targets, {
				x = corner.X + size.X / 2,
				y = corner.Y + size.Y / 2,
				order = 0,
				shown = size.X > 0 and usable(control),
				selectable = true,
			})
		end
	end
	const from = object.AbsolutePosition + object.AbsoluteSize / 2
	const before = object:GetAttribute(Steer.ATTRIBUTE)
	const mine = if type(before) == "string" then before else ""
	local now = ""
	for _, each in WAYS do
		const initial = string.sub(each.way, 1, 1)
		if get(object, each.way) == nil or string.find(mine, initial, 1, true) then
			const index = Pick.toward(targets, from.X, from.Y, each.dx, each.dy, rtl)
			put(object, each.way, if index then candidates[index] else object)
			now ..= initial
		end
	end
	object:SetAttribute(Steer.ATTRIBUTE, now)
end

return Steer
