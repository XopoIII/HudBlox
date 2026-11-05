--!strict
--- Protocol tests, not native signal/PlayerModule acceptance.
const Protocol = require("../../src/ControlProtocol")
const Session = require("../../src/ControlSession")
const Spec = require("../Spec")
const Switch = require("../../src/ControlSwitch")
const function cell(initial: boolean, name: string, log: { string })
	const value = { enabled = initial }
	local listener: ((boolean) -> ())? = nil
	local stale: ((boolean) -> ())? = nil
	const binding: Switch.Binding = {
		key = value,
		read = function()
			return value.enabled
		end,
		write = function(enabled)
			value.enabled = enabled
			table.insert(log, name .. tostring(enabled))
		end,
		watch = function(fn)
			listener = fn
			stale = fn
			return function()
				listener = nil
				table.insert(log, name .. "stop")
			end
		end,
	}
	return {
		value = value,
		binding = binding,
		notify = function(enabled: boolean)
			value.enabled = enabled
			if listener then
				listener(enabled)
			end
		end,
		deferred = function(enabled: boolean)
			if stale then
				stale(enabled)
			end
		end,
	}
end
for _, before in { true, false } do
	Spec.test("controls and gui adopt " .. tostring(before), function()
		const log: { string } = {}
		const c, g = cell(before, "c", log), cell(before, "g", log)
		const session = Session.new()
		Session.step(session, c.binding, g.binding)
		Spec.equal({ c.value.enabled, g.value.enabled }, { false, false })
		Session.finish(session)
		Spec.equal({ c.value.enabled, g.value.enabled }, { before, before })
		Spec.equal(log, { "cfalse", "gfalse", "cstop", "gstop", "c" .. tostring(before), "g" .. tostring(before) })
		const direct = cell(before, "direct", {})
		const held = Switch.begin(direct.binding)
		assert(held, "Direct binding must adopt")
		Switch.disconnect(held)
		Switch.restore(held)
		Spec.equal(direct.value.enabled, before)
	end)
end
Spec.test("controls observed reenable deferred own and stale exit", function()
	const log: { string } = {}
	const g = cell(false, "g", log)
	const session = Session.new()
	Session.step(session, nil, g.binding)
	g.notify(true)
	Spec.equal(g.value.enabled, false)
	g.deferred(false)
	Spec.equal((session.gui :: Switch.Held).intent, true)
	Session.finish(session)
	const size = #log
	g.deferred(true)
	g.deferred(false)
	Spec.equal(#log, size)
	Spec.equal(g.value.enabled, true)
end)
Spec.test("controls modern poll reasserts and preserves observed intent", function()
	const api = { Enabled = false }
	const binding = Protocol.modern(api)
	assert(binding, "validated binding fixture must exist")
	const session = Session.new()
	Session.step(session, binding, nil)
	api.Enabled = true
	Session.step(session, binding, nil)
	Spec.equal(api.Enabled, false)
	Session.finish(session)
	Spec.equal(api.Enabled, true)
end)
Spec.test("controls late recreation and no backend churn", function()
	const log: { string } = {}
	const c = cell(true, "c", log)
	const g = cell(false, "g", log)
	const replacement = cell(true, "r", log)
	const session = Session.new()
	Session.step(session, nil, nil)
	Spec.equal(log, {})
	Session.step(session, c.binding, nil)
	Session.step(session, c.binding, g.binding)
	Session.step(session, c.binding, replacement.binding)
	Spec.equal(log, { "cfalse", "gfalse", "gstop", "gfalse", "rfalse" })
	Session.finish(session)
	Spec.equal(replacement.value.enabled, true)
end)
Spec.test("controls failed write retried and backend replaced", function()
	local fail = true
	const api = { Enabled = true }
	const binding: Switch.Binding = {
		key = api,
		read = function()
			return api.Enabled
		end,
		write = function(enabled)
			if fail then
				error("temporary write")
			end
			api.Enabled = enabled
		end,
	}
	const session = Session.new()
	Session.step(session, binding, nil)
	Spec.equal(session.controls, nil)
	fail = false
	Session.step(session, binding, nil)
	Spec.equal(api.Enabled, false)
	const replacement = { Enabled = false }
	Session.step(session, Protocol.modern(replacement), nil)
	Spec.equal(api.Enabled, true)
	Session.finish(session)
	Spec.equal(replacement.Enabled, false)
end)
Spec.test("controls finish restores live gui after backend rebuild", function()
	const log: { string } = {}
	const old = cell(false, "old", log)
	const live = cell(true, "live", log)
	local current = old.binding
	local enabledState = true
	const controls: Switch.Binding = {
		key = {},
		read = function()
			return enabledState
		end,
		write = function(enabled)
			enabledState = enabled
			if enabled then
				current = live.binding
			end
			table.insert(log, "c" .. tostring(enabled))
		end,
	}
	const session = Session.new()
	Session.step(session, controls, old.binding)
	Session.finish(session, function()
		return current
	end)
	Spec.equal(log, { "cfalse", "oldfalse", "oldstop", "ctrue", "oldfalse", "livefalse" })
	Spec.equal(live.value.enabled, false)
end)
Spec.test("controls modern priority validated fallback and legacy no getter", function()
	const starter = { Enabled = false }
	const scripts = { Enabled = true }
	local reads = 0
	const function forbidden(): unknown
		reads += 1
		return scripts
	end
	const first = Protocol.choose(function()
		return starter
	end, forbidden, forbidden)
	assert(first, "validated first fixture must exist")
	Spec.equal(first.key, starter)
	Spec.equal(reads, 0)
	const second = Protocol.choose(function()
		return { Enabled = "bad" }
	end, function()
		return scripts
	end, forbidden)
	assert(second, "validated second fixture must exist")
	Spec.equal(second.key, scripts)
	Spec.equal(reads, 0)
	const invalidCases: { unknown } = {
		false,
		"bad",
		{},
		{ GetControls = true },
		{
			GetControls = function(): unknown
				error("not ready")
			end,
		},
		{
			GetControls = function(): unknown
				return { Enable = true }
			end,
		},
	}
	for _, invalid in invalidCases do
		Spec.equal(Protocol.legacy(invalid), nil)
	end
	local enabled = false
	const api = {
		Enable = function()
			enabled = true
		end,
		Disable = function()
			enabled = false
		end,
	}
	const legacy = Protocol.legacy({
		GetControls = function()
			return api
		end,
	})
	assert(legacy, "validated legacy fixture must exist")
	Spec.equal(legacy.read(), nil)
	const session = Session.new()
	Session.step(session, legacy, nil)
	Spec.equal(enabled, false)
	Session.finish(session)
	Spec.equal(enabled, true)
end)
Spec.test("controls deferred generation and invalidation", function()
	const log: { string } = {}
	const g = cell(false, "g", log)
	const pending: { () -> () } = {}
	g.binding.defer = function(fn)
		table.insert(pending, fn)
	end
	const held = Switch.begin(g.binding)
	assert(held, "validated held fixture must exist")
	g.notify(true)
	Spec.equal(g.value.enabled, false)
	g.notify(true)
	Spec.equal(#pending, 2)
	const size = #log
	pending[1]()
	Spec.equal(#log, size)
	pending[2]()
	Spec.equal(#log, size + 1)
	g.deferred(false)
	Spec.equal(held.intent, true)
	g.notify(true)
	Switch.disconnect(held)
	Switch.restore(held)
	const endSize = #log
	pending[3]()
	Spec.equal(#log, endSize)
	Spec.equal(g.value.enabled, true)
end)
Spec.test("controls replacement disconnects before restores", function()
	const log: { string } = {}
	const c, g = cell(true, "c", log), cell(true, "g", log)
	const session = Session.new()
	Session.step(session, c.binding, g.binding)
	Session.step(session, nil, nil)
	Spec.equal(log, { "cfalse", "gfalse", "cstop", "gstop", "ctrue", "gtrue" })
end)
Spec.test("controls finish preserves unadopted replacement intent", function()
	for _, initial in { true, false } do
		const log: { string } = {}
		const a = cell(not initial, "a", log)
		const b = cell(initial, "b", log)
		const session = Session.new()
		Session.step(session, nil, a.binding)
		Session.finish(session, function()
			return b.binding
		end)
		Spec.equal(b.value.enabled, initial)
		Spec.equal(a.value.enabled, not initial)
		Spec.equal(log, { "afalse", "astop", "a" .. tostring(not initial) })
	end
end)
Spec.test("controls finish restores detached reusable gui", function()
	for _, initial in { true, false } do
		const log: { string } = {}
		const a = cell(initial, "a", log)
		const session = Session.new()
		Session.step(session, nil, a.binding)
		Session.finish(session, function()
			return nil
		end)
		Spec.equal(a.value.enabled, initial)
		Spec.equal(log, { "afalse", "astop", "a" .. tostring(initial) })
	end
end)
return {}
