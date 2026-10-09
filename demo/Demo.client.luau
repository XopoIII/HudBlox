--!strict
--- The kit to look at on a device: the README's top line with a ticking wallet, a round button
--- that sends a reward flight into it, and the bag dialog with tabs. Every icon is the icon
--- resolver's tinted disc, so the demo needs no assets.
---
--- Run it with rojo (see demo/README.md): the kit's `src` is mapped into ReplicatedStorage.
const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const HudBlox = require(ReplicatedStorage:WaitForChild("HudBlox"))

const playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- A demo counts nothing and reads left to right; Host is still said, as a game would say it.
HudBlox.Host.set({})

const theme = {
	icon = HudBlox.Icons.resolver({
		ids = {},
		tints = {
			coin = Color3.fromRGB(255, 200, 60),
			power = Color3.fromRGB(130, 170, 255),
			shop = Color3.fromRGB(120, 220, 140),
			bag = Color3.fromRGB(220, 150, 255),
		},
	}),
}

const gui = HudBlox.SafeArea.screen(playerGui, "Hud")
const row = HudBlox.TopBar.mount(gui, theme)

-- The wallet: two segments, both pinned, the coin one ticking once a second. The capsule keeps
-- one width; the pin is what stops the row jittering.
const wallet, pulse = row.addPill({
	{ lead = "coin", pin = { "999.9K", "888.8M" } },
	{ lead = "power", pin = { "9999" } },
})
wallet.segments[2].value.Text = "7"

task.spawn(function()
	local coins = 1200
	while true do
		task.wait(1)
		coins += 37
		wallet.segments[1].value.Text = string.format("%.1fK", coins / 1000)
	end
end)

-- The shop button sends a reward flight into the wallet, over whatever is open.
const layer = HudBlox.Flight.layer(playerGui)
const shop = row.addButton("shop")
shop.Activated:Connect(function()
	const lead = wallet.segments[1].lead
	if lead then
		HudBlox.Flight.send(layer, {
			from = HudBlox.Flight.centre(shop),
			to = lead,
			count = 8,
			draw = function(frame: Frame)
				theme.icon("coin", frame).Size = UDim2.fromScale(1, 1)
			end,
			landed = function()
				HudBlox.Flight.pulse(pulse)
			end,
		})
	end
end)

-- A whole dialog on the bag button: tabs in the body, the menu's buttons in the footer.
const dialog = HudBlox.Dialog.new(playerGui, "Bag", "Bag", 620, 600)

const tabs = HudBlox.Tabs.mount(dialog.body, {
	{ key = "all", label = "All" },
	{ key = "gear", label = "Gear" },
	{ key = "food", label = "Food" },
})
tabs.frame.Position = UDim2.fromOffset(0, 8)
HudBlox.Native.text(dialog.body, "The body is the game's to fill.", HudBlox.Native.BODY_SIZE)

HudBlox.Native.button(dialog.footer, "Close", "secondary").Activated:Connect(function()
	dialog.setOpen(false)
end)

const bag = row.addLeftButton("bag")
bag.Activated:Connect(function()
	dialog.toggle()
end)

-- A corner read-out that steps aside while the dialog is up.
const MARGIN = 16
local openDialogs = 0
local refresh: () -> ()
const clock = HudBlox.Indicator.capsule(gui, "Clock", Vector2.new(1, 1), theme)
HudBlox.Theme.label(theme, "Text", clock, "12:00", HudBlox.Indicator.TEXT_SIZE)
refresh = HudBlox.Indicator.follow({
	gui = gui,
	frames = { clock },
	bottom = function(): number
		return HudBlox.TouchClearance.base(MARGIN)
	end,
	place = function()
		clock.Position = UDim2.new(1, -MARGIN, 1, -HudBlox.TouchClearance.base(MARGIN))
	end,
	busy = function(): boolean
		return openDialogs > 0
	end,
})
dialog.changed.Event:Connect(function(open: boolean)
	openDialogs += if open then 1 else -1
	refresh()
end)
