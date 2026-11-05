--!strict
--- A held boolean's observed intent. Own false writes cannot become outside intent.
const ControlSwitch = {}
export type Binding = {
	key: unknown,
	read: () -> boolean?,
	write: (boolean) -> (),
	-- Signal adapters read current value when delivered; a stale captured true is not attributable.
	watch: (((boolean) -> ()) -> () -> ())?,
	defer: ((() -> ()) -> ())?,
}
export type Held = {
	binding: Binding,
	intent: boolean,
	writing: boolean,
	generation: number,
	active: boolean,
	stop: (() -> ())?,
}
const function suppress(held: Held)
	held.writing = true
	held.generation += 1
	const ok = pcall(held.binding.write, false)
	held.writing = false
	return ok
end
function ControlSwitch.observe(held: Held, value: boolean)
	-- A same-value false assignment is unobservable on native signals/plain tables.
	-- A deferred false notification of our write also cannot erase observed true intent.
	if not held.active or held.writing or not value then
		return
	end
	held.intent = value
	-- Close the observed true-to-false gap synchronously; only reinforcement is deferred.
	suppress(held)
	const generation = held.generation
	const function reconcile()
		if held.active and held.generation == generation then
			suppress(held)
		end
	end
	if held.binding.defer then
		held.binding.defer(reconcile)
	end
end
function ControlSwitch.begin(binding: Binding, captured: boolean?): Held?
	const ok, before = pcall(binding.read)
	if not ok then
		return nil
	end
	const held: Held = {
		binding = binding,
		intent = if before == nil then true else before,
		writing = false,
		generation = 0,
		active = true,
		stop = nil,
	}
	if captured ~= nil then
		held.intent = captured
	end
	if binding.watch then
		held.stop = binding.watch(function(value)
			ControlSwitch.observe(held, value)
		end)
	end
	if not suppress(held) then
		held.active = false
		held.generation += 1
		if held.stop then
			held.stop()
		end
		return nil
	end
	return held
end
function ControlSwitch.poll(held: Held)
	const ok, now = pcall(held.binding.read)
	if ok and now == true then
		ControlSwitch.observe(held, true)
	end
end
function ControlSwitch.reassert(held: Held)
	const ok, now = pcall(held.binding.read)
	if ok and now == true then
		suppress(held)
	end
end
function ControlSwitch.disconnect(held: Held?)
	if held then
		held.active = false
		held.generation += 1
	end
	if held and held.stop then
		held.stop()
		held.stop = nil
	end
end
function ControlSwitch.restore(held: Held?)
	if held then
		pcall(held.binding.write, held.intent)
	end
end
return ControlSwitch
