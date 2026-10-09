#!/usr/bin/env sh
# Builds the demo place and checks what was built: `rojo build demo`, then the place read back
# against `src/` and `demo/` (tests/DemoPlace.luau). A project file that is broken, or that no
# longer maps the kit and the script to where a client finds them, fails here.
#
# The place is written to build/demo.rbxl, which git ignores: open it in Studio to look at the kit.
#
# `--yes` answers LuneBlox's prompts, which would otherwise throw with no TTY (hooks and CI).
#
# Usage: build-demo.sh   (no arguments)
set -e
export PATH="$HOME/.rokit/bin:$PATH"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

luneblox run tests/DemoPlace --yes
