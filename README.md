# HudBlox

**HUD capsules and round buttons that look like Roblox's own top bar, placed by the device's real
safe zones.**

HudBlox draws a game's counters as the dark capsules Roblox draws its own menu and chat buttons as,
on the same line, in the same plate, at the same sizes. It puts them where the device and Roblox
leave room: never under a notch, never under Roblox's buttons, never under the thumbstick. The
sizes were not designed: they were read off a live client's top bar, and the kit was built and used
in a live game before it became a package.

> **Status: 0.2.0.** The placement arithmetic is proven by specs that run on every push, and each
> of 31 small slips in it makes the suite fail (`tests/Mutate.luau`). The modules that build
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
HudBlox = { name = "xopoiii/hudblox", version = "=0.2.0", target = "roblox" }
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
  `Native.iconButton(parent, glyph, ring: GuiObject?)`. The focus ring a gamepad shows is the game's
  and is handed in.
- `Rtl.reader(isRtl: () -> boolean): RtlReader`: the mirror for a right-to-left locale, switched by
  the game's own answer: `apply(root)`, `flipEdge(frame)`, `slot(index)`, `start()`, `active()`.
  The mechanics are `Rtl.flipX`, `Rtl.flipListAlign`, `Rtl.alignText`, `Rtl.mirror`.

## What stays in the game

Its icon ids, its locale and its text direction, its focus ring, its dialogs, and every colour
beyond Roblox's measured plate. A kit module reads nothing of the game it is in.

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
