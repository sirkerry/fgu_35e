# fgu_35e

Fantasy Grounds Unity extensions for the official 3.5E (Dungeons and Dragons
3.5E) and PFRPG (Pathfinder 1E) rulesets, by Kerry Harrison (sirkerry).

Each extension lives in its own folder under `extensions/`, fully
self-contained with its own workflow scripts (`backup.sh`/`deploy.sh`/
`sync-to-repo.sh`/`restore.sh`/`build-ext.sh`) and README — see
[[feedback_live_first_no_symlinks]]: all FGU dev happens live at
`~/.smiteworks/fgdata/extensions/<name>/`, never via symlink; these repo
folders are git-tracked backups synced with `sync-to-repo.sh`.

**Forge listing assets** (`forge/*.svg`, `forge/*.png`) live only in the
repo under each extension's `forge/` folder. They must **not** be
deployed into the live FGU extensions directory or packaged into
`.ext` files — FG Forge rejects uploads that contain `.svg` inside the
extension package. `deploy.sh` only syncs `extension/`; `build-ext.sh`
also excludes `forge/` and `*.svg` as a safety net.

## Extensions

- **[35e-advdis](extensions/35e-advdis/README.md)** — ADV/DIS & Modifier
  Buttons. Adds 5E-style modifier stack buttons (ADV/DIS, +1/-1, +2/-2,
  +5/-5) to the 3.5E/PFRPG desktop. Requires the third-party
  `Feature: Extended Automation` extension, which already implements the
  ADV/DIS roll mechanic itself — this extension supplies the missing UI
  plus a numeric-modifier engine for the +1/-2/+5 buttons.
- **[35e-target20](extensions/35e-target20/README.md)** — Target 20.
  Ability checks, skill checks, saving throws, and attack/grapple rolls
  always compare against a flat 20 — any natural target (a spell's DC, or
  a target's AC/CMD) is folded into the roll as a bonus/penalty instead of
  changing the target number. Ability/skill/save rolls also add character
  level; attack/grapple rolls do not.
