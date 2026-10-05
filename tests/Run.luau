--!strict
--- The suite: every spec file, in order. A spec file runs its specs as it loads.
---
--- Only the arithmetic runs here (`Layout`, `Clearance`, `Band`): it needs no Roblox. The modules
--- that build Instances are type-checked against the Roblox API (`tests/consumer/Game.luau` uses
--- all of them) and are not run by this suite.
---
--- Run from the repository root: `luneblox run tests/Run --yes` (or `sh scripts/run-tests.sh`).
const Runtime = require("./Runtime")
const Spec = require("./Spec")

Runtime.notice()

require("./unit/Layout")
require("./unit/Clearance")
require("./unit/Band")

Spec.finish()
