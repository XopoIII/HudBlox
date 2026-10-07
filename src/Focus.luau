--!strict
--- Where a gamepad's selection is, one panel at a time.
---
--- Every panel that opens pushes a scope (its root and what B does there) and pops it when it
--- closes. The newest scope owns the pad:
---
--- - the selection is kept inside its root (a `SelectionGroup` that stops at every edge), put there
---   when the panel opens and put back when the focused control goes away (a tile removed);
--- - B is "back" for that scope alone, so two panels never both close;
--- - the character stands still and the world's prompts are off, since the stick and the buttons
---   belong to the panel (`TouchControls`).
---
--- All of it only while the player is on a gamepad (`PadInput`): a mouse or a finger sees no ring,
--- and taking the pad up with a panel open puts the ring in it. The engine's own auto-selection is
--- switched off, so nothing but this module ever selects.
---
--- The order of scopes is `Stack`'s and the choice of control is `Pick`'s, both pure and tested.
---
--- NOTHING HAPPENS UNTIL A GAME ASKS. `start` (which the first `push` calls) is what switches the
--- engine's auto-selection off and begins to follow the selection; a game that never opens a panel
--- through here keeps the engine's own behaviour. A game that wants the engine's auto-selection off
--- from its first frame calls `start` as its client loads.
const Host = require("./Host")
const PadInput = require("./PadInput")
const Pick = require("./Pick")
const Ring = require("./Ring")
const Stack = require("./Stack")
const TouchControls = require("./TouchControls")

const Focus = {}

export type Options = {
	--- What B does while this scope is on top.
	back: (() -> ())?,
	--- Where the focus starts; `Pick.first` when it is nil or cannot be chosen.
	first: (() -> GuiObject?)?,
}

type Scope = {
	root: GuiBase2d,
	back: (() -> ())?,
	first: (() -> GuiObject?)?,
	-- The control last in focus here and where it stood.
	object: GuiObject?,
	at: Vector2?,
}

const ACTION = "FocusBack"
--- The priority B is bound at: `Enum.ContextActionPriority.High` and a hundred, above every other
--- binding of B a game makes.
Focus.PRIORITY = 2100

const stack: Stack.Stack<Scope> = { entries = {} }
local ringed = false
local started = false

const function shown(object: GuiObject, root: GuiBase2d): boolean
	local at: Instance? = object
	while at and at ~= root do
		if at:IsA("GuiObject") and not at.Visible then
			return false
		end
		at = at.Parent
	end
	return at == root
end

const function inside(scope: Scope, object: GuiObject?): boolean
	return object ~= nil and object.Selectable and shown(object, scope.root)
end

const function choose(scope: Scope): GuiObject?
	if inside(scope, scope.object) then
		return scope.object
	end
	const first = scope.first
	const wanted = if scope.at == nil and first then first() else nil
	if inside(scope, wanted) then
		return wanted
	end
	const objects: { GuiObject } = {}
	const targets: { Pick.Target } = {}
	for _, child in scope.root:GetDescendants() do
		if child:IsA("GuiObject") and child.Selectable then
			const corner, size = child.AbsolutePosition, child.AbsoluteSize
			table.insert(objects, child)
			table.insert(targets, {
				x = corner.X + size.X / 2,
				y = corner.Y + size.Y / 2,
				order = child.SelectionOrder,
				shown = shown(child, scope.root),
				selectable = true,
			})
		end
	end
	const rtl = Host.rtl().active()
	const at = scope.at
	const index = if at then Pick.nearest(targets, at.X, at.Y, rtl) else Pick.first(targets, rtl)
	return if index then objects[index] else nil
end

const function settle()
	const guiService = game:GetService("GuiService")
	const top = Stack.top(stack)
	const held = top ~= nil and PadInput.active()
	game:GetService("ProximityPromptService").Enabled = not held
	const selected = guiService.SelectedObject
	if not top then
		return
	end
	const scope = top.value
	if not held then
		-- The pad was put down: the ring goes with it.
		if inside(scope, selected) then
			guiService.SelectedObject = nil
		end
		return
	end
	if inside(scope, selected) then
		return
	end
	const pick = choose(scope)
	if pick then
		guiService.SelectedObject = pick
	end
end

-- A frame later, not at once: a panel just shown has no layout yet, and `Pick` reads where things
-- stand.
local queued = false
const function queue()
	if queued then
		return
	end
	queued = true
	task.delay(0, function()
		queued = false
		settle()
	end)
end

--> Switches the engine's own auto-selection off and begins to follow the selection. The first
--> `push` calls it; a second call does nothing.
function Focus.start()
	if started then
		return
	end
	started = true
	const guiService = game:GetService("GuiService")
	guiService.AutoSelectGuiEnabled = false
	guiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
		const top = Stack.top(stack)
		if not top then
			return
		end
		const scope = top.value
		const selected = guiService.SelectedObject
		if selected and inside(scope, selected) then
			scope.object = selected
			scope.at = selected.AbsolutePosition + selected.AbsoluteSize / 2
		else
			queue()
		end
	end)
	PadInput.onChange(queue)
end

const function back(_: string, state: Enum.UserInputState): Enum.ContextActionResult
	const top = Stack.top(stack)
	const act = if top then top.value.back else nil
	if state == Enum.UserInputState.Begin and act then
		Host.padUsed("Back")
		act()
	end
	return Enum.ContextActionResult.Sink
end

--> Gives the pad to the panel `root` under `name`. Pushing a name again moves it to the top.
function Focus.push(name: string, root: GuiBase2d, options: Options?)
	Focus.start()
	if not ringed then
		const playerGui = root:FindFirstAncestorOfClass("PlayerGui")
		if playerGui then
			ringed = true
			Ring.install(playerGui)
		end
	end
	root.SelectionGroup = true
	root.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
	root.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
	root.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
	root.SelectionBehaviorRight = Enum.SelectionBehavior.Stop
	if Stack.size(stack) == 0 then
		game:GetService("ContextActionService")
			:BindActionAtPriority(ACTION, back, false, Focus.PRIORITY, Enum.KeyCode.ButtonB)
	end
	Stack.push(stack, name, {
		root = root,
		back = if options then options.back else nil,
		first = if options then options.first else nil,
		object = nil,
		at = nil,
	})
	TouchControls.set(`focus:{name}`, true)
	if PadInput.active() then
		Host.padUsed("Panel")
	end
	queue()
end

--> Takes the pad back from the panel pushed as `name`, wherever it stands in the stack.
function Focus.pop(name: string)
	const scope = Stack.pop(stack, name)
	if not scope then
		return
	end
	TouchControls.set(`focus:{name}`, false)
	const guiService = game:GetService("GuiService")
	const selected = guiService.SelectedObject
	if selected and selected:IsDescendantOf(scope.root) then
		guiService.SelectedObject = nil
	end
	if Stack.size(stack) == 0 then
		game:GetService("ContextActionService"):UnbindAction(ACTION)
	end
	queue()
end

--> Whether any panel holds the focus: the world's own buttons stand down.
function Focus.open(): boolean
	return Stack.size(stack) > 0
end

return Focus
