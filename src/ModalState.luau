--!strict
--- Synchronous transitions. Effects release ownership before observers see the new state.
const ModalState = {}
export type Handle = {
	set: (boolean) -> (),
	isOpen: () -> boolean,
	observe: ((boolean) -> ()) -> () -> (),
	destroy: () -> (),
}
function ModalState.new(effect: (boolean) -> ()): Handle
	local open, dead, version = false, false, 0
	const listeners: { [(boolean) -> ()]: boolean } = {}
	const function set(want: boolean)
		if dead or open == want then
			return
		end
		open = want
		version += 1
		const mine = version
		effect(want)
		const snapshot: { (boolean) -> () } = {}
		for listener in listeners do
			table.insert(snapshot, listener)
		end
		for _, listener in snapshot do
			if dead or mine ~= version then
				break
			end
			if listeners[listener] then
				listener(want)
			end
		end
	end
	return {
		set = set,
		isOpen = function(): boolean
			return open
		end,
		observe = function(listener: (boolean) -> ()): () -> ()
			if not dead then
				listeners[listener] = true
			end
			return function()
				listeners[listener] = nil
			end
		end,
		destroy = function()
			if dead then
				return
			end
			dead = true
			version += 1
			table.clear(listeners)
			if open then
				open = false
				effect(false)
			end
		end,
	}
end
return ModalState
