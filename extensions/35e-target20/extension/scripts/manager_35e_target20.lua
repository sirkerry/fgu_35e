--
-- 3.5E/PFRPG Target 20
--
-- Applies to the "non-combat" d20 roll types (ability checks, skill checks,
-- saving throws) AND attack/grapple rolls, via two different mechanisms
-- (see below). Non-combat rolls run via the universal onActionPreModRoll
-- wildcard hook (same hook family used by 35e-advdis).
--
-- 1) EVERY roll of these three types is always compared against a flat
--    DC 20, never the roll's own "natural" DC - but the natural DC isn't
--    thrown away, it's folded into the roll itself instead:
--       delta = 20 - naturalDC
--       nMod  = nMod + delta
--       nTarget = 20
--    A DC 16 fireball save becomes "roll +4, need 20" instead of "roll +0,
--    need 16" - mathematically identical pass/fail outcome, but every
--    check/save in play always reads as "did I hit 20", which is the
--    whole point of Target 20 as a branding/consistency device. Saves are
--    where this matters in practice - every real spell/effect save already
--    arrives with its own nTarget set (via performVsRoll, the normal
--    incoming-attack path) before this hook ever runs, so naturalDC = that
--    spell's actual DC. Ability/skill checks only ever arrive with a
--    pre-set nTarget via the GM's rarer party-sheet group-check DC fields
--    (performPartySheetRoll) - same treatment applied there too for
--    consistency, though it'll rarely trigger.
--
--    When there's no natural DC at all (the everyday "click an ability
--    score to roll a check" or "GM asks for an ungoverned save" case),
--    naturalDC defaults to 20 itself, so delta = 0 - no adjustment, no
--    tag, nTarget just becomes 20 directly. Same end result as before.
--
-- 2) Character level is always added on top, PC only (DB field "level" on
--    the actor node - the same field ActorManager35E.getAbilityScore reads
--    for its own "lev"/"lvl" lookup). NPCs get +0 (3.5E NPCs use Hit Dice,
--    not a "level" field - not handled here, out of scope unless asked).
--
-- Both adjustments land in rRoll.nMod before any roll-type-specific
-- modRoll/modSave function runs - safe, since none of those reset nMod,
-- they only add to it via their own separate nAddMod/effect-dice-mod calls.
--
-- ATTACK/GRAPPLE (melee/ranged/grapple base attack), added 2026-07-17:
-- same "fold the natural target into a delta, always compare against 20"
-- idea, using the target's AC instead of a spell/effect DC - no level bonus
-- here, matching the user's own framing of level as a "non-combat roll"
-- bonus specifically.
--
-- This needed a completely different mechanism than checks/saves, though -
-- AC isn't known at onActionPreModRoll time at all. It's computed later, at
-- RESULT-handling time, inside manager_action_attack.lua's onAttack, via
-- ActorManager35E.getDefenseValue(rSource, rTarget, rRoll) - confirmed via
-- direct source read to be the ONLY caller of getDefenseValue anywhere in
-- 3.5E/PFRPG, so wrapping it directly (not a generic wildcard hook, there
-- isn't one at this stage) is safe: no other call site to miss.
--
-- getDefenseValue itself sets rRoll.nDefenseVal to a BASE AC value, but the
-- final AC actually used for the hit/miss comparison is computed in TWO
-- additive steps - onAttack adds rRoll.nDefEffectsBonus (situational/effect
-- AC bonuses - dodge, cover, etc.) on top, AFTER getDefenseValue returns.
-- So this wrapper can't just set nDefenseVal = 20 directly (onAttack's own
-- addition afterward would push it past 20) - it pre-compensates instead:
-- nDefenseVal = 20 - nDefEffectsBonus, so that once onAttack's own
-- "+ nDefEffectsBonus" step runs, the result lands on exactly 20.
--
-- rRoll.nTotal also needs a DIRECT, explicit adjustment here (not just
-- nMod) - CoreRPG's core engine (manager_actions.lua's handleResolution)
-- computes rRoll.nTotal = dice + nMod once, BEFORE resolveAction/onAttack
-- ever runs, and nothing recomputes it dynamically afterward. Only nMod
-- carries forward automatically - to a LATER, separately-rolled crit-confirm
-- roll, which copies rRoll.nMod directly (manager_action_attack.lua:625,
-- "rCritConfirmRoll.nMod = rRoll.nMod + nCCMod") and inherits nDefenseVal=20
-- via a cached "[AC %d]" tag built from our already-adjusted value - so
-- crit-confirm correctly falls in line with zero extra code needed here.
--
-- Grapple note: this only ever fires for grapple checks under PFRPG rules
-- (DataCommon.isPFRPG()) - PFRPG's onGrapple calls the shared onAttack path
-- (CMB vs CMD), same as a normal attack. Pure 3.5E's own onGrapple never
-- calls getDefenseValue at all (confirmed via source read) - stock 3.5E
-- grapple is an opposed check the GM compares manually, no automated target
-- value to fold in, so there's nothing for this extension to touch there.
--

local _fnOrigOnPreModRoll;
local _fnOrigGetDefenseValue;

function onInit()
	_fnOrigOnPreModRoll = GameManager.getMultiKeyFunction("onActionPreModRoll", "");
	GameManager.setMultiKeyFunction("onActionPreModRoll", "", onPreModRoll);

	_fnOrigGetDefenseValue = ActorManager35E.getDefenseValue;
	ActorManager35E.getDefenseValue = getDefenseValue;
end

function onPreModRoll(rSource, rTarget, rRoll)
	if rRoll.sType == "ability" or rRoll.sType == "skill" or rRoll.sType == "save" then
		local nNaturalDC = tonumber(rRoll.nTarget) or 20;
		local nDelta = 20 - nNaturalDC;
		if nDelta ~= 0 then
			rRoll.nMod = (rRoll.nMod or 0) + nDelta;
			rRoll.sDesc = (rRoll.sDesc or "") .. string.format(" [DC %d -> T20 %+d]", nNaturalDC, nDelta);
		end
		rRoll.nTarget = 20;

		local nLevel = 0;
		if rSource and ActorManager.isPC(rSource) then
			local nodeActor = ActorManager.getCreatureNode(rSource);
			if nodeActor then
				nLevel = DB.getValue(nodeActor, "level", 0);
			end
		end
		if nLevel ~= 0 then
			rRoll.nMod = (rRoll.nMod or 0) + nLevel;
			rRoll.sDesc = (rRoll.sDesc or "") .. string.format(" [%+d LEVEL]", nLevel);
		end
	end

	if _fnOrigOnPreModRoll then
		_fnOrigOnPreModRoll(rSource, rTarget, rRoll);
	end
end

function getDefenseValue(rAttacker, rDefender, rRoll)
	local vRet1, vRet2, vRet3, vRet4 = _fnOrigGetDefenseValue(rAttacker, rDefender, rRoll);

	if rRoll and rRoll.nDefenseVal then
		local nDefEffectsBonus = rRoll.nDefEffectsBonus or 0;
		local nFinalAC = rRoll.nDefenseVal + nDefEffectsBonus;
		local nDelta = 20 - nFinalAC;
		if nDelta ~= 0 then
			rRoll.nMod = (rRoll.nMod or 0) + nDelta;
			rRoll.nTotal = (rRoll.nTotal or 0) + nDelta;
			rRoll.sDesc = (rRoll.sDesc or "") .. string.format(" [AC %d -> T20 %+d]", nFinalAC, nDelta);
		end
		-- Pre-compensate so onAttack's own "+ nDefEffectsBonus" step (run
		-- right after this function returns) lands exactly on 20.
		rRoll.nDefenseVal = 20 - nDefEffectsBonus;
	end

	return vRet1, vRet2, vRet3, vRet4;
end
