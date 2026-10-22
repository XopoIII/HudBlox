--!strict
--- Where the ring stands in a part of the screen: its first control, as `Pick.first` orders them
--- (the lowest `SelectionOrder`, the top row, the reading start of it), and a tile walked whole.
---
--- A page drawn a share of a frame at a time has no controls yet the moment its tab is turned, and
--- the ring falls back to the dialog's X; `ring` waits for the page and puts it on the first.
const Focus = require("./Focus")
const Host = require("./Host")
const PadGlyph = require("./PadGlyph")
const PadInput = require("./PadInput")
const Pick = require("./Pick")

const PadPage = {}

--- How long a page is given to be drawn before the ring is put on it, in seconds.
PadPage.SETTLE = 0.15

-- Whether `object` is drawn inside `root`: it and everything between them visible.
const function shown(object: GuiObject, root: Instance): boolean
	local at: Instance? = object
	while at and at ~= root do
		if at:IsA("GuiObject") and not at.Visible then
			return false
		end
		at = at.Parent
	end
	return at == root
end

--> The first control a gamepad's ring stands on in `root`, nil for none: the selectable buttons
--> drawn there, ordered as `Pick.first` orders them, those under `skip` left out.
function PadPage.first(root: Instance, skip: Instance?): GuiObject?
	const candidates: { GuiObject } = {}
	const targets: { Pick.Target } = {}
	for _, item in root:GetDescendants() do
		if item:IsA("GuiButton") and item.Selectable and not (skip and item:IsDescendantOf(skip)) then
			const corner, size = item.AbsolutePosition, item.AbsoluteSize
			table.insert(candidates, item)
			table.insert(targets, {
				x = corner.X + size.X / 2,
				y = corner.Y + size.Y / 2,
				order = item.SelectionOrder,
				shown = shown(item, root) and size.X > 0,
				selectable = true,
			})
		end
	end
	const index = Pick.first(targets, Host.rtl().active())
	return if index then candidates[index] else nil
end

--> On a pad, puts the ring on `root`'s first control once it is drawn, `PadPage.SETTLE` from now,
--> if the panel that holds the pad is still the one `root` stands in.
function PadPage.ring(root: Instance, skip: Instance?)
	task.delay(PadPage.SETTLE, function()
		if not PadInput.active() or not Focus.within(root) then
			return
		end
		const first = PadPage.first(root, skip)
		if first then
			game:GetService("GuiService").SelectedObject = first
		end
	end)
end

--- The size of a key's picture on a tile's own button while the ring stands on the tile, in
--- pixels, and the action a tile's keys other than A are bound under while it is ringed.
PadPage.CAP = 20
PadPage.ACTION = "PadTile"

export type Key = {
	--- The key: `ButtonA` for the press of the tile itself, another face button for a second one.
	key: Enum.KeyCode,
	--- The tile's own button it presses, which wears its picture while the ring is on the tile.
	button: GuiButton,
	press: () -> (),
}

-- the tile whose keys are bound now
local bound: TextButton? = nil

--> Makes a tile `frame` walked whole by the ring: an unseen button over all of it, under what is
--> drawn on it. Its own buttons are left out of the ring's walk, so the ring stops once a tile and
--> the list scrolls to show the tile whole; while the ring stands on it each of `keys` wears its
--> key's picture on its button and presses it, the first of a key whose button is shown (a tile
--> that buys with stars or Robux, or is worn, shows one or the other). Returns the button.
function PadPage.tile(frame: GuiObject, keys: { Key }): TextButton
	const whole = Instance.new("TextButton")
	whole.Name = "Whole"
	whole.Text = ""
	whole.AutoButtonColor = false
	whole.BackgroundTransparency = 1
	whole.Size = UDim2.fromScale(1, 1)
	whole.ZIndex = 0
	whole.Parent = frame
	const hints: { Frame } = {}
	for _, entry in keys do
		entry.button.Selectable = false
		-- the key's picture on the button, there only while the ring is on the tile
		const hint = Instance.new("Frame")
		hint.Name = "PadHint"
		hint.BackgroundTransparency = 1
		hint.Size = UDim2.fromScale(1, 1)
		hint.ZIndex = entry.button.ZIndex
		hint.Visible = false
		hint.Parent = entry.button
		PadGlyph.corner(hint, entry.key, PadPage.CAP)
		table.insert(hints, hint)
	end
	const function press(key: Enum.KeyCode): boolean
		for _, entry in keys do
			if entry.key == key and entry.button.Visible then
				entry.press()
				return true
			end
		end
		return false
	end
	whole.Activated:Connect(function()
		press(Enum.KeyCode.ButtonA)
	end)
	const function act(_: string, state: Enum.UserInputState, input: InputObject): Enum.ContextActionResult
		if state == Enum.UserInputState.Begin and press(input.KeyCode) then
			return Enum.ContextActionResult.Sink
		end
		return Enum.ContextActionResult.Pass
	end
	const others: { Enum.KeyCode } = {}
	for _, entry in keys do
		if entry.key ~= Enum.KeyCode.ButtonA and not table.find(others, entry.key) then
			table.insert(others, entry.key)
		end
	end
	whole.SelectionGained:Connect(function()
		for _, hint in hints do
			hint.Visible = true
		end
		if #others > 0 then
			bound = whole
			game:GetService("ContextActionService")
				:BindActionAtPriority(PadPage.ACTION, act, false, Focus.PRIORITY - 1, table.unpack(others))
		end
	end)
	whole.SelectionLost:Connect(function()
		for _, hint in hints do
			hint.Visible = false
		end
		if bound == whole then
			bound = nil
			game:GetService("ContextActionService"):UnbindAction(PadPage.ACTION)
		end
	end)
	return whole
end

--> A tile walked whole that A presses: `tile` with `inner`, the tile's own button (a claim or a
--> buy), pressing `press` while it is shown.
function PadPage.whole(frame: GuiObject, inner: GuiButton, press: () -> ()): TextButton
	return PadPage.tile(frame, { { key = Enum.KeyCode.ButtonA, button = inner, press = press } })
end

return PadPage
