--!strict
--- Actual wrapper discovery scheduling seam: coroutines suspend the resolver, not native Roblox.
const Runner = require("../../src/ControlRunner")
const Spec = require("../Spec")
const Switch = require("../../src/ControlSwitch")
const function cell(label: string, log: { string }): Switch.Binding
	local enabled = true
	return {
		key = label,
		read = function()
			return enabled
		end,
		write = function(value)
			enabled = value
			table.insert(log, label .. tostring(value))
		end,
	}
end
Spec.test("controls runner release while discovery suspended", function()
	const log: { string } = {}
	const a, b = cell("a", log), cell("b", log)
	local nextBinding = a
	local suspended = false
	local pending: thread? = nil
	const runner = Runner.new(function()
		if suspended then
			coroutine.yield()
		end
		return nextBinding
	end, function()
		return nil
	end, function(fn)
		const thread = coroutine.create(fn)
		pending = thread
		const ok, message = coroutine.resume(thread)
		assert(ok, tostring(message))
	end)
	Runner.step(runner, true, true, false)
	Spec.equal(log, { "afalse" })
	nextBinding = b
	suspended = true
	Runner.step(runner, true, true, false)
	Runner.step(runner, false, false, false)
	Spec.equal(log, { "afalse", "atrue" })
	assert(pending, "resolver coroutine must be pending")
	const ok, message = coroutine.resume(pending)
	assert(ok, tostring(message))
	Spec.equal(log, { "afalse", "atrue" })
	Spec.equal(runner.session.controls, nil)
end)
Spec.test("controls runner old generation cannot alter new ownership", function()
	const log: { string } = {}
	const binding = cell("c", log)
	const pending: { () -> () } = {}
	const runner = Runner.new(function()
		return binding
	end, function()
		return nil
	end, function(fn)
		table.insert(pending, fn)
	end)
	Runner.step(runner, true, true, false)
	Runner.step(runner, false, false, false)
	Runner.step(runner, true, true, false)
	pending[1]()
	Spec.equal(log, {})
	Spec.equal(runner.resolving, true)
	pending[2]()
	Spec.equal(log, { "cfalse" })
	Runner.step(runner, false, false, false)
	Spec.equal(log, { "cfalse", "ctrue" })
end)
Spec.test("controls runner resolver exception retries and input change cancels", function()
	const log: { string } = {}
	const binding = cell("c", log)
	local fail = true
	const pending: { () -> () } = {}
	const runner = Runner.new(function()
		if fail then
			error("fixture resolver failure")
		end
		return binding
	end, function()
		return nil
	end, function(fn)
		table.insert(pending, fn)
	end)
	Runner.step(runner, true, true, false)
	pending[1]()
	Spec.equal(runner.resolving, false)
	fail = false
	Runner.step(runner, true, true, false)
	Runner.step(runner, true, false, false)
	pending[2]()
	Spec.equal(log, {})
	Runner.step(runner, true, true, false)
	pending[3]()
	Spec.equal(log, { "cfalse" })
	Runner.step(runner, false, false, false)
end)
Spec.test("controls runner replaced pending resource retries and cancels", function()
	const log: { string } = {}
	const a, b = cell("a", log), cell("b", log)
	local binding = a
	local key: unknown = "a"
	local cancelled = 0
	const pending: { () -> () } = {}
	const runner = Runner.new(function()
		return binding
	end, function()
		return nil
	end, function(fn)
		table.insert(pending, fn)
	end, function(): { unknown }
		return { key }
	end, function()
		cancelled += 1
	end)
	Runner.step(runner, true, true, false)
	const started = cancelled
	key, binding = "b", b
	Runner.step(runner, true, true, false)
	Spec.equal(cancelled, started + 1)
	Spec.equal(#pending, 2)
	pending[1]()
	Spec.equal(log, {})
	pending[2]()
	Spec.equal(log, { "bfalse" })
	Runner.step(runner, false, false, false)
	Spec.equal(cancelled, started + 2)
	Spec.equal(log, { "bfalse", "btrue" })
end)
return {}
