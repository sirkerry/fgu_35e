# 3.5E/PFRPG ADV/DIS & Modifier Buttons

FGU extension for the official 3.5E (Dungeons and Dragons 3.5E) and PFRPG
(Pathfinder 1E) rulesets.

Adds 5E-style modifier stack buttons — **ADV**/**DIS**, **+2**/**-2**,
**+5**/**-5** — to the desktop modifier stack panel, between the modifier
number box and the dice tower.

**Requires [`Feature: Extended Automation`](https://forge.fantasygrounds.com)
(by rhythmist, mr900rr, darrenan, tahl_liadon, bmos, DCrumb, RabidPaladin,
SoxMax, Cristmo, rhagelstrom, rogervinc, mattekure, rmilmine, Kelrugem, Moon
Wizard) to be loaded alongside this extension.** FGU extensions have no
native dependency-enforcement mechanism, so this isn't checked at load time
beyond a one-time GM chat warning — but without it, ADV/DIS will click and
release with zero effect on the dice.

## How It Works

**ADV/DIS is not reimplemented here at all.** `Feature: Extended Automation`
already ships a fully generic Advantage/Disadvantage mechanic
(`manager_actions_kel.lua`) for every d20-shaped roll (attack, save, skill,
init) in 3.5E/PFRPG — it reads the `ModifierManager` keys `"ADV"` and
`"DISADV"`, doubling the relevant die and keeping the favorable result. It
just never shipped any buttons to set those keys. This extension supplies
exactly that: two `button_modifierkey` controls named `ADV` and `DISADV`
(the control's name *is* the key it toggles — no button naming freedom here,
`DISADV` specifically, not 5E's own `"DIS"`).

**+2/-2/+5/-5 needed real code, not just buttons.** Unlike 2E (its own
`manager_actions2.lua`) or 5E (`ActionsManager2.encodeDesktopMods`), neither
3.5E, PFRPG, nor Extended-Automation has any existing engine that reads
`PLUS2`/`MINUS2`/`PLUS5`/`MINUS5` keys and applies a numeric bonus. This
extension's `manager_35e_advdis.lua` is a direct port of 5E's own
`encodeDesktopMods`, registered on the same universal
`onActionPostModRoll` wildcard hook (`GameManager.setMultiKeyFunction(...,
"", fn)`) that every CoreRPG-based ruleset fires for every roll type,
regardless of ruleset — the same hook family Extended-Automation and
`2e-advdis` both already use for their own logic. Any pre-existing handler
on this hook is chain-preserved, not overwritten.

## Layout Notes

Stock 3.5E/PFRPG declare **zero** modifier-stack buttons of their own (unlike
2E's stock 10) — CoreRPG's base `modifierstack` panel is only 74px wide,
sized for none. This extension widens it to 200px (matching 5E's own panel
width) and adds all 6 buttons fresh, anchored off the existing `modifier`
number field using the same offset convention proven in `2e-advdis`: first
pair offset 17px off the modifier field, each subsequent pair offset 6px,
top row / bottom row split via `anchor="bottom" offset="8"`.

## Compatibility

- Official 3.5E (Dungeons and Dragons 3.5E) and PFRPG (Pathfinder 1E)
  rulesets — PFRPG inherits everything from 3.5E via `importruleset`, so both
  get the same buttons/layout
- Purely additive to 3.5E/PFRPG — no stock ruleset file is edited
- Does not touch, override, or duplicate anything in `Feature: Extended
  Automation` — it's a strict prerequisite, not a fork or alternative

## Installation

Drop the `35e-advdis` folder into your Fantasy Grounds Unity `extensions/`
directory and enable it, along with `Feature: Extended Automation`, when
loading a 3.5E or PFRPG campaign.
