# Changelog

Every release is listed here, newest first. The format follows Keep a Changelog, and versions follow
semantic versioning.

## Unreleased

## 0.9.2 - 2026-10-09

### Changed

- `Button.round` makes its two squash tweens once per button instead of a fresh Tween per press: a
  button is pressed hundreds of times a session. A press that interrupts a release (or the reverse)
  now cancels the other tween first, so it is one smooth move rather than two racing ones.

### Not done

- Instance code, not run by the suite: type-checked through `tests/consumer/Game.luau`, not looked
  at in a game.

## 0.9.1 - 2026-10-09

### Fixed

- `Pill.pinWidth` no longer writes its answer into a label whose capsule was destroyed before the
  text engine answered (a respawn, a closed dialog), which errored in the measuring thread.

### Changed

- `Pill.measure` keeps the text engine's answers by font, size and candidate strings: a surface
  rebuilt whole (a respawn, a reopened dialog) asks nothing that was already answered. A failed
  pass is never kept, so a text engine that was not ready is asked again next time.

### Not done

- Both are Instance code and are not run by the suite: they are type-checked through
  `tests/consumer/Game.luau`, and have not been looked at in a game.

## 0.9.0 - 2026-10-09

### Added

- `Host.set`'s `backPriority`: the priority a panel's B ("back") is bound at, for a game whose own
  binding of B must sit above or below it. `Focus.PRIORITY` when left out; read when the first
  scope is pushed, so say it before the first panel opens.

### Changed

- A focus scope keeps its list of the panel's controls and re-reads it when the tree changes,
  instead of walking every descendant at every repick. Where each control stands and whether it is
  Selectable is still read at the pick; a control that becomes Selectable with no add or remove is
  seen at the next one.

### Not done

- The cache and its watches are Instance code and are not run by the suite: they are type-checked
  through `tests/consumer/Game.luau`, and have not been looked at in a game.

## 0.8.0 - 2026-10-09

### Added

- `Flight.send` returns a second value, `cancel`: it calls back the icons still in the air and
  lands nothing, for where the reason for the reward goes away before it arrives (the shop it was
  bought in closed, the player teleported).

### Changed

- However many rewards are in the air at once, one RenderStepped connection steps them all (was:
  one per flight), and the icon frames come from a per-layer pool instead of a fresh
  `Instance.new` each: a rain of rewards costs one connection and no new Instances. A pooled frame
  is handed to `draw` emptied, and the flight owns its frames for the flight's duration, as before.

### Not done

- The driver and the pool build and reuse Instances and are not run by the suite: they are
  type-checked through `tests/consumer/Game.luau`, and have not been looked at in a game.

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
