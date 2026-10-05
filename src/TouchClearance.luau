--!strict
--- Reads the platform's thumbstick and jump button, so a bottom-corner read-out can stand above
--- them. The arithmetic is `Clearance`'s, where the specs are.
---
--- 0 on a screen without touch controls.
const Clearance = require("./Clearance")

const TouchClearance = {}

-- The PlayerModule's pieces a thumb rests on. DynamicThumbstickFrame is left out: it is the whole
-- invisible left half of the screen the stick may start in.
const CONTROLS: { [string]: true } = { JumpButton = true, ThumbstickFrame = true, ThumbstickStart = true }

const function touchGui(): ScreenGui?
	const player = game:GetService("Players").LocalPlayer
	const playerGui = if player then player:FindFirstChildOfClass("PlayerGui") else nil
	const gui = if playerGui then playerGui:FindFirstChild("TouchGui") else nil
	return if gui and gui:IsA("ScreenGui") then gui else nil
end

--> Pixels from the screen's bottom edge to the top of the highest visible control.
function TouchClearance.height(): number
	if not game:GetService("UserInputService").TouchEnabled then
		return 0
	end
	const gui = touchGui()
	const frame = if gui then gui:FindFirstChild("TouchControlFrame") else nil
	if not (frame and frame:IsA("GuiObject")) then
		return 0
	end
	const controls: { Clearance.Control } = {}
	for _, piece in frame:GetDescendants() do
		if CONTROLS[piece.Name] and piece:IsA("GuiObject") then
			table.insert(controls, { top = piece.AbsolutePosition.Y, visible = piece.Visible })
		end
	end
	return Clearance.height(frame.AbsolutePosition.Y + frame.AbsoluteSize.Y, controls)
end

--> How far above the screen's bottom edge a corner read-out's lower edge belongs right now:
--> `margin` above the controls, or above the edge where there are none.
function TouchClearance.base(margin: number): number
	return Clearance.base(margin, TouchClearance.height())
end

--> Calls `changed` whenever the controls arrive, move, hide or the screen turns. Returns the
--> function that stops it. Does nothing on a screen without touch.
function TouchClearance.follow(changed: () -> ()): () -> ()
	if not game:GetService("UserInputService").TouchEnabled then
		return function() end
	end
	const connections: { RBXScriptConnection } = {}
	const function watch(piece: Instance)
		if CONTROLS[piece.Name] and piece:IsA("GuiObject") then
			table.insert(connections, piece:GetPropertyChangedSignal("AbsolutePosition"):Connect(changed))
			table.insert(connections, piece:GetPropertyChangedSignal("Visible"):Connect(changed))
			changed()
		end
	end
	const player = game:GetService("Players").LocalPlayer
	const playerGui = player:WaitForChild("PlayerGui")
	table.insert(connections, playerGui.DescendantAdded:Connect(watch))
	for _, piece in playerGui:GetDescendants() do
		watch(piece)
	end
	const camera = game:GetService("Workspace").CurrentCamera
	if camera then
		table.insert(connections, camera:GetPropertyChangedSignal("ViewportSize"):Connect(changed))
	end
	return function()
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
	end
end

return TouchClearance
