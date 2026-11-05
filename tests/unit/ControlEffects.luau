--!strict
--- Backend-GUI side-effect protocol fixtures, not native acceptance.
const Session = require("../../src/ControlSession")
const Spec = require("../Spec")
const Switch = require("../../src/ControlSwitch")
const function fixture(initial: boolean, deferred: boolean?)
	local value = initial
	local listener: ((boolean) -> ())? = nil
	local queue: { () -> () } = {}
	local live: Switch.Binding? = nil
	const function notify(enabled: boolean)
		value = enabled
		if listener then
			const fn = listener
			if deferred then
				table.insert(queue, function()
					fn(value)
				end)
			else
				fn(value)
			end
		end
	end
	const gui: Switch.Binding = {
		key = {},
		read = function()
			return value
		end,
		write = notify,
		watch = function(fn)
			listener = fn
			return function()
				listener = nil
			end
		end,
	}
	live = gui
	const function controls(initialEnabled: boolean?): Switch.Binding
		local enabled = if initialEnabled == nil then true else initialEnabled
		return {
			key = {},
			read = function()
				return enabled
			end,
			write = function(nextValue)
				enabled = nextValue
				if live then
					live.write(nextValue)
				end
			end,
		}
	end
	return {
		gui = gui,
		controls = controls,
		notify = notify,
		replace = function(nextGui: Switch.Binding)
			live = nextGui
		end,
		flush = function()
			const batch = queue
			queue = {}
			for _, fn in batch do
				fn()
			end
		end,
		read = function()
			return value
		end,
	}
end
Spec.test("controls gui snapshots before backend side effect", function()
	for _, initial in { true, false } do
		const f = fixture(initial)
		const session = Session.new()
		Session.step(session, f.controls(), f.gui)
		Spec.equal(f.read(), false)
		assert(session.gui, "GUI must be adopted")
		Spec.equal(session.gui.intent, initial)
		Session.finish(session, function()
			return f.gui
		end)
		Spec.equal(f.read(), initial)
	end
end)
Spec.test("controls backend replacement own reenable preserves gui intent", function()
	for _, initial in { true, false } do
		const f = fixture(initial)
		const session = Session.new()
		Session.step(session, f.controls(), f.gui)
		Session.step(session, f.controls(), f.gui)
		Spec.equal(f.read(), false)
		assert(session.gui, "GUI must remain adopted")
		Spec.equal(session.gui.intent, initial)
		Session.finish(session, function()
			return f.gui
		end)
		Spec.equal(f.read(), initial)
	end
end)
Spec.test("controls runner preadoption before backend side effect", function()
	const Runner = require("../../src/ControlRunner")
	for _, initial in { true, false } do
		const f = fixture(initial)
		const backend = f.controls()
		const runner = Runner.new(function()
			return backend
		end, function()
			return f.gui
		end, function(fn)
			fn()
		end)
		Runner.step(runner, true, true, true)
		Spec.equal(f.read(), false)
		Runner.step(runner, false, false, false)
		Spec.equal(f.read(), initial)
	end
end)
Spec.test("controls queued sibling writes and external observed intent", function()
	for _, initial in { true, false } do
		const f = fixture(initial, true)
		const session = Session.new()
		Session.step(session, f.controls(), f.gui)
		f.flush()
		Session.step(session, f.controls(), f.gui)
		f.flush()
		assert(session.gui, "GUI must remain adopted")
		Spec.equal(session.gui.intent, initial)
		Spec.equal(f.read(), false)
		f.notify(true)
		f.flush()
		Spec.equal(session.gui.intent, true)
		Spec.equal(f.read(), false)
		Session.finish(session, function()
			return f.gui
		end)
		f.flush()
		Spec.equal(f.read(), true)
	end
end)
Spec.test("controls both replacements snapshot before any sibling write", function()
	for _, deferred in { true, false } do
		for _, initial in { true, false } do
			const f = fixture(not initial, deferred)
			const nextGui = fixture(initial, deferred)
			const session = Session.new()
			Session.step(session, f.controls(), f.gui)
			f.replace(nextGui.gui)
			Session.step(session, f.controls(), nextGui.gui)
			f.flush()
			nextGui.flush()
			assert(session.gui, "Replacement GUI must be adopted")
			Spec.equal(session.gui.intent, initial)
			Spec.equal(nextGui.read(), false)
			Session.finish(session, function()
				return nextGui.gui
			end)
			f.flush()
			nextGui.flush()
			Spec.equal(nextGui.read(), initial)
		end
	end
end)
Spec.test("controls replacement snapshot before old gui restore", function()
	const f = fixture(true)
	local enabled = false
	const backend: Switch.Binding = {
		key = {},
		read = function()
			return enabled
		end,
		write = function(value)
			enabled = value
		end,
	}
	const original = f.gui
	const reactive: Switch.Binding = {
		key = original.key,
		read = original.read,
		write = function(value)
			original.write(value)
			enabled = value
		end,
	}
	const session = Session.new()
	Session.step(session, nil, reactive)
	enabled = false
	Session.step(session, backend, fixture(false).gui)
	assert(session.controls, "Replacement backend must be adopted")
	Spec.equal(session.controls.intent, false)
	Session.finish(session)
	Spec.equal(enabled, false)
end)
Spec.test("controls sibling true reassert does not become outside intent", function()
	for _, deferred in { true, false } do
		const f = fixture(false, deferred)
		const session = Session.new()
		Session.step(session, f.controls(), f.gui)
		f.flush()
		local enabled = true
		const nextBackend: Switch.Binding = {
			key = {},
			read = function()
				return enabled
			end,
			write = function(value)
				enabled = value
			end,
		}
		Session.step(session, nextBackend, f.gui)
		f.flush()
		Spec.equal(f.read(), false)
		assert(session.gui, "GUI must remain adopted")
		Spec.equal(session.gui.intent, false)
		Session.finish(session, function()
			return f.gui
		end)
		f.flush()
		Spec.equal(f.read(), false)
	end
end)
Spec.test("controls finish protects unadopted gui from sibling restore", function()
	for _, deferred in { true, false } do
		for _, initial in { true, false } do
			const f = fixture(not initial, deferred)
			const replacement = fixture(initial, deferred)
			const session = Session.new()
			Session.step(session, f.controls(not initial), f.gui)
			f.flush()
			f.replace(replacement.gui)
			Session.finish(session, function()
				return replacement.gui
			end)
			f.flush()
			replacement.flush()
			Spec.equal(replacement.read(), initial)
		end
	end
end)
Spec.test("controls finish protects preexisting late unadopted gui", function()
	for _, deferred in { true, false } do
		for _, initial in { true, false } do
			const f = fixture(false, deferred)
			const late = fixture(initial, deferred)
			const session = Session.new()
			Session.step(session, f.controls(not initial), nil)
			f.replace(late.gui)
			Session.finish(session, function()
				return late.gui
			end)
			f.flush()
			late.flush()
			Spec.equal(late.read(), initial)
		end
	end
end)
return {}
