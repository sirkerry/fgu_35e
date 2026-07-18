--
-- 3.5E/PFRPG Exploding Damage
--
-- Classic exploding-dice house rule for all damage rolls - weapons and
-- spells alike. When a damage die rolls its maximum possible value, it
-- rerolls and adds the new result to the total, chaining if the reroll
-- also explodes.
--
-- Not custom reroll logic - FGU/CoreRPG's dice engine already has a native
-- compound-explode die mode ("e!"). CoreRPG's shared ActionDamageD20.getRoll
-- (manager_action_damage_d20.lua) already reads a per-clause
-- bExplodeCompound flag and sets that die mode via DiceRollManager -
-- this extension just sets that flag on every clause before the roll.
--
-- 3.5E's own manager_action_damage.lua confirmed (via direct source read,
-- not assumed) to NOT define its own getRoll/performRoll at all - it just
-- calls ActionDamageD20.registerStandardDamageHealHandlers() and layers a
-- size-based die-count adjustment on top via a separate wildcard hook.
-- Every real call site for damage in 3.5E (weapon damage via
-- campaign/scripts/char_weapon.lua and the shared common/scripts/
-- string_attackline.lua control that also renders spell/power damage
-- lines) calls ActionDamageD20.performRoll directly, which itself calls
-- ActionDamageD20.getRoll internally - so patching getRoll alone covers
-- weapon damage (PC/NPC) and spell/power damage in one place, same single
-- patch point 5E's own port of this extension uses (steadfast5e_expdmg).
-- Confirmed Feature: Extended Automation only ever CALLS
-- ActionDamageD20.getRoll (for its own bleed/thorns mechanic) and never
-- reassigns it, so there's nothing else to chain around here.
--
-- Known limitation: 3.5E/PFRPG's own critical-hit dice-doubling
-- (ActionDamageD20.applyModCritical35E, dispatched via
-- GameManager.isOption("critical", {"3.5E","PF"})) builds a fresh doubled
-- damage clause but does not carry bExplodeCompound over to it (confirmed
-- via direct source read: its own tDiceData table passed to
-- DiceRollManager.addDamageDice omits that field). So on a critical hit,
-- the ORIGINAL dice in a damage roll still explode, but the EXTRA doubled
-- dice added by the crit rule do not. Same known gap already documented
-- on 2e-expdmg/steadfast5e_expdmg for their own respective critical-hit
-- functions - not something this extension can fix without editing a
-- shared CoreRPG file, which this project avoids on principle.
--

local _fnOrigGetRoll;

function onInit()
	_fnOrigGetRoll = ActionDamageD20.getRoll;
	ActionDamageD20.getRoll = getRoll;
end

function getRoll(rActor, rAction)
	for _,tClause in ipairs(rAction.clauses or {}) do
		tClause.bExplodeCompound = true;
	end

	return _fnOrigGetRoll(rActor, rAction);
end
