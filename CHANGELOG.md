# Changelog

Every release is listed here, newest first. The format follows Keep a Changelog, and versions follow
semantic versioning.

## Unreleased

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
