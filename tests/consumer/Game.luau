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
const waiting: HudBlox.BadgeHandle = HudBlox.Badge.pin(rail, theme, { colour = Color3.fromRGB(0, 120, 255) })
waiting.set(3)
waiting.set(nil)
const mirrored: HudBlox.BadgeOptions = { colour = Color3.new(1, 0, 0), ink = Color3.new(1, 1, 1), leading = true }
HudBlox.Badge.pin(rail, theme, mirrored).frame.Visible = HudBlox.Badge.text(12) == "9+"

-- A strip of tabs, and a count on one of them.
const tabEntries: { HudBlox.TabsEntry } = { { key = "pets", label = "Pets" }, { key = "eggs", label = "Eggs" } }
const tabOptions: HudBlox.TabsOptions = {
	picked = function(_key: string) end,
	first = "eggs",
	name = "Kinds",
	height = HudBlox.TabFit.HEIGHT,
	width = HudBlox.TabFit.width(712, 2, HudBlox.TabFit.GAP, HudBlox.TabFit.WIDTH),
	gap = HudBlox.TabFit.GAP,
	text = HudBlox.TabFit.TEXT,
}
const tabs: HudBlox.TabsHandle = HudBlox.Tabs.mount(gui, tabEntries, tabOptions)
tabs.frame.Position = UDim2.fromOffset(0, HudBlox.TabFit.NARROWEST)
if tabs.pick("pets") and tabs.on() == "pets" then
	HudBlox.Badge.pin(tabs.buttons.pets, theme, { colour = Color3.new(0, 0, 1) }).set(2)
end

-- A reward flying into the capsule that counts it.
const flightLayer: ScreenGui = HudBlox.Flight.layer(playerGui, "Rewards")
const coinLead = wallet.segments[1].lead
if coinLead then
	const flight: HudBlox.FlightOptions = {
		from = HudBlox.Flight.centre(rail),
		to = coinLead,
		count = 8,
		draw = function(frame: Frame, _index: number)
			theme.icon("coin", frame).Size = UDim2.fromScale(1, 1)
		end,
		landed = function(_index: number, _count: number)
			HudBlox.Flight.pulse(pulse, 1.2)
		end,
		size = HudBlox.FlightPath.SIZE,
		radius = HudBlox.FlightPath.RADIUS,
	}
	const flying: number = HudBlox.Flight.send(flightLayer, flight)
	const _x, _y, _scale, phase = HudBlox.FlightPath.place(0.1, 1, flying, 0, 0, 100, 100, 46)
	const landed: HudBlox.FlightPhase = "done"
	if phase == landed or HudBlox.FlightPath.lasts(flying) < HudBlox.FlightPath.leaves(2) then
		const x, y = HudBlox.FlightPath.ring(1, HudBlox.FlightPath.count(8), 46)
		rail.Position = UDim2.fromOffset(x, y)
	end
end

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

-- What there is one of for the whole client is said once.
const hooks: HudBlox.HostHooks = {
	rtl = rtl,
	padUsed = function(_act: HudBlox.PadAct) end,
}
HudBlox.Host.set(hooks)
const _reader: HudBlox.RtlReader = HudBlox.Host.rtl()
HudBlox.Host.padUsed("Panel")

-- A whole dialog, over the game's own hotbar.
const bar: HudBlox.DialogBottom = { band = 82, room = 360 }
const dialogOptions: HudBlox.DialogOptions = {
	bottom = bar,
	cover = function(_covered: boolean) end,
}
const shopDialog: HudBlox.DialogHandle = HudBlox.Dialog.new(playerGui, "Shop", "Shop", 620, 600, dialogOptions)
const plain: HudBlox.DialogHandle = HudBlox.Dialog.new(playerGui, "Help", "Help", 460, 330)
HudBlox.Native.button(shopDialog.footer, "Buy").Activated:Connect(function()
	shopDialog.toggle()
end)
shopDialog.changed.Event:Connect(function(_open: boolean) end)
shopDialog.setOpen(true)
plain.setOpen(false)
const _parts: { Instance } = { shopDialog.gui, shopDialog.panel, shopDialog.title, shopDialog.body }
const frame: HudBlox.DialogFrame = HudBlox.DialogGeometry.layout(801, 392, 58, 620, 600, bar)
const _covers: boolean = not frame.clearsBottom
const _box: { number } = { frame.width, frame.height, frame.top, HudBlox.DialogGeometry.TOP_ROW_BOTTOM }
const _attribute: string = HudBlox.Dialog.OPEN_ATTRIBUTE

-- A gamepad's selection: a panel of the game's own, the ring, and the pure parts.
HudBlox.Focus.start()
const focusOptions: HudBlox.FocusOptions = {
	back = function() end,
	first = function(): GuiObject?
		return buy
	end,
}
HudBlox.Focus.push("panel", panel, focusOptions)
const _held: boolean = HudBlox.Focus.open()
HudBlox.Focus.pop("panel")
buy.SelectionImageObject = HudBlox.Ring.square()
close.SelectionImageObject = HudBlox.Ring.round()
const targets: { HudBlox.PickTarget } = { { x = 10, y = 10, order = 0, shown = true, selectable = true } }
const _first: number? = HudBlox.Pick.first(targets, false)
const _nearest: number? = HudBlox.Pick.nearest(targets, 0, 0, rtl.active())
const scopes: { entries: { { name: string, value: number } } } = { entries = {} }
HudBlox.Stack.push(scopes, "a", 1)
const _size: number = HudBlox.Stack.size(scopes)

-- The pad itself, and the touch controls.
const _onPad: boolean = HudBlox.PadInput.active()
const stopPad = HudBlox.PadInput.onChange(function(_active: boolean) end)
const _cap: ImageLabel = HudBlox.PadGlyph.cap(buy, Enum.KeyCode.ButtonA, 18)
const menu: HudBlox.PadMenuConfig = {
	gui = gui,
	buttons = { buy, leave },
	first = buy,
	bag = leave,
	toggleBag = shopDialog.toggle,
}
HudBlox.PadMenu.bind(menu)
HudBlox.TouchControls.set("help", true)
HudBlox.TouchControls.set("help", false)
stopPad()

-- The game's own Tools in the stock backpack: what each is, its picture, and every word.
const function describe(tool: Tool): HudBlox.BackpackItem
	return {
		tool = tool,
		id = tool.Name,
		fresh = tool:GetAttribute("Fresh") == true,
		tip = tool.Name,
		search = tool.Name,
		kind = "tool",
		rim = Color3.new(1, 1, 1),
		counted = true,
		picture = tool.Name,
	}
end
const draw: HudBlox.BackpackDraw = function(_view: ViewportFrame, _item: HudBlox.BackpackItem, done: (boolean) -> ())
	done(false)
end
const words: HudBlox.BackpackWords = {
	title = "Backpack",
	search = "Search",
	nothing = "Nothing here yet",
	allOnBar = "Everything is on the bar",
	count = function(n: number): string
		return `Backpack ({n})`
	end,
}
const filters: { HudBlox.BackpackFilter } = { { label = "All" }, { kind = "tool", label = "Tools" } }
const backpackConfig: HudBlox.BackpackConfig = {
	describe = describe,
	draw = draw,
	text = words,
	filters = filters,
	pinned = "Sword",
	used = function(_act: HudBlox.BackpackAct) end,
}
const backpack: HudBlox.BackpackHandle = HudBlox.Backpack.mount(Players.LocalPlayer, backpackConfig)
backpack.toggle()
backpack.rest(Instance.new("Tool"), 4 * HudBlox.Backpack.Rest.share(3, 4))
const kept: HudBlox.BackpackOrder = HudBlox.Backpack.Order.new(10, "Sword")
HudBlox.Backpack.Order.add(kept, "Sword", false)
const spot: HudBlox.BackpackPlace? = HudBlox.Backpack.Order.where(kept, "Sword")
const taps = HudBlox.Backpack.Moves.new()
const _outcome = HudBlox.Backpack.Moves.tap(taps, kept, 0, "Sword", spot or { zone = "bar", index = 1 }, true)
const _verdict = HudBlox.Backpack.Press.classify("touch", "grid", 0, 12, 0.05)
const _barTop: number = HudBlox.Backpack.Bar.BOTTOM + HudBlox.Backpack.Bar.HEIGHT + HudBlox.Backpack.Slot.SIZE
const _small: number = HudBlox.Backpack.PHONE_W
HudBlox.HotbarCover.set("help", true)
const _covered: boolean = HudBlox.HotbarCover.hidden()
const stopCover = HudBlox.HotbarCover.onChange(function(_hidden: boolean) end)
HudBlox.HotbarCover.set("help", false)
stopCover()

-- A surface that can be unmounted stops everything it started.
const unbind = HudBlox.SafeArea.bind(gui, row.fit)
unbind()
stopTouch()
stopBand()
stopFollowing()
row.destroy()
