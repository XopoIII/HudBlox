--!strict
--- Execute the shipped tab text assignments on real LuneBlox TextButtons, not GUI fakes.
--- This configuration regression does not measure rendered wrapping or pixel fit.
const Spec = require("../Spec")
const TabFit = require("@hudblox/TabFit")
const fs = require("@lune/fs")
const roblox = require("@lune/roblox")

const source = fs.readFile("src/Tabs.luau")
const size = string.match(source, "button%.TextSize = [^\n]+")
const wrapped = string.match(source, "button%.TextWrapped = [^\n]+")
assert(size and wrapped, "Tabs must explicitly configure text size and wrapping")
-- Lune typedefs omit class properties. Dynamic execution reads the real instance without a cast.
const chunk = loadstring(
	"return function(button, vertical, options, entry, TabFit)\n"
		.. size
		.. "\n"
		.. wrapped
		.. "\nreturn {wrapped = button.TextWrapped, size = button.TextSize, scaled = button.TextScaled} end"
)
assert(chunk, "tab text configuration must compile")
const configure = chunk()

Spec.test("vertical tab labels wrap without shrinking while horizontal labels stay single-line", function()
	const button = roblox.Instance.new("TextButton")
	Spec.equal(configure(button, true, nil, {}, TabFit), { wrapped = true, size = 20, scaled = false }, "rail")
	Spec.equal(configure(button, false, nil, {}, TabFit), { wrapped = false, size = 20, scaled = false }, "row")
	Spec.equal(
		configure(button, true, { text = 24 }, {}, TabFit),
		{ wrapped = true, size = 24, scaled = false },
		"custom text"
	)
	Spec.equal(
		configure(button, true, nil, { icon = "fixture" }, TabFit),
		{ wrapped = true, size = 11, scaled = false },
		"icon text unchanged"
	)
	button:Destroy()
end)

return nil
