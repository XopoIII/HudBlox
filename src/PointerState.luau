--!strict
--- Single-owner capture shared by hold and drag; a second finger cannot steal it.
const PointerState = {}
export type Capture<T> = {
	begin: (T) -> boolean,
	owns: (T) -> boolean,
	finish: (T) -> boolean,
	cancel: () -> T?,
	destroy: () -> T?,
}
function PointerState.new<T>(_type: T?): Capture<T>
	local active: T? = nil
	local dead = false
	const function cancel(): T?
		const old = active
		active = nil
		return old
	end
	return {
		begin = function(value: T): boolean
			if dead or active ~= nil then
				return false
			end
			active = value
			return true
		end,
		owns = function(value: T): boolean
			return active == value
		end,
		finish = function(value: T): boolean
			if active ~= value then
				return false
			end
			active = nil
			return true
		end,
		cancel = cancel,
		destroy = function(): T?
			dead = true
			return cancel()
		end,
	}
end
return PointerState
