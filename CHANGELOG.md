# Changelog

Every release is listed here, newest first. The format follows Keep a Changelog, and versions follow
semantic versioning.

## Unreleased

## 0.1.0 - 2026-10-05

The HUD kit of Grabby Pit as a package: the same capsules, the same measured numbers, with every
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

### Changed from Grabby Pit's copy

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
  Grabby Pit and only decide where wrapping begins.
- `Layout.pillWidth` is derived from the properties `Pill` sets, not measured on a client.
- Not ported: the dialog (`NativeModal`, `ModalGeometry`), hiding the touch controls under a dialog
  (`TouchControls`), the gamepad focus family (`Focus`, `PadInput`, `PadMenu`, `PadGlyph`) and the
  backpack. They are a dialog kit and an input kit, not the HUD.
- No Wally package, no `.rbxm` and no roblox-ts typings.
