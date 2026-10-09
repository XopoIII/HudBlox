# The demo place

A runnable look at the kit on a device: the README's top line with a ticking wallet, a reward
flight on the shop button, and the bag dialog with tabs. No assets are needed — every icon is the
icon resolver's tinted disc.

## Run it

1. Install rojo, any way (for example `rokit add rojo-rbx/rojo`).
2. From the repository's root: `rojo serve demo`.
3. In Studio, open an empty baseplate, connect the rojo plugin, and press Play.

The kit's `src` is mapped to `ReplicatedStorage/HudBlox`, and `Demo.client.luau` runs from
StarterPlayerScripts and builds the HUD from it: what you see is the package exactly as a game
uses it.

## What to look at

- The row shares the line of Roblox's own top bar and stays out of the notch (turn the device, or
  resize the window: the row fits itself again).
- The wallet's coin count ticks once a second and the row does not jitter: that is the pinned
  widths.
- The shop button sends a flight of coins into the wallet; the wallet pulses as they land.
- The bag button opens the dialog: backdrop, pop-in, and a close by the X, a tap outside, or a
  gamepad's B, whose ring stays inside the panel while it is up.
- The clock in the corner steps aside while the dialog is open.
