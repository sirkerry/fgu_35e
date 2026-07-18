# 3.5E/PFRPG Target 20

FGU extension for the official 3.5E (Dungeons and Dragons 3.5E) and PFRPG
(Pathfinder 1E) rulesets.

Standardizes ability checks, skill checks, saving throws, **and attack/
grapple rolls** to always be compared against a flat **DC/AC 20** — never
the roll's own "natural" target number. Ability/skill checks and saves also
always add the character's level on top; attack/grapple rolls do not (level
is a "non-combat roll" bonus only).

---

## The Core Idea

**Every roll is always compared against 20, but the natural target number
isn't thrown away — it's folded into the roll itself as a bonus or
penalty:**

```
delta = 20 - naturalTarget   (naturalTarget = a save/check's DC, or an attack's target AC)
nMod  = nMod + delta
target = 20
```

A DC 16 fireball Reflex save becomes "roll +4, need 20" instead of "roll
+0, need 16" — mathematically identical pass/fail outcome, but every
roll in play always reads as "did I hit 20", which is the whole point of
Target 20.

## Ability Checks, Skill Checks, and Saves

**Character level is always added on top** of the delta above, PC only —
3.5E NPCs use Hit Dice rather than a "level" field, so this doesn't apply
to them.

This matters most for saves, since a real incoming spell/effect always
arrives with its own DC already attached; ability and skill checks only
ever get a pre-set DC from the GM's rarer party-sheet group-check fields,
so in practice they'll almost always just show a flat `[vs. DC 20]` with
no adjustment tag.

**Example:** a 5th-level PC with a +2 Reflex modifier fails a DC 16
fireball save under stock rules with a roll of 10 (`10 + 2 = 12 < 16`).
Under Target 20: `delta = 20 - 16 = +4`, level `+5` also added, effective
roll `10 + 2 + 4 + 5 = 21 >= 20` → **SUCCESS**. Chat log shows
`[DC 16 -> T20 +4] [+5 LEVEL]`.

## Attack and Grapple Rolls

Same delta idea, using the target's AC (or CMD, for a PFRPG-mode grapple)
instead of a spell/effect DC — **no level bonus here**, since level is
specifically a non-combat-roll bonus in this extension's design. Chat log
shows `[AC 16 -> T20 +4]`.

Natural 20s/1s (auto-threat/auto-miss) are untouched, since those are
based on the raw die result, not the total. Critical-confirmation rolls
automatically inherit the same treatment with no extra logic needed —
they copy the original attack roll's modifier and target AC directly, both
of which are already Target-20-adjusted by the time the crit-confirm roll
is built.

**Grapple only gets this treatment under PFRPG rules** (Combat Maneuver
Bonus vs. Combat Maneuver Defense, which shares the same resolution path as
a normal attack). Stock 3.5E's own grapple is an opposed check the GM
compares manually — there's no automated target value in that path for
this extension to fold into a flat 20.

## How It Works Under the Hood

Unlike 2E (whose ability/skill checks are natively roll-*under*, needing a
genuinely different roll mechanic to get a unified roll-over-vs-20 system —
see `fgu_2e/extensions/2e-target20`), **3.5E/PFRPG's ability checks, skill
checks, saves, and attacks are already roll-over**, and the stock ruleset
already has DC/AC verdict systems built in for all of them — this
extension just standardizes what they're compared against.

**Ability/skill checks and saves** go through a single `onActionPreModRoll`
wildcard hook (the same universal per-roll hook family used by
`35e-advdis`/`Feature: Extended Automation`) — `manager_action_ability.lua`/
`manager_action_skill.lua`/`manager_action_save.lua`'s own result handlers
already append `[vs. DC X] [SUCCESS]`/`[FAILURE]` whenever `rRoll.nTarget`
is set; this hook just makes sure it's always set (defaulting to 20 when
there's no natural DC at all) and applies the delta/level math beforehand.

**Attack/grapple rolls** need a different mechanism — AC isn't known until
result-handling time, inside `manager_action_attack.lua`'s `onAttack`, via
`ActorManager35E.getDefenseValue` (confirmed to be the only caller of that
function anywhere in 3.5E/PFRPG). This extension wraps that function
directly: it lets the real AC get computed as normal, then folds the delta
into the roll's modifier/total and pre-compensates `nDefenseVal` so the
comparison that follows immediately afterward lands on exactly 20.

## Compatibility

- Official 3.5E (Dungeons and Dragons 3.5E) and PFRPG (Pathfinder 1E)
  rulesets — PFRPG inherits the relevant scripts unchanged from 3.5E, so
  both get identical behavior (except grapple, see above)
- Purely additive — no stock ruleset file is edited
- Does not require (or interact with) `Feature: Extended Automation` /
  `35e-advdis` — independent extensions, safe to run with or without each
  other; confirmed no overlapping hook/function usage
- Miss chance (concealment) rolls are untouched — that's a d100 roll,
  doesn't map onto a "compare to 20" scale

## Installation

Drop the `35e-target20` folder into your Fantasy Grounds Unity
`extensions/` directory and enable it when loading a 3.5E or PFRPG
campaign.
