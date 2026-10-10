# Changelog

Every release is listed here, newest first. The format follows Keep a Changelog, and versions follow
semantic versioning.

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
