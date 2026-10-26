# NeNe Poker — Agent Guide

Short English entry point. The authoritative handbook is [CLAUDE.md](CLAUDE.md) (Japanese);
the normative documents live in [docs/](docs/).

## Project identity

- Product: NeNe Poker — a Swift terminal screensaver where four hand-written AI characters play no-limit Texas hold'em forever; one of them is the main player in the front seat
- Language / UI: Swift 6 / terminal (ANSI escapes, no ncurses)
- Package: `NeNePoker` (SwiftPM, Swift 6.4.1 pinned in `.swift-version`, zero external dependencies)
- Governing principle: **one meaning, one canonical implementation path, enforced by machines**

## Required reading before changing production code

1. `docs/ARCHITECTURE_CONSTITUTION.md`
2. `docs/PROJECT_LAYOUT.md`
3. `docs/CODING_RULES.md`
4. `docs/QUALITY_GATES.md`
5. `docs/DEVELOPMENT_WORKFLOW.md`
6. `docs/COMMIT_CONVENTIONS.md`
7. `docs/GLOSSARY.md`
8. `docs/REQUIREMENTS.md` (the owner's decisions)

Then the active issue, the relevant accepted ADRs, and any active waivers.

## Agent rules

- Do not invent a second implementation path because it is locally convenient.
- Do not weaken a gate to make a change pass. Fix the code instead.
- Do not mark a rule `active` in `docs/QUALITY_GATES.md` before its enforcement exists.
- Do not read the current time, randomness, locale, or environment outside the `nene-poker` executable target (the composition root).
- Do not write a catch-all in a `switch`: `default:`, `@unknown default`, `case _:`, `case let x:`, `case (let x):`, `case .a, _:` or `case (_, _):`. They disable exhaustiveness checking.
- Do not write `init` in an `extension`; it can bypass a `private init` from another file of the same target.
- Do not use `async`, `await`, `Task`, `actor`, threads, Dispatch, or `@preconcurrency`.
- Do not add a SwiftPM target without `.treatAllWarnings(as: .error)` and `ExistentialAny`; the manifest beats command-line flags.
- Do not add external packages, and never a poker engine or hand-evaluator library (owner's decision).
- Copy published reference numbers (hand-category counts) from the primary source and cite it next to the test; never write them from memory.
- Keep one path each for action legality, pot distribution and hand comparison in Core; the engine picks from Core's legal actions and its equity estimate uses Core's comparison.
- Keep the view mode (`v`) display-only: it lives in Render, never in Core or Engine types.
- Do not show win probabilities or suggested actions, do not add human play, and do not name real casinos, poker sites or brands.
- Do not override the owner's decisions in `docs/REQUIREMENTS.md` or add features they did not ask for; ask first.
- Do not add suppressions, lint baselines, or tool exclusions without an active waiver (or at all, where the language forbids them).
- Do not claim a command passed unless it was actually executed.
- Prefer the smallest change that fully follows the canonical path.

## Releases

The only way to build release artifacts is `make release TAG=v<version>` (version input: `Sources/nene-poker/Version.swift`).
Publishing a tag or a GitHub Release is an outside action: do it only after the owner confirms.

## The only definition of done

```bash
make bootstrap   # once after clone
make check
```

Local and CI run exactly this. Use narrow checks while iterating; run the full gate before
moving the PR from Draft to Ready.

## Required completion report

Issue and rule IDs, files and behavior changed, verification commands and results,
documentation or schema changes, active waiver IDs (or `none`), remaining risks.

Investigation-only requests do not authorize editing, committing, pushing, or opening PRs.
