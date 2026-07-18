# 3.5E/PFRPG - Exploding Damage

FGU extension for the official 3.5E (Dungeons and Dragons 3.5E) and PFRPG
(Pathfinder 1E) rulesets.

Classic exploding-dice house rule for **all** damage rolls — weapons and
spells alike. When a damage die rolls its maximum possible value, it
rerolls and adds the new result to the total, repeating if the reroll also
explodes.

---

## The Mechanic

Every damage roll (weapon or spell) has each of its dice flagged to use
FGU's own native **compound-explode** die mode before the roll happens.
Concretely: a `2d6` damage roll becomes, mechanically, the equivalent of
rolling `2d6!` — any die that lands on its maximum value (a 6 on a d6, a 4
on a d4, etc.) is automatically rerolled and the new result is added to
that die's total, chaining for as long as it keeps exploding.

This isn't custom reroll logic built for this extension — it's a real,
existing FGU/CoreRPG dice-engine feature (the same one 4E's "Vorpal"
weapon property and Shadowdark's "Momentum" feature use), just switched on
for every 3.5E/PFRPG damage roll instead of gated behind a specific weapon
property.

## How It Works

3.5E/PFRPG's own `manager_action_damage.lua` doesn't implement its own
damage-roll builder at all — confirmed via direct source read, not
assumed — it just calls CoreRPG's shared
`ActionDamageD20.registerStandardDamageHealHandlers()` and layers a
size-based die-count adjustment on top. Every real damage roll in
3.5E/PFRPG, weapon or spell, ultimately calls the shared
`ActionDamageD20.performRoll`, which calls `ActionDamageD20.getRoll`
internally:

- **Weapon damage** (PC and NPC) — `campaign/scripts/char_weapon.lua`
  calls `ActionDamageD20.performRoll` directly, with `rAction.clauses`
  already built by `CharManager.getWeaponDamageRollStructures` (one clause
  per weapon damage-type row, ability bonus already folded in).
- **Spell/power damage** — the shared `common/scripts/string_attackline.lua`
  control (used to render clickable damage segments embedded in spell/
  feature description text) calls the *same*
  `ActionDamageD20.performRoll`, with `rAction.clauses` built by
  `CombatManager2.parseAttackLine`.

Both paths always populate `rAction.clauses` before reaching
`performRoll`/`getRoll` — confirmed directly in both builder functions, not
assumed from precedent. This extension monkey-patches
`ActionDamageD20.getRoll` alone: before delegating to the original, it
walks `rAction.clauses` and sets `bExplodeCompound = true` on each one.
CoreRPG's own damage-roll builder already reads that flag per clause and,
via `DiceRollManager`, sets each die's native `"e!"` (compound explode)
mode — this extension never touches dice results directly or reimplements
the reroll-and-add logic itself. A single patch point covers weapon and
spell damage alike, the same design already used for the 5E port of this
extension (`steadfast5e_expdmg`).

## What This Means in Practice

- **Weapon damage** — melee and ranged, PC and NPC — explodes.
- **Spell damage** — any power/spell dealing damage via the standard
  damage action — explodes.
- **Normal (non-max) rolls** are completely unaffected — no extra dice, no
  message changes, until a die actually lands on its maximum.

## Known Limitation: Critical Hits

3.5E/PFRPG's own critical-hit dice-doubling
(`ActionDamageD20.applyModCritical35E`, dispatched via
`GameManager.isOption("critical", {"3.5E","PF"})` — confirmed this is a
3.5E/PFRPG-specific function, distinct from the generic
`applyModCriticalDoubleDice` other rulesets use) builds a fresh doubled
damage clause but does not carry `bExplodeCompound` over to it (confirmed
via direct source read: its own dice-data table passed to
`DiceRollManager.addDamageDice` omits that field). In practice this means:
on a critical hit, the **original** dice in a damage roll will still
explode normally, but the **extra doubled dice** added by the critical-hit
rule will not themselves explode. This is the same known gap already
documented on `2e-expdmg`/`steadfast5e_expdmg` for their own respective
critical-hit functions — a gap in shared CoreRPG code, not something this
extension can fix without editing a file this project avoids touching on
principle.

## Compatibility

- Official 3.5E (Dungeons and Dragons 3.5E) and PFRPG (Pathfinder 1E)
  rulesets
- No stock ruleset file is edited — a single monkey-patch of
  `ActionDamageD20.getRoll`, reusing FGU's own native exploding-dice die
  mode rather than any custom logic
- Confirmed no conflict with `Feature: Extended Automation` — it only ever
  *calls* `ActionDamageD20.getRoll` (for its own bleed/thorns mechanic), it
  never reassigns it, so there's nothing to chain around

## Installation

Drop the `35e-expdmg` folder into your Fantasy Grounds Unity `extensions/`
directory and enable it when loading a 3.5E or PFRPG campaign.
