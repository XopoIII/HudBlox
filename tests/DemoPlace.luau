--!strict
--- Builds the demo place (`rojo build demo`) and reads it back: the place must hold the kit
--- exactly as `src/` has it, and the demo's script exactly as `demo/` has it.
---
---     luneblox run tests/DemoPlace --yes     (or `sh scripts/build-demo.sh`)
---
--- A project file that no longer parses fails the build. One that maps the wrong folder, drops a
--- module or runs the script from where a client does not run it builds all the same, and is found
--- here: every file under `src/` is a ModuleScript at its own place under
--- ReplicatedStorage.HudBlox with that file's source, nothing else is there, and
--- StarterPlayer.StarterPlayerScripts.Demo is a LocalScript with the demo's source.
---
--- It proves the place is built right. It does not run it: that needs a Roblox client.
const fs = require("@lune/fs")
const process = require("@lune/process")
const roblox = require("@lune/roblox")

const PROJECT = "demo"
const SOURCE = "src"
const SCRIPT = "demo/Demo.client.luau"
const OUT_DIR = "build"
const PLACE = `{OUT_DIR}/demo.rbxl`

-- What is read of a script. The `@lune/roblox` typedefs name no class's properties (their own
-- note says an Instance is cast whole to read one), so this is the one place that is done.
type Script = { Source: string, Disabled: boolean }
const function scriptOf(instance: roblox.Instance): Script
	return instance :: any
end

const faults: { string } = {}
const function fault(text: string)
	table.insert(faults, text)
end

--> Every module `dir` holds, by its path in the place: "Backpack/Bar" for `Backpack/Bar.luau`,
--> "Backpack" for `Backpack/init.luau`, "" for the root's own `init.luau`.
const function modulesOf(dir: string, at: string, into: { [string]: string })
	for _, name in fs.readDir(dir) do
		const path = `{dir}/{name}`
		if fs.isDir(path) then
			modulesOf(path, if at == "" then name else `{at}/{name}`, into)
		elseif name == "init.luau" then
			into[at] = path
		else
			const stem = string.match(name, "^(.+)%.luau$")
			if stem then
				into[if at == "" then stem else `{at}/{stem}`] = path
			else
				fault(`{path} is not a Luau module: the place would not hold it as one`)
			end
		end
	end
end

--> Every ModuleScript under `root` by its path from it, `root` itself as "".
const function scriptsOf(root: roblox.Instance, at: string, into: { [string]: roblox.Instance })
	if root.ClassName == "ModuleScript" then
		into[at] = root
	else
		fault(`{root:GetFullName()} is a {root.ClassName}, not a ModuleScript`)
	end
	for _, child in root:GetChildren() do
		scriptsOf(child, if at == "" then child.Name else `{at}/{child.Name}`, into)
	end
end

if not fs.isDir(OUT_DIR) then
	fs.writeDir(OUT_DIR)
end
if fs.isFile(PLACE) then
	fs.removeFile(PLACE)
end
const built = process.exec("rojo", { "build", PROJECT, "--output", PLACE })
if not built.ok or not fs.isFile(PLACE) then
	print(built.stdout .. built.stderr)
	print(`demo-place: rojo build {PROJECT} failed`)
	process.exit(1)
end

const place = roblox.deserializePlace(fs.readFile(PLACE))

const kit = place:GetService("ReplicatedStorage"):FindFirstChild("HudBlox")
if kit == nil then
	fault("ReplicatedStorage.HudBlox is not in the place")
else
	const files: { [string]: string } = {}
	modulesOf(SOURCE, "", files)
	const scripts: { [string]: roblox.Instance } = {}
	scriptsOf(kit, "", scripts)
	local count = 0
	for at, path in files do
		count += 1
		const module = scripts[at]
		if module == nil then
			fault(`{path} is not in the place (ReplicatedStorage.HudBlox/{at})`)
		elseif scriptOf(module).Source ~= fs.readFile(path) then
			fault(`{module:GetFullName()} does not hold the source of {path}`)
		end
	end
	for at, module in scripts do
		if files[at] == nil then
			fault(`{module:GetFullName()} is in the place and not under {SOURCE}/`)
		end
	end
	if count == 0 then
		fault(`no modules found under {SOURCE}/`)
	end
	if #faults == 0 then
		print(`demo-place: ReplicatedStorage.HudBlox holds all {count} modules of {SOURCE}/, as written`)
	end
end

const scriptsFolder = place:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
const demo = if scriptsFolder then scriptsFolder:FindFirstChild("Demo") else nil
if demo == nil then
	fault("StarterPlayer.StarterPlayerScripts.Demo is not in the place")
elseif demo.ClassName ~= "LocalScript" then
	fault(`{demo:GetFullName()} is a {demo.ClassName}, not a LocalScript: a client would not run it`)
elseif scriptOf(demo).Source ~= fs.readFile(SCRIPT) then
	fault(`{demo:GetFullName()} does not hold the source of {SCRIPT}`)
elseif scriptOf(demo).Disabled then
	fault(`{demo:GetFullName()} is disabled`)
end

if #faults > 0 then
	for _, text in faults do
		print(`demo-place: {text}`)
	end
	process.exit(1)
end
print(`demo-place: StarterPlayerScripts.Demo is a LocalScript holding {SCRIPT}; built to {PLACE}`)
