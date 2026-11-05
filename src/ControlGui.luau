--!strict
--- The live TouchGui, including one created after a hold began.
const Switch = require("./ControlSwitch")
const ControlGui = {}
function ControlGui.find(): Switch.Binding?
	const player = game:GetService("Players").LocalPlayer
	const playerGui = if player then player:FindFirstChildOfClass("PlayerGui") else nil
	const gui = if playerGui then playerGui:FindFirstChild("TouchGui") else nil
	if not (gui and gui:IsA("ScreenGui")) then
		return nil
	end
	return {
		key = gui,
		read = function()
			return gui.Enabled
		end,
		write = function(enabled)
			gui.Enabled = enabled
		end,
		defer = function(callback)
			task.defer(callback)
		end,
		watch = function(changed)
			const connection = gui:GetPropertyChangedSignal("Enabled"):Connect(function()
				changed(gui.Enabled)
			end)
			return function()
				connection:Disconnect()
			end
		end,
	}
end
return ControlGui
