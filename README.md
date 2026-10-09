# HudBlox

**HUD capsules and round buttons that look like Roblox's own top bar, placed by the device's real
safe zones.**

HudBlox draws a game's counters as the dark capsules Roblox draws its own menu and chat buttons as,
on the same line, in the same plate, at the same sizes. It puts them where the device and Roblox
leave room: never under a notch, never under Roblox's buttons, never under the thumbstick. The
sizes were not designed: they were read off a live client's top bar, and the kit was built and used
in a live game before it became a package.

> **Status: 0.9.3.** The placement arithmetic and the backpack's order and taps are proven by specs
> that run on every push, and each of 166 small slips in them makes the suite fail
> (`tests/Mutate.luau`). The modules that build
> Instances are checked against the Roblox API by the type gate, under both type solvers, and were
> ported from code that runs in a live game; as a package they have not yet been run in a game or
> looked at on devices. Try it in a test place first.

## Install

```sh
pesde add xopoiii/hudblox -t roblox -a HudBlox
```

or pin it exactly in `pesde.toml`:

```toml
[dependencies]
HudBlox = { name = "xopoiii/hudblox", version = "=0.9.3", target = "roblox" }
```

HudBlox runs on the client. It has no dependencies.

## The top line in a minute

```lua
local HudBlox = require(path.to.HudBlox)

-- The game's icons stay in the game: the kit is told how to draw one by name.
local theme: HudBlox.Theme = {
	icon = HudBlox.Icons.resolver({
		ids = { coin = "rbxassetid://...", power = "rbxassetid://...", shop = "rbxassetid://...", bag = "rbxassetid://..." },
	}),
}

-- A ScreenGui inside the device's safe insets, edge to edge, so the row can share Roblox's line.
local gui = HudBlox.SafeArea.screen(playerGui, "Hud")
local row = HudBlox.TopBar.mount(gui, theme)

-- The right row fills left to right and hugs the right edge: the last thing added is in the corner.
local shop = row.addButton("shop")
local wallet = row.addPill({
	{ lead = "coin", pin = { "999.9K", "888.8M" } }, -- pinned: the row does not jitter as it ticks
	{ lead = "power", pin = { "9999" } },
})
-- One round button on the left, 8 past Roblox's own, read from GuiService.TopbarInset.
local bag = row.addLeftButton("bag")

wallet.segments[1].value.Text = "120"
wallet.segments[2].value.Text = "7"
shop.Activated:Connect(openShop)
bag.Activated:Connect(openBag)
```

The row fits itself again whenever the screen or Roblox's inset changes, and it **warns in the
output if it wraps**: a row that does not fit is not clipped, it grows a second line where nobody
looks. Ask ahead of time with `Layout.fits` (below).

## The API

`HudBlox` is a table of modules. Sizes are pixels; `Measure` holds the measured numbers.

### Theme: what the game hands in

```lua
type Theme = {
	icon: (name: string, parent: Instance) -> GuiObject, -- required
	plate: Color3?,             -- default: Roblox's own, RGB 18, 18, 21
	plateTransparency: number?, -- default: 0.08
	font: Font?,                -- default: Builder Sans Bold
	text: Color3?,              -- default: white
	press: (() -> ())?,         -- called on the frame a round button is pressed: a click sound
}
```

`Icons.resolver(options): Icon` builds `icon` from the game's table:

```lua
type IconOptions = {
	ids: { [string]: string } | (name: string) -> string?, -- "rbxassetid://..." by name
	tints: { [string]: Color3 }?,   -- the disc's colour for a name with no image yet
	pixelated: boolean?,            -- true for pixel art: not filtered when scaled
	smooth: { [string]: boolean }?, -- names filtered anyway: line glyphs among pixel art
	color: Color3?,                 -- a colour over every image: white art in the theme's ink
}
```

A name with no id draws a plain disc, so a missing picture never breaks a screen.

### TopBar: the row

`TopBar.mount(gui: ScreenGui, theme: Theme): Row`

| `Row` | |
| --- | --- |
| `addPill(parts: { Part }, tappable: boolean?): (Capsule, UIScale)` | A capsule in the right row, one segment per part. The `UIScale` is yours to animate: a pulse does not move the row. `tappable` makes the plate a `TextButton`. |
| `addButton(icon: string): TextButton` | A round button in the right row. |
| `addLeftButton(icon: string): TextButton` | A round button on the left, past Roblox's own buttons. |
| `fit()` | Places everything again. The row calls it itself on every screen or inset change. |
| `destroy()` | Disconnects and destroys the row and its left buttons. |
| `frame: Frame` | The row's frame. |

For the row to share the line of Roblox's own buttons the gui must ignore the gui inset
(`SafeArea.screen` makes one). In a gui that respects the inset the row sits below Roblox's buttons,
reserves nothing for them, and the first left button starts at the edge margin, 16.

### Pill: a capsule

```lua
type Part = {
	lead: string?,    -- the icon's name; nil or "" for no lead
	emoji: boolean?,  -- `lead` is a text glyph to show as it is
	pin: { string }?, -- the widest texts the value can hold: its width is pinned to the widest
}
type Segment = { value: TextLabel, lead: GuiObject? }
type Capsule = { plate: GuiObject, segments: { Segment } }
```

- `Pill.build(parent, theme, parts: { Part }, tappable: boolean?): Capsule`: a capsule anywhere.
- `Pill.segment(plate, theme, order: number, part: Part): Segment`: one more segment, later.
- `Pill.pinWidth(label: TextLabel, candidates: { string })`: pins a label to its widest text. Padding
  the string does not do this: the font is not monospaced, so "01:24" and "02:12" differ in width.
- `Pill.measure(font, size, candidates, done: (widest: number) -> ())`: the measurement alone.

### Button: a round button

`Button.round(parent, theme, icon: string, options: ButtonOptions?): TextButton`

```lua
type ButtonOptions = {
	name: string?,         -- default "IconButton"
	size: number?,         -- default 44
	iconPx: number?,       -- default 24, the ink Roblox draws
	iconFraction: number?, -- the icon as a fraction of the plate instead (Measure.ICON_FRACTION)
}
```

It squashes to 0.9 on press and has no hover state. Connect `Activated`.

### Badge: a count on a button

`Badge.pin(button: GuiObject, theme, options: BadgeOptions): BadgeHandle`

```lua
type BadgeOptions = {
	colour: Color3,    -- the disc's colour: the kit owns none
	ink: Color3?,      -- the digit's colour; the theme's text colour when left out
	leading: boolean?, -- the upper leading corner, for a button a right-to-left layout mirrored
}
type BadgeHandle = { set: (count: number?) -> (), frame: Frame }
```

A small disc on the button's upper trailing corner, above its icon, like the one Roblox's chat
button wears. `set(3)` shows "3", `set(12)` shows "9+", and `set(0)` or `set(nil)` hides it. It
shows nothing until it is given a count.

- `Badge.text(count: number?): string?`: what a badge reads for a count, nil for no badge.
- `Badge.width(text: string): number`: the disc's width for that text.

### Tabs: a strip of tabs

`Tabs.mount(parent: Instance, entries: { TabsEntry }, options: TabsOptions?): TabsHandle`

```lua
type TabsEntry = { key: string, label: string }
type TabsOptions = {
	picked: ((key: string) -> ())?, -- told each time a tab is put on, by a press or by `pick`
	first: string?,                 -- the tab that is on at first; the first one when left out
	name: string?,                  -- the strip's name in the tree, "Tabs" when left out
	height: number?, width: number?, gap: number?, text: number?, -- TabFit's when left out
}
type TabsHandle = {
	frame: Frame,                       -- as wide as its parent, one tab high; the game places it
	buttons: { [string]: TextButton },  -- each tab by its key, to pin a Badge to one
	pick: (key: string) -> boolean,     -- puts a tab on; false for a key that is no tab's
	on: () -> string,                   -- the key of the tab that is on
}
```

A row of the menu's buttons of which one wears the blue. The strip fills from the reader's own
side (`Host`), and when it is narrower than its tabs ask for they share it evenly. What stands
under a tab is the game's: `picked` shows it. `picked` is not called at mount.

- `TabFit.width(span, count, gap, most): number`: how wide each of `count` tabs is in a strip
  `span` wide. `TabFit.HEIGHT` 40, `WIDTH` 150, `GAP` 8, `TEXT` 20, `NARROWEST` 44.

The backpack's filters are this strip, a chip's size.

### Flight: a reward flying to its counter

```lua
const layer = Flight.layer(playerGui)
const flying, cancel = Flight.send(layer, {
	from = Flight.centre(claimButton),   -- or any point in AbsolutePosition's space
	to = wallet.segments[1].lead,        -- what the icons fly into
	count = 8,                           -- FlightPath.count of it flies: at most 12
	draw = function(frame, index) ... end, -- fills one icon's frame
	landed = function(index, count) Flight.pulse(walletScale) end,
})
```

Each icon leaves a thirty-second of a second after the one before, steps out to its own place on
a ring round the source, then flies into the target, shrinking, and is gone. The target is read
every frame. `landed` is called as each icon lands, which is when a game writes the new number;
a target that leaves the tree lands every icon still in the air at once, so nothing is lost.

`send` returns how many fly and a `cancel`, which calls back the icons still in the air and lands
nothing — for where the reason for the reward goes away before it arrives. However many rewards
fly at once, one RenderStepped connection steps them all, and the icon frames come from a pool
rather than from `Instance.new`.

- `Flight.layer(playerGui, name?): ScreenGui`: where they fly, ten layers over a dialog; made once.
- `Flight.centre(object): Vector2`: the middle of a GuiObject, for `from`.
- `Flight.pulse(scale: UIScale, peak: number?)`: swells a counter and settles it. `TopBar`'s
  `addPill` returns the capsule's `UIScale` for this.
- `FlightPath.count`, `leaves`, `lasts`, `ring`, `place`: the times and the path as arithmetic.

A point in the world is turned into `from` by the game (`Camera:WorldToScreenPoint`).

### SafeArea: the screen

| | |
| --- | --- |
| `SafeArea.screen(parent, name): ScreenGui` | The HUD's gui: kept across respawns, inside the device's safe insets, over Roblox's strip. |
| `SafeArea.topStrip(gui): number` | The height of Roblox's strip at the top of `gui`; 0 for a gui that respects the inset. |
| `SafeArea.usableHeight(gui): number` | The height below that strip. |
| `SafeArea.y(gui, fraction): UDim` | `fraction` of the usable height: use it where `UDim.new(fraction, 0)` would go. |
| `SafeArea.insetMinX(): number` | Where Roblox's buttons end: `GuiService.TopbarInset.Min.X`. |
| `SafeArea.topbarFreeX(gui): number` | The same, in `gui`'s coordinates. |
| `SafeArea.chromeFreeX(gui, rowTop): number` | What a row at `rowTop` must leave for Roblox; 0 below its line. |
| `SafeArea.measure(gui): Screen` | `gui` as `Layout` takes it. |
| `SafeArea.bind(gui, place): () -> ()` | Runs `place` now and on every change of the area; returns the stop. |

### The bottom corners

A read-out in a bottom corner stands above the thumbstick and the jump button by their measured
height, not by a guess from the device type:

```lua
local MARGIN = 12
local card = HudBlox.Indicator.capsule(gui, "Clock", Vector2.new(1, 1), theme)
local function place()
	card.Position = UDim2.new(1, -MARGIN, 1, -HudBlox.TouchClearance.base(MARGIN))
end
local refresh, stop = HudBlox.Indicator.follow({
	gui = gui,
	frames = { card },
	bottom = function() return HudBlox.TouchClearance.base(MARGIN) end,
	place = place,
	busy = function() return dialogsOpen > 0 end, -- optional; call refresh() when it changes
})
```

- `TouchClearance.height(): number`: pixels from the screen's bottom to the top of the highest
  visible touch control; 0 without touch controls.
- `TouchClearance.base(margin): number`: how far above the bottom edge a read-out's lower edge goes.
- `TouchClearance.follow(changed): () -> ()`: calls `changed` when the controls arrive, move or hide.
- `Indicator.capsule(parent, name, anchor: Vector2, theme): Frame`: a read-out's plate, 36 high and
  half as solid as a top-bar capsule; put icons and text in it (`Indicator.TEXT_SIZE`, `HEIGHT`,
  `STACK`, `PAD`).
- `Indicator.follow(options): (refresh, stop)`: keeps a read-out placed, and hides its gui while the
  game is `busy` or while something reported to `Band` reaches under it.
- `Band.set(key, rect: { left, right, top }?)`, `Band.lift(left, right, bottom): number`,
  `Band.has(key)`, `Band.onChange(changed): () -> ()`: the game's own bottom furniture (a hotbar)
  reports its rectangle; a card asks how much higher it must stand to clear it.

### Layout and Clearance: the arithmetic

No Instances, so a game can put its own worst case in a spec:

```lua
local Layout = HudBlox.Layout
local top = Layout.top({ width = 801, left = 0, top = -58 }, 208, 1) -- screen, TopbarInset.Min.X, left buttons
-- top.lefts = { 216 }, top.rowLeft = 268, top.rowWidth = 517, top.onChromeLine = true
local needs = Layout.rowNeeds({
	Layout.pillWidth({ { ink = 44, lead = true }, { ink = 44, lead = true } }), -- 186
	44, -- a round button
})
assert(Layout.fits(top, needs))
```

`Layout`: `top`, `fits`, `rowNeeds`, `pillWidth`, `leftStart`, `onChromeLine`, `freeX`,
`chromeFreeX`, `topStrip`, `usableHeight`, `yOffset`, `pinned`, `mirrorX`.
`Clearance`: `height(bottom, controls: { { top: number, visible: boolean } })`, `base(margin, height)`,
`stacked(base, index, size, gap)`.

### Native and Rtl

- `Native`: Roblox's menu look. Colours (`SURFACE`, `TILE`, `PRIMARY`, `CAPSULE`, `TEXT`, `BODY`,
  `DIVIDER` and their transparencies), sizes (`CORNER`, `PAD`, `GAP`, `BUTTON_H`, `TITLE_SIZE`,
  `BODY_SIZE`), `Native.font(weight?)`,
  `Native.text(parent, text, size, { weight?, color?, align? }?)`,
  `Native.button(parent, text, "primary" | "secondary"?)`,
  `Native.iconButton(parent, glyph, ring: GuiObject?)`. A line starts where the game's reader
  starts unless `align` says otherwise (`Host`), and a round button wears the kit's round focus
  ring unless one is handed in.
- `Rtl.reader(isRtl: () -> boolean): RtlReader`: the mirror for a right-to-left locale, switched by
  the game's own answer: `apply(root)`, `flipEdge(frame)`, `slot(index)`, `start()`, `active()`.
  The mechanics are `Rtl.flipX`, `Rtl.flipListAlign`, `Rtl.alignText`, `Rtl.mirror`.

### Host: what there is one of

```lua
HudBlox.Host.set({
	rtl = HudBlox.Rtl.reader(function() return myLocaleIsRtl end),
	padUsed = function(act) countPadUse(act) end,
	backPriority = 2200, -- where a panel's B sits against the game's own binding of B
})
```

A capsule takes its theme as an argument, because a game may draw two looks. Which way its reader
reads and who counts a gamepad's presses are one for the whole client, and the dialog, the focus
and `Native.text` read them here. Nothing is required: unset, the reader reads left to right and
nobody counts. `padUsed` hears `"Panel"`, `"Back"`, `"Hud"` and `"Bag"`. `backPriority` moves the
panel's B ("back") above or below the game's own binding of B; `Focus.PRIORITY` when left out.

### Dialog: a whole dialog

```lua
local shop = HudBlox.Dialog.new(playerGui, "Shop", "Shop", 620, 600, {
	bottom = { band = 82, room = 360 },          -- a hotbar the panel keeps above
	cover = function(covered) hideHotbar(covered) end,
})
HudBlox.Native.button(shop.footer, "Buy")
openButton.Activated:Connect(shop.toggle)
```

`Dialog.new(playerGui, name, title, width, height, options?)` builds a ScreenGui (DisplayOrder 10)
with a backdrop that dims the world, a nearly solid panel, a title, a close button on the left as in
the Escape menu, a divider, a `body` to fill and a `footer` that takes a button's height once it
holds one. It hands back `gui`, `panel`, `title`, `body`, `footer`, `setOpen(open)`, `toggle()` and
`changed` (a BindableEvent fired with the new state).

- It closes on the X, on a tap outside and on a gamepad's B, pops in and shrinks out.
- While it is up the touch controls are hidden and the character stands (`TouchControls`), a
  gamepad's focus stays inside the panel (`Focus`), and the PlayerGui attribute `ModalsOpen` counts
  it (`Dialog.OPEN_ATTRIBUTE`), for whatever steps aside for a dialog.
- Its size is `DialogGeometry.layout(width, height, strip, maxW, maxH, bottom?)`, plain arithmetic
  with a spec for every rule: framed where the screen has room, under Roblox's strip where it is
  short, full height on a landscape phone, never over the top row, and above the game's bottom band
  (`bottom`) while `room` is left over it. Where it is not, `clearsBottom` is false and `cover(true)`
  tells the game to hide the band until the dialog closes.

### Focus, Ring, Pick, Stack: a gamepad's selection

- `Focus.push(name, root, { back?, first? }?)` gives the pad to a panel: the selection is kept
  inside `root`, B runs `back` for the newest panel alone, the world's prompts are off and the
  character stands. `Focus.pop(name)` takes it back, `Focus.open()` says whether any panel has it.
  Only while the player is on a gamepad (`PadInput`): a mouse or a finger sees no ring.
- `Focus.start()` switches the engine's own auto-selection off and begins to follow the selection.
  The first `push` calls it; a game that wants the engine's auto-selection off from its first frame
  calls it as its client loads. A game that never pushes keeps the engine's own behaviour.
- `Ring.square()` and `Ring.round()`: the white outline of the focused control, in place of the
  engine's blue box. `Ring.install(playerGui)` (which the first `push` does) gives every control the
  square one; a round button names the round one itself.
- `Pick.first(targets, rtl)` and `Pick.nearest(targets, x, y, rtl)`: where focus starts in a panel
  and where it goes when the focused control is gone. `Stack`: which panels hold the focus, a name
  standing once. Both are plain data with specs.

### PadInput, PadGlyph, PadMenu, TouchControls

- `PadInput.active()` and `PadInput.onChange(fn) -> stop`: whether the player is on a gamepad now
  (`UserInputService.PreferredInput`). In Studio only, `Workspace:SetAttribute("PadCheck", true)`
  answers yes, for a test bridge whose pad keys arrive as a keyboard's.
- `PadGlyph.cap(parent, keyCode, size)`: the picture of a pad's button as the player's own pad
  draws it, shown only while they are on a pad.
- `PadMenu.bind({ gui, buttons, first, bag, toggleBag })`: D-pad down puts the focus on a top bar's
  buttons, D-pad right opens the game's most used panel. Both stand down while a panel has the focus.
- `TouchControls.set(reason, hide)`: hides the thumbstick and the jump button and holds the
  character, keyed by reason so two surfaces can overlap.

### Backpack: the hotbar and the inventory

Roblox's own backpack cannot be opened from a script, so a game that wants a button for its
inventory draws the stock layout itself. `Backpack.mount` does: a hotbar of ten slots (three on a
phone), the inventory above it with a count, a search box and the game's filters, drag and drop,
tap then tap, a double tap, the keys 1 to 0 and the backquote, and a gamepad's focus, A, X, B and
bumpers.

```luau
const backpack = HudBlox.Backpack.mount(player, {
	describe = function(tool: Tool): HudBlox.BackpackItem
		return {
			tool = tool,
			id = tool.Name,
			fresh = false,
			tip = tool.Name,
			search = tool.Name,
			kind = "tool",
			counted = true,
			picture = tool.Name,
		}
	end,
	draw = function(view: ViewportFrame, item: HudBlox.BackpackItem, done: (boolean) -> ())
		done(false)
	end,
	text = {
		title = "Backpack",
		search = "Search",
		nothing = "Nothing here yet",
		allOnBar = "Everything is on the bar",
		count = function(n: number): string
			return `Backpack ({n})`
		end,
	},
	filters = { { label = "All" }, { kind = "tool", label = "Tools" } },
})
button.Activated:Connect(backpack.toggle)
-- A thing that cannot be used again yet: its slot is shaded and empties as the seconds pass.
backpack.rest(tool, 4)
```

| `BackpackConfig` | |
|---|---|
| `describe(tool): BackpackItem` | What a Tool is: its `id` (the same through a respawn), whether it is `fresh`, its `tip`, what a `search` finds it by, its `kind` for the filters, its `rim` colour, whether it is `counted`, and what its `picture` is of. The kit reads no attribute off a Tool. |
| `draw(view, item, done)` | Puts the item's picture in the slot's ViewportFrame. |
| `text` | The inventory's words, in the player's language. |
| `filters` | The inventory's filter buttons; one with no `kind` shows everything. |
| `pinned` | The id of the thing that owns the bar's first slot and never leaves it. |
| `used(act)` | Called with `"Open"`, `"Drag"`, `"Double"` or `"Pair"`, for a game that counts them. |

The handle has `toggle()` and `rest(tool, seconds)`: a dark shade over that thing's slot, whole as
the rest begins and emptying downward to nothing as it ends. It follows the thing if it is moved;
nothing or less clears it. When a thing rests, and for how long, is the game's.

`Backpack.Order`, `Backpack.Moves`, `Backpack.Press` and `Backpack.Rest` are the pure parts: where
each thing sits (a thing seen before goes back where it was; a fresh one takes the slot of the one
longest on a full bar), what a tap means, what a press still down has become, and how long a thing
still rests. `Backpack.Slot.SIZE`,
`Backpack.Bar.HEIGHT` and `Backpack.Bar.BOTTOM` are the layout's numbers, for a dialog that keeps
above the bar.

`HotbarCover.set(reason, hide)` hides the bar while something covers it (a `Dialog`'s `cover`),
keyed by reason; `HotbarCover.hidden()` and `HotbarCover.onChange(fn) -> stop` read it. The open
inventory closes when a dialog opens, and reports itself to `Band` as `"hotbar"` and `"inventory"`.

## What stays in the game

Its icon ids, its locale and its text direction, what its dialogs hold, what its Tools are and how
they are pictured, and every colour beyond Roblox's measured plate. A kit module reads nothing of the game it is in.

## The measurements

Read off CoreGui's `TopBarApp` in a live client (last on 2026-09-22 and 2026-09-23):

| What | Value |
| --- | --- |
| Capsule and round button | 44 high, fully round |
| Plate | RGB 18, 18, 21 at transparency 0.08 |
| Icon | 24 (inside a 36 hit area) |
| Number | Builder Sans Bold, 22, white |
| Inside a capsule | 10 before the lead, 6 between lead and number, 16 between segments, 12 after |
| The line | 16 from the screen's edge, 12 from the top, 8 between things |
| Roblox's strip | 58 tall on a phone; its buttons ended at x = 208 there (`TopbarInset.Min.X`), which moves |

## Contributing

```sh
rokit install                       # the pinned toolchain
lefthook install                    # the gates, before every commit and push
sh scripts/run-tests.sh             # the specs
luneblox run tests/Mutate --yes     # every slip in the arithmetic must fail the suite
lefthook run pre-commit --all-files # every pre-commit gate over the whole tree
```

Specs run on [LuneBlox](https://github.com/XopoIII/LuneBlox), which runs the Luau version and fast
flags Roblox runs.

## License

MIT. See [LICENSE](LICENSE).
