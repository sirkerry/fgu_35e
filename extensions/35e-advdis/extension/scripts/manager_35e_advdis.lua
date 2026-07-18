--
-- 3.5E/PFRPG ADV/DIS & Modifier Buttons
--
-- ADV/DISADV have no logic here at all - "Feature: Extended Automation"
-- (manager_actions_kel.lua) already owns that mechanic generically for every
-- d20-shaped 3.5E/PFRPG roll, keyed on ModifierManager.getKey("ADV")/("DISADV").
-- This script only supplies the missing +1/-1/+2/-2/+5/-5 numeric-modifier engine
-- (3.5E/PFRPG has none, unlike 2E or 5E) - a direct port of 5E's own
-- ActionsManager2.encodeDesktopMods (5E/scripts/manager_actions2.lua), using
-- the same universal onActionPostModRoll wildcard hook.
--

local _fnOrigOnPostModRoll;

function onInit()
	_fnOrigOnPostModRoll = GameManager.getMultiKeyFunction("onActionPostModRoll", "");
	GameManager.setMultiKeyFunction("onActionPostModRoll", "", onPostModRoll);

	if Session.IsHost and not ActionsManagerKel then
		ChatManager.SystemMessage("3.5E/PFRPG ADV/DIS & Modifier Buttons: \"Feature: Extended Automation\" is not loaded - ADV/DIS buttons will have no effect on rolls until it is enabled.");
	end
end

function onPostModRoll(rSource, rTarget, rRoll)
	local nMod = 0;
	if ModifierManager.getKey("PLUS1") then
		nMod = nMod + 1;
	end
	if ModifierManager.getKey("MINUS1") then
		nMod = nMod - 1;
	end
	if ModifierManager.getKey("PLUS2") then
		nMod = nMod + 2;
	end
	if ModifierManager.getKey("MINUS2") then
		nMod = nMod - 2;
	end
	if ModifierManager.getKey("PLUS5") then
		nMod = nMod + 5;
	end
	if ModifierManager.getKey("MINUS5") then
		nMod = nMod - 5;
	end

	if nMod ~= 0 then
		rRoll.sDesc = (rRoll.sDesc or "") .. string.format(" [%+d]", nMod);
		rRoll.nMod = (rRoll.nMod or 0) + nMod;
	end

	if _fnOrigOnPostModRoll then
		_fnOrigOnPostModRoll(rSource, rTarget, rRoll);
	end
end
