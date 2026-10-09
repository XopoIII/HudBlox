--!strict
--- The kit to look at on a device: the README's top line with a wallet that ticks, a round button
--- that sends a reward flying into it, a dialog with tabs behind a button that wears a count, and
--- a clock in the corner that steps aside for the dialog. Every icon is the icon resolver's tinted
--- disc, so the demo needs no assets.
---
--- `demo/default.project.json` maps the kit's `src` to ReplicatedStorage.HudBlox and this script
--- to StarterPlayerScripts (see demo/README.md). It is formatted, linted and type-checked with the
--- kit on every push, under both type solvers, and the place is built: what is written here is
--- today's API.
const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const HudBlox = require(ReplicatedStorage:WaitForChild("HudBlox"))

const playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- What there is one of for the whole client is said once, before anything is built. The demo reads
-- left to right, so it gives no `rtl`; it prints what a gamepad does, where a game would count it.
-- A game with a binding of B of its own gives `backPriority` here too.
HudBlox.Host.set({
	padUsed = function(act: HudBlox.PadAct)
		print(`[HudBlox demo] gamepad: {act}`)
	end,
})

-- The icons stay in the game. With no ids, each name draws a disc in its tint.
const theme: HudBlox.Theme = {
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

-- The top line. The right row fills left to right and hugs the right edge: the wallet, added
-- last, keeps the corner.
const gui = HudBlox.SafeArea.screen(playerGui, "Hud")
const row = HudBlox.TopBar.mount(gui, theme)
const shop = row.addButton("shop")
-- Both values are pinned to the widest text they can hold, so the row does not move as they tick.
const wallet, pulse = row.addPill({
	{ lead = "coin", pin = { "999.9K", "888.8M" } },
	{ lead = "power", pin = { "9999" } },
})
const bag = row.addLeftButton("bag")

const function short(amount: number): string
	return if amount < 1000 then tostring(amount) else string.format("%.1fK", amount / 1000)
end

local coins = 940
const function showCoins()
	wallet.segments[1].value.Text = short(coins)
end
showCoins()
wallet.segments[2].value.Text = "7"

-- The shop button sends a reward into the wallet, on a layer above every dialog. The number
-- counts an icon when it lands, not when it is sent. `send` returns how many icons fly and a
-- function that calls back the ones still in the air, for a reward whose reason goes away;
-- nothing here does.
const COINS_AN_ICON = 5
const layer = HudBlox.Flight.layer(playerGui)
shop.Activated:Connect(function()
	const lead = wallet.segments[1].lead
	if lead then
		HudBlox.Flight.send(layer, {
			from = HudBlox.Flight.centre(shop),
			to = lead,
			count = 8,
			-- The frame is not in the layer yet and may have flown before: fill it, keep nothing.
			draw = function(frame: Frame)
				theme.icon("coin", frame).Size = UDim2.fromScale(1, 1)
			end,
			landed = function()
				coins += COINS_AN_ICON
				showCoins()
				HudBlox.Flight.pulse(pulse)
			end,
		})
	end
end)

-- A whole dialog on the bag button: tabs in the body, the menu's button in the footer. It closes
-- by its X, a tap outside, the footer's button and a gamepad's B.
const dialog = HudBlox.Dialog.new(playerGui, "Bag", "Bag", 620, 600)

const TABS: { HudBlox.TabsEntry } = {
	{ key = "all", label = "All" },
	{ key = "gear", label = "Gear" },
	{ key = "food", label = "Food" },
}
-- What stands under a tab is the game's: here, one line below the strip.
const under = HudBlox.Native.text(dialog.body, "", HudBlox.Native.BODY_SIZE, { color = HudBlox.Native.BODY })
under.Position = UDim2.fromOffset(0, HudBlox.TabFit.HEIGHT + HudBlox.Native.GAP)
const function showTab(key: string)
	under.Text = `The "{key}" tab is on.`
end
const tabs = HudBlox.Tabs.mount(dialog.body, TABS, { picked = showTab })
-- `picked` is not called at mount.
showTab(tabs.on())

HudBlox.Native.button(dialog.footer, "Close", "secondary").Activated:Connect(function()
	dialog.setOpen(false)
end)

-- A count on the button's corner, gone once the dialog has been opened.
const waiting = HudBlox.Badge.pin(bag, theme, { colour = Color3.fromRGB(0, 120, 255) })
waiting.set(3)
bag.Activated:Connect(function()
	dialog.toggle()
end)
dialog.changed.Event:Connect(function(open: boolean)
	if open then
		waiting.set(nil)
	end
end)

-- A gamepad reaches the top line by the D-pad: down puts the focus on `first`, right opens the
-- dialog. Both buttons wear the picture of their direction while a pad is in the hands.
HudBlox.PadMenu.bind({
	gui = gui,
	buttons = { bag, shop },
	first = shop,
	bag = bag,
	toggleBag = dialog.toggle,
})

-- A read-out in the bottom right corner, above the jump button on a phone. It stands in a gui of
-- its own, because a read-out steps aside by having its whole gui switched off.
const MARGIN = 16
const corner = HudBlox.SafeArea.screen(playerGui, "ReadOuts")
const card = HudBlox.Indicator.capsule(corner, "Clock", Vector2.new(1, 1), theme)
const clock = HudBlox.Theme.label(theme, "Time", card, "", HudBlox.Indicator.TEXT_SIZE)
clock.AutomaticSize = Enum.AutomaticSize.X
clock.Size = UDim2.fromOffset(0, HudBlox.Indicator.HEIGHT)
const function showClock()
	clock.Text = os.date("%H:%M")
end
showClock()

-- A dialog that is up is counted in an attribute of PlayerGui, for whatever steps aside for one.
const function dialogUp(): boolean
	const up = playerGui:GetAttribute(HudBlox.Dialog.OPEN_ATTRIBUTE)
	return type(up) == "number" and up > 0
end
const refresh = HudBlox.Indicator.follow({
	gui = corner,
	frames = { card },
	bottom = function(): number
		return HudBlox.TouchClearance.base(MARGIN)
	end,
	place = function()
		card.Position = UDim2.new(1, -MARGIN, 1, -HudBlox.TouchClearance.base(MARGIN))
	end,
	busy = dialogUp,
})
playerGui:GetAttributeChangedSignal(HudBlox.Dialog.OPEN_ATTRIBUTE):Connect(refresh)

-- The demo's own life: the wallet earns once a second, and the clock is read again.
while true do
	task.wait(1)
	coins += 37
	showCoins()
	showClock()
end
