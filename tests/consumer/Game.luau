--!strict
--- A game's use of the whole public API, as the README shows it. It is checked by the type gate
--- under both solvers (`scripts/type-check.sh`) and is NOT run: it needs a Roblox client.
---
--- When the API changes, this file changes with it, and the README's example after it.
const HudBlox = require("@hudblox")

const Players = game:GetService("Players")

-- The game's own icon ids stay in the game.
const ICONS = {
	coin = "rbxassetid://1",
	power = "rbxassetid://2",
	shop = "rbxassetid://3",
	leaders = "rbxassetid://4",
	bag = "rbxassetid://5",
}

const theme: HudBlox.Theme = {
	icon = HudBlox.Icons.resolver({ ids = ICONS, pixelated = true, smooth = { shop = true } }),
	press = function() end,
}

const playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
const gui = HudBlox.SafeArea.screen(playerGui, "Hud")

-- The top line: one capsule with two numbers, two round buttons beside it, one on the left.
const row: HudBlox.Row = HudBlox.TopBar.mount(gui, theme)
const shop = row.addButton("shop")
const leaders = row.addButton("leaders")
const wallet, pulse = row.addPill({
	{ lead = "coin", pin = { "999.9K", "888.8M" } },
	{ lead = "power", pin = { "9999" } },
})
const bag = row.addLeftButton("bag")
wallet.segments[1].value.Text = "120"
wallet.segments[2].value.Text = "7"
pulse.Scale = 1.1
shop.Activated:Connect(function() end)
leaders.Activated:Connect(function() end)
bag.Activated:Connect(function() end)

-- The same pieces on their own, and an icon by function.
const byFunction: HudBlox.Theme = {
	icon = HudBlox.Icons.resolver({
		ids = function(name: string): string?
			return ICONS[name]
		end,
		tints = { coin = Color3.new(1, 1, 0) },
		color = Color3.new(1, 1, 1),
	}),
	plate = Color3.new(0, 0, 0),
	plateTransparency = 0.2,
	font = Font.fromEnum(Enum.Font.GothamBold),
	text = Color3.new(1, 1, 1),
}
const lone: HudBlox.Capsule = HudBlox.Pill.build(gui, byFunction, { { lead = "km", emoji = true }, {} }, true)
const extra: HudBlox.Segment = HudBlox.Pill.segment(lone.plate, byFunction, 3, { lead = "coin" })
HudBlox.Pill.pinWidth(extra.value, { "00:00" })
HudBlox.Pill.measure(HudBlox.Theme.font(byFunction), HudBlox.Measure.TEXT, { "0" }, function(_widest: number) end)
const rail = HudBlox.Button.round(gui, theme, "shop", { name = "Rail", size = 56, iconFraction = 0.74 })
rail.Position = UDim2.new(0, HudBlox.Measure.EDGE, HudBlox.SafeArea.y(gui, 0.5).Scale, 0)

-- The screen, read and as arithmetic.
const screen: HudBlox.Screen = HudBlox.SafeArea.measure(gui)
const top: HudBlox.Top = HudBlox.Layout.top(screen, HudBlox.SafeArea.insetMinX(), 1)
const needs = HudBlox.Layout.rowNeeds({
	HudBlox.Layout.pillWidth({ { ink = 60, lead = true }, { ink = 44, lead = true } }),
	HudBlox.Measure.HEIGHT,
	HudBlox.Measure.HEIGHT,
})
if not HudBlox.Layout.fits(top, needs) then
	warn("the top row does not fit this screen")
end
const _strip: number = HudBlox.SafeArea.topStrip(gui) + HudBlox.SafeArea.usableHeight(gui)
const _free: number = HudBlox.SafeArea.topbarFreeX(gui) + HudBlox.SafeArea.chromeFreeX(gui, HudBlox.Measure.TOP)

-- A read-out in the bottom right corner, above the jump button and the game's own hotbar.
const MARGIN = 12
const card = HudBlox.Indicator.capsule(gui, "Clock", Vector2.new(1, 1), theme)
const clock = HudBlox.Native.text(card, "12:00", HudBlox.Indicator.TEXT_SIZE, { weight = Enum.FontWeight.Bold })
clock.AutomaticSize = Enum.AutomaticSize.X
clock.Size = UDim2.fromOffset(0, HudBlox.Indicator.HEIGHT)
local dialogs = 0
const refresh, stopFollowing = HudBlox.Indicator.follow({
	gui = gui,
	frames = { card },
	bottom = function(): number
		return HudBlox.TouchClearance.base(MARGIN)
	end,
	place = function()
		card.Position = UDim2.new(1, -MARGIN, 1, -HudBlox.TouchClearance.base(MARGIN))
	end,
	busy = function(): boolean
		return dialogs > 0
	end,
})
dialogs += 1
refresh()
HudBlox.Band.set("hotbar", { left = 100, right = 300, top = 60 })
const stopBand = HudBlox.Band.onChange(refresh)
const _lift: number = HudBlox.Band.lift(0, 120, MARGIN)
const _has: boolean = HudBlox.Band.has("hotbar")
const _height: number = HudBlox.Clearance.height(392, { { top = 250, visible = true } })
const stopTouch = HudBlox.TouchClearance.follow(refresh)

-- The menu look, and the mirror for a right-to-left locale.
const rtl: HudBlox.RtlReader = HudBlox.Rtl.reader(function(): boolean
	return false
end)
const panel = Instance.new("Frame")
panel.BackgroundColor3 = HudBlox.Native.SURFACE
panel.BackgroundTransparency = HudBlox.Native.MODAL_T
const dim = Instance.new("Frame")
dim.BackgroundColor3 = HudBlox.Native.SURFACE
dim.BackgroundTransparency = HudBlox.Native.BACKDROP_T
const strip = Instance.new("Frame")
strip.BackgroundTransparency = HudBlox.Native.SURFACE_T
const _title = HudBlox.Native.text(panel, "Shop", HudBlox.Native.TITLE_SIZE, { align = rtl.start() })
const buy = HudBlox.Native.button(panel, "Buy", "primary")
const leave = HudBlox.Native.button(panel, "Close", "secondary")
buy.LayoutOrder = rtl.slot(1)
leave.LayoutOrder = rtl.slot(2)
const ring = Instance.new("Frame")
const close = HudBlox.Native.iconButton(panel, "x", ring)
rtl.flipEdge(close)
rtl.apply(panel)
panel.Parent = gui

-- A surface that can be unmounted stops everything it started.
const unbind = HudBlox.SafeArea.bind(gui, row.fit)
unbind()
stopTouch()
stopBand()
stopFollowing()
row.destroy()
