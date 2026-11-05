--!strict
--- Disposable source/test snapshot: mutants never change the owning working tree.
const fs = require("@lune/fs")
const process = require("@lune/process")
const Workspace = {}
const function copy(from: string, to: string)
	fs.writeDir(to)
	for _, name in fs.readDir(from) do
		const source, target = from .. "/" .. name, to .. "/" .. name
		if fs.isDir(source) then
			copy(source, target)
		else
			fs.writeFile(target, fs.readFile(source))
		end
	end
end
function Workspace.new(): (string, () -> ())
	fs.writeDir("build")
	const prefix = process.cwd .. "build/mutants."
	const result = process.exec("mktemp", { "-d", prefix .. "XXXXXX" })
	assert(result.ok, "could not create mutant snapshot")
	const path = string.gsub(result.stdout, "%s+$", "")
	assert(
		string.sub(path, 1, #prefix) == prefix and not string.find(path, "..", 1, true),
		"unsafe mutant snapshot path"
	)
	copy("src", path .. "/src")
	copy("tests", path .. "/tests")
	fs.writeFile(path .. "/.luaurc", fs.readFile(".luaurc"))
	return path, function()
		fs.removeDir(path)
	end
end
return Workspace
