# The demo place

A place to look at the kit in, on a device or in Studio's device emulator, before installing
anything: the README's top line with a wallet that ticks, a reward flying into it, a dialog with
tabs behind a button that wears a count, and a clock in the corner. It needs no assets: every icon
is the icon resolver's tinted disc.

`default.project.json` maps the kit's `src/` to `ReplicatedStorage.HudBlox`, as a game has it after
installing the package, and [`Demo.client.luau`](Demo.client.luau) to `StarterPlayerScripts`. The
script is example code: it is formatted, linted and type-checked against the kit under both type
solvers on every push, and the place is built and read back
([`tests/DemoPlace.luau`](../tests/DemoPlace.luau)). None of that runs it: what it looks like is
seen only in Roblox.

The demo is the repository's and is not published: the pesde package holds `src/` only
(`scripts/check-package.sh` fails if anything else gets in).

## Open it

`rokit install` in the repository's root installs the pinned rojo with the rest of the toolchain.
Then either:

- **Build the place and open it.** `sh scripts/build-demo.sh` writes `build/demo.rbxl` (git
  ignores it). Open it in Studio and press Play.
- **Serve it into an open place.** `rojo serve demo`, then in Studio open an empty baseplate,
  connect the Rojo plugin and press Play. An edit to `src/` or to the script is in the place on
  the next Play.

For a phone or a tablet, use Studio's device emulator, or publish the built place to a test
experience and join it from the device.

## What it shows

| Look at | By | The kit's part |
| --- | --- | --- |
| The row shares the line of Roblox's own buttons and stays out of a notch; it fits itself again when the window is resized or the device turned | resizing, the emulator's devices | `SafeArea`, `TopBar` |
| The wallet earns once a second and the row does not move as the number changes | watching it | `Pill` (pinned widths) |
| Eight coins burst from the shop button and fly into the wallet; the number counts each as it lands and the capsule pulses | the green button | `Flight`, `FlightPath` |
| The round buttons squash on a press | any of them | `Button` |
| The left button stands just past Roblox's own and wears a "3" until the dialog has been opened once | the purple button | `TopBar`, `Badge` |
| The dialog: backdrop, pop-in, tabs, a footer button; it closes by its X, a tap outside, the footer's button, a gamepad's B | the purple button | `Dialog`, `Tabs`, `Native` |
| The clock in the bottom right corner stands above the jump button on a phone and steps aside while the dialog is up | opening the dialog | `Indicator`, `TouchClearance` |
| On a gamepad: D-pad down puts a ring on the shop button, D-pad right opens the dialog, the ring stays inside the dialog while it is up, and the output prints each act | a gamepad, or `Workspace:SetAttribute("PadCheck", true)` in Studio | `PadMenu`, `Focus`, `Ring`, `PadGlyph`, `Host` |

If the row ever wraps to a second line, the kit warns in the output: look there on the narrowest
device you try.

## What it does not show

- `Backpack` and `HotbarCover`: they draw a game's own Tools, and the demo has none.
- `Rtl`: the demo reads left to right.
- `Band`: nothing stands at the bottom of the demo's screen for a read-out to clear.
