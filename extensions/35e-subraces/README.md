# 3.5E/PFRPG Subraces

FGU extension for the official 3.5E (Dungeons and Dragons 3.5E) and PFRPG
(Pathfinder 1E) rulesets.

Adds a **Subraces** section to the Race record. Ctrl-drop a race onto it to
copy it in as a new subrace (with its own Traits section). Applying a race
with subraces to a character prompts for which one (auto-picked if there's
only one), then applies that subrace's own traits alongside the base
race's.

---

## Why

Stock 3.5E/PFRPG has **no Subraces concept anywhere** — confirmed via
direct source read, not assumed. `CharManager.addRace`
(`manager_char.lua:1197`) only ever reads a race's own `racialtraits` list;
there's no `subraces` field, no separate subrace record type, nothing. A
handful of orphaned CoreRPG strings exist
(`library_recordtype_label_race_subrace`, etc.) but nothing in 3.5E or
PFRPG ever reads them — they appear to be leftover boilerplate from other
official rulesets (e.g. 5E) that do implement subraces natively.

This extension adds that missing piece, reusing those orphaned strings
directly for its own UI text (no new strings needed there).

**Scope note:** this was originally scoped as a broader port of an
FSOSR-style Race record (Subraces + Proficiencies + Skills). It was
narrowed to Subraces only — 3.5E already has a working, wired-up mechanism
for racial skill/save bonuses and proficiencies via regex-parsing a
Trait's free text (`checkForRacialSkillBonus`/`checkForRacialSaveBonus`/
`handleProficiencies` in `manager_char.lua`, all triggered automatically
for any trait whose name isn't otherwise special-cased). Whether that
text-matching mechanism is sufficient in practice, or a more structured
authoring UI is still wanted later, is still under consideration.

## How It Works

**The UI side** (`campaign/record_subrace_35e.xml`) adds a new
`referencesubrace` record type — nested-only, nothing to browse
independently in the sidebar (same convention 2E's own native Subraces and
FSOSR's own `reference_subrace` both use). `referencesubrace_main` is a
near-exact structural copy of 3.5E's own `referencerace_main`: same Traits
section, reusing the *exact same* row class (`ref_racial_trait`) and
datasource field name (`.racialtraits`) the base Race record already uses.

The base Race record gets a new **Subraces** section, inserted above
Traits. Ctrl-drop a race shortcut onto its header to copy that race in as
a new subrace — the same drag-to-copy UX FSOSR and 2E both already use.

**The character-apply side** (`scripts/manager_35e_subraces.lua`) wraps
`CharManager.addRace` directly (confirmed the only definition/call site
for this function, so a direct wrap is safe — there's no generic wildcard
hook at this level the way there is for dice rolls):

1. Calls the original function unchanged first — base race name/link/traits
   apply exactly as before, zero regression.
2. Checks the race's own `subraces` child list. None: done. Exactly one:
   applied automatically, no prompt. More than one: prompts via the same
   generic CoreRPG `select_dialog` flow 3.5E's own spell-level-selection
   code already uses elsewhere.
3. Applying the chosen subrace loops its own `racialtraits` list through
   the *exact same* `CharManager.addRacialTrait` function the base race
   already uses — no new trait-application logic, just reused verbatim.
4. The character's `race` field is updated to reflect the subrace: if the
   subrace's name already contains the base race's name (e.g. "Mountain
   Dwarf" for race "Dwarf"), it replaces outright; otherwise it's appended
   in parentheses (e.g. "Elf (Grey)").

## Compatibility

- Official 3.5E (Dungeons and Dragons 3.5E) and PFRPG (Pathfinder 1E)
  rulesets — PFRPG inherits `manager_char.lua`/`record_race.xml` unchanged
  from 3.5E, so both get identical behavior
- Purely additive — no stock ruleset file is edited
- Independent of `35e-advdis`/`35e-target20` — no shared hooks or functions

## Installation

Drop the `35e-subraces` folder into your Fantasy Grounds Unity
`extensions/` directory and enable it when loading a 3.5E or PFRPG
campaign.
