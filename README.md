# NeNe Poker

A terminal screensaver in which four hand-written AI characters play no-limit Texas hold'em at one table, hand after hand, until you press `q`.
One of them sits in the front seat as the "main player": you watch the table over that player's shoulder, and their cards are always face up.
Written in Swift for Ubuntu on WSL2 and Windows Terminal. The rules, the hand evaluator and the AI are written from scratch, with no external engine.
It is a sibling of [NeNe Gambit](https://github.com/hideyukiMORI/nene-gambit) (chess), [NeNe Reversi](https://github.com/hideyukiMORI/nene-reversi)
and [NeNe Igo](https://github.com/hideyukiMORI/nene-igo) (Go). The chips are imaginary points; nothing here involves money.

🚧 **Nothing runs yet.** The rules and the gate are being put in place before any product code is written (Issue #1).
The first product code will be the cards and the hand evaluator, with no screen, and nothing is drawn until the counts of every hand category
over all 5-card hands match the published ones.

## Development

```bash
make bootstrap   # once after cloning (commit hook and a static SwiftLint binary)
make check       # the one definition of done, identical locally and on CI
```

- Swift 6.4.1 (`.swift-version`), SwiftPM only, zero external dependencies in the product
- Entry points: [CLAUDE.md](CLAUDE.md) (Japanese) and [AGENTS.md](AGENTS.md) (English). What the machines enforce right now is in [docs/QUALITY_GATES.md](docs/QUALITY_GATES.md); the owner's decisions are in [docs/REQUIREMENTS.md](docs/REQUIREMENTS.md)

## License

MIT ([LICENSE](LICENSE))
