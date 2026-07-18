--
-- 3.5E/PFRPG Subraces
--
-- CharManager.addRace (manager_char.lua:1197) sets the character's race
-- name/link and loops the race's own "racialtraits" child list, applying
-- each via CharManager.addRacialTrait. It has no concept of subraces at
-- all - confirmed via direct source read, not guessed.
--
-- This wraps addRace directly (confirmed the only caller/definition site
-- for this exact function, so a direct wrap is safe - no wildcard hook
-- exists at this level the way onActionPreModRoll does for rolls):
-- call the original unchanged first (base race name/link/traits, zero
-- regression), then check the race's own new "subraces" child list -
-- zero subraces: nothing further to do. Exactly one: apply it directly,
-- no prompt. More than one: prompt via the same generic CoreRPG
-- select_dialog/requestSelection flow 3.5E's own list_spellclass.lua
-- already uses elsewhere (confirmed same calling convention, ported
-- directly).
--
-- Applying a chosen subrace loops ITS OWN "racialtraits" list through the
-- exact same CharManager.addRacialTrait function the base race already
-- uses - no new trait-application logic, just reused verbatim.
--

local _fnOrigAddRace;

function onInit()
	_fnOrigAddRace = CharManager.addRace;
	CharManager.addRace = addRace;
end

function addRace(nodeChar, sClass, sRecord)
	_fnOrigAddRace(nodeChar, sClass, sRecord);

	local nodeSource = DB.findNode(sRecord);
	if not nodeSource then
		return;
	end

	local aSubraces = DB.getChildList(nodeSource, "subraces");
	if #aSubraces == 0 then
		return;
	elseif #aSubraces == 1 then
		applySubrace(nodeChar, aSubraces[1]);
	else
		local aOptions = {};
		for _,v in ipairs(aSubraces) do
			table.insert(aOptions, { text = DB.getValue(v, "name", ""), });
		end

		local rCustom = { nodeChar = nodeChar, sRecord = sRecord };
		local wSelect = Interface.openWindow("select_dialog", "");
		local sTitle = Interface.getString("char_title_selectsubrace");
		local sMessage = string.format(Interface.getString("char_message_selectsubrace"), DB.getValue(nodeSource, "name", ""));
		wSelect.requestSelection(sTitle, sMessage, aOptions, onSubraceSelected, rCustom);
	end
end

function onSubraceSelected(aSelection, rCustom)
	if not aSelection or #aSelection == 0 then
		return;
	end

	local nodeSource = DB.findNode(rCustom.sRecord);
	if not nodeSource then
		return;
	end

	for _,v in ipairs(DB.getChildList(nodeSource, "subraces")) do
		if DB.getValue(v, "name", "") == aSelection[1] then
			applySubrace(rCustom.nodeChar, v);
			break;
		end
	end
end

function applySubrace(nodeChar, nodeSubrace)
	local sSubrace = DB.getValue(nodeSubrace, "name", "");
	local sCharName = DB.getValue(nodeChar, "name", "");

	-- If the subrace's own name already contains the base race's name
	-- (e.g. "Mountain Dwarf" for race "Dwarf"), replace outright; otherwise
	-- append it in parentheses (e.g. "Elf (Grey)"). Same convention FSOSR
	-- already uses for this exact case.
	local sRace = DB.getValue(nodeChar, "race", "");
	if sRace ~= "" then
		if sSubrace:match(sRace) then
			DB.setValue(nodeChar, "race", "string", sSubrace);
		else
			DB.setValue(nodeChar, "race", "string", sRace .. " (" .. sSubrace .. ")");
		end
	end

	for _,v in ipairs(DB.getChildList(nodeSubrace, "racialtraits")) do
		CharManager.addRacialTrait(nodeChar, "referenceracialtrait", DB.getPath(v));
	end

	ChatManager.SystemMessage(string.format(Interface.getString("char_message_subraceadd"), sSubrace, sCharName));
end
