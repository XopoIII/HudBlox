--!strict
--- Validation and backend preference over unknown loaded values, independent of Instances.
const Switch = require("./ControlSwitch")
const ControlProtocol = {}
type Modern = { Enabled: boolean }
type Legacy = { Enable: (unknown) -> (), Disable: (unknown) -> () }
type PlayerApi = { GetControls: (unknown) -> unknown }
function ControlProtocol.modern(value: unknown): Switch.Binding?
	if type(value) ~= "table" then
		return nil
	end
	const fields = value :: { [string]: unknown }
	if type(fields.Enabled) ~= "boolean" then
		return nil
	end
	const api = value :: Modern
	return {
		key = api,
		read = function()
			return api.Enabled
		end,
		write = function(enabled)
			api.Enabled = enabled
		end,
	}
end
function ControlProtocol.legacy(value: unknown): Switch.Binding?
	if type(value) ~= "table" then
		return nil
	end
	const fields = value :: { [string]: unknown }
	if type(fields.GetControls) ~= "function" then
		return nil
	end
	const playerApi = value :: PlayerApi
	const ok, controls = pcall(playerApi.GetControls, value)
	if not ok or type(controls) ~= "table" then
		return nil
	end
	const members = controls :: { [string]: unknown }
	if type(members.Enable) ~= "function" or type(members.Disable) ~= "function" then
		return nil
	end
	const api = controls :: Legacy
	return {
		key = api,
		-- No verified getter: release is best-effort Enable, not an exact snapshot.
		read = function()
			return nil
		end,
		write = function(enabled)
			if enabled then
				api.Enable(api)
			else
				api.Disable(api)
			end
		end,
	}
end
function ControlProtocol.choose(starter: () -> unknown, scripts: () -> unknown, legacy: () -> unknown): Switch.Binding?
	return ControlProtocol.modern(starter()) or ControlProtocol.modern(scripts()) or ControlProtocol.legacy(legacy())
end
return ControlProtocol
