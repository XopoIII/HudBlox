--!strict
--- Whether the player is on a gamepad right now.
---
--- The engine's own answer (`UserInputService.PreferredInput`), which flips as the player moves from
--- the mouse to the pad and back, so the focus ring, the button pictures and the held controls all
--- follow one switch.
---
--- In Studio only, a `PadCheck = true` attribute on Workspace answers yes whatever the engine says:
--- a test bridge can send a pad's key codes but they arrive as a keyboard's, so nothing else would
--- let a pad's interface be checked there.
---
--- Nothing is connected until somebody asks: requiring this module touches no service.
const PadInput = {}

--- The Workspace attribute that forces a gamepad in Studio.
PadInput.STUDIO_ATTRIBUTE = "PadCheck"

const listeners: { [(active: boolean) -> ()]: true } = {}
local started = false
local active = false

const function read(studio: boolean): boolean
	if studio and game:GetService("Workspace"):GetAttribute(PadInput.STUDIO_ATTRIBUTE) == true then
		return true
	end
	return game:GetService("UserInputService").PreferredInput == Enum.PreferredInput.Gamepad
end

const function start()
	if started then
		return
	end
	started = true
	const studio = game:GetService("RunService"):IsStudio()
	active = read(studio)
	const function refresh()
		const now = read(studio)
		if now ~= active then
			active = now
			for listener in table.clone(listeners) do
				if listeners[listener] then
					listener(now)
				end
			end
		end
	end
	game:GetService("UserInputService"):GetPropertyChangedSignal("PreferredInput"):Connect(refresh)
	if studio then
		game:GetService("Workspace"):GetAttributeChangedSignal(PadInput.STUDIO_ATTRIBUTE):Connect(refresh)
	end
end

--> Whether the player is on a gamepad now.
function PadInput.active(): boolean
	start()
	return active
end

--> Calls `changed` with the new answer when the player takes up or puts down the pad. Returns the
--> function that stops it.
function PadInput.onChange(changed: (active: boolean) -> ()): () -> ()
	start()
	const function listener(now: boolean)
		changed(now)
	end
	listeners[listener] = true
	return function()
		listeners[listener] = nil
	end
end

return PadInput
