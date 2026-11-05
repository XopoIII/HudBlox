--!strict
--- Lazy discovery; missing, failed and replaced modules are retried only while owned.
const Protocol = require("./ControlProtocol")
const Switch = require("./ControlSwitch")
const ControlBackend = {}
const function load(resolve: () -> Instance?): unknown
	const module = resolve()
	if not (module and module:IsA("ModuleScript")) then
		return nil
	end
	const ok, value = pcall(require, module)
	-- require can yield: never adopt a resource replaced while loading.
	return if ok and resolve() == module then value else nil
end
function ControlBackend.sources(): { unknown }
	const sources: { unknown } = {}
	const starter = game:GetService("StarterPlayer"):FindFirstChild("PlayerModule")
	const player = game:GetService("Players").LocalPlayer
	const scripts = if player then player:FindFirstChild("PlayerScripts") else nil
	const module = if scripts then scripts:FindFirstChild("PlayerModule") else nil
	const a = if starter then starter:FindFirstChild("ControlModule") else nil
	const b = if module then module:FindFirstChild("ControlModule") else nil
	if a then
		table.insert(sources, a)
	end
	if b then
		table.insert(sources, b)
	end
	if module then
		table.insert(sources, module)
	end
	return sources
end
function ControlBackend.find(): Switch.Binding?
	return Protocol.choose(function()
		return load(function()
			const module = game:GetService("StarterPlayer"):FindFirstChild("PlayerModule")
			return if module then module:FindFirstChild("ControlModule") else nil
		end)
	end, function()
		return load(function()
			const player = game:GetService("Players").LocalPlayer
			const scripts = if player then player:FindFirstChild("PlayerScripts") else nil
			const module = if scripts then scripts:FindFirstChild("PlayerModule") else nil
			return if module then module:FindFirstChild("ControlModule") else nil
		end)
	end, function()
		return load(function()
			const player = game:GetService("Players").LocalPlayer
			const scripts = if player then player:FindFirstChild("PlayerScripts") else nil
			return if scripts then scripts:FindFirstChild("PlayerModule") else nil
		end)
	end)
end
return ControlBackend
