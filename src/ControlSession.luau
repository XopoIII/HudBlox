--!strict
--- Protocol coordination; native discovery is injected, never emulated by this module.
const Switch = require("./ControlSwitch")
const ControlSession = {}
export type Session = { controls: Switch.Held?, gui: Switch.Held? }
function ControlSession.new(): Session
	return { controls = nil, gui = nil }
end
const function same(held: Switch.Held?, binding: Switch.Binding?): boolean
	return (held == nil and binding == nil) or (held ~= nil and binding ~= nil and held.binding.key == binding.key)
end
function ControlSession.step(session: Session, controls: Switch.Binding?, gui: Switch.Binding?)
	const changeControls = not same(session.controls, controls)
	const changeGui = not same(session.gui, gui)
	-- Snapshot both replacements before any sibling restore or suppression write.
	local capturedControls: boolean? = nil
	if changeControls and controls then
		const ok, value = pcall(controls.read)
		if ok then
			capturedControls = value
		end
	end
	local captured: boolean? = nil
	if changeGui and gui then
		const ok, value = pcall(gui.read)
		if ok then
			captured = value
		end
	elseif session.gui then
		Switch.poll(session.gui)
	end
	const observer = session.gui
	if observer then
		observer.writing = true
	end
	if changeControls then
		Switch.disconnect(session.controls)
	end
	if changeGui then
		Switch.disconnect(session.gui)
	end
	if changeControls then
		Switch.restore(session.controls)
		session.controls = nil
	end
	if changeGui then
		Switch.restore(session.gui)
		session.gui = nil
	end
	if controls then
		if session.controls == nil then
			session.controls = Switch.begin(controls, capturedControls)
		end
		if session.controls then
			Switch.poll(session.controls)
		end
	end
	if observer then
		observer.writing = false
	end
	if gui then
		if session.gui == nil then
			session.gui = Switch.begin(gui, captured)
		end
		if session.gui then
			Switch.reassert(session.gui)
		end
	end
end
function ControlSession.finish(session: Session, liveGui: (() -> Switch.Binding?)?)
	Switch.disconnect(session.controls)
	Switch.disconnect(session.gui)
	const before = if liveGui then liveGui() else nil
	const unadopted = before and (not session.gui or before.key ~= session.gui.binding.key)
	local intent = if session.gui then session.gui.intent else nil
	if unadopted and before then
		const ok, observed = pcall(before.read)
		intent = if ok then observed else nil
	end
	Switch.restore(session.controls)
	if liveGui then
		const current = liveGui()
		if not current or (session.gui and current.key ~= session.gui.binding.key) then
			Switch.restore(session.gui)
		end
		local unchanged = false
		if current and unadopted and before and current.key == before.key then
			const ok, observed = pcall(current.read)
			unchanged = ok and observed == intent
		end
		if current and intent ~= nil and not unchanged then
			pcall(current.write, intent)
		end
	else
		Switch.restore(session.gui)
	end
	session.controls = nil
	session.gui = nil
end
return ControlSession
