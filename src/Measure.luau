--!strict
--- The measured numbers of Roblox's own top bar, and nothing else.
---
--- THE NUMBERS ARE THE ASSET, not the code around them. Each was read off a live client (CoreGui's
--- `TopBarApp`, last on 2026-09-22 and 2026-09-23 in a live game), and a retyped approximation of one
--- is worth nothing. Change one only against a new measurement, and say where it was read.
---
--- Plain numbers only, so the arithmetic that uses them (`Layout`, `Clearance`) runs without Roblox.
const Measure = {}

--- A capsule and a round button are both this tall; Roblox's menu button is 44 x 44.
Measure.HEIGHT = 44
--- From the screen's side edge to the first thing on the top line. Roblox's menu button starts at 16.
Measure.EDGE = 16
--- From the top of the device to the top line. Roblox's buttons span y 12..56.
Measure.TOP = 12
--- Between two things on the top line. Roblox's menu ends at 60 and its chat starts at 68.
Measure.GAP = 8

--- The plate of Roblox's capsules: RGB 18, 18, 21 at transparency 0.08.
Measure.PLATE_R = 18
Measure.PLATE_G = 18
Measure.PLATE_B = 21
Measure.PLATE_T = 0.08

--- The ink of a lead icon. Roblox draws a 24-pixel glyph inside a 36-pixel hit area; matching the
--- hit area instead made icons half again too big.
Measure.LEAD = 24
--- A capsule's number: Builder Sans Bold at 22.
Measure.TEXT = 22
--- Inside a capsule: 10 before the lead, which reads as part of the glyph, and 12 after the number.
Measure.PAD_LEFT = 10
Measure.PAD_RIGHT = 12
--- Between a lead and the number it labels.
Measure.PART_GAP = 6
--- Between two segments of one capsule, ink to ink.
Measure.SEGMENT_GAP = 16

--- A round button shrinks to this on press and has no hover state: the audience has no cursor.
Measure.SQUASH = 0.9
Measure.SQUASH_SECONDS = 0.07
--- An icon as a fraction of its plate, for a button that stands alone (a rail down the screen's
--- edge). On the top line the icon is `LEAD` pixels instead, because Roblox's is.
Measure.ICON_FRACTION = 0.74

return Measure
