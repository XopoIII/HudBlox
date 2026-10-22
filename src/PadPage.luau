--!strict
--- Where the ring stands in a part of the screen: its first control, as `Pick.first` orders them
--- (the lowest `SelectionOrder`, the top row, the reading start of it), and a tile walked whole.
---
--- A page drawn a share of a frame at a time has no controls yet the moment its tab is turned, and
--- the ring falls back to the dialog's X; `ring` waits for the page and puts it on the first.
const Focus = require("./Focus")
const Host = require("./Host")
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

--> Makes a tile `frame` walked whole by the ring: an unseen button over all of it, under what is
--> drawn on it, which `press`es while `inner` (the tile's own button, a claim or a buy) is shown.
--> `inner` is left out of the ring's walk, so the ring stops once a tile. Returns the button.
function PadPage.whole(frame: GuiObject, inner: GuiButton, press: () -> ()): TextButton
	const whole = Instance.new("TextButton")
	whole.Name = "Whole"
	whole.Text = ""
	whole.AutoButtonColor = false
	whole.BackgroundTransparency = 1
	whole.Size = UDim2.fromScale(1, 1)
	whole.ZIndex = 0
	whole.Parent = frame
	inner.Selectable = false
	whole.Activated:Connect(function()
		if inner.Visible then
			press()
		end
	end)
	return whole
end

return PadPage
