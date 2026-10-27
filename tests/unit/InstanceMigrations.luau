--!strict
--- Real UICorner instances on LuneBlox: the retired CornerRadius property migrates through the four
--- replacement radii, in memory and through Roblox's binary model format.
const Spec = require("../Spec")
const roblox = require("@lune/roblox")

type Corner = {
	CornerRadius: UDim,
	BottomLeftRadius: UDim,
	BottomRightRadius: UDim,
	TopLeftRadius: UDim,
	TopRightRadius: UDim,
}

-- The Lune typedefs intentionally do not declare class-specific properties, as in DemoPlace.luau.
const function propertiesOf(instance: roblox.Instance): Corner
	return instance :: any
end

-- UDim is present at runtime but absent from the same typedefs.
const function newUDim(scale: number, offset: number): UDim
	return (roblox :: any).UDim.new(scale, offset)
end

Spec.test("writing CornerRadius updates every replacement radius", function()
	const corner = propertiesOf(roblox.Instance.new("UICorner"))
	const radius = newUDim(0.25, 12)
	corner.CornerRadius = radius

	Spec.equal(corner.BottomLeftRadius, radius, "bottom left")
	Spec.equal(corner.BottomRightRadius, radius, "bottom right")
	Spec.equal(corner.TopLeftRadius, radius, "top left")
	Spec.equal(corner.TopRightRadius, radius, "top right")
	Spec.equal(corner.CornerRadius, radius, "legacy read")
end)

Spec.test("a replacement radius supplies the legacy CornerRadius read", function()
	const corner = propertiesOf(roblox.Instance.new("UICorner"))
	const radius = newUDim(0.5, 7)
	corner.BottomLeftRadius = radius
	corner.BottomRightRadius = newUDim(0, 2)
	corner.TopLeftRadius = newUDim(0, 3)
	corner.TopRightRadius = newUDim(0, 4)

	Spec.equal(corner.CornerRadius, radius, "legacy read")
end)

Spec.test("migrated radii survive a binary model round-trip", function()
	const instance = roblox.Instance.new("UICorner")
	const corner = propertiesOf(instance)
	const radius = newUDim(0.75, 9)
	corner.CornerRadius = radius

	const decoded = roblox.deserializeModel(roblox.serializeModel({ instance }))
	Spec.equal(#decoded, 1, "one root")
	const roundTrip = propertiesOf(decoded[1])
	Spec.equal(roundTrip.CornerRadius, radius, "legacy read")
	Spec.equal(roundTrip.BottomLeftRadius, radius, "bottom left")
	Spec.equal(roundTrip.BottomRightRadius, radius, "bottom right")
	Spec.equal(roundTrip.TopLeftRadius, radius, "top left")
	Spec.equal(roundTrip.TopRightRadius, radius, "top right")
end)

return nil
