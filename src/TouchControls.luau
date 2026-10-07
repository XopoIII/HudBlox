--!strict
--- Hides the platform's thumbstick and jump button while a dialog owns the screen, and holds the
--- character still under it.
---
--- They are core UI, so no ZIndex of a game's gets above them; the only way a dialog covers them is
--- for them not to be there. `ControlModule:Disable()` also zeroes the move vector: hiding only
--- `TouchGui` left the character walking off on the last stick position while the player read the
--- dialog.
---
--- Keyed by reason, so two surfaces can overlap: one closing never shows the controls while the
--- other still wants them hidden.
---
--- On a gamepad there is nothing to hide, but the stick that moves the focus would walk the
--- character too, so the controls are held the same way while the pad is in use (`PadInput`). On a
--- keyboard this does nothing.
const PadInput = require("./PadInput")

const TouchControls = {}

const reasons: { [string]: true } = {}
local controls: any = nil
local hidden = false
local held = false
local following = false

-- Found lazily and without WaitForChild: a wait here would hang whatever asked before the
-- PlayerModule exists.
const function getControls(): any
	if controls then
		return controls
	end
	const player = game:GetService("Players").LocalPlayer
	const scripts = if player then player:FindFirstChild("PlayerScripts") else nil
	const module = if scripts then scripts:FindFirstChild("PlayerModule") else nil
	if not (module and module:IsA("ModuleScript")) then
		return nil
	end
	const ok, api = pcall(function(): any
		return (require(module) :: any):GetControls()
	end)
	if ok then
		controls = api
	end
	return controls
end

const function touchGui(): ScreenGui?
	const player = game:GetService("Players").LocalPlayer
	const playerGui = if player then player:FindFirstChildOfClass("PlayerGui") else nil
	const gui = if playerGui then playerGui:FindFirstChild("TouchGui") else nil
	return if gui and gui:IsA("ScreenGui") then gui else nil
end

const function apply()
	const want = next(reasons) ~= nil
	const touch = game:GetService("UserInputService").TouchEnabled
	const hold = want and (touch or PadInput.active())
	if hold ~= held then
		held = hold
		const api = getControls()
		if api then
			pcall(function()
				if hold then
					api:Disable()
				else
					api:Enable()
				end
			end)
		end
	end
	if not touch or want == hidden then
		return
	end
	hidden = want
	-- After the controls, both ways: `Enable` rebuilds its frames inside this gui, so switching it
	-- on last is what leaves them visible.
	const gui = touchGui()
	if gui then
		gui.Enabled = not want
	end
end

--> `reason` names the surface asking. Idempotent in both directions.
function TouchControls.set(reason: string, hide: boolean)
	if not following then
		following = true
		PadInput.onChange(apply)
	end
	reasons[reason] = if hide then true else nil
	apply()
end

return TouchControls
