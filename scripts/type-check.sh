#!/usr/bin/env sh
# The type gate: `luau-lsp analyze` over every Luau file we own, in strict mode (.luaurc).
#
# `src/` is analysed against the Roblox API definitions, since it runs in Roblox. `tests/` runs on
# LuneBlox and sees both: the `@lune` typedefs through the .luaurc alias, and the Roblox definitions
# for the types the library itself names.
#
# `demo/` runs in Roblox too, and reaches the kit as a game does: by its Instance, which only a
# rojo sourcemap of the demo's project can tell luau-lsp is `src/`. So the sourcemap is built here,
# and the demo is checked against the kit under both solvers, as a game's code would be.
#
# The Roblox definitions are downloaded once per luau-lsp pin and kept out of git; `luneblox setup`
# writes the `@lune` typedefs that .luaurc aliases, so CI has them too.
#
# Usage: type-check.sh   (no arguments)
set -e
export PATH="$HOME/.rokit/bin:$PATH"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

for arg in "$@"; do
	echo "type-check: unknown argument '$arg' (it takes none; the whole tree is checked)" >&2
	exit 2
done

# The definitions come from the tag of the luau-lsp that rokit.toml pins, so the gate reads the same
# Roblox API on every machine and every day. A bump of that pin downloads them again.
lsp_version="$(sed -n 's/.*JohnnyMorganz\/luau-lsp@\([0-9.]*\)".*/\1/p' rokit.toml)"
if [ -z "$lsp_version" ]; then
	echo "type-check: no luau-lsp pin found in rokit.toml" >&2
	exit 1
fi
if [ ! -f globalTypes.d.luau ] || [ "$(cat globalTypes.d.luau.version 2>/dev/null)" != "$lsp_version" ]; then
	curl -fsSL -o globalTypes.d.luau \
		"https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/$lsp_version/scripts/globalTypes.d.luau"
	echo "$lsp_version" >globalTypes.d.luau.version
fi
luneblox setup >/dev/null

# The new type solver, as Roblox Studio runs it.
luau-lsp analyze --flag:LuauSolverV2=true --defs globalTypes.d.luau src tests

# A game may still be checked with the old solver: the public types must read the same to it.
# tests/consumer/Game.luau is a game's use of the whole public API and must be clean there too; the
# library's own files are the new solver's business, so they are ignored in this run.
luau-lsp analyze --flag:LuauSolverV2=false --defs globalTypes.d.luau --ignore "src/**" tests/consumer/Game.luau

# The demo place. rojo writes a sourcemap's paths relative to the project file, and luau-lsp reads
# them relative to where it runs, so both run in demo/.
#
# With a sourcemap luau-lsp says once that it cannot watch the file for changes ("[WARN] client does
# not allow didChangeWatchedFiles registration"): true of every command-line run and nothing to
# fix, so that one line is dropped and every other line is printed.
DEMO_LOG="$(mktemp)"
trap 'rm -f "$DEMO_LOG"' EXIT
(cd demo && rojo sourcemap default.project.json --output sourcemap.json >/dev/null)

analyze_demo() {
	demo_status=0
	(cd demo && luau-lsp analyze "$@" --sourcemap sourcemap.json --defs ../globalTypes.d.luau .) >"$DEMO_LOG" 2>&1 ||
		demo_status=$?
	grep -v 'didChangeWatchedFiles' "$DEMO_LOG" || true
	return "$demo_status"
}

analyze_demo --flag:LuauSolverV2=true
# The kit's own files are the new solver's business here too; the demo must read the same to both.
analyze_demo --flag:LuauSolverV2=false --ignore "../src/**"

echo "type-check: clean"
