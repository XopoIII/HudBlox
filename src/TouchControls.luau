--!strict
--- Token holds stop movement for every input. Legacy set bits retain touch/pad semantics.
const Backend = require("./ControlBackend")
const Gui = require("./ControlGui")
const Holds = require("./ControlHolds")
const Runner = require("./ControlRunner")
const TouchControls = {}
export type Release = () -> ()
const book = Holds.new()
local loader: thread? = nil
const runner = Runner.new(
	Backend.find,
	Gui.find,
	function(fn)
		loader = task.spawn(fn)
	end,
	Backend.sources,
	function()
		if loader and coroutine.status(loader) ~= "dead" then
			pcall(task.cancel, loader)
		end
		loader = nil
	end
)
const listeners: { RBXScriptConnection } = {}
local running = false
local elapsed = 0
const function apply()
	const input = game:GetService("UserInputService")
	const pad = input.PreferredInput == Enum.PreferredInput.Gamepad
		or (game:GetService("RunService"):IsStudio() and workspace:GetAttribute("PadCheck") == true)
	const movement, touch = Holds.wants(book, input.TouchEnabled, pad)
	if not Holds.active(book) then
		running = false
		for _, connection in listeners do
			connection:Disconnect()
		end
		table.clear(listeners)
		-- Invalidate queued callbacks before controls rebuild the GUI, then restore the LIVE GUI.
	end
	Runner.step(runner, Holds.active(book), movement, touch)
end
const function start()
	if running then
		return
	end
	running = true
	elapsed = 0
	const input = game:GetService("UserInputService")
	table.insert(listeners, input:GetPropertyChangedSignal("PreferredInput"):Connect(apply))
	table.insert(listeners, input:GetPropertyChangedSignal("TouchEnabled"):Connect(apply))
	const run = game:GetService("RunService")
	if run:IsStudio() then
		table.insert(listeners, workspace:GetAttributeChangedSignal("PadCheck"):Connect(apply))
	end
	-- One bounded reconciliation loop only while there is ownership. Modern tables have no signal.
	table.insert(
		listeners,
		run.Heartbeat:Connect(function(dt)
			elapsed += dt
			if elapsed >= 0.1 then
				elapsed = 0
				apply()
			end
		end)
	)
end
function TouchControls.hold(reason: string): Release
	return Holds.hold(book, reason, function()
		if Holds.active(book) then
			start()
		end
		apply()
	end)
end
function TouchControls.set(reason: string, hide: boolean)
	Holds.set(book, reason, hide)
	if Holds.active(book) then
		start()
	end
	if running then
		apply()
	end
end
return TouchControls
