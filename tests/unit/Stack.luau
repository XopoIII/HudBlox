--!strict
--- Which panels hold the gamepad's focus: the newest on top, a name standing once.
const Spec = require("../Spec")
const Stack = require("@hudblox/Stack")

const function names(stack: Stack.Stack<number>): string
	const list: { string } = {}
	for _, entry in stack.entries do
		table.insert(list, entry.name)
	end
	return table.concat(list, ",")
end

const function topOf(stack: Stack.Stack<number>): Stack.Entry<number>
	const top = Stack.top(stack)
	assert(top, "the stack is empty")
	return top
end

Spec.test("a new stack is empty: no top, size 0", function()
	const stack: Stack.Stack<number> = { entries = {} }
	Spec.equal(Stack.size(stack), 0, "size")
	Spec.equal(Stack.top(stack), nil, "top")
end)

Spec.test("the newest scope is on top", function()
	const stack: Stack.Stack<number> = { entries = {} }
	Stack.push(stack, "hud", 1)
	Stack.push(stack, "modal:Shop", 2)
	Spec.equal(names(stack), "hud,modal:Shop", "order")
	Spec.equal(topOf(stack), { name = "modal:Shop", value = 2 }, "top")
	Spec.equal(Stack.size(stack), 2, "size")
end)

Spec.test("a name pushed again moves to the top with its new value, and stands once", function()
	const stack: Stack.Stack<number> = { entries = {} }
	Stack.push(stack, "a", 1)
	Stack.push(stack, "b", 2)
	Stack.push(stack, "a", 3)
	Spec.equal(names(stack), "b,a", "order")
	Spec.equal(topOf(stack).value, 3, "the new value")
	Spec.equal(Stack.size(stack), 2, "once")
end)

Spec.test("popping the top hands the focus back to the one under it", function()
	const stack: Stack.Stack<number> = { entries = {} }
	Stack.push(stack, "hud", 1)
	Stack.push(stack, "modal:Shop", 2)
	Spec.equal(Stack.pop(stack, "modal:Shop"), 2, "its value")
	Spec.equal(topOf(stack).name, "hud", "top")
	Spec.equal(Stack.size(stack), 1, "size")
end)

Spec.test("a scope is popped from under another, and the top is left alone", function()
	const stack: Stack.Stack<number> = { entries = {} }
	Stack.push(stack, "a", 1)
	Stack.push(stack, "b", 2)
	Stack.push(stack, "c", 3)
	Spec.equal(Stack.pop(stack, "b"), 2, "its value")
	Spec.equal(names(stack), "a,c", "order")
	Spec.equal(topOf(stack).name, "c", "top")
end)

Spec.test("popping a name that is not there changes nothing", function()
	const stack: Stack.Stack<number> = { entries = {} }
	Stack.push(stack, "a", 1)
	Spec.equal(Stack.pop(stack, "b"), nil, "no such name")
	Spec.equal(names(stack), "a", "untouched")
	Spec.equal(Stack.pop(stack, "a"), 1, "the one there")
	Spec.equal(Stack.pop(stack, "a"), nil, "gone the second time")
	Spec.equal(Stack.size(stack), 0, "empty")
	Spec.equal(Stack.top(stack), nil, "no top")
end)

return nil
