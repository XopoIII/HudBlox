--!strict
--- Which panels hold the gamepad's focus, the newest on top. Pure (`tests/unit/Stack.luau`).
---
--- A name stands once: pushing it again moves it to the top with its new value. Popping takes a
--- name out wherever it stands, since panels close in any order.
const Stack = {}

export type Entry<T> = { name: string, value: T }
--- An empty stack is `{ entries = {} }`, written where its type is known.
export type Stack<T> = { entries: { Entry<T> } }

const function find<T>(stack: Stack<T>, name: string): number?
	for index, entry in stack.entries do
		if entry.name == name then
			return index
		end
	end
	return nil
end

--> Puts `name` on top with `value`; a name already there moves up. Hands back the value the name
--> stood with before, for the caller to let go of, or nil when the name is new.
function Stack.push<T>(stack: Stack<T>, name: string, value: T): T?
	const index = find(stack, name)
	local replaced: T? = nil
	if index then
		const old = table.remove(stack.entries, index)
		replaced = if old then old.value else nil
	end
	table.insert(stack.entries, { name = name, value = value })
	return replaced
end

--> Takes `name` out, wherever it stands, and hands back its value; nil when it is not there.
function Stack.pop<T>(stack: Stack<T>, name: string): T?
	const index = find(stack, name)
	if not index then
		return nil
	end
	const entry = table.remove(stack.entries, index)
	return if entry then entry.value else nil
end

--> The newest entry, or nil for an empty stack.
function Stack.top<T>(stack: Stack<T>): Entry<T>?
	return stack.entries[#stack.entries]
end

function Stack.size<T>(stack: Stack<T>): number
	return #stack.entries
end

return Stack
