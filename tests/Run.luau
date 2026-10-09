--!strict
--- The suite: every spec file, in order. A spec file runs its specs as it loads.
---
--- Only what needs no Roblox runs here: the arithmetic (`Layout`, `Clearance`, `Band`,
--- `DialogGeometry`, `Pick`, `Stack`), a badge's count, the backpack's order, taps and presses, and the hotbar's cover. The modules that build Instances are type-checked against the Roblox API
--- (`tests/consumer/Game.luau` uses all of them) and are not run by this suite.
---
--- Run from the repository root: `luneblox run tests/Run --yes` (or `sh scripts/run-tests.sh`).
const Runtime = require("./Runtime")
const Spec = require("./Spec")

Runtime.notice()

require("./unit/Layout")
require("./unit/Clearance")
require("./unit/Band")
require("./unit/DialogGeometry")
require("./unit/Pick")
require("./unit/Stack")
require("./unit/BackpackOrder")
require("./unit/BackpackMoves")
require("./unit/BackpackRest")
require("./unit/HotbarCover")
require("./unit/Badge")
require("./unit/Tabs")
require("./unit/Flight")
require("./unit/FlightBook")
require("./unit/TextMemo")

Spec.finish()
