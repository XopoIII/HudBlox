#!/usr/bin/env sh
# The package carries the library and nothing else: each tracked file under src/ is in the pesde
# archive, and beside them only pesde.toml, README.md and LICENSE.
#
# WHY IT IS CHECKED: pesde reads `includes` as globs, so `"src"` matches the folder and nothing in
# it. A package built that way holds only what the glob names, its first `require("@self/...")` fails
# in any game that installs it, and every spec here still passes against the source tree. Only a look
# at the built package finds that. (KeepBlox shipped three such versions before it had this check.)
#
# WHY "NOTHING ELSE" IS CHECKED TOO: the demo place (demo/), the specs and the scripts are the
# repository's, not a game's. A glob added to `includes` one day would ship them into every game
# that installs the kit, and nothing else here would notice.
#
# `pesde publish --dry-run` packs the archive and publishes nothing.
#
# Usage: check-package.sh
set -e
export PATH="$HOME/.rokit/bin:$PATH"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

git ls-files src | sort >"$WORK/expected"
if [ ! -s "$WORK/expected" ]; then
	echo "check-package: no tracked files under src/" >&2
	exit 1
fi

# pesde writes package.tar.gz next to the manifest, so it packs a copy of the tracked files: all of
# them, so that what `includes` leaves out is left out by `includes` and not by this copy.
mkdir "$WORK/pesde"
git ls-files | while read -r file; do
	mkdir -p "$WORK/pesde/$(dirname "$file")"
	cp "$file" "$WORK/pesde/$file"
done
(cd "$WORK/pesde" && pesde publish --dry-run --yes >"$WORK/pesde.log" 2>&1) || {
	cat "$WORK/pesde.log" >&2
	echo "check-package: pesde publish --dry-run failed" >&2
	exit 1
}
# pesde can refuse a file it is told to include (a rojo project file, say), write no archive and
# still exit with success.
if [ ! -f "$WORK/pesde/package.tar.gz" ]; then
	cat "$WORK/pesde.log" >&2
	echo "check-package: pesde publish --dry-run wrote no package" >&2
	exit 1
fi
# Files only: an archive may list its folders too.
tar -tzf "$WORK/pesde/package.tar.gz" | sed 's|^\./||' | grep -v '/$' | sort >"$WORK/pesde.all"
grep '^src/' "$WORK/pesde.all" >"$WORK/pesde.list" || true

missing="$(comm -23 "$WORK/expected" "$WORK/pesde.list")"
if [ -n "$missing" ]; then
	echo "check-package: the pesde package leaves out:" >&2
	echo "$missing" | sed 's/^/  /' >&2
	exit 1
fi

{
	cat "$WORK/expected"
	printf '%s\n' pesde.toml README.md LICENSE
} | sort >"$WORK/allowed"
extra="$(comm -13 "$WORK/allowed" "$WORK/pesde.all")"
if [ -n "$extra" ]; then
	echo "check-package: the pesde package carries what is not the library's:" >&2
	echo "$extra" | sed 's/^/  /' >&2
	echo "  Only src/, pesde.toml, README.md and LICENSE are published (pesde.toml's includes)." >&2
	exit 1
fi

echo "check-package: the pesde package carries all $(wc -l <"$WORK/expected" | tr -d ' ') files of src/ and nothing of demo/, tests/ or scripts/"
