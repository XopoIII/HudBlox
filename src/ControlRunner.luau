--!strict
--- Nonblocking discovery seam used by the native wrapper; generations invalidate suspended work.
const Session = require("./ControlSession")
const Switch = require("./ControlSwitch")
const Runner = {}
export type Runner = {
	session: Session.Session,
	controls: () -> Switch.Binding?,
	gui: () -> Switch.Binding?,
	schedule: (() -> ()) -> (),
	active: boolean,
	movement: boolean,
	touch: boolean,
	generation: number,
	resolving: boolean,
	sources: (() -> { unknown })?,
	cancel: (() -> ())?,
	keys: { unknown },
}
function Runner.new(
	controls: () -> Switch.Binding?,
	gui: () -> Switch.Binding?,
	schedule: (() -> ()) -> (),
	sources: (() -> { unknown })?,
	cancel: (() -> ())?
): Runner
	return {
		session = Session.new(),
		controls = controls,
		gui = gui,
		schedule = schedule,
		active = false,
		movement = false,
		touch = false,
		generation = 0,
		resolving = false,
		sources = sources,
		cancel = cancel,
		keys = {},
	}
end
function Runner.step(state: Runner, active: boolean, movement: boolean, touch: boolean)
	const keys = if active and state.sources then state.sources() else {}
	local replaced = #keys ~= #state.keys
	for i, key in keys do
		if key ~= state.keys[i] then
			replaced = true
		end
	end
	state.keys = keys
	if state.active ~= active or state.movement ~= movement or replaced then
		state.generation += 1
		if state.cancel then
			pcall(state.cancel)
		end
		state.resolving = false
	end
	state.active, state.movement, state.touch = active, movement, touch
	if not active then
		Session.finish(state.session, state.gui)
		return
	end
	const held = state.session.controls
	Session.step(state.session, if movement and held then held.binding else nil, if touch then state.gui() else nil)
	if not movement or state.resolving then
		return
	end
	state.resolving = true
	const generation = state.generation
	const scheduled = pcall(state.schedule, function()
		const ok, binding = pcall(state.controls)
		if state.generation ~= generation or not state.active or not state.movement then
			return
		end
		state.resolving = false
		if ok then
			Session.step(state.session, binding, if state.touch then state.gui() else nil)
		end
	end)
	if not scheduled and state.generation == generation then
		state.resolving = false
	end
end
return Runner
