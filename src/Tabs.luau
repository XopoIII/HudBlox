--!strict
--- A strip of tabs: a row of the menu's buttons of which one is on.
---
---     const tabs = Tabs.mount(dialog.body, {
---         { key = "pets", label = "Pets" },
---         { key = "eggs", label = "Eggs" },
---     }, { picked = show })
---     tabs.pick("eggs")
---
--- The tab that is on wears the menu's blue, the others its faint white: the two looks
--- `Native.button` already has. The strip lays its tabs from the reader's own side, and when it is
--- narrower than its tabs ask for they share it evenly instead of running off its end.
---
--- What stands under a tab is the game's: `picked` is told the key and shows what it will. The
--- sizes and the sharing rule are `TabFit`'s.
---
--- On a gamepad the bumpers turn the strip a tab left or right while the panel it stands in holds
--- the pad (`Focus`), the left bumper always to the left, and the two end tabs wear the bumpers'
--- pictures (`PadGlyph`). A strip that should not answer them says `bumpers = false`.
const Bindable = require("./Bindable")
const Focus = require("./Focus")
const Host = require("./Host")
const Native = require("./Native")
const PadGlyph = require("./PadGlyph")
const TabFit = require("./TabFit")

const Tabs = {}

--- The bumpers' action, and the size of their pictures on the end tabs, in pixels.
Tabs.ACTION = "TabsBumpers"
Tabs.CAP = 18

-- every strip that answers the bumpers, and how it steps
const strips: { [Frame]: (by: number) -> () } = {}
local bound = false

-- Whether `object` is drawn: it and everything over it visible, in a gui that is on.
const function drawn(object: GuiObject): boolean
	local at: Instance? = object
	while at do
		if at:IsA("GuiObject") and not at.Visible then
			return false
		elseif at:IsA("LayerCollector") then
			return at.Enabled
		end
		at = at.Parent
	end
	return false
end

-- One binding for every strip: a bumper goes to the strip drawn in the panel that holds the pad.
const function bind()
	if bound or not Bindable.here() then
		return
	end
	bound = true
	game:GetService("ContextActionService"):BindActionAtPriority(
		Tabs.ACTION,
		function(_: string, state: Enum.UserInputState, input: InputObject): Enum.ContextActionResult
			if state ~= Enum.UserInputState.Begin then
				return Enum.ContextActionResult.Pass
			end
			for frame, step in strips do
				if Focus.within(frame) and drawn(frame) then
					step(if input.KeyCode == Enum.KeyCode.ButtonL1 then -1 else 1)
					return Enum.ContextActionResult.Sink
				end
			end
			return Enum.ContextActionResult.Pass
		end,
		false,
		Focus.PRIORITY,
		Enum.KeyCode.ButtonL1,
		Enum.KeyCode.ButtonR1
	)
end

export type Entry = {
	--- What `picked` is told, and the tab's name in the tree.
	key: string,
	--- The word on the tab.
	label: string,
}

export type Options = {
	--- Called with a tab's key each time it is put on: by a press, or by `pick`. Not called at
	--- mount.
	picked: ((key: string) -> ())?,
	--- The tab that is on at first. The first one when left out.
	first: string?,
	--- The strip's name in the tree. "Tabs" when left out.
	name: string?,
	--- Whether a gamepad's bumpers turn the strip, with their pictures on its end tabs. True when
	--- left out.
	bumpers: boolean?,
	--- A tab's height, widest width, the gap between two and the size of its word; `TabFit`'s
	--- when left out.
	height: number?,
	width: number?,
	gap: number?,
	text: number?,
}

export type Handle = {
	--- The strip: as wide as its parent, one tab high. The game places it.
	frame: Frame,
	--- Each tab by its key, for a game that pins a count to one.
	buttons: { [string]: TextButton },
	--- Puts the tab `key` on and tells `picked`. False, and nothing done, for a key that is not a
	--- tab's.
	pick: (key: string) -> boolean,
	--- The key of the tab that is on.
	on: () -> string,
}

--> Builds the strip in `parent` with one tab for each of `entries`, in their order, and returns
--> its handle. At least one entry is needed.
function Tabs.mount(parent: Instance, entries: { Entry }, options: Options?): Handle
	assert(#entries > 0, "Tabs.mount: no entries")
	const height = (options and options.height) or TabFit.HEIGHT
	const most = (options and options.width) or TabFit.WIDTH
	const gap = (options and options.gap) or TabFit.GAP
	const reader = Host.rtl()

	const frame = Instance.new("Frame")
	frame.Name = (options and options.name) or "Tabs"
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, height)
	frame.Parent = parent
	const row = Instance.new("UIListLayout")
	row.FillDirection = Enum.FillDirection.Horizontal
	row.SortOrder = Enum.SortOrder.LayoutOrder
	row.Padding = UDim.new(0, gap)
	row.HorizontalAlignment = if reader.active() then Enum.HorizontalAlignment.Right else Enum.HorizontalAlignment.Left
	row.Parent = frame

	const buttons: { [string]: TextButton } = {}
	local on = entries[1].key

	const function paint()
		for key, button in buttons do
			const lit = key == on
			button.BackgroundColor3 = if lit then Native.PRIMARY else Native.TEXT
			button.BackgroundTransparency = if lit then 0 else 0.9
		end
	end

	const function fit()
		const width = TabFit.width(frame.AbsoluteSize.X, #entries, gap, most)
		for _, button in buttons do
			button.Size = UDim2.fromOffset(width, height)
		end
	end

	const function pick(key: string): boolean
		if not buttons[key] then
			return false
		end
		on = key
		paint()
		const picked = options and options.picked
		if picked then
			picked(key)
		end
		return true
	end

	for i, entry in entries do
		assert(not buttons[entry.key], `Tabs.mount: two tabs are called "{entry.key}"`)
		const button = Native.button(frame, entry.label, "secondary")
		button.Name = entry.key
		button.LayoutOrder = reader.slot(i)
		button.TextSize = (options and options.text) or TabFit.TEXT
		button.Size = UDim2.fromOffset(most, height)
		buttons[entry.key] = button
		button.Activated:Connect(function()
			pick(entry.key)
		end)
	end

	const first = options and options.first
	if first and buttons[first] then
		on = first
	end
	paint()
	-- A strip not yet laid out reports no width: its tabs keep their widest until it has one.
	frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if frame.AbsoluteSize.X > 0 then
			fit()
		end
	end)
	if frame.AbsoluteSize.X > 0 then
		fit()
	end

	if #entries > 1 and not (options and options.bumpers == false) then
		-- the left bumper goes left: back in reading order, on in a strip read from the right
		const ahead = if reader.active() then -1 else 1
		strips[frame] = function(by: number)
			local place = 1
			for i, entry in entries do
				if entry.key == on then
					place = i
				end
			end
			pick(entries[TabFit.step(#entries, place, by * ahead)].key)
		end
		frame.Destroying:Connect(function()
			strips[frame] = nil
		end)
		const left = if reader.active() then entries[#entries] else entries[1]
		const right = if reader.active() then entries[1] else entries[#entries]
		const lb = PadGlyph.cap(buttons[left.key], Enum.KeyCode.ButtonL1, Tabs.CAP)
		lb.AnchorPoint = Vector2.new(0.5, 0.5)
		lb.Position = UDim2.fromOffset(4, 4)
		const rb = PadGlyph.cap(buttons[right.key], Enum.KeyCode.ButtonR1, Tabs.CAP)
		rb.AnchorPoint = Vector2.new(0.5, 0.5)
		rb.Position = UDim2.new(1, -4, 0, 4)
		bind()
	end

	return {
		frame = frame,
		buttons = buttons,
		pick = pick,
		on = function(): string
			return on
		end,
	}
end

return Tabs
