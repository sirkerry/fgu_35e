# 3.5E/PFRPG Target 20

FGU extension for the official 3.5E (Dungeons and Dragons 3.5E) and PFRPG (Pathfinder 1E) rulesets.

Standardizes ability checks, skill checks, saving throws, and attack/grapple rolls to always be compared against a flat DC/AC of 20 — the roll's natural target number is folded into the roll itself as a bonus or penalty instead of being compared to directly.

## How It Works

For any roll, the difference between 20 and the natural target (a spell's DC, an attack's target AC) is added to the roll as a modifier, and the target is set to 20. The pass/fail result is always identical to rolling under the old rules — only the presentation changes, so every roll in play always reads as "did I hit 20."

Ability checks and skill checks also add half the character's level as a bonus; saving throws add the character's full level. Attack and grapple rolls do not get a level bonus.

## How to Use

Just enable the extension and load a 3.5E or PFRPG campaign — no setup required. Make any ability check, skill check, save, or attack roll as normal; chat shows the adjustment applied (e.g. `[DC 16 -> T20 +4] [+5 LEVEL]`) and the result compared against 20.

## What's Left Alone

- Miss chance (concealment) rolls, which are a d100 roll and don't map onto this scale.
- Stock 3.5E's opposed grapple check (grapple gets this treatment only under PFRPG's Combat Maneuver rules).
- Natural 20s and 1s still always hit or miss regardless of modifiers.

## Compatibility

- Official 3.5E (Dungeons and Dragons 3.5E) and PFRPG (Pathfinder 1E) rulesets
- Does not require, and works fine alongside, "Feature: Extended Automation" or the 3.5E/PFRPG ADV/DIS extension
