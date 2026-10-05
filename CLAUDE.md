# HudBlox - working notes

HudBlox is a HUD kit for Roblox: dark capsules and round buttons that look like Roblox's own top-bar
buttons, placed by the device's real safe zones. It was extracted from the game Grabby Pit and is
used by the owner's games as a pinned pesde package (`xopoiii/hudblox`, target `roblox`).

## Everything here is written in English

Code, comments, identifiers, docs, commit messages, PR bodies. `scripts/check-english.sh` enforces it on
every commit. Conversation with the owner may be in another language; nothing in another language
lands in the repository.

## The tree is at zero

- No lint warnings, no type errors, no formatting drift. A warning is a failure: one that is tolerated
  once stops being read.
- Every `.luau` file starts with `--!strict` on line 1 and never opts out (`scripts/check-strict.sh`).
- No Luau file is over 300 lines (`scripts/check-file-size.sh`). A file that reaches the cap is split
  into modules, not exempted.
- The same gates run in lefthook (pre-commit, pre-push) and in CI (`.github/workflows/checks.yaml`).

## The kit reads nothing of its host

This is the reason the package exists, and the rule a change is checked against first.

- A game's icon ids, its locale and text direction, its focus ring, its dialogs' state and every
  colour beyond Roblox's measured plate are **arguments**: a theme, an option, a function. No module
  requires anything outside `src/`, reads an attribute a game sets, or names a game's Instance.
- Nothing touches `game` at require time. Services are fetched inside the function that needs them.
- No game's content lands here: no icon id, no string a player reads, no game's name in code.

## The numbers are measured

`src/Measure.luau` holds what was read off Roblox's own top bar in a live client. A number there is
changed only against a new measurement, and the comment says where and when it was read. A number
that "looks right" is not a measurement.

## Rules are proven, not argued

- Arithmetic is kept apart from Instances (`Layout`, `Clearance`, `Band` against `TopBar`,
  `SafeArea`, `TouchClearance`), so every placement rule is a spec that runs without Roblox.
- Specs are strict: exact values, the negative case beside the positive one, no vacuous passes.
- A new rule lands with its spec and with a mutant in `tests/Mutants.luau`: the spec is seen failing
  against the broken line before it is trusted. `luneblox run tests/Mutate --yes` must kill every
  mutant.
- A spec is never loosened to make it pass.
- What cannot run off Roblox (everything that builds an Instance) is said to be unproven, in the
  changelog's "Not done", rather than covered by a fake that proves the fake.
  `tests/consumer/Game.luau` uses the whole public API and is type-checked under both solvers; it
  changes with the API, and the README's example after it.

## Dependencies

- **No runtime dependencies.** `src/` is plain Luau.
- **Latest stable versions only.** Every tool and CI action is pinned exactly to its latest stable
  release at the time it is added or bumped (check with `gh release view -R owner/repo`). Never a
  prerelease, and never a pin copied from a sibling repo without checking.
- **LuneBlox is ours** (XopoIII/LuneBlox). When HudBlox needs something from it, the change is made
  there and flagged to the owner, not worked around here.

## Modern Luau: the version Roblox runs

- **`const`** for every binding that is never reassigned, including requires, module tables and
  functions (`const function`). `local` only for a binding that really is reassigned.
- **String requires**: `require("./Sibling")` between modules and `require("@self/Module")` in
  `init.luau`, so the same files load in Roblox and on LuneBlox.
- **The new type solver.** `scripts/type-check.sh` runs luau-lsp with `LuauSolverV2`, as Studio
  checks games, and checks the consumer file under the old solver too.
- No cast to `any` to silence a type.

## Architecture in one breath

- `Measure`: the numbers. `Layout`, `Clearance`, `Band`: arithmetic over plain numbers.
- `Theme`, `Icons`: what the host hands in.
- `Pill`, `Button`: one capsule, one round button. `TopBar`: the row that places them.
- `SafeArea`, `TouchClearance`: read the engine and hand the numbers to the arithmetic.
- `Indicator`: the bottom-corner read-outs. `Native`: Roblox's menu look. `Rtl`: the mirror.
- `init.luau` exposes the modules and re-exports their types.

## Distribution

- **Package:** pesde only (`xopoiii/hudblox`, `pesde.toml` and `pesde.lock`).
  `scripts/check-package.sh` checks that the built archive carries every file of `src/`.
- **Not shipped:** a Wally package, an `.rbxm`, roblox-ts typings.
- **A release** carries one version in `pesde.toml`, `pesde.lock` and `README.md` (the status line
  and the two install lines), and its entry in `CHANGELOG.md`.

## Releasing

The version bump and the changelog entry are part of the pull request, not of this list.

1. Merge the pull request with a merge commit (`gh pr merge <n> --merge`), then check out `main` and
   pull.
2. On the merged `main`, run `sh scripts/check-package.sh`, `sh scripts/run-tests.sh` and
   `luneblox run tests/Mutate --yes`. All must pass there, not only on the branch.
3. Tag and push the tag: `git tag vX.Y.Z && git push origin vX.Y.Z`.
4. Create the GitHub Release: `gh release create vX.Y.Z --title "HudBlox X.Y.Z" --notes-file <notes>`.
   The notes hold, in order: a summary line, the changelog entry's sections, **Evidence** (the spec
   count, the mutants killed, the gates that passed, anything looked at in a game, and anything that
   was not), **Known, not fixed** when there is something, and **Install** (the pesde line).
5. Publish the package: `pesde publish --yes` (after `pesde auth login` once per machine). A
   published version cannot be replaced, so it comes after the tag and the release.
6. Pin the new version in the games that use it, in each game's own repository.

## Commits

- A plain declarative English subject, no conventional-commit prefix.
- The body says what changed and why, in prose.
- A closing "Checked:" paragraph lists what was run and what it reported.
- One commit a step; never commit with the gate red, never bypass a hook.

## Commands

| Command | What it does |
|---|---|
| `rokit install` | Installs the pinned toolchain (`rokit.toml`) |
| `lefthook install` | Installs the git hooks |
| `sh scripts/run-tests.sh` | Runs the suite on LuneBlox (`tests/Run.luau`) |
| `luneblox run tests/Mutate --yes` | Mutation adequacy: every mutant must fail the suite (`-- Band` for one file) |
| `sh scripts/type-check.sh` | `luau-lsp analyze` over `src` and `tests`, and the consumer under the old solver |
| `selene src tests` | Lint |
| `stylua --check src tests` | Format check (`stylua src tests` to fix) |
| `sh scripts/check-strict.sh` | `--!strict` gate |
| `sh scripts/check-file-size.sh` | 300-line gate |
| `sh scripts/check-english.sh` | English-only gate |
| `sh scripts/check-package.sh` | The pesde archive carries all of `src/` (`pesde publish --dry-run`) |
| `lefthook run pre-commit --all-files` | Every pre-commit gate over the whole tree |
