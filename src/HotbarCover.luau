--!strict
--- Hides a game's hotbar while something that covers it is up (a dialog too tall to end above it,
--- `Dialog`'s `cover`), and keeps Roblox's own backpack switched off under a hotbar the game draws
--- itself (`Backpack`).
---
--- Roblox's CoreGui backpack cannot be opened from a script, so a game that wants a button for its
--- inventory draws the stock layout itself, and Roblox's must never show under it. Switching it off
--- can fail while the core scripts are still starting, so it is retried.
---
--- Keyed by reason, as `TouchControls` is, so two dialogs can overlap: one closing never brings the
--- hotbar back while the other still covers it.
const HotbarCover = {}

const reasons: { [string]: true } = {}
const listeners: { [(hidden: boolean) -> ()]: true } = {}
local hidden = false

--> Whether anything covers the hotbar now.
function HotbarCover.hidden(): boolean
	return hidden
end

--> `reason` names the surface asking; it asks for the hotbar hidden (`hide` true) or stops asking.
--> Asking twice is asking once.
function HotbarCover.set(reason: string, hide: boolean)
	reasons[reason] = if hide then true else nil
	const want = next(reasons) ~= nil
	if want == hidden then
		return
	end
	hidden = want
	for listener in table.clone(listeners) do
		if listeners[listener] then
			listener(want)
		end
	end
end

--> Calls `changed` with the new state whenever the hotbar becomes hidden or shown again. Returns the
--> function that stops it.
function HotbarCover.onChange(changed: (hidden: boolean) -> ()): () -> ()
	-- A wrapper, so the same function passed twice is two listeners.
	const function listener(now: boolean)
		changed(now)
	end
	listeners[listener] = true
	return function()
		listeners[listener] = nil
	end
end

--> Switches Roblox's own backpack off for the session. No event says the core scripts are ready
--> to hear it and asking too early throws, so it is retried for a while.
function HotbarCover.disableCore()
	task.spawn(function()
		const starterGui = game:GetService("StarterGui")
		for _ = 1, 20 do
			const ok = pcall(function()
				starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
			end)
			if ok and not starterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack) then
				return
			end
			task.wait(0.5)
		end
	end)
end

return HotbarCover
