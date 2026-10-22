# Changelog

Every release is listed here, newest first. The format follows Keep a Changelog, and versions follow
semantic versioning.

## 0.12.1 - 2026-10-22

A game's owner, checking 0.12.0 on a television, found a picked card's outline cut off at the
top of a list, and no A on a card the ring stood on.

### Fixed

- **A list shows the control in focus with room round it**: **`PadScroll.reveal`** scrolls the
  list the ring stands in so the control shows whole with `PadScroll.MARGIN`, 10 points, round
  it; the engine scrolls to the control's own edges, and the ring and an outline drawn outside
  them were cut off. Where the canvas goes is **`PadScroll.into`**, plain numbers: 3 specs and
  3 mutants. The stick's scroll is kept between the canvas's ends in pixels, as the canvas is
  scrolled.
- **`DialogColumn.RING_ROOM`** is the ring's width and four points, room for a picked card's own
  outline too.
- **A on whatever the ring stands on**: **`Ring.say`** puts A's picture on the control in focus
  when it says no key of its own (a dialog's X wears B, a tile's buttons their keys), and takes it
  off as the ring leaves, the same on every control of every panel.

## 0.12.0 - 2026-10-22

The top line is drawn at Roblox's own scale. On a television Roblox draws its bar half again as
large (a strip of 87 against a computer's 58, the menu button 66 x 66 at x 24 and y 18), and the
kit's capsules and buttons stood beside it at a computer's size, smaller than Roblox's and out of
its line. A phone or any device that draws the bar at another size is followed the same way.

### Added

- **`Measure.STRIP`**, 58: Roblox's strip on the computer the other numbers were read on.
- **`Layout.scale(strip)`**: Roblox's scale of its bar, the strip's height over `Measure.STRIP`, 1
  for a strip that is not reported. 1 spec and 2 mutants.
- **`SafeArea.chromeScale()`**: that scale on the running device, for what a game stands beside or
  under the bar. **`SafeArea.follow(gui)`** keeps a gui of the game's own (a column of round
  buttons down the edge) at it, as the bar changes.

The rest of a game's pad, which a game had to write for itself and the next would again:

- **`PadCard.hold(name, root, first, options)`**: a card the game draws by hand holds the pad
  while it is shown, as a dialog does, the ring on `first` with A's picture, B doing `back` with
  its picture on `cancel`; a card built hidden takes the pad as it is shown.
- **`PadPage.first(root)`**, **`PadPage.ring(root)`**, **`PadPage.whole(frame, inner, press)`**: the
  first control of a part of the screen as `Pick` orders it; the ring put on it once a page drawn a
  share of a frame at a time is there; a tile walked whole by the ring, A pressing its button.
- **`PadChord.bind(chords)`**: a bumper held as a chord, the face buttons and the D-pad pressing what
  the game names from anywhere, each control wearing its key while the bumper is down and the
  bumper's own picture standing where the game says while it is up; the world's prompts off while
  a chord is held. **`PadChord.match`**, the rule, is plain data: 2 specs and 3 mutants.
- **`Tabs`' bumpers** leave the tabs out of the ring's walk and put the ring on the turned page's
  first control.

Every dialog walked the same way on a pad, in every game (a game's owner, testing on a pad: a
wardrobe whose last row had one card could not be reached from the middle column, the stick
swung the camera behind a list, and the top row's ring was cut off):

- **`Pick.toward`**, and **`Steer`**: a press of the D-pad or the stick goes to the nearest
  control that way, straight in line or, when none is, beside the line (a step aside weighs
  `Pick.ASIDE`, 2, steps along); `Focus` writes it on the control in focus as the engine's
  `NextSelection` of each way, and keeps a way a game wrote itself. 4 specs and 3 mutants.
- **`PadScroll`**: while a panel holds the pad, the right stick scrolls the list the ring stands
  in, and neither it nor the triggers reach the camera. **`PadScroll.step`**, how far a tilt
  scrolls, is plain numbers: 3 specs and 3 mutants.
- **`DialogColumn.mount(body, options)`**: the one column a dialog's body scrolls in, with room
  round its lines for the ring, the bar in a strip of its own with air before it.
- **`PadPage.tile(frame, keys)`**: a tile walked whole whose buttons each say their key while the
  ring stands on it (A wears or buys with stars, X buys with Robux), the first of a key whose button
  is shown pressing; **`PadPage.whole`** is a tile of one A, and now says it on its button.
- **Dialogs at Roblox's scale**: **`DialogGeometry.scaled`** lays a panel out in points of the
  bar's scale and `Dialog` draws it at that scale, half again as large on a television and still
  on the screen. 2 specs and 3 mutants. **`SafeArea.follow`** takes a card drawn by hand too.
- **A key's cap black on white**: `PadGlyph` fills the engine's cut-out letter with black and
  edges the white; a D-pad's way is a white disc with a black arrow. **`PadGlyph.shape`** says
  which a key has: 2 specs and 3 mutants. **`Ring.fit`** rounds the ring as the control in focus
  is rounded, at the scale it is drawn at.
- **The specs run on LuneBlox 0.11.0**, which gives them Roblox's `Enum`: `PadChord.find` is
  checked with `Enum.KeyCode` values as a game calls it. 2 specs and 2 mutants.

### Changed

- **`PadGlyph.cap` and `PadGlyph.corner` return a Frame**, not an ImageLabel: the picture is one
  of the cap's parts.
- **`TopBar`'s left buttons stand in a holder of their own** (`LeftHolder`) that carries Roblox's
  scale: the button's own UIScale is its squash, and an object is drawn at one UIScale only.

- **`Layout.top(screen, insetMinX, leftCount, rowTop?, scale?)`** lays the line out at `scale`:
  the edge margin, the top, the gaps and each left button's step grow with it. Without a scale it
  is the line it was. **`Layout.fits(top, needs, scale?)`** draws written widths at the scale.
  The arithmetic's mutants were moved onto the scaled lines, and 2 more added.
- **`TopBar.mount`** draws the row and the left buttons at `SafeArea.chromeScale()` (a UIScale
  named `ChromeScale` on each), placed at that scale, and fits again as the bar changes. The wrap
  check and a capsule's holder read the row in its own units.

### Not done

- The UIScale on the row and the left buttons, `SafeArea.follow`, `PadCard`, `PadPage` and the
  chords' binding and pictures build Instances or read the engine's input, so they are not run by
  the suite; they are looked at in a game in Studio's ten-foot interface with a pad.

## 0.11.0 - 2026-10-22

A dialog says on a gamepad what its keys do, and a strip of tabs turns on the bumpers. A game's
owner, trying a dialog with a pad, could not tell what to press: the focus stood on the body's first
control, nothing showed that B closes, and the tabs could only be reached by walking the ring up to
them.

### Added

- **`dialog.primary(button)`** names the button A accepts with: the pad's focus starts on it each
  time the dialog opens, and it wears A's picture. Nil takes the name off.
- **The dialog's X wears B's picture** on a pad.
- **`Tabs.mount`'s bumpers** (`Options.bumpers`, true when left out): while the panel the strip
  stands in holds the pad (`Focus`), the left bumper turns it a tab to the left and the right one a
  tab to the right, the left one always leftward in a strip read from the right; the end tabs wear
  the bumpers' pictures. One binding serves every strip, and a bumper goes to the strip drawn in the
  panel on top. `Tabs.ACTION`, `Tabs.CAP`.
- **`TabFit.step(count, on, by)`**: the place a bumper takes a strip to, kept within its ends. 1
  spec and 2 mutants.
- **`Focus.within(object)`**: whether a control stands in the panel that holds the pad.
- **`PadGlyph.corner(parent, code, size)`**: a cap pinned on a control's lower right corner,
  `PadGlyph.INSET` in from it.

### Not done

- The bumpers' binding, the pictures and a dialog's first focus on its primary build Instances and
  read the engine's input, so they are not run by the suite; checked against the Roblox API by the
  type gate under both solvers, and in a game in Studio.

## 0.10.3 - 2026-10-14

The top row's wrap warning speaks only for a wrap that stays, and once a row. Until now it fired on
every change of the row's size while the row was taller than one capsule. On a phone a
landscape-only game draws its first frames at portrait widths, before the engine turns the screen,
and so the row warned for a moment that nobody saw, and again on every resize. The message carries
the sizes, so each one was a row of its own in an error report, and a wrap that stays was buried
among them.

### Fixed

- **`TopBar.mount`** warns only when the row is still wrapped one second after it wrapped. A wrap
  that ends sooner says nothing; a wrap that ends and comes back is timed from its return. The
  warning names the settle period.
- **Once a mounted row.** After its warning a row says nothing more for any later wrap; a row
  mounted again after `destroy` may warn again. `destroy` silences a check still waiting.

### Added

- `src/Wrap.luau`, internal like `FlightBook` and not in the kit's table: what a wrap is (taller
  than one capsule by more than a pixel of rounding, moved here from `TopBar`) and when it is
  reported, as plain data over a delay the caller hands in (`task.delay` in a game). 9 specs and 11
  mutants.

### Not done

- `TopBar`'s wiring (the size signal, `task.delay`, the message) is Instance code and the suite
  does not run it. It is type-checked under both solvers. It was not looked at in a game: neither
  the quiet startup on a phone nor a wrap that stays.
- One second is chosen, not measured: how long the screen's turn at startup takes on the slowest
  phone has not been read.

## 0.10.2 - 2026-10-12

A dialog, a top bar's menu and a backpack can be built and opened on a server. Until now the first
dialog opened there raised `ContextActionService:BindAction can only be called from a local
script`, so a game could not open one in a suite of its own that runs on a server: an Open Cloud
task, or a spec under `ServerScriptService`.

On a client nothing changes: every action is bound when it was, at the priority it was.

### Fixed

- **`Focus.push` on a server** no longer raises. It bound B ("back") through
  `ContextActionService`, which the engine allows from a client only. Everything else a pushed
  scope does there was already taken by the engine: the selection group, the selection it follows,
  the world's prompts, the touch controls.
- So **`Dialog`'s `setOpen` and `toggle`** work on a server: the panel is placed, shown, counted in
  `ModalsOpen` and closed again, and `changed` fires. Only B is missing, as there is no pad.
- **`PadMenu.bind`**, **the backpack's keys** (`Backpack.mount`: 1 to 0, the backquote, the
  bumpers) and **its Y button** bind nothing on a server, for the same reason. They build what
  they built.

### Added

- `src/Bindable.luau`, internal like `TextMemo` and `FlightBook` and not in the kit's table: the
  one place that asks whether an action can be bound (`RunService:IsClient()`).

### Not done

- This is Instance code, and the suite here does not run it: there is no spec and no mutant for
  it. It is type-checked under both solvers. What was run is a game's own suite, on a server
  through Open Cloud, with these four files in place of 0.10.1's: it opened a dialog, closed it by
  `setOpen(false)`, opened it again and read `ModalsOpen` at each step. With 0.10.1 the same suite
  raised on the first opening.
- `PadMenu.bind` and `Backpack.mount` were not run on a server at all. Their guard is the same
  line; whether the rest of a backpack is built there without a player has not been looked at.
- A client was not looked at again. The change there is one call that answers true.

## 0.10.1 - 2026-10-10

A maintenance release. The package holds the same 50 files of `src/` as 0.10.0, byte for byte: a
game that moves to it changes a version number.

### Changed

- The tools the repository checks itself with are the newest releases: LuneBlox 0.10.16, which runs
  the specs and the mutants, and lefthook 2.2.1.

## 0.10.0 - 2026-10-10

One press on a gamepad puts a thing of the open inventory in the hands. Until now A picked a slot up
to move it and X sent it across; to hold a thing from the inventory a pad's player sent it to the
bar, closed the inventory and stepped along the bar with the bumpers.

With a keyboard, a mouse or a finger nothing changes. On a gamepad A, X, B, the D-pad and the
bumpers do what they did in 0.9.0.

### Added

- **Y on the focused slot of the open inventory** equips the thing and closes the inventory, for a
  slot of the bar or of the inventory. On the thing already in the hands it puts it away and
  closes, because that is what a press on its bar slot does with the inventory closed; on an empty
  slot, or with the focus off the slots, nothing happens.
- The rule is `Backpack.Hands` (`src/Backpack/Hands.luau`), pure: `press` (`"equip"`, `"stow"`,
  `"none"` or `"pass"`, typed `HudBlox.BackpackHands`), `sinks`, `acts` and `button`. A spec for
  every row and 18 mutants.
- Y stays the game's own button outside the inventory. The backpack binds it as a
  `ContextActionService` action (`BackpackEquip`) when the inventory opens, at the priority a
  panel's B is bound at (`Host.set`'s `backPriority`, or `Focus.PRIORITY`), and unbinds it when
  the inventory closes, however it closes: by B, by its button or key, by a dialog opening or the
  hotbar being covered, and when the backpack's gui is destroyed. While the inventory holds the
  pad's focus every press of it is sunk, the ones that do nothing too; with the player off a
  gamepad, or another panel over the inventory, the press is passed on.
- `BackpackConfig.padEquip`: the button, `Enum.KeyCode.ButtonY` when left out; another key code
  for a game that wants one; `false` binds nothing.
- `PadAct` gains `"Equip"`: `Host.set`'s `padUsed` hears it once for each equip or stow by the
  button.
- `Focus.holds(name)`: whether the panel pushed under that name holds the pad now, on top of every
  other. `Stack.onTop(stack, name)` is its pure part, with a spec and three mutants.

### Changed

- **A game whose pad counter is typed to the five old acts no longer type-checks** against
  `padUsed`, under either solver: a function that takes fewer acts than the kit reports does not
  fit. That is how a new act has always reached a game, loudly; add `"Equip"` to the counter's
  type and to wherever the acts are listed.
- A backpack's gui destroyed with its inventory open now lets go of its focus scope and its
  listener for A and X as well; before, both outlived the gui.
- The README's status no longer says the Instance-building modules have not been run in a game.
  It names the modules a live game calls, the ones that run inside those, and what has only been
  type-checked.
- `tests/consumer/Game.luau` reached the 300-line cap: its backpack part is `tests/consumer/Bag.luau`,
  and the type gate reads the whole folder under the old solver.
- The README lists `"Move"` among the acts `padUsed` hears; it has been reported since the
  backpack came, and the line had never been brought up to date.

### Not done

- **Nothing of the button's Instance side has been run**, in a game or in the demo: the binding,
  the sink, the unbinding on each way of closing. `src/Backpack/Pad.luau` is type-checked under
  the new solver and the rule it follows is specified; the rest waits for a game and a pad.
- Whether a prompt that also sits on Y (a `ProximityPrompt` with `GamepadKeyCode = ButtonY`) can
  start from the same held press once the inventory has closed is not known. `Focus` switches the
  prompts off while a panel holds the pad and on again a frame after it lets go.
- No hint of Y is drawn. The inventory draws no hint for A or X either, so there was no place to
  follow; a game that wants one pins `PadGlyph.cap` where it likes.
- The demo place has no backpack and does not show this. The demo itself has not been run: it is
  type-checked and the place is built and read back; what it looks like on a device has been seen
  by nobody yet.

### Around the package

On main since 0.9.0 and not in the archive a game installs, which is 50 files of `src/` now (the
49 of 0.9.0, and `Backpack/Hands.luau`).

- `demo/`: a place that shows the kit (`sh scripts/build-demo.sh`, or `rojo serve demo`): the top
  line with a wallet that ticks, a reward flight on the shop button, a dialog with tabs behind a
  button that wears a count, a corner clock that steps aside for the dialog, and the D-pad's way
  to the top line. No assets needed: the icons are the resolver's tinted discs. It is the demo of
  pull request #12, rewritten against today's API; as first written it would have hidden the
  whole HUD with the clock (both stood in one ScreenGui), drawn the tabs over the body's text
  and left the clock's label without a size.
- The gates read `demo/`: stylua, selene, the strict-mode, file-size and English checks, and the
  type gate, which builds a rojo sourcemap of the demo's project and checks the demo against the
  kit under both solvers. `rojo` 7.7.1 is pinned in `rokit.toml`.
- `scripts/build-demo.sh` (`tests/DemoPlace.luau`): builds the place and reads it back. Every file
  of `src/` must be a ModuleScript at its place under `ReplicatedStorage.HudBlox` with that file's
  source, nothing else may be there, and the demo must be a LocalScript in `StarterPlayerScripts`.
- `scripts/check-package.sh` now fails when the pesde archive holds anything but `src/`,
  `pesde.toml`, `README.md` and `LICENSE`, and when pesde writes no archive at all (it exits with
  success when it refuses an included file). It packs a copy of every tracked file, so `demo/`,
  `tests/` and `scripts/` are left out by `includes` and not by the copy.
- The README says that `Indicator.follow` switches off the whole gui it is given, so read-outs
  stand in a ScreenGui of their own.

## 0.9.0 - 2026-10-09

### Added

- `Host.set`'s `backPriority`, and `Host.backPriority()` to read it: the priority a panel's B
  ("back") is bound at, for a game whose own binding of B must sit above or below it.
  `Focus.PRIORITY` (2100, as before) when left out; read when the first scope is pushed, so say
  it before the first panel opens.
- `Stack.push` hands back the value a name stood with before, or nil for a new name.
- `TextMemo`: kept text measurements as plain data, with specs and mutants. It is `Pill`'s own and
  is not part of the kit's table.

### Changed

- A focus scope keeps its list of the panel's controls and re-reads it when the tree changes (a
  `DescendantAdded` or a `DescendantRemoving` under the panel), instead of walking every
  descendant at every repick. Where each control stands, whether it is shown and whether it is
  Selectable are still read at the pick. A scope lets go of its two watches and of its list when
  it is popped, and when its name is pushed again while it stands.
- `Pill.measure` keeps the text engine's answers by font, size and candidate strings, in any
  order: a surface rebuilt whole (a respawn, a reopened dialog) asks nothing that was already
  answered. Only a whole answer is kept: a pass in which the engine failed for any candidate, or
  answered zero, is asked again next time. At most 256 answers are held; one more starts the memo
  again. For a kept answer `done` is called before `measure` returns, as it already was whenever
  the text engine did not yield.
- `Button.round` makes its two squash tweens with the button and plays them again, instead of
  making a Tween at every press and every release. The goals (`Measure.SQUASH` and 1), the time
  and the easing are 0.7.0's, and a press still takes over from a release under way: the tween
  given way to is cancelled and the other played, from where the scale stands.
- `TopBar`'s holder-sizing connection is listed with the row's other connections and disconnected
  by `destroy`. It died with the row before, as the row's Instances were destroyed.

### Not done

- The stack this release was written as (pull requests #8 to #11) also made `Pill.pinWidth` skip a
  label with no parent, on the ground that writing to a destroyed label errors. It does not, and
  the skip would have passed over a label pinned before it was parented once its answer was kept.
  It is not in this release: `pinWidth` writes as 0.7.0 did.
- The focus cache and its watches, the tweens and the row's connection are Instance code and are
  not run by the suite. They are type-checked through `tests/consumer/Game.luau` and have not
  been looked at in a game. What is proven is `Stack` and `TextMemo`. That a Tween played again
  after it completed or was cancelled starts from where its property stands is Roblox's
  documented behaviour and was not run here: press one round button several times to see it.
- The demo place of pull request #12 is not in this release: no gate reads `demo/` yet.

## 0.8.0 - 2026-10-09

### Added

- `Flight.send` returns a second value, `cancel`: it calls back the icons still in the air and
  lands nothing, for where the reason for the reward goes away before it arrives (the shop it was
  bought in closed, the player teleported). A `landed` may cancel any flight, its own included,
  and may send another: the flights beside it fly on.
- `FlightBook`: the list of flights in the air and the pools of spent icon frames as plain data,
  with specs and mutants. It is `Flight`'s own and is not part of the kit's table.

### Changed

- However many rewards are in the air at once, one RenderStepped connection steps them all (was:
  one per flight), and the frame each icon is drawn in comes from a per-layer pool (was: a fresh
  `Instance.new("Frame")` each, destroyed on landing). Only that wrapper frame is pooled: what
  `draw` puts into it is made by the game for every icon and destroyed on landing, as before.
- A pooled frame is handed to `draw` without children and with a new frame's look (name,
  visibility, anchor, position, size, rotation, z-index, layout order, clipping, background,
  border). A connection or an attribute `draw` hangs on the frame itself is not undone; a `draw`
  that only adds children, as the README's does, is unaffected.
- As in 0.7.0, a frame is put in the layer after `draw` has filled it; now a flight's frames go in
  together, once every one is drawn, so a `draw` that throws leaves nothing in the layer (0.7.0
  left the icons drawn before the throw there, hidden).
- A layer's pool is dropped when the layer is destroyed.
- A cancelled flight leaves the driver's list on the next frame, not inside `cancel`; the one
  connection is dropped on that frame when it was the last flight.

### Not done

- The driver and the pool build and reuse Instances and are not run by the suite: what is proven
  is `FlightBook`'s bookkeeping (no flight skipped or dropped unspent when a step cancels or
  sends, no frame handed out twice, a dropped key's pool gone). That `Flight` uses it as said, the
  frame's reset look, the draw-before-layer order and the pool's drop on `Destroying` are
  type-checked through `tests/consumer/Game.luau` and have not been looked at in a game.

## 0.7.0 - 2026-10-08

### Added

- `BackpackHandle.rest(tool, seconds)`: a dark shade over the slot of a thing that cannot be used
  again yet, whole as the rest begins and emptying downward as it runs out. It is kept by the
  thing, so it follows it to another slot, and a redraw in its middle shows what is left. When a
  thing rests and for how long is the game's; nothing or less clears it.
- `Backpack.Rest.start`, `of` and `share`: the rest as arithmetic, specified.

### Not done

- The shade itself is built from Instances and is not run by the suite: it is type-checked through
  `tests/consumer/Game.luau` and was looked at in a game.

## 0.6.0 - 2026-10-08

### Added

- `Tabs.mount(parent, entries, options)`: a strip of tabs for a dialog's body, of which one wears
  the menu's blue. It fills from the reader's own side, and tabs that do not fit share the strip
  evenly. `buttons` gives each tab by its key, so a `Badge` can be pinned to one.
- `TabFit.width`: how wide each tab is in a strip, specified.
- `Flight.send(layer, options)`: a reward's icons burst out of where it was given and fly into the
  capsule that counts it, over every dialog. `Flight.layer`, `Flight.centre` and `Flight.pulse`
  beside it. What an icon is, how many fly and what a landing does are the game's.
- `FlightPath.count`, `leaves`, `lasts`, `ring` and `place`: the flight as arithmetic, specified.

### Changed

- The backpack's row of filters is a `Tabs` strip. The filter that is on when the inventory is
  made is the first one given; it was the one with no `kind`, wherever it stood, and none at all
  when every filter had a kind. Filters too many for the inventory's width now share it instead
  of running off its end.
- The README's status line and pin said 0.4.0 through 0.5.0.

### Not done

- `Tabs.mount` and `Flight.send` build Instances and are not run by the suite: they are
  type-checked through `tests/consumer/Game.luau` and were looked at in a game.

## 0.5.0 - 2026-10-07

### Added

- `Badge.pin(button, theme, options)`: a count on a button's upper trailing corner, above its icon,
  like the disc Roblox's chat button wears. `set(count)` shows a digit up to 9, "9+" past it, and
  hides the disc for nothing. The colour is the game's; `leading` puts it on the other corner for a
  mirrored layout.
- `Badge.text` and `Badge.width`: the pure parts, specified.

### Not done

- The disc itself is built from Instances and is not run by the suite: it is type-checked through
  `tests/consumer/Game.luau` and was looked at in a game.

## 0.4.0 - 2026-10-07

The backpack, the last of what the first game kept beside the kit.

### Added

- `Backpack.mount(player, config)`: a hotbar and the inventory above it in Roblox's stock layout,
  with drag and drop, tap then tap, a double tap, the keys and a gamepad. What a Tool is
  (`describe`), its picture (`draw`), the filters, every word (`text`), a pinned first slot
  (`pinned`) and a counter of how it is used (`used`) are the game's.
- `Backpack.Order`, `Backpack.Moves`, `Backpack.Press`: the pure parts, specified rule by rule.
- `HotbarCover`: hides a hotbar while something covers it, keyed by reason, and switches Roblox's
  own backpack off.

### Changed from the game's own copy

- The first slot belonged to one named thing. It belongs to `pinned` now, and with nothing pinned
  it is a slot like the rest.
- A slot's rim took its colour from the thing's rarity. The game hands the colour in, and a slot
  with no rim keeps the colour it had: a rim that is not drawn has none to show.
- What a press has become was worked out from a Vector2. It is plain numbers now (`Press`), so it
  runs in the specs.
- `HotbarCover.onChange` takes a function in place of a BindableEvent, and tells its listeners at
  once.

### Fixed against the game's own copy

- A double tap on a thing on the bar picks it up on the first tap and sends it to the inventory on
  the second. The slot it left kept pulsing, empty, until something else stood there. An emptied
  slot drops its outlines now.

### Not done

- `Backpack.mount`, `Gesture`, `Slot`, `Bar`, `Grid`, `Paint`, `Pad`, `Keys` and `Items` build
  Instances or read input, and are checked by the type gate only in this repository. They are ported
  line for line from a live game, whose own migration compares its interface before and after.

## 0.3.0 - 2026-10-07

The dialog and the gamepad's focus, which the first game still kept beside the kit.

### Added

- `Dialog.new`: a whole dialog in Roblox's own look, sized by `DialogGeometry` (plain arithmetic,
  specified rule by rule). The game's bottom furniture (`bottom`) and what hides it under a dialog
  that covers it (`cover`) are options.
- `Focus`, with `Ring`, `Pick` and `Stack`: a gamepad's selection, one panel at a time. Nothing in
  the engine changes until a game calls `Focus.start` or pushes its first panel.
- `PadInput`, `PadGlyph`, `PadMenu`, `TouchControls`.
- `Host.set({ rtl?, padUsed? })`: which way the game's reader reads and who counts a gamepad's
  presses, said once for the parts of the kit there is one of.

### Changed

- `Native.text` starts a line where the host's reader starts when `align` is left out. It was
  always the left. A game that has not called `Host.set` sees no difference.
- `Native.iconButton` wears the kit's round focus ring when none is handed in. It was the engine's
  own box.

### Changed from the game's own copy

- A panel's header had an inset that stepped it clear of Roblox's buttons. Since panels start below
  the top row no screen gives it a value other than zero: over 364,800 screens it never did. It is
  not ported, and the dialog no longer follows the top-bar inset, which could only move it.
- `PadInput` and `TouchControls` connect nothing until somebody asks, and `PadInput.onChange` takes
  a function in place of a BindableEvent.

## 0.2.0 - 2026-10-07

### Changed

- `Native.BACKDROP_T` is 0.5 (it was 1): a dialog dims the world behind it. The package carried the
  number the first game had before its owner played two weeks with it and asked for the change.
- No file names a game any more.

### Added

- `Native.MODAL_T` (0.06): the transparency of a dialog's own panel, nearly solid, for a panel with
  text to read on it. `Native.SURFACE_T` (0.3) stays for a strip over the world.

## 0.1.0 - 2026-10-05

The HUD kit of a live game as a package: the same capsules, the same measured numbers, with every
seam to the game cut. A kit module reads nothing of the game it is in.

### Added

- `TopBar.mount`: the top line. A right-aligned row of capsules and round buttons, and round buttons
  on the left that start 8 past Roblox's own buttons, read from `GuiService.TopbarInset`. The row
  reserves Roblox's span only while it shares Roblox's line, fits itself again on every change of
  the screen or the inset, and warns when it wraps.
- `Pill`: the capsule, with any number of `[icon][number]` segments. A segment's width can be
  pinned to its widest text (`pin`, `Pill.pinWidth`), so a number that ticks does not shove the row.
- `Button.round`: the round button on the capsule's plate, with a press squash and no hover state.
- `Theme` and `Icons.resolver`: what a game hands in. The icon ids stay in the game, as a table or a
  function; a name with no image draws a disc. The plate, the font and the text colour default to
  Roblox's own.
- `SafeArea`: the HUD's ScreenGui inside the device's safe insets, Roblox's strip, the usable
  height, the top-bar inset, and `bind` to follow them.
- `TouchClearance`, `Clearance`: how high a bottom-corner read-out stands to clear the thumbstick
  and the jump button, measured from the controls.
- `Indicator`: the corner read-out's capsule, and `follow`, which keeps it placed and hides it while
  the game is busy or its own bottom furniture reaches under it.
- `Band`: where a game reports that furniture (a hotbar) and a card asks how far to lift.
- `Native`: Roblox's menu look as colours, sizes, a text line, the two buttons and the small round
  glyph button. The gamepad focus ring is handed in.
- `Rtl.reader`: the right-to-left mirror, switched by a function the game supplies.
- `Layout`, `Clearance`, `Measure`: the arithmetic and the measured numbers, free of Instances, so a
  game can put its own worst-case row in a spec (`Layout.top`, `Layout.pillWidth`, `Layout.fits`).

### Changed from the game's own copy

- `Pill.build` and `Row.addPill` take a list of parts and return a `Capsule` table, in place of
  positional `lead, emoji, tappable` arguments and three return values.
- The theme is data with defaults (`plate`, `font`, `text`), in place of `corner` and `label`
  closures the game had to write.
- `Band` tells its listeners through `Band.onChange`, which returns a stop, in place of a
  `BindableEvent`; it copies a reported rectangle, so a reporter that moves its own table and
  reports it again is heard.
- `TouchClearance.follow` and `Indicator.follow` return a stop. `Indicator.follow` asks the game
  whether it is busy through an option, in place of reading a `ModalsOpen` attribute and an
  `inventory` rectangle.
- `Rtl` is switched by `Rtl.reader(isRtl)`, in place of a field read from the game's text module
  when the module loads.

### Not done

- The modules that build Instances are checked by the type gate only. Nothing in this repository
  runs them: there is no spec in a Roblox client yet, and nobody has looked at this package on a
  phone with a notch, a tablet or a narrow window.
- The top-bar inset of a phone held upright has not been measured. The specs use the 208 measured
  on a phone on its side; with that inset, an upright phone 390 wide leaves a row beside one left
  button 106 wide, which holds two round buttons and no capsule. `Layout.fits` says so; the kit
  does not rearrange the row.
- With no left buttons the right row may begin exactly where Roblox's buttons end, without the gap
  a left button keeps; below the chrome line it may reach the screen's left edge. Both are as in
  that game and only decide where wrapping begins.
- `Layout.pillWidth` is derived from the properties `Pill` sets, not measured on a client.
- (Ported in 0.3.0, all but the backpack.) Not ported: the dialog (`NativeModal`, `ModalGeometry`), hiding the touch controls under a dialog
  (`TouchControls`), the gamepad focus family (`Focus`, `PadInput`, `PadMenu`, `PadGlyph`) and the
  backpack. They are a dialog kit and an input kit, not the HUD.
- No Wally package, no `.rbxm` and no roblox-ts typings.
