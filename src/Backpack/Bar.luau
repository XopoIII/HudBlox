--!strict
--- The hotbar at the bottom centre, in the stock backpack's layout: `Slot.SIZE` squares `Slot.GAP`
--- apart, ten of them on a computer or a console and three on a phone.
---
--- Closed, it shows only the slots that hold something, centred, as the stock one does. With the
--- inventory open every slot shows, empty ones too, so there is somewhere to drop a thing.
---
--- A mouse over a filled slot shows the thing's tip just above it, and so does a gamepad's focus, on
--- the bar and in the inventory (`Pad`).
const Host = require("../Host")
const Items = require("./Items")
const Native = require("../Native")
const Slot = require("./Slot")

const Bar = {}

Bar.HEIGHT = Slot.SIZE + Slot.GAP * 2
-- Space under the bar, off the screen's bottom edge.
Bar.BOTTOM = 4

const KEYS = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }

export type Bar = {
	frame: Frame,
	slots: { Slot.Slot },
	--- Makes `count` slots.
	resize: (count: number) -> (),
	--- Shows the slots; `all` shows the empty ones too. Returns the width.
	layout: (all: boolean) -> number,
	--- The item under the mouse or in a gamepad's focus, for the tooltip.
	hover: (slot: Slot.Slot?, item: Items.Item?) -> (),
}

--> The width of a bar of `count` shown slots.
function Bar.width(count: number): number
	return Slot.GAP + count * (Slot.SIZE + Slot.GAP)
end

--> The bar under `parent`. `made` is called with each slot as it is made, to bind its gesture;
--> `draw` fills a slot's picture.
function Bar.new(parent: Instance, made: (slot: Slot.Slot) -> (), draw: Slot.Draw): Bar
	const frame = Instance.new("Frame")
	frame.Name = "Bar"
	frame.AnchorPoint = Vector2.new(0.5, 1)
	frame.Position = UDim2.new(0.5, 0, 1, -Bar.BOTTOM)
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromOffset(Bar.width(0), Bar.HEIGHT)
	frame.Parent = parent

	const tip = Native.text(parent, "", 15, { weight = Enum.FontWeight.Bold })
	tip.Name = "Tooltip"
	tip.TextWrapped = false
	tip.AutomaticSize = Enum.AutomaticSize.X
	tip.Size = UDim2.fromOffset(0, 22)
	tip.AnchorPoint = Vector2.new(0.5, 1)
	tip.BackgroundColor3 = Native.CAPSULE
	tip.BackgroundTransparency = Native.CAPSULE_T
	tip.TextXAlignment = Enum.TextXAlignment.Center
	tip.Visible = false
	tip.ZIndex = 20
	const pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.Parent = tip
	const tipCorner = Instance.new("UICorner")
	tipCorner.CornerRadius = UDim.new(0, 6)
	tipCorner.Parent = tip

	local bar: Bar
	bar = {
		frame = frame,
		slots = {},
		resize = function(count: number)
			while #bar.slots > count do
				(table.remove(bar.slots) :: Slot.Slot).destroy()
			end
			while #bar.slots < count do
				const index = #bar.slots + 1
				const slot = Slot.new(frame, { zone = "bar", index = index }, draw)
				slot.frame.Name = "Slot" .. index
				table.insert(bar.slots, slot)
				made(slot)
			end
		end,
		layout = function(all: boolean): number
			const keys = game:GetService("UserInputService").KeyboardEnabled
			const rtl = Host.rtl().active()
			local x = Slot.GAP
			for index, slot in bar.slots do
				const shown = all or slot.id ~= nil
				slot.frame.Visible = shown
				slot.setNumber(if keys then KEYS[index] else nil)
				if shown then
					-- Slot 1 at the reading start: the right edge in a right-to-left locale.
					slot.frame.Position = if rtl
						then UDim2.new(1, -(x + Slot.SIZE), 0, Slot.GAP)
						else UDim2.fromOffset(x, Slot.GAP)
					x += Slot.SIZE + Slot.GAP
				end
			end
			frame.Size = UDim2.fromOffset(x, Bar.HEIGHT)
			return x
		end,
		hover = function(slot: Slot.Slot?, item: Items.Item?)
			if not (slot and item) then
				tip.Visible = false
				return
			end
			tip.Text = item.tip
			const at = slot.frame.AbsolutePosition
			const size = slot.frame.AbsoluteSize
			tip.Position = UDim2.fromOffset(at.X + size.X / 2, at.Y - 6)
			tip.Visible = true
		end,
	}
	return bar
end

return Bar
