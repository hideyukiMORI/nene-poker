# NeNe Poker

> *Four snarky AIs play no-limit hold'em in your terminal. Forever. Press `q` to make them stop.*

A terminal screensaver in which four AI characters play no-limit Texas hold'em at one table, hand after hand, trading insults the whole time.
One of them sits in the front seat as the **main player**: you watch the table over their shoulder, and their cards are always face up.
When one player has all the chips, the table resets and the next one starts. You don't have to do anything.
The chips are imaginary points. Nothing here involves money, and nobody is asking you to bet.

[![release](https://img.shields.io/github/v/release/hideyukiMORI/nene-poker)](https://github.com/hideyukiMORI/nene-poker/releases/latest)
![platform](https://img.shields.io/badge/platform-Linux%20x86__64%20%2F%20WSL2-555)
![license](https://img.shields.io/badge/license-MIT-555)

**English** · [日本語](README.ja.md)

![A showdown in the NEON theme](docs/images/showdown-neon.png)

<sub>A real screenshot (not composited): the build just before v0.1.0 in Windows Terminal on WSL2 (`--seed 1`, 120×30). At the showdown NIT.BAK's pair of sixes beats BLUFF.EXE's pair of fives.
The main player, TILT.SH, folded king-eight preflop; the king came on the river. His cards stay face up, so you get to watch that happen.</sub>

It is a sibling of [NeNe Gambit](https://github.com/hideyukiMORI/nene-gambit) (chess), [NeNe Reversi](https://github.com/hideyukiMORI/nene-reversi)
and [NeNe Igo](https://github.com/hideyukiMORI/nene-igo) (Go).

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/hideyukiMORI/nene-poker/main/install.sh | bash
```

This downloads the latest [release](https://github.com/hideyukiMORI/nene-poker/releases/latest), verifies it against `SHA256SUMS`,
and only then installs it as `~/.local/bin/nene-poker`. If the checksum doesn't match, nothing is installed.
The whole script is [install.sh](install.sh), about 45 lines.

- Requirements: Linux on x86_64 with glibc 2.35 or newer (Ubuntu 22.04+). Tested on Ubuntu under WSL2 with Windows Terminal
- No Swift needed. It is a single file with the Swift standard library linked statically; the only dynamic dependencies are libc, libm, libstdc++ and libgcc_s
- To uninstall: `rm ~/.local/bin/nene-poker`

<details>
<summary>Install by hand</summary>

```bash
v=0.1.0
curl -fsSL -O https://github.com/hideyukiMORI/nene-poker/releases/download/v$v/nene-poker-$v-linux-x86_64.tar.gz \
           -O https://github.com/hideyukiMORI/nene-poker/releases/download/v$v/SHA256SUMS
sha256sum --check SHA256SUMS
tar -xzf nene-poker-$v-linux-x86_64.tar.gz
./nene-poker-$v-linux-x86_64/nene-poker
```
</details>

## How to watch

```bash
nene-poker
```

| Key | |
| --- | --- |
| `q` | Quit (Ctrl+C works too; however it ends, your terminal is restored) |
| `t` | Next color theme (12 in total) |
| `v` | `VIEW: YOU` (default) shows only the main player's cards; `VIEW: ALL` shows everyone's, so you can see who is bluffing |

| Option | |
| --- | --- |
| `--view you\|all` | Which cards to show at start (default `you`) |
| `--theme NAME` | `NEON` `PHOSPHOR` `AMBER` `SYNTHWAVE` `GLACIER` `BLOODMOON` `VAPOR` `MONO` `TOXIC` `GILDED` `ABYSS` `PAPER` |
| `--seed N` | Same seed, same tables, **same banter** (`v` never changes what happens, only what you see) |
| `--move-interval SEC` | Time per action (default 1.0 s) |
| `--result-pause SEC` | How long the result of a hand or a table stays up (default 3 s) |
| `--version` | Print the version and exit |

The terminal needs at least **80×24**. At **112×28 or larger you get the big table** (Windows Terminal's default 120×30 is enough).
If the window is too small, it tells you, in one line, how big it needs to be.

A table usually lasts **about six minutes** (23 hands in the median of 60 measured tables, twelve minutes at most): everyone starts with 1,500 chips and the blinds go up every ten hands.

### Reading the screen

- **The table**: the main player sits at the bottom (big cards), the others at the left, top and right. `>` marks whose turn it is, `(D)` the dealer button, `SB` / `BB` the blinds.
  Under each seat: their chips and their last action (`CALL 80`, `RAISE 240`, `ALL-IN`, `FOLD`)
- **Cards**: blocks in the card color with an ASCII rank and suit (`A K Q J T 9 … 2`, `s h d c`) in a four-color deck: spades black, hearts red, diamonds blue, clubs green.
  The suit symbols ♠♥♦♣ are deliberately not used: Windows Terminal draws them as emoji that ignore the theme colors
- **Your hand**: once the flop is out, the name of the main player's best hand appears next to their cards (`PAIR OF QUEENS`). There is no win percentage and no advice. They're on their own
- **POT**: in the middle, with side pots when someone is all in (`POT 360 + SIDE 120`)
- **MATCH / STACKS / LOG / RESULT**: table, hand, blinds and dealer; everyone's chips; the actions of this hand; the winner, the hand and the amount (and the champion with a countdown at the end of a table)
- **COMMS**: the two lines under the table, the latest things the cast said

## The cast

At every table the four are shuffled into the seats; whoever lands at the bottom is the main player for that table.

| | How they play | In their words |
| --- | --- | --- |
| **BLUFF.EXE** `>:]` | Loose and aggressive, bluffs one time in four | *"I have a great hand. I always do. Ask anyone."* |
| **NIT.BAK** `-_-` | Tight. Plays only strong hands, rarely bluffs | *"I'm a .bak file. I exist only in case of disaster."* |
| **TILT.SH** `*o*` | Hot-headed. Calls light and bets big | *"This shell script has no error handling. Neither do I."* |
| **ODDS.CSV** `o.O` | Follows the pot odds and runs the most simulations | *"The math is fair. That's what makes it brutal."* |

Each decision is a home-made Monte Carlo estimate (deal the unknown cards at random a few hundred to 1,500 times, compare the hands) weighed against the pot odds and the character's personality.
In 60 measured tables, TILT.SH won 18, NIT.BAK 17, ODDS.CSV 15 and BLUFF.EXE 10.

Each has 50 lines for specific moments: betting, folding, going all in, winning a pot, losing a showdown, busting out, winning the table, long quiet stretches. A few of them:

> **ODDS.CSV** (losing a showdown) *"Variance. Look it up. Then stop looking at me."*<br>
> **TILT.SH** (losing) *"RIGGED. The river is rigged. All rivers."*<br>
> **NIT.BAK** (busting out) *"Restoring from backup. Wait, I am the backup."*<br>
> **BLUFF.EXE** (winning) *"You folded to air. Beautiful, delicate air."*

The other 196 are yours to collect.

## Twelve themes

Cycle with `t`: `NEON` (default), `PHOSPHOR`, `AMBER`, `SYNTHWAVE`, `GLACIER`, `BLOODMOON`, `VAPOR`, `MONO`, `TOXIC`, `GILDED`, `ABYSS`, and `PAPER` (the only light theme).

| PAPER, `VIEW: ALL` | SYNTHWAVE at 80×24 |
| --- | --- |
| ![PAPER with everyone's cards shown](docs/images/paper-all.png) | ![SYNTHWAVE in the compact layout](docs/images/compact-synthwave.png) |

In every theme, every letter and digit is at least 4.5:1 against its background, the four suit colors are distinct and readable on the cards, and the card faces and backs stand out from the felt.
No human eyeballs this: a test computes it from the colors of the cells it actually renders, in all 12 themes, both layouts and both views.

---

## Under the hood

NeNe Poker wears the face of a poker screensaver, but it is also **an experiment in having machines enforce the rules**.
Everything from Issue #1 to the release pipeline happened on a single day, 2026-10-26. Every number below is in the repository's records (ADRs, tests, gate proofs).

### 1. The hand evaluator is checked against published numbers

No poker engine, no hand-evaluator library. The evaluator picks the best five of seven cards directly from bit masks, and it is checked on **every** possible hand:
all 2,598,960 five-card hands and all 133,784,560 seven-card hands are counted by category on every `make check` (about four seconds),
and the counts must match the tables published in [Counting Rocks!](https://arxiv.org/abs/2108.04902) and [Williamson (2025)](https://arxiv.org/abs/2511.06145),
copied from the primary sources with the citation next to the test ([ADR 0006](docs/adr/0006-published-hand-counts-and-rule-tests.md)).

### 2. The table rules have chapter and verse

Blinds, minimum raises, short all-ins that do or don't reopen the betting, side pots, split pots and the odd chip, and who gets the button when play goes heads-up all follow
Robert's Rules of Poker (version 11), and the tests cite the section they check ([ADR 0007](docs/adr/0007-table-rules-from-roberts-rules.md)).
200 random tables are played on every `make check` to check that no chip is ever created or lost and no card is ever dealt twice.

### 3. "View" is not part of the game

`v` switches what you see, never what happens. The view mode lives only in the rendering module, which the game and the AI **cannot import**,
so there is no path by which it could change a decision, a shuffle or a line of banter.

### 4. The first screenshot found a bug the tests didn't

Before the first real screenshot, every test passed. The screenshot showed `POT 20 + SIDE 10` before anyone had acted: side pots were being cut at every bet size, not only at all-in amounts.
It was fixed in the rules and pinned with a test ([ADR 0008](docs/adr/0008-table-screen-and-random-players.md)). A later screenshot caught the winner's seat still showing the chips from before the payout ([ADR 0010](docs/adr/0010-screen-photos-on-windows-terminal.md)).

### 5. An AI that never reads the clock, or libm

The game and AI code **cannot read** the current time, random numbers or environment variables; if they try, a home-grown conformance check fails the build.
The Monte Carlo estimate stops after a fixed number of samples, not after some seconds, and it counts in integers: `Double.rounded()` turned out to need libm, which the core does not link ([ADR 0011](docs/adr/0011-equity-estimate-and-cast.md)).
A decision takes about half a millisecond on average.

### 6. Rules aren't written down, they're enforced

The repository has 71 rules, each with an ID and a status saying whether a machine enforces it.
Right now **50 are active** (break one and `make check` fails). The rest are honestly labeled "not yet checked by a machine" or "cannot be blocked by a machine" ([quality gates](docs/QUALITY_GATES.md)).
Swift 6.4.1 was measured in 80 cases before any product code was written ([phase0-results.json](docs/quality/phase0-results.json)), and no check is trusted until it has been seen to fail:
**64 planted violations**, each caught by the intended rule, are recorded in the [gate proofs](docs/quality/gate-proofs.md).
Whether it ends with `q`, Ctrl+C, SIGTERM or even SIGSEGV, the terminal is restored; the real binary is run inside a pseudo-terminal on every `make check` to prove it.

---

## Development

```bash
make bootstrap           # once after cloning (commit hook and a static SwiftLint binary)
make check               # the one definition of done, identical locally and on CI
make release TAG=v<ver>  # build the release artifacts (only if they pass the checks)
```

- Swift 6.4.1 (`.swift-version`), SwiftPM only, zero external dependencies in the product. About 4,000 lines of source and 1,500 lines of tests
- Entry points: [CLAUDE.md](CLAUDE.md) (Japanese) and [AGENTS.md](AGENTS.md) (English). Design decisions are in 13 [ADRs](docs/adr/README.md); requirements and the owner's decisions are in [REQUIREMENTS.md](docs/REQUIREMENTS.md) (both in Japanese)
- Humans and AI write under the same rules and the same gates. The code here was written by Claude Code; the project owner set the requirements and the decisions

## License

MIT ([LICENSE](LICENSE))
