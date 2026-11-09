--!strict
--- Mutation adequacy of the suite: is the checker strong enough? Each mutant in tests/Mutants is a
--- small, plausible slip in the arithmetic, the kind a refactor could make. The suite runs once per
--- mutant and must fail; a mutant that survives shows a rule no spec proves.
---
---     luneblox run tests/Mutate --yes             (every mutant; well under a second each)
---     luneblox run tests/Mutate --yes -- Band     (only the mutants of files matching "Band")
---
--- Every mutant's `from` must occur exactly once in its file, so a change to the code that moves it
--- fails here loudly instead of testing nothing. Only a disposable source/test copy is mutated.
--- Control mutants must load and fail their exact named assertion; an arbitrary nonzero exit is not a kill.
const fs = require("@lune/fs")
const process = require("@lune/process")

const Mutants = require("./Mutants")
const Workspace = require("./MutationWorkspace")

type Mutant = Mutants.Mutant

const function count(text: string, pattern: string): number
	local found, start = 0, 1
	while true do
		const first, last = string.find(text, pattern, start, true)
		if first == nil then
			return found
		end
		found += 1
		start = (last :: number) + 1
	end
end

const function suitePasses(work: string, mutant: Mutant?): boolean
	const result = process.exec("luneblox", { "run", "tests/Run", "--yes" }, { cwd = work })
	if
		not result.ok
		and mutant
		and (
			string.find(mutant.file, "/Control", 1, true)
			or string.find(mutant.file, "/UiRules", 1, true)
			or string.find(mutant.file, "/ModalState", 1, true)
			or string.find(mutant.file, "/PointerState", 1, true)
		)
	then
		const text = string.gsub(result.stderr, "\27%[[%d;]*m", "")
		const named = string.find(text, "FAIL " .. mutant.breaks .. "\n", 1, true)
		const ending = if named then string.find(text, "\n\n", named, true) else nil
		const block = if named then string.sub(text, named, ending or #text) else ""
		assert(
			string.find(block, "expected ", 1, true)
				and string.find(
					block,
					if string.find(mutant.file, "/Control", 1, true)
						then "tests/unit/Control"
						else "tests/unit/UiOwnership",
					1,
					true
				),
			"not a named semantic assertion kill: " .. text
		)
		print("semantic assertion: " .. (string.match(block, "\n([^\n]+)") or block))
	end
	return result.ok
end

local only: string? = nil
for _, arg in process.args do
	if string.sub(arg, 1, 1) ~= "-" then
		only = arg
	end
end
-- Every chosen mutant must still match its code before any runs, so a stale one fails at once.
const chosen: { [number]: Mutant } = {}
for index, mutant in Mutants do
	if only == nil or string.find(mutant.file, only :: string, 1, true) then
		const occurrences = count(fs.readFile(mutant.file), mutant.from)
		assert(occurrences == 1, `mutant {index} ({mutant.file}): its code occurs {occurrences} times, not once`)
		chosen[index] = mutant
	end
end

const work, cleanup = Workspace.new()
const survivors: { Mutant } = {}
local ran = 0
const okRun, problem = pcall(function()
	assert(suitePasses(work, nil), "baseline suite failed before mutants")
	for index, mutant in Mutants do
		if chosen[index] == nil then
			continue
		end
		const target = work .. "/" .. mutant.file
		const original = fs.readFile(target)
		const first, last = string.find(original, mutant.from, 1, true)
		fs.writeFile(
			target,
			string.sub(original, 1, (first :: number) - 1) .. mutant.to .. string.sub(original, (last :: number) + 1)
		)
		const ok, passed = pcall(suitePasses, work, mutant)
		fs.writeFile(target, original)
		assert(ok, `mutant {index}: the suite could not run: {passed}`)
		ran += 1
		print(`{if passed then "SURVIVED" else "killed  "} {index} {mutant.file}: {mutant.breaks}`)
		if passed then
			table.insert(survivors, mutant)
		end
	end
end)
cleanup()
assert(okRun, tostring(problem))
assert(ran > 0, "no mutant ran: a check that checks nothing is not green")
print(`{ran - #survivors} of {ran} mutants killed`)
process.exit(if #survivors == 0 then 0 else 1)
