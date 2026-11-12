--!strict
--- What the player's Reduce Motion setting and the game's own word mean together.
---
--- Only the arithmetic runs here: `Host.motion` reads `GuiService.ReducedMotionEnabled` and is
--- unproven off Roblox, as every engine read is.
const Host = require("@hudblox/Host")
const Spec = require("../Spec")

Spec.test("a player who said nothing gets full motion", function()
	Spec.equal(Host.motionOf(false), "Full", "unset")
	Spec.equal(Host.motionOf(false, nil), "Full", "explicitly unset")
end)

Spec.test("Roblox's Reduce Motion setting is honoured", function()
	Spec.equal(Host.motionOf(true), "Reduced", "reduced")
end)

Spec.test("a game's own word wins over the setting, both ways", function()
	Spec.equal(Host.motionOf(true, "Full"), "Full", "a game keeping a movement it needs")
	Spec.equal(Host.motionOf(false, "Reduced"), "Reduced", "a game asking for less than the player did")
	Spec.equal(Host.motionOf(true, "Reduced"), "Reduced", "both agree")
end)

return nil
