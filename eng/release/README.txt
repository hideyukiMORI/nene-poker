NeNe Poker @VERSION@ (Linux x86_64)
===================================

A terminal screensaver in which four AI characters play no-limit Texas hold'em at one table,
hand after hand, until you press q. One of them sits in the front seat as the main player:
their cards are always face up. The chips are imaginary points; nothing here involves money.

Requirements: Linux on x86_64 with glibc 2.35 or newer (Ubuntu 22.04 or later),
for example Ubuntu on WSL2 in Windows Terminal. Swift is not needed (the standard library is linked statically).

Download and verify
-------------------
1. Download these two files from the GitHub Release into one folder:
     nene-poker-@VERSION@-linux-x86_64.tar.gz
     SHA256SUMS
2. Verify (it must say OK):
     sha256sum --check SHA256SUMS
3. Extract and run:
     tar -xzf nene-poker-@VERSION@-linux-x86_64.tar.gz
     ./nene-poker-@VERSION@-linux-x86_64/nene-poker

Keys
----
  q   quit
  t   next color theme (12 themes)
  v   show only the main player's cards (VIEW: YOU, the default) or everyone's (VIEW: ALL)

Options
-------
  --theme NAME          NEON PHOSPHOR AMBER SYNTHWAVE GLACIER BLOODMOON VAPOR MONO TOXIC GILDED ABYSS PAPER
  --view you|all        which cards to show at start (default you)
  --seed N              the same seed gives the same tables and the same banter
  --move-interval SEC   time between actions (default 1.0)
  --result-pause SEC    time to show the result of a hand or a table (default 3)
  --version             print the version and exit

The terminal must be at least 80x24. At 112x28 or larger the table is drawn larger.

License: MIT (see LICENSE)
Source: https://github.com/hideyukiMORI/nene-poker
