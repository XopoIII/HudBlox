--!strict
--- Mouse/touch capture; generic UI cancellation and global listeners belong to the kit.
const PointerState = require("./PointerState")
const Pointer = {}
export type Handle = { cancel: () -> (), destroy: () -> () }
export type Hold = { began: (InputObject) -> (), ended: (InputObject) -> () }
export type Drag = { moved: (number, number) -> (), ended: (() -> ())? }
const function visible(gui: GuiObject): boolean
	local node: Instance? = gui
	while node do
		if node:IsA("GuiObject") and not node.Visible then
			return false
		end
		if node:IsA("ScreenGui") and not node.Enabled then
			return false
		end
		node = node.Parent
	end
	return gui:IsDescendantOf(game) and (not gui:IsA("GuiButton") or gui.Interactable)
end
const function bind(gui: GuiObject, callbacks: Hold, moved: ((InputObject) -> ())?): Handle
	const uis = game:GetService("UserInputService")
	const capture: PointerState.Capture<InputObject> = PointerState.new(nil :: InputObject?)
	const connections: { RBXScriptConnection } = {}
	local ancestry: { RBXScriptConnection } = {}
	local dead = false
	const function cancel()
		const input = capture.cancel()
		if input then
			callbacks.ended(input)
		end
	end
	const function destroy()
		if dead then
			return
		end
		dead = true
		const input = capture.destroy()
		for _, connection in connections do
			connection:Disconnect()
		end
		for _, connection in ancestry do
			connection:Disconnect()
		end
		if input then
			callbacks.ended(input)
		end
	end
	const function check()
		if not visible(gui) then
			cancel()
		end
	end
	const function watch()
		for _, connection in ancestry do
			connection:Disconnect()
		end
		table.clear(ancestry)
		local node: Instance? = gui
		while node do
			if node:IsA("GuiObject") then
				table.insert(ancestry, node:GetPropertyChangedSignal("Visible"):Connect(check))
			end
			if node:IsA("ScreenGui") then
				table.insert(ancestry, node:GetPropertyChangedSignal("Enabled"):Connect(check))
			end
			node = node.Parent
		end
		check()
	end
	table.insert(
		connections,
		gui.AncestryChanged:Connect(function()
			cancel()
			if not dead then
				watch()
			end
		end)
	)
	table.insert(connections, gui.Destroying:Connect(destroy))
	if gui:IsA("GuiButton") then
		table.insert(connections, gui:GetPropertyChangedSignal("Interactable"):Connect(check))
	end
	table.insert(
		connections,
		gui.InputBegan:Connect(function(input: InputObject)
			if dead or not visible(gui) or uis:GetFocusedTextBox() then
				return
			end
			if
				input.UserInputType ~= Enum.UserInputType.Touch
				and input.UserInputType ~= Enum.UserInputType.MouseButton1
			then
				return
			end
			if capture.begin(input) then
				callbacks.began(input)
			end
		end)
	)
	table.insert(
		connections,
		uis.InputEnded:Connect(function(input: InputObject)
			if capture.finish(input) then
				callbacks.ended(input)
			end
		end)
	)
	table.insert(
		connections,
		uis.InputChanged:Connect(function(input: InputObject)
			check()
			if moved and not dead then
				moved(input)
			end
		end)
	)
	table.insert(connections, uis.WindowFocusReleased:Connect(cancel))
	table.insert(connections, uis.TextBoxFocused:Connect(cancel))
	watch()
	return { cancel = cancel, destroy = destroy }
end
function Pointer.hold(button: GuiButton, callbacks: Hold): Handle
	return bind(button, callbacks, nil)
end
function Pointer.drag(gui: GuiObject, callbacks: Drag): Handle
	local active: InputObject? = nil
	local last = Vector3.zero
	return bind(gui, {
		began = function(input: InputObject)
			active = input
			last = input.Position
		end,
		ended = function(_input: InputObject)
			active = nil
			if callbacks.ended then
				callbacks.ended()
			end
		end,
	}, function(input: InputObject)
		const owner = active
		if not owner then
			return
		end
		if
			input ~= owner
			and not (
				owner.UserInputType == Enum.UserInputType.MouseButton1
				and input.UserInputType == Enum.UserInputType.MouseMovement
			)
		then
			return
		end
		const delta = input.Position - last
		last = input.Position
		callbacks.moved(delta.X, delta.Y)
	end)
end
function Pointer.activate(button: GuiButton, callback: () -> ()): () -> ()
	const connection = button.Activated:Connect(function()
		if visible(button) then
			callback()
		end
	end)
	return function()
		connection:Disconnect()
	end
end
return Pointer
