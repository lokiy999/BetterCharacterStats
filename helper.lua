BCS = BCS or {}

local BCS_Tooltip = getglobal("BetterCharacterStatsTooltip") or CreateFrame("GameTooltip", "BetterCharacterStatsTooltip", nil, "GameTooltipTemplate")
local BCS_Prefix = "BetterCharacterStatsTooltip"
BCS_Tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

local L = BCS["L"]

local strfind = strfind
local tonumber = tonumber
local tinsert = tinsert
local lastBlessingOfWisdomMP5 = 0 -- Stores last detected MP5 from BoW
local lastGearBonus = 1 --Stores the gear bonus snapshot (default 1.0)

local function tContains(table, item)
	local index = 1
	while table[index] do
		if ( item == table[index] ) then
			return 1
		end
		index = index + 1
	end
	return nil
end

function BCS:GetPlayerAura(searchText, auraType)
	if not auraType then
		-- buffs
		-- http://blue.cardplace.com/cache/wow-dungeons/624230.htm
		-- 32 buffs max
		for i=0, 31 do
			local index = GetPlayerBuff(i, 'HELPFUL')
			if index > -1 then
				BCS_Tooltip:SetPlayerBuff(index)
				local MAX_LINES = BCS_Tooltip:NumLines()
					
				for line=1, MAX_LINES do
					local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
					if left:GetText() then
						local value = {strfind(left:GetText(), searchText)}
						if value[1] then
							return unpack(value)
						end
					end
				end
			end
		end
	elseif auraType == 'HARMFUL' then
		for i=0, 6 do
			local index = GetPlayerBuff(i, auraType)
			if index > -1 then
				BCS_Tooltip:SetPlayerBuff(index)
				local MAX_LINES = BCS_Tooltip:NumLines()
					
				for line=1, MAX_LINES do
					local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
					if left:GetText() then
						local value = {strfind(left:GetText(), searchText)}
						if value[1] then
							return unpack(value)
						end
					end
				end
			end
		end
	end
end

function BCS:GetPlayerAuraValue(searchText, auraType)
    local maxAuras = auraType == "HARMFUL" and 6 or 31 -- 6 debuffs max, 32 buffs max

    for i = 0, maxAuras do
        local index = GetPlayerBuff(i, auraType)
        if index > -1 then
            BCS_Tooltip:SetPlayerBuff(index)
            local MAX_LINES = BCS_Tooltip:NumLines()

            for line = 1, MAX_LINES do
                local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
                if left and left:GetText() then
                    local _, _, value = strfind(left:GetText(), searchText)
                    if value then
                        return tonumber(value) -- Extracts and returns the numeric value found in the tooltip
                    end
                end
            end
        end
    end

    return 0 -- Return 0 if no match is found
end

--Added a 3rd way to find buffs in game by ~Khan to get ingame icons example: Interface\Icons\Spell_Holy_SealOfWisdom
-- run this ingame : /script function m(s) DEFAULT_CHAT_FRAME:AddMessage(s); end for i=1,16 do s=UnitBuff("target", i); if(s) then m("B "..i..": "..s); end s=UnitDebuff("target", i); if(s) then m("D "..i..": "..s); end end
-- or this: /script for i=1,32 do local t=UnitBuff("player",i); if t then DEFAULT_CHAT_FRAME:AddMessage(i..": "..t) end end
function BCS:GetPlayerAuraTexture(auraTexture)
    for i = 1, 40 do -- Max buffs in Vanilla is 40
        local texture = UnitBuff("player", i)
        if not texture then break end

        if texture == auraTexture then
            return true -- Buff found
        end
    end
    return false -- Buff not found
end

-- ! Used in Ranged too
local hit_debuff = 0
function BCS:GetHitRating(hitOnly)
	local Hit_Set_Bonus = {}
	local hit = 0;
	local MAX_INVENTORY_SLOTS = 19;
	
	-- Items
	for slot=0, MAX_INVENTORY_SLOTS do
		local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
		if hasItem then
			local MAX_LINES = BCS_Tooltip:NumLines()
			local SET_NAME = nil
			
			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L["Equip: Improves your chance to hit by (%d)%%."])
					if value then
						hit = hit + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["/Hit %+(%d+)"])
					if value then
						hit = hit + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["Equip: Improves your chance to hit with attacks and spells by (%d+)%%."])
					if value then
						hit = hit + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["%+(%d+)%% Hit"])					
					if value then
						hit = hit + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), "(.+) %(%d/%d%)")
					if value then
						SET_NAME = value
					end
					_,_, value = strfind(left:GetText(), L["^Set: Improves your chance to hit by (%d)%%."])
					if value and SET_NAME and not tContains(Hit_Set_Bonus, SET_NAME) then
						tinsert(Hit_Set_Bonus, SET_NAME)
						hit = hit + tonumber(value)
						line = MAX_LINES
					end
				end
			end
			
		end
	end

	-- buffs
	local _, _, hitFromAura = BCS:GetPlayerAura(L["Chance to hit increased by (%d)%%."])
	if hitFromAura then
		hit = hit + tonumber(hitFromAura)
	end
	 _, _, hitFromAura = BCS:GetPlayerAura(L["Improves your chance to hit by (%d+)%%."])
	if hitFromAura then
		hit = hit + tonumber(hitFromAura)
	end
	 _, _, hitFromAura = BCS:GetPlayerAura(L["Increases attack power by %d+ and chance to hit by (%d+)%%."])
	if hitFromAura then
		hit = hit + tonumber(hitFromAura)
	end
	-- debuffs
	_, _, hitFromAura = BCS:GetPlayerAura(L["Chance to hit reduced by (%d+)%%."], 'HARMFUL')
	if hitFromAura then
		hit_debuff = hit_debuff + tonumber(hitFromAura)
	end
	_, _, hitFromAura = BCS:GetPlayerAura(L["Chance to hit decreased by (%d+)%% and %d+ Nature damage every %d+ sec."], 'HARMFUL')
	if hitFromAura then
		hit_debuff = hit_debuff + tonumber(hitFromAura)
	end
	hitFromAura = BCS:GetPlayerAura(L["Lowered chance to hit."], 'HARMFUL')
	if hitFromAura then
		hit_debuff = hit_debuff + 25
	end
	
	local MAX_TABS = GetNumTalentTabs()
	
	-- ! Can I remove this part?
	--[[
	local Cache_GetHitRating_Tab, Cache_GetHitRating_Talent
	if Cache_GetHitRating_Tab and Cache_GetHitRating_Talent then
		BCS_Tooltip:SetTalent(Cache_GetHitRating_Tab, Cache_GetHitRating_Talent)
		local MAX_LINES = BCS_Tooltip:NumLines()
		
		for line=1, MAX_LINES do
			local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
			if left:GetText() then
				local _,_, value = strfind(left:GetText(), L["Increases your chance to hit with all attacks and spells by (%d+)%%."])
				local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(Cache_GetHitRating_Tab, Cache_GetHitRating_Talent)
				if value and rank > 0 then
					hit = hit + tonumber(value)		
					line = MAX_LINES
				end

				-- Hunter
				-- Killer Instinct
				_,_, value = strfind(left:GetText(), L["Increases hit and crit chance by (%d+)%% for both you and your pet."])
				name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(Cache_GetHitRating_Tab, Cache_GetHitRating_Talent)
				if value and rank > 0 then
					hit = hit + tonumber(value)
					line = MAX_LINES
				end

				-- Rogue / Warrior
				-- Precision / Precision
				_,_, value = strfind(left:GetText(), L["Increases your chance to hit with melee weapons by (%d)%%."])
				name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(Cache_GetHitRating_Tab, Cache_GetHitRating_Talent)
				if value and rank > 0 then
					hit = hit + tonumber(value)
					line = MAX_LINES
				end
				
				-- Hunter
				-- ?? what talent, if any
				-- ! deprecated?
				_,_, value = strfind(left:GetText(), L["Increases hit chance by (%d)%% and increases the chance movement impairing effects will be resisted by an additional %d+%%."])
				name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(Cache_GetHitRating_Tab, Cache_GetHitRating_Talent)
				if value and rank > 0 then
					hit = hit + tonumber(value)
					line = MAX_LINES
				end

				-- Paladin / Shaman
				-- Precision / Nature's Guidance			
				_,_, value = strfind(left:GetText(), L["Increases your chance to hit with melee attacks and spells by (%d+)%%."])
				name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(Cache_GetHitRating_Tab, Cache_GetHitRating_Talent)
				if value and rank > 0 then
					hit = hit + tonumber(value)
					line = MAX_LINES
				end
			end
		end
		
		if not hitOnly then
			hit = hit - hit_debuff
			if hit < 0 then hit = 0 end
			return hit
		else
			return hit
		end
	end
	--]]
	
	for tab=1, MAX_TABS do
		local MAX_TALENTS = GetNumTalents(tab)
		
		for talent=1, MAX_TALENTS do
			BCS_Tooltip:SetTalent(tab, talent);
			local MAX_LINES = BCS_Tooltip:NumLines()
			
			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				if left:GetText() then	
					-- Druid
					-- Accuracy
					local _,_, value = strfind(left:GetText(), L["Increases your chance to hit with all attacks and spells by (%d+)%%."])
					name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						hit = hit + tonumber(value)
						line = MAX_LINES
					end

					-- Hunter
					-- Killer Instinct
					_,_, value = strfind(left:GetText(), L["Increases hit and crit chance by (%d+)%% for both you and your pet."])
					name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						hit = hit + tonumber(value)
						line = MAX_LINES
					end

					-- Rogue / Warrior
					-- Precision / Precision
					_,_, value = strfind(left:GetText(), L["Increases your chance to hit with melee weapons by (%d)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						hit = hit + tonumber(value)
						line = MAX_LINES
					end

					-- Paladin / Shaman
					-- Precision / Nature's Guidance		 		
					_,_, value = strfind(left:GetText(), L["Increases your chance to hit with melee attacks and spells by (%d+)%%."])
					name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						hit = hit + tonumber(value)
						line = MAX_LINES
					end
				end	
			end			
		end
	end
	
	if not hitOnly then
		hit = hit - hit_debuff
		if hit < 0 then hit = 0 end -- Dust Cloud OP
		return hit
	else
		return hit
	end
end

function BCS:GetRangedHitRating()
	local melee_hit = BCS:GetHitRating(true)
	local ranged_hit = melee_hit
	local debuff = hit_debuff

	local hasItem = BCS_Tooltip:SetInventoryItem("player", 18) -- ranged enchant
	if hasItem then
		local MAX_LINES = BCS_Tooltip:NumLines()
		for line=1, MAX_LINES do
			local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
			if left:GetText() then
				local _,_, value = strfind(left:GetText(), L["+(%d)%% Hit"])
				if value then
					ranged_hit = ranged_hit + tonumber(value)
					line = MAX_LINES
				end
			end
		end
	end
	
	ranged_hit = ranged_hit - debuff
	if ranged_hit < 0 then ranged_hit = 0 end
	return ranged_hit
end

function BCS:GetSpellHitRating()
	local hit = 0
	local arcaneHit = 0
	local fireHit = 0
	local frostHit = 0
	local holyHit = 0
	local natureHit = 0
	local shadowHit = 0
	local afflictionHit = 0
	local destructionHit = 0
	local tauntHit = 0
	local hit_Set_Bonus = {}

	local Hit_Schools = {}
	
	-- scan gear
	local MAX_INVENTORY_SLOTS = 19
	for slot=0, MAX_INVENTORY_SLOTS do
		local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
		
		if hasItem then
			local SET_NAME
			local MAX_LINES = BCS_Tooltip:NumLines()
			
			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L["Equip: Improves your chance to hit with spells by (%d)%%."])
					if value then
						hit = hit + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["Equip: Improves your chance to hit with attacks and spells by (%d+)%%."])
					if value then
						hit = hit + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["/Spell Hit %+(%d+)"])
					if value then
						hit = hit + tonumber(value)
					end				
					_,_, value = strfind(left:GetText(), L["%+(%d+)%% Hit"])					
					if value then
						hit = hit + tonumber(value)
					end
					
					_,_, value = strfind(left:GetText(), "(.+) %(%d/%d%)")
					if value then
						SET_NAME = value
					end
					_, _, value = strfind(left:GetText(), L["^Set: Improves your chance to hit with spells by (%d)%%."])
					if value and SET_NAME and not tContains(hit_Set_Bonus, SET_NAME) then
						tinsert(hit_Set_Bonus, SET_NAME)
						hit = hit + tonumber(value)
					end
				end
			end
		
		end
	end
	
	-- scan talents
	local MAX_TABS = GetNumTalentTabs()
	
	for tab=1, MAX_TABS do
		local MAX_TALENTS = GetNumTalents(tab)
		
		for talent=1, MAX_TALENTS do
			BCS_Tooltip:SetTalent(tab, talent)
			local MAX_LINES = BCS_Tooltip:NumLines()
			
			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				if left:GetText() then
					-- Druid 
					-- Accuracy
					_,_, value = strfind(left:GetText(), L["Increases your chance to hit with all attacks and spells by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						hit = hit + tonumber(value)
						line = MAX_LINES
					end

					-- Shaman
					-- Elemental Precision
					_,_, value = strfind(left:GetText(), L["Increases your chance to hit with Fire, Frost and Nature spells by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						fireHit = fireHit + tonumber(value)
						frostHit = frostHit + tonumber(value)
						natureHit = natureHit + tonumber(value)
						line = MAX_LINES
					end

					-- Mage
					-- Elemental Precision
					local _,_, value = strfind(left:GetText(), L["Reduces the chance that the opponent can resist your Frost and Fire spells by (%d)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						fireHit = fireHit + tonumber(value)
						frostHit = frostHit + tonumber(value)
						line = MAX_LINES
					end
										
					-- Mage
					-- Arcane Focus
					_,_, value = strfind(left:GetText(), L["Reduces the chance that the opponent can resist your Arcane spells by (%d+)%% and gives you a (%d+)%% chance to avoid interruption caused by damage while channeling Arcane Missiles."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						arcaneHit = arcaneHit + tonumber(value)
						line = MAX_LINES
					end

					-- Priest
					-- Shadow Focus
					_,_, value = strfind(left:GetText(), L["Reduces your target's chance to resist your Shadow spells by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						shadowHit = shadowHit + tonumber(value)
						line = MAX_LINES
					end

					-- Priest
					-- Spell Focus
					_,_, value = strfind(left:GetText(), L["Improves your chance to hit with spells by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						hit = hit + tonumber(value)
						line = MAX_LINES
					end

					-- Paladin
					-- Precision
					_,_, value = strfind(left:GetText(), L["Increases your chance to hit with melee attacks and spells by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						hit = hit + tonumber(value)
						line = MAX_LINES
					end
					-- Warlock
					-- Suppression
					_,_, value, value2 = strfind(left:GetText(), L["Increases the range of your Affliction spells by (%d+) yds and reduces the chance for enemies to resist your Affliction spells by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value2 and rank > 0 then
						afflictionHit = afflictionHit + tonumber(value2)
						line = MAX_LINES
					end

					-- Warlock
					-- Intensity
					_,_, value, value2 = strfind(left:GetText(), L["Reduces the chance for enemies to resist your Destruction spells by (%d+)%% and gives you a (%d+)%% chance to resist interruption caused by damage while casting or channeling any Destruction spell."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						destructionHit = destructionHit + tonumber(value)
						line = MAX_LINES
					end

					-- Warrior
					-- Mocker
					_,_, value = strfind(left:GetText(), L["Improves your chance to hit with Taunt, Challenging Shout and Mocking Blow abilities by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						tauntHit = tauntHit + tonumber(value)
						line = MAX_LINES
					end
				end	
			end
			
		end
	end
	
	-- buffs
	local _, _, hitFromAura = BCS:GetPlayerAura(L["Spell hit chance increased by (%d+)%%."])
	if hitFromAura then
		hit = hit + tonumber(hitFromAura)
	end

	Hit_Schools["Affliction"] = afflictionHit
	Hit_Schools["Arcane"] = arcaneHit
	Hit_Schools["Destruction"] = destructionHit
	Hit_Schools["Fire"] = fireHit
	Hit_Schools["Frost"] = frostHit
	Hit_Schools["Holy"] = holyHit
	Hit_Schools["Nature"] = natureHit
	Hit_Schools["Shadow"] = shadowHit
	Hit_Schools["Taunt"] = tauntHit

	return hit, Hit_Schools
	
end

local Cache_GetCritChance_SpellID, Cache_GetCritChance_BookType, Cache_GetCritChance_Line
local Cache_GetCritChance_Tab, Cache_GetCritChance_Talent
function BCS:GetCritChance()
	local crit = 0
	local axeCrit = 0
	local daggerCrit = 0
	local fistCrit = 0
	local polearmCrit = 0
	local Crit_Schools = {}
	local _, class = UnitClass('player')

	-- scan talents
	local MAX_TABS = GetNumTalentTabs()
	
	for tab=1, MAX_TABS do
		local MAX_TALENTS = GetNumTalents(tab)		
		
		for talent=1, MAX_TALENTS do
			BCS_Tooltip:SetTalent(tab, talent)
			local MAX_LINES = BCS_Tooltip:NumLines()			
			
			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				
				if left:GetText() then
					-- Hunter
					-- ! Talent name?
					local _,_, value = strfind(left:GetText(), L["Increases your critical strike chance with all attacks by (%d)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						crit = crit + tonumber(value)
						line = MAX_LINES
					end

					-- Warrior
					-- Polearm Specialization
					local _,_, value = strfind(left:GetText(), L["Increases your chance to get a critical strike with Axes and Polearms by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						axeCrit = axeCrit + tonumber(value)
						polearmCrit = polearmCrit + tonumber(value)
						line = MAX_LINES
					end

					-- Rogue
					-- Close Quarters Combat 
					local _,_, value = strfind(left:GetText(), L["Increases your chance to get a critical strike with Axe, Fist and Dagger weapons by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						axeCrit = axeCrit + tonumber(value)
						daggerCrit = daggerCrit + tonumber(value)
						fistCrit = fistCrit + tonumber(value)
						line = MAX_LINES
					end

					-- General check?
					local _,_, value = strfind(left:GetText(), L["Increases your critical strike chance with all attacks by (%d)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						crit = crit + tonumber(value)
						line = MAX_LINES
					end					
				end				
			end			
		end
	end
	
	-- speedup
	if Cache_GetCritChance_SpellID and Cache_GetCritChance_BookType and Cache_GetCritChance_Line then
		BCS_Tooltip:SetSpell(Cache_GetCritChance_SpellID, Cache_GetCritChance_BookType)
		local left = getglobal(BCS_Prefix .. "TextLeft" .. Cache_GetCritChance_Line)
		if left:GetText() then
			local _,_, value = strfind(left:GetText(), L["([%d.]+)%% chance to crit"])
			if value then
				crit = crit + tonumber(value)
			end
		end
		
		return crit
	end
	
	local MAX_TABS = GetNumSpellTabs()

	for tab=1, MAX_TABS do
		local name, texture, offset, numSpells = GetSpellTabInfo(tab)
		
		for spell=1, numSpells do
			local currentPage = ceil(spell/SPELLS_PER_PAGE)
			local SpellID = spell + offset + ( SPELLS_PER_PAGE * (currentPage - 1))

			BCS_Tooltip:SetSpell(SpellID, BOOKTYPE_SPELL)
			local MAX_LINES = BCS_Tooltip:NumLines()
			
			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L["([%d.]+)%% chance to crit"])
					if value then
						crit = crit + tonumber(value)
						
						Cache_GetCritChance_SpellID = SpellID
						Cache_GetCritChance_BookType = BOOKTYPE_SPELL
						Cache_GetCritChance_Line = line
						
						line = MAX_LINES
						spell = numSpells
						tab = MAX_TABS
					end
				end
			end
			
		end
	end

	Crit_Schools["Axe"] = axeCrit
	Crit_Schools["Dagger"] = daggerCrit
	Crit_Schools["Fist Weapon"] = fistCrit
	Crit_Schools["Polearm"] = polearmCrit

	return crit, Crit_Schools
end

local Cache_GetRangedCritChance_Tab, Cache_GetRangedCritChance_Talent, Cache_GetRangedCritChance_Line
function BCS:GetRangedCritChance()
	local crit = BCS:GetCritChance()
	
	if Cache_GetRangedCritChance_Tab and Cache_GetRangedCritChance_Talent and Cache_GetRangedCritChance_Line then
		BCS_Tooltip:SetTalent(Cache_GetRangedCritChance_Tab, Cache_GetRangedCritChance_Talent)
		local left = getglobal(BCS_Prefix .. "TextLeft" .. Cache_GetRangedCritChance_Line)
		
		if left:GetText() then
			local _,_, value = strfind(left:GetText(), L["Increases your critical strike chance with ranged weapons by (%d)%%."])
			local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(Cache_GetRangedCritChance_Tab, Cache_GetRangedCritChance_Talent)
			if value and rank > 0 then
				crit = crit + tonumber(value)
			end
		end
	
		return crit
	end
	
	local MAX_TABS = GetNumTalentTabs()
	
	for tab=1, MAX_TABS do
		local MAX_TALENTS = GetNumTalents(tab)
		
		for talent=1, MAX_TALENTS do
			BCS_Tooltip:SetTalent(tab, talent);
			local MAX_LINES = BCS_Tooltip:NumLines()
			
			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L["Increases your critical strike chance with ranged weapons by (%d)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						crit = crit + tonumber(value)
						
						line = MAX_LINES
						talent = MAX_TALENTS
						tab = MAX_TABS
					end
				end
			end
			
		end
	end
	
	return crit
end

function BCS:GetSpellCritChance()
	local Crit_Set_Bonus = {}
	local spellCrit = 0
	local arcaneCrit = 0
	local fireCrit = 0
	local frostCrit = 0
	local holyCrit = 0
	local natureCrit = 0
	local shadowCrit = 0
	local destructionCrit = 0
	local offensiveCrit = 0
	local shockCrit = 0

	local allCritDamage = 0
	local destructionCritDamage = 0
	local fireCritDamage = 0
	local frostCritDamage = 0
	local holyCritDamage = 0
	local natureCritDamage = 0
	local offensiveCritDamage = 0
	local firetotemCritDamage = 0

	local _, intellect = UnitStat("player", 4)
	local _, class = UnitClass("player")
	local Crit_Schools = {}
	local Crit_Damage_Schools = {}
	
	-- values from theorycraft / http://wow.allakhazam.com/forum.html?forum=21&mid=1157230638252681707
	if class == "MAGE" then
		spellCrit = 0.2 + (intellect / 59.5)
	elseif class == "WARLOCK" then
		spellCrit = 1.7 + (intellect / 60.6)
	elseif class == "PRIEST" then
		spellCrit = 0.8 + (intellect / 59.56)
	elseif class == "DRUID" then
		spellCrit = 1.8 + (intellect / 60)
	elseif class == "SHAMAN" then
		spellCrit = 1.8 + (intellect / 59.2)
	-- ! Check if Paladin is correct
	elseif class == "PALADIN" then
		spellCrit = intellect / 29.5
	end
	
	local MAX_INVENTORY_SLOTS = 19
	
	-- items
	for slot=0, MAX_INVENTORY_SLOTS do
		local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
		
		if hasItem then
			local SET_NAME = nil
			
			for line=1, BCS_Tooltip:NumLines() do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)

				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L["Equip: Improves your chance to get a critical strike with spells by (%d)%%."])
					if value then
						spellCrit = spellCrit + tonumber(value)
					end

					local _,_, value = strfind(left:GetText(), L["Equip: Improves your critical strike chance for all attacks and spells by (%d)%%."])
					if value then
						spellCrit = spellCrit + tonumber(value)
					end

					_,_, value = strfind(left:GetText(), L["Increases the critical effect chance of your Arcane spells by (%d+)%%."])
					if value then
						arcaneCrit = arcaneCrit + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["Improves your chance to get a critical strike with Arcane spells by (%d+)%%."])
					if value then
						arcaneCrit = arcaneCrit + tonumber(value)
					end

					_, _, value = strfind(left:GetText(), L["Increases the critical effect chance of your Fire spells by (%d+)%%."])
					if value then
						fireCrit = fireCrit + tonumber(value)
					end
					_, _, value = strfind(left:GetText(), L["Improves your chance to get a critical strike with Fire spells by (%d+)%%."])
					if value then
						fireCrit = fireCrit + tonumber(value)
					end

					_, _, value = strfind(left:GetText(), L["Increases the critical effect chance of your Frost spells by (%d+)%%."])
					if value then
						frostCrit = frostCrit + tonumber(value)
					end
					_, _, value = strfind(left:GetText(), L["Improves your chance to get a critical strike with Frost spells by (%d+)%%."])
					if value then
						frostCrit = frostCrit + tonumber(value)
					end
					
					_, _, value = strfind(left:GetText(), L["Increases the critical effect chance of your Holy spells by (%d+)%%."])
					if value then
						holyCrit = holyCrit + tonumber(value)
					end
					_, _, value = strfind(left:GetText(), L["Improves your chance to get a critical strike with Holy spells by (%d+)%%."])
					if value then
						holyCrit = holyCrit + tonumber(value)
					end
					
					_, _, value = strfind(left:GetText(), L["Increases the critical effect chance of your Nature spells by (%d+)%%."])
					if value then
						natureCrit = natureCrit + tonumber(value)
					end
					_, _, value = strfind(left:GetText(), L["Improves your chance to get a critical strike with Nature spells by (%d+)%%."])
					if value then
						natureCrit = natureCrit + tonumber(value)
					end
					
					_, _, value = strfind(left:GetText(), L["Increases the critical effect chance of your Shadow spells by (%d+)%%."])
					if value then
						shadowCrit = shadowCrit + tonumber(value)
					end
					_, _, value = strfind(left:GetText(), L["Improves your chance to get a critical strike with Shadow spells by (%d+)%%."])
					if value then
						shadowCrit = shadowCrit + tonumber(value)
					end					
					
					_,_, value = strfind(left:GetText(), "(.+) %(%d/%d%)")
					if value then
						SET_NAME = value
					end

					_, _, value = strfind(left:GetText(), L["^Set: Improves your chance to get a critical strike with spells by (%d)%%."])
					if value and SET_NAME and not tContains(Crit_Set_Bonus, SET_NAME) then
						tinsert(Crit_Set_Bonus, SET_NAME)
						spellCrit = spellCrit + tonumber(value)
					end

					_, _, value = strfind(left:GetText(), L["^Set: Improves your critical strike chance for all attacks and spells by (%d)%%."])
					if value and SET_NAME and not tContains(Crit_Set_Bonus, SET_NAME) then
						tinsert(Crit_Set_Bonus, SET_NAME)
						spellCrit = spellCrit + tonumber(value)
					end

				end
			end
		end
		
	end

	-- buffs
	local _, _, critFromAura = BCS:GetPlayerAura(L["Chance for a critical hit with a spell increased by (%d+)%%."])
	if critFromAura then
		spellCrit = spellCrit + tonumber(critFromAura)
	end
	_, _, critFromAura = BCS:GetPlayerAura(L["While active, target's critical hit chance with spells and attacks increases by 10%%."])
	if critFromAura then
		spellCrit = spellCrit + 10
	end
	_, _, critFromAura = BCS:GetPlayerAura(L["Increases chance for a melee, ranged, or spell critical by (%d+)%% and all attributes by %d+."])
	if critFromAura then
		spellCrit = spellCrit + tonumber(critFromAura)
	end
	critFromAura = BCS:GetPlayerAura(L["Increases critical chance of spells by 10%%, melee and ranged by 5%% and grants 140 attack power. 120 minute duration."])
	if critFromAura then
		spellCrit = spellCrit + 10
	end
	_, _, critFromAura = BCS:GetPlayerAura(L["Critical strike chance with spells and melee attacks increased by (%d+)%%."])
	if critFromAura then
		spellCrit = spellCrit + tonumber(critFromAura)
	end
	if critFromAura then
		spellCrit = spellCrit + tonumber(critFromAura)
	end
	_, _, critFromAura = BCS:GetPlayerAura(L["Spell critical chance increased by (%d+)%%."])
	if critFromAura then
		spellCrit = spellCrit + tonumber(critFromAura)
	end

	-- debuffs
	_, _, _, critFromAura = BCS:GetPlayerAura(L["Melee critical-hit chance reduced by (%d+)%%.\r\nSpell critical-hit chance reduced by (%d+)%%."], 'HARMFUL')
	if critFromAura then
		spellCrit = spellCrit - tonumber(critFromAura)
	end

	-- scan talents
	local MAX_TABS = GetNumTalentTabs()
	
	for tab=1, MAX_TABS do
		local MAX_TALENTS = GetNumTalents(tab)
		
		for talent=1, MAX_TALENTS do
			BCS_Tooltip:SetTalent(tab, talent)
			local MAX_LINES = BCS_Tooltip:NumLines()

			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				if left:GetText() then
					-- Druid
					-- Vengeance
					_,_, value, value2 = strfind(left:GetText(), L["Increases the critical strike damage bonus of your offensive spells by (%d+)%% and for your feral abilities by (%d+)%%d."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						offensiveCritDamage = offensiveCritDamage + tonumber(value)
						line = MAX_LINES
					end	
				
					-- Mage
					-- Arcane Instability
					_,_, value = strfind(left:GetText(), L["Increases your spell damage and critical strike chance by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						spellCrit = spellCrit + tonumber(value)
						line = MAX_LINES
					end	

					-- Mage
					-- Arcane Wrath
					_,_, value = strfind(left:GetText(), L["Increases the critical strike damage bonus of your spells by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						allCritDamage = allCritDamage + tonumber(value)
						line = MAX_LINES
					end	

					-- Mage
					-- Critical Mass
					_,_, value = strfind(left:GetText(), L["Increases the critical strike chance of your Fire spells by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						fireCrit = fireCrit + tonumber(value)
						line = MAX_LINES
					end	

					-- Mage
					-- Ice Shards
					_,_, value = strfind(left:GetText(), L["Increases the critical strike damage bonus of your Frost spells by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						frostCritDamage = frostCritDamage + tonumber(value)
						line = MAX_LINES
					end	

					-- Mage 
					-- Lord of the North Wind
					_,_, value, value2 = strfind(left:GetText(), L["Increases the critical strike chance of your Frost spells by (%d+)%% and the chance you are hit by melee and ranged attacks reduced by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						frostCrit = frostCrit + tonumber(value)
						line = MAX_LINES
					end	

					-- Mage
					-- Overheat
					_,_, value, value2 = strfind(left:GetText(), L["Improves your chance to get a critical strike with spells by (%d+)%%, but increases the threat generated by your critical hits by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						spellCrit = spellCrit + tonumber(value)
						line = MAX_LINES
					end	

					-- Priest
					-- Holy Specialization
					_,_, value = strfind(left:GetText(), L["Increases the critical effect chance of your Holy spells by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						holyCrit = holyCrit + tonumber(value)
						line = MAX_LINES
					end

					-- Priest
					-- Force of Will
					_,_, value, value2 = strfind(left:GetText(), L["^Increases your spell damage by (%d+)%% and the critical strike chance of your offensive spells by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value2 and rank > 0 then
						offensiveCrit = offensiveCrit + tonumber(value2)
						line = MAX_LINES
					end

					-- Priest
					-- Purifying Light
					_,_, value, value2 = strfind(left:GetText(), L["Increases the critical strike damage bonus of your Holy spells by (%d+)%% and increases damage dealt to Undead or Demons by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						holyCritDamage = holyCritDamage + tonumber(value)
						line = MAX_LINES
					end

					-- Paladin
					-- Conviction					
					_,_, value = strfind(left:GetText(), L["Increases your chance to get a critical strike with attacks and offensive spells by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						offensiveCrit = offensiveCrit + tonumber(value)
						line = MAX_LINES
					end

					-- Shaman
					-- Elemental Fury
					_,_, value = strfind(left:GetText(), L["Increases the critical strike damage bonus of your Searing, Magma, and Fire Nova Totems, and your Fire, Frost and Nature spells by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						fireCritDamage = fireCritDamage + tonumber(value)
						frostCritDamage = frostCritDamage + tonumber(value)
						natureCritDamage = natureCritDamage + tonumber(value)
						firetotemCritDamage = firetotemCritDamage + tonumber(value)
						line = MAX_LINES
					end

					-- Shaman
					-- Thundering Strikes
					_,_, value = strfind(left:GetText(), L["Improves your chance to get a critical strike with your weapon attacks and Shock spells by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						shockCrit = shockCrit + tonumber(value)
						line = MAX_LINES
					end

					-- Warlock
					-- Devastation					
					_,_, value = strfind(left:GetText(), L["Increases the critical strike chance of your Destruction spells by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						destructionCrit = destructionCrit + tonumber(value)
						line = MAX_LINES
					end

					-- Warlock
					-- Ruin					
					_,_, value = strfind(left:GetText(), L["Increases the critical strike damage bonus of your Destruction spells by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						destructionCritDamage = destructionCritDamage + tonumber(value)
						line = MAX_LINES
					end
				end
			end		

		end	
	end

	Crit_Schools["Arcane"] = arcaneCrit
	Crit_Schools["Destruction"] = destructionCrit
	Crit_Schools["Fire"] = fireCrit
	Crit_Schools["Frost"] = frostCrit
	Crit_Schools["Holy"] = holyCrit
	Crit_Schools["Nature"] = natureCrit
	Crit_Schools["Shadow"] = shadowCrit
	Crit_Schools["Shock"] = shockCrit
	Crit_Schools["Offensive"] = offensiveCrit
	
	Crit_Damage_Schools["All"] = allCritDamage
	Crit_Damage_Schools["Destruction"] = destructionCritDamage
	Crit_Damage_Schools["Fire"] = fireCritDamage
	Crit_Damage_Schools["Frost"] = frostCritDamage
	Crit_Damage_Schools["Holy"] = holyCritDamage
	Crit_Damage_Schools["Nature"] = natureCritDamage
	Crit_Damage_Schools["Offensive"] = offensiveCritDamage
	Crit_Damage_Schools["Fire Totems"] = firetotemCritDamage

	return spellCrit, Crit_Schools, Crit_Damage_Schools
end

function BCS:GetSpellPower()
	local spellPower = UnitStat("player",4) * (1/3);
	local arcanePower = 0;
	local firePower = 0;
	local frostPower = 0;
	local holyPower = 0;
	local naturePower = 0;
	local shadowPower = 0;
	local damagePower = 0;
	
	local MAX_INVENTORY_SLOTS = 19
	local SpellPower_Set_Bonus = {}
	local SpellPower_Schools = {}
	
	for slot=0, MAX_INVENTORY_SLOTS do
		local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
		
		if hasItem then
			local SET_NAME
			
			for line=1, BCS_Tooltip:NumLines() do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L["Equip: Increases damage and healing done by magical spells and effects by up to (%d+)."])
					if value then
						spellPower = spellPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["Spell Damage %+(%d+)"])
					if value then
						spellPower = spellPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["^%+(%d+) Spell Damage and Healing"])
					if value then
						spellPower = spellPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["^%+(%d+) Damage and Healing Spells"])
					if value then
						spellPower = spellPower + tonumber(value)
					end
					
					_,_, value = strfind(left:GetText(), L["Equip: Increases damage done by Arcane spells and effects by up to (%d+)."])
					if value then
						arcanePower = arcanePower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["^%+(%d+) Arcane Spell Damage"])
					if value then
						arcanePower = arcanePower + tonumber(value)
					end
					
					_,_, value = strfind(left:GetText(), L["Equip: Increases damage done by Fire spells and effects by up to (%d+)."])
					if value then
						firePower = firePower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["Fire Damage %+(%d+)"])
					if value then
						firePower = firePower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["^%+(%d+) Fire Spell Damage"])
					if value then
						firePower = firePower + tonumber(value)
					end
					
					_,_, value = strfind(left:GetText(), L["Equip: Increases damage done by Frost spells and effects by up to (%d+)."])
					if value then
						frostPower = frostPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["Frost Damage %+(%d+)"])
					if value then
						frostPower = frostPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["^%+(%d+) Frost Spell Damage"])
					if value then
						frostPower = frostPower + tonumber(value)
					end
					
					_,_, value = strfind(left:GetText(), L["Equip: Increases damage done by Holy spells and effects by up to (%d+)."])
					if value then
						holyPower = holyPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["^%+(%d+) Holy Spell Damage"])
					if value then
						holyPower = holyPower + tonumber(value)
					end
					
					_,_, value = strfind(left:GetText(), L["Equip: Increases damage done by Nature spells and effects by up to (%d+)."])
					if value then
						naturePower = naturePower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["^%+(%d+) Nature Spell Damage"])
					if value then
						naturePower = naturePower + tonumber(value)
					end
					
					_,_, value = strfind(left:GetText(), L["Equip: Increases damage done by Shadow spells and effects by up to (%d+)."])
					if value then
						shadowPower = shadowPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["Shadow Damage %+(%d+)"])
					if value then
						shadowPower = shadowPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["^%+(%d+) Shadow Spell Damage"])
					if value then
						shadowPower = shadowPower + tonumber(value)
					end	
					
					-- Priest AC Trinket
					_,_, value = strfind(left:GetText(), L["^Equip: Increases spell damage by up to (%d+)%% of your total Intellect and healing done by up to (%d+)%% of your total Spirit."])
					if value then
						local effectiveStat = UnitStat("player", 4)
						spellPower = spellPower + floor(((tonumber(value) / 100) * effectiveStat))
					end
	
					_,_, value = strfind(left:GetText(), "(.+) %(%d/%d%)")
					if value then
						SET_NAME = value
					end
					
					_, _, value = strfind(left:GetText(), L["^Set: Increases damage and healing done by magical spells and effects by up to (%d+)%."])
					if value and SET_NAME and not tContains(SpellPower_Set_Bonus, SET_NAME) then
						tinsert(SpellPower_Set_Bonus, SET_NAME)
						spellPower = spellPower + tonumber(value)
					end
					
				end
			end
		end
	end

	-- scan talents
	local MAX_TABS = GetNumTalentTabs()
	
	for tab=1, MAX_TABS do
		local MAX_TALENTS = GetNumTalents(tab)		
		
		for talent=1, MAX_TALENTS do
			BCS_Tooltip:SetTalent(tab, talent)
			local MAX_LINES = BCS_Tooltip:NumLines()			
			
			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				
				if left:GetText() then
					-- Priest / Druid / Shaman 
					-- Spiritual Guidance / Animism / Nature Spirit
					local _,_, value = strfind(left:GetText(), L["Increases spell damage and healing by up to (%d+)%% of your total Spirit."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						local stat, effectiveStat = UnitStat("player", 5)
						spellPower = spellPower + floor(((tonumber(value) / 100) * effectiveStat))
						line = MAX_LINES
					end

					-- Paladin
					-- Crusade
					local _,_, value = strfind(left:GetText(), L["Increases spell damage and healing by up to (%d+)%% of your total Strength."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						local stat, effectiveStat = UnitStat("player", 1)
						spellPower = spellPower + floor(((tonumber(value) / 100) * effectiveStat))
						line = MAX_LINES
					end
				end				
			end
			
		end
	end

	-- Shaman Enchants
	local enchantDamage, _ = BCS:GetWeaponEnchant()
	damagePower = damagePower + enchantDamage

	local _, _, spellPowerFromAura = BCS:GetPlayerAura(L["Magical damage dealt is increased by up to (%d+)."])
	if spellPowerFromAura then
		spellPower = spellPower + tonumber(spellPowerFromAura)
		damagePower = damagePower + tonumber(spellPowerFromAura)
	end
	
	SpellPower_Schools["Holy"] = math.floor(holyPower);
	SpellPower_Schools["Fire"] = math.floor(firePower);
	SpellPower_Schools["Nature"] = math.floor(naturePower);
	SpellPower_Schools["Frost"] = math.floor(frostPower);
	SpellPower_Schools["Shadow"] = math.floor(shadowPower);
	SpellPower_Schools["Arcane"] = math.floor(arcanePower);
	
	return math.floor(spellPower), SpellPower_Schools, math.floor(damagePower)
end

--! Deprecated
--[[function BCS:GetSpellPower_old(school)
	if school then
		if not L["Equip: Increases damage done by "..school.." spells and effects by up to (%d+)."] then return -1 end
		local spellPower = 0;
		local MAX_INVENTORY_SLOTS = 19
		
		for slot=0, MAX_INVENTORY_SLOTS do
			local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
			
			if hasItem then
				for line=1, BCS_Tooltip:NumLines() do
					local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
					
					if left:GetText() then
						local _,_, value = strfind(left:GetText(), L["Equip: Increases damage done by "..school.." spells and effects by up to (%d+)."])
						if value then
							spellPower = spellPower + tonumber(value)
						end
						if L[school.." Damage %+(%d+)"] then
							_,_, value = strfind(left:GetText(), L[school.." Damage %+(%d+)"])
							if value then
								spellPower = spellPower + tonumber(value)
							end
						end
						if L["^%+(%d+) "..school.." Spell Damage"] then
							_,_, value = strfind(left:GetText(), L["^%+(%d+) "..school.." Spell Damage"])
							if value then
								spellPower = spellPower + tonumber(value)
							end
						end
					end
				end
			end
			
		end
		
		return math.floor(spellPower)
	else
		local spellPower = 0 + UnitStat("player",4)*0.33;
		local arcanePower = spellPower;
		local firePower = spellPower;
		local frostPower = spellPower;
		local holyPower = spellPower;
		local naturePower = spellPower;
		local shadowPower = spellPower;
		local damagePower = spellPower;
		local MAX_INVENTORY_SLOTS = 19
		
		local SpellPower_Set_Bonus = {}
		
		-- scan gear
		for slot=0, MAX_INVENTORY_SLOTS do
			local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
			
			if hasItem then
				local SET_NAME
				
				for line=1, BCS_Tooltip:NumLines() do
					local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
					
					if left:GetText() then
						local _,_, value = strfind(left:GetText(), L["Equip: Increases damage and healing done by magical spells and effects by up to (%d+)."])
						if value then
							spellPower = spellPower + tonumber(value)
						end
						_,_, value = strfind(left:GetText(), L["Spell Damage %+(%d+)"])
						if value then
							spellPower = spellPower + tonumber(value)
						end
						_,_, value = strfind(left:GetText(), L["^%+(%d+) Spell Damage and Healing"])
						if value then
							spellPower = spellPower + tonumber(value)
						end
						_,_, value = strfind(left:GetText(), L["^%+(%d+) Damage and Healing Spells"])
						if value then
							spellPower = spellPower + tonumber(value)
						end
						
						_,_, value = strfind(left:GetText(), L["Equip: Increases damage done by Arcane spells and effects by up to (%d+)."])
						if value then
							arcanePower = arcanePower + tonumber(value)
						end
						_,_, value = strfind(left:GetText(), L["^%+(%d+) Arcane Spell Damage"])
						if value then
							arcanePower = arcanePower + tonumber(value)
						end
						
						_,_, value = strfind(left:GetText(), L["Equip: Increases damage done by Fire spells and effects by up to (%d+)."])
						if value then
							firePower = firePower + tonumber(value)
						end
						_,_, value = strfind(left:GetText(), L["Fire Damage %+(%d+)"])
						if value then
							firePower = firePower + tonumber(value)
						end
						_,_, value = strfind(left:GetText(), L["^%+(%d+) Fire Spell Damage"])
						if value then
							firePower = firePower + tonumber(value)
						end
						
						_,_, value = strfind(left:GetText(), L["Equip: Increases damage done by Frost spells and effects by up to (%d+)."])
						if value then
							frostPower = frostPower + tonumber(value)
						end
						_,_, value = strfind(left:GetText(), L["Frost Damage %+(%d+)"])
						if value then
							frostPower = frostPower + tonumber(value)
						end
						_,_, value = strfind(left:GetText(), L["^%+(%d+) Frost Spell Damage"])
						if value then
							frostPower = frostPower + tonumber(value)
						end
						
						_,_, value = strfind(left:GetText(), L["Equip: Increases damage done by Holy spells and effects by up to (%d+)."])
						if value then
							holyPower = holyPower + tonumber(value)
						end
						_,_, value = strfind(left:GetText(), L["^%+(%d+) Holy Spell Damage"])
						if value then
							holyPower = holyPower + tonumber(value)
						end
						
						_,_, value = strfind(left:GetText(), L["Equip: Increases damage done by Nature spells and effects by up to (%d+)."])
						if value then
							naturePower = naturePower + tonumber(value)
						end
						_,_, value = strfind(left:GetText(), L["^%+(%d+) Nature Spell Damage"])
						if value then
							naturePower = naturePower + tonumber(value)
						end
						
						_,_, value = strfind(left:GetText(), L["Equip: Increases damage done by Shadow spells and effects by up to (%d+)."])
						if value then
							shadowPower = shadowPower + tonumber(value)
						end
						_,_, value = strfind(left:GetText(), L["Shadow Damage %+(%d+)"])
						if value then
							shadowPower = shadowPower + tonumber(value)
						end
						_,_, value = strfind(left:GetText(), L["^%+(%d+) Shadow Spell Damage"])
						if value then
							shadowPower = shadowPower + tonumber(value)
						end
						
						_,_, value = strfind(left:GetText(), "(.+) %(%d/%d%)")
						if value then
							SET_NAME = value
						end

						_, _, value = strfind(left:GetText(), L["^Set: Increases damage and healing done by magical spells and effects by up to (%d+)%."])
						if value and SET_NAME and not tContains(SpellPower_Set_Bonus, SET_NAME) then
							tinsert(SpellPower_Set_Bonus, SET_NAME)
							spellPower = spellPower + tonumber(value)
						end
						
					end
				end
			end
			
		end
		
		-- scan talents
		local MAX_TABS = GetNumTalentTabs()
		
		for tab=1, MAX_TABS do
			local MAX_TALENTS = GetNumTalents(tab)
			
			for talent=1, MAX_TALENTS do
				BCS_Tooltip:SetTalent(tab, talent)
				local MAX_LINES = BCS_Tooltip:NumLines()
				
				for line=1, MAX_LINES do
					local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
					if left:GetText() then
						-- Priest
						-- Spiritual Guidance
						local _,_, value = strfind(left:GetText(), L["^Increases spell damage and healing by up to (%d+)%% of your total Spirit."])
						local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
						if value and rank > 0 then
							local stat, effectiveStat = UnitStat("player", 5)
							spellPower = spellPower + floor(((tonumber(value) / 100) * effectiveStat))
							
							-- nothing more is currenlty supported, break out of the loops
							line = MAX_LINES
							talent = MAX_TALENTS
							tab = MAX_TABS
						end
					end	
				end
				
			end
		end
		
		-- buffs
		local _, _, spellPowerFromAura = BCS:GetPlayerAura(L["Magical damage dealt is increased by up to (%d+)."])
		if spellPowerFromAura then
			spellPower = spellPower + tonumber(spellPowerFromAura)
			damagePower = damagePower + tonumber(spellPowerFromAura)
		end
		
		local secondaryPower = 0
		local secondaryPowerName = ""
		
		if arcanePower > secondaryPower then
			secondaryPower = arcanePower
			secondaryPowerName = L.SPELL_SCHOOL_ARCANE
		end
		if firePower > secondaryPower then
			secondaryPower = firePower
			secondaryPowerName = L.SPELL_SCHOOL_FIRE
		end
		if frostPower > secondaryPower then
			secondaryPower = frostPower
			secondaryPowerName = L.SPELL_SCHOOL_FROST
		end
		if holyPower > secondaryPower then
			secondaryPower = holyPower
			secondaryPowerName = L.SPELL_SCHOOL_HOLY
		end
		if naturePower > secondaryPower then
			secondaryPower = naturePower
			secondaryPowerName = L.SPELL_SCHOOL_NATURE
		end
		if shadowPower > secondaryPower then
			secondaryPower = shadowPower
			secondaryPowerName = L.SPELL_SCHOOL_SHADOW
		end
		
		return math.floor(spellPower), secondaryPower, secondaryPowerName, damagePower
	end
end]]

function BCS:GetHealingPower()
	local healPower = 0;
	local healPower_Set_Bonus = {}
	local MAX_INVENTORY_SLOTS = 19
	
	for slot=0, MAX_INVENTORY_SLOTS do
		local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
		
		if hasItem then
			local SET_NAME
			
			for line=1, BCS_Tooltip:NumLines() do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L["Equip: Increases healing done by spells and effects by up to (%d+)."])
					if value then
						healPower = healPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["Healing Spells %+(%d+)"])
					if value then
						healPower = healPower + tonumber(value)
					end
					_,_, value = strfind(left:GetText(), L["^%+(%d+) Healing Spells"])
					if value then
						healPower = healPower + tonumber(value)
					end

					-- Priest AC Trinket
					_,_, value, value2 = strfind(left:GetText(), L["^Equip: Increases spell damage by up to (%d+)%% of your total Intellect and healing done by up to (%d+)%% of your total Spirit."])
					if value then
						local effectiveStatInt, effectiveStatSpirit = UnitStat("player", 4), UnitStat("player", 5)
						healPower = healPower - floor(((tonumber(value) / 100) * effectiveStatInt))
						healPower = healPower + floor(((tonumber(value2) / 100) * effectiveStatSpirit))
					end
					
					_,_, value = strfind(left:GetText(), "(.+) %(%d/%d%)")
					if value then
						SET_NAME = value
					end
					_, _, value = strfind(left:GetText(), L["^Set: Increases healing done by spells and effects by up to (%d+)%."])
					if value and SET_NAME and not tContains(healPower_Set_Bonus, SET_NAME) then
						tinsert(healPower_Set_Bonus, SET_NAME)
						healPower = healPower + tonumber(value)
					end
				end
			end
		end
		
	end
	
	-- buffs
	local _, _, healPowerFromAura = BCS:GetPlayerAura(L["Healing done by magical spells is increased by up to (%d+)."])
	if healPowerFromAura then
		healPower = healPower + tonumber(healPowerFromAura)
	end

	-- enchants
	local _, enchantHealing = BCS:GetWeaponEnchant()
	healPower = healPower + enchantHealing
		
	-- Edited from return healPower
	return math.floor(healPower)
end
--[[
-- server\src\game\Object\Player.cpp
float Player::OCTRegenMPPerSpirit()
{
    float addvalue = 0.0;

    float Spirit = GetStat(STAT_SPIRIT);
    uint8 Class = getClass();

    switch (Class)
    {
        case CLASS_DRUID:   addvalue = (Spirit / 5 + 15);   break;
        case CLASS_HUNTER:  addvalue = (Spirit / 5 + 15);   break;
        case CLASS_MAGE:    addvalue = (Spirit / 4 + 12.5); break;
        case CLASS_PALADIN: addvalue = (Spirit / 5 + 15);   break;
        case CLASS_PRIEST:  addvalue = (Spirit / 4 + 12.5); break;
        case CLASS_SHAMAN:  addvalue = (Spirit / 5 + 17);   break;
        case CLASS_WARLOCK: addvalue = (Spirit / 5 + 15);   break;
    }

    addvalue /= 2.0f;   // the above addvalue are given per tick which occurs every 2 seconds, hence this divide by 2

    return addvalue;
}

void Player::UpdateManaRegen()
{
    // Mana regen from spirit
    float power_regen = OCTRegenMPPerSpirit();
    // Apply PCT bonus from SPELL_AURA_MOD_POWER_REGEN_PERCENT aura on spirit base regen
    power_regen *= GetTotalAuraMultiplierByMiscValue(SPELL_AURA_MOD_POWER_REGEN_PERCENT, POWER_MANA);

    // Mana regen from SPELL_AURA_MOD_POWER_REGEN aura
    float power_regen_mp5 = GetTotalAuraModifierByMiscValue(SPELL_AURA_MOD_POWER_REGEN, POWER_MANA) / 5.0f;

    // Set regen rate in cast state apply only on spirit based regen
    int32 modManaRegenInterrupt = GetTotalAuraModifier(SPELL_AURA_MOD_MANA_REGEN_INTERRUPT);
    if (modManaRegenInterrupt > 100)
        { modManaRegenInterrupt = 100; }

    m_modManaRegenInterrupt = power_regen_mp5 + power_regen * modManaRegenInterrupt / 100.0f;

    m_modManaRegen = power_regen_mp5 + power_regen;
}
]]

local function GetRegenMPPerSpirit()
	local addvalue = 0
	
	local stat, Spirit, posBuff, negBuff = UnitStat("player", 5)
	local lClass, class = UnitClass("player")
	
	if class == "DRUID" then
		addvalue = (Spirit / 5 + 15)
	elseif class == "HUNTER" then
		addvalue = (Spirit / 5 + 15)
	elseif class == "MAGE" then
		addvalue = (Spirit / 4 + 12.5)
	elseif class == "PALADIN" then
		addvalue = (Spirit / 5 + 15)
	elseif class == "PRIEST" then
		addvalue = (Spirit / 4 + 12.5)
	elseif class == "SHAMAN" then
		addvalue = (Spirit / 5 + 17)
	elseif class == "WARLOCK" then
		addvalue = (Spirit / 5 + 15)
	else
		return addvalue
	end
	return addvalue
end

--FUNC used in conjunction with GetGearSetBonus (Ten Storms ***NOT IMPLEMENTED YET***) to help facilitate SNAPSHOT /w Mana Spring Totem & Ranks 1-4 update tooltip
function BCS:UpdateManaSpringTotem()
	-- Get current Mana Spring Totem value from tooltip
	local currentMsTVal = BCS:GetPlayerAuraValue("Gain (%d+) mana every 2 seconds.")
	
	-- If the buff is gone, reset
	if not currentMsTVal or currentMsTVal == 0 then
		lastMsTVal = currentMsTVal
		return 0 -- No buff active
	end
	
	-- Check if this is a differnt rank MsT
	if currentMsTVal ~= lastMsTVal then
		lastMsTVal = currentMsTVal
	end
	
	return lastMsTVal --return last rank (can add snapshot for gear above)
end

--FUNC used in conjunction with GetGearSetBonus (Zaldalar 2pc) to help facilitate SNAPSHOT /w Blessing of Wisdom & Ranks 1-6 update tooltip
function BCS:UpdateBlessingOfWisdom()
    -- Get current BoW MP5 value from tooltip
    local currentBoWMP5 = BCS:GetPlayerAuraValue("Restores (%d+) mana every 5 seconds.")

    -- If the buff is gone, reset MP5 and check for gear bonus
    if not currentBoWMP5 or currentBoWMP5 == 0 then
        lastBlessingOfWisdomMP5 = 0
		lastGearBonus = 1 -- Reset gear bonus since BoW is gone
        --DEFAULT_CHAT_FRAME:AddMessage("Blessing of Wisdom lost! Gear snapshot reset to 100% multiplier, MP5 set to 0.")
        return 0 -- No buff active
    end

    -- Check if this is a fresh BoW application
    if currentBoWMP5 ~= lastBlessingOfWisdomMP5 then
        lastBlessingOfWisdomMP5 = currentBoWMP5
		lastGearBonus = BCS:GetGearSetBonus() -- Snapshot Zandalar gear bonus
        --DEFAULT_CHAT_FRAME:AddMessage("Blessing of Wisdom (Updated): " .. lastBlessingOfWisdomMP5 .. " MP5 | Gear Bonus Snapshot: " .. lastGearBonus)
    end

    return lastBlessingOfWisdomMP5 -- Return current snapshot value
end

--FUNC used to get SNAPSHOT of Gear separated for bonuses even after equiping other gear
function BCS:GetGearSetBonus()
    local gearBonus = 1 -- Default multiplier (100%)

    local MAX_INVENTORY_SLOTS = 19
    for slot = 0, MAX_INVENTORY_SLOTS do
        local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
        if hasItem then
            for line = 1, BCS_Tooltip:NumLines() do
                local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
                if left and left:GetText() then
                    local text = strlower(left:GetText())
                    if strfind(text, "set: increases the effect of all blessings by 10%%") then
                        gearBonus = 1.1 -- Apply the ZG 10% bonus
                        break
                    end
                end
            end
        end
    end

    return gearBonus
end

function BCS:GetManaRegen()
	-- to-maybe-do: apply buffs/talents
	local base, casting
	local power_regen = GetRegenMPPerSpirit()
	
	casting = power_regen / 100
	base = power_regen

	local mp5 = 0					-- Initialize to prevent nil errors
	local paladinManaRegen = 0
	local paladinManaTick = 0

	-- Fetch Updated Blessing of Wisdom Value
    local blessingOfWisdomMP5 = BCS:UpdateBlessingOfWisdom()
	
	-- Default Multiplier
	local divineGraceBonus = 1 -- Default 100% (no modifier)
	
	-- Get player's max mana
	local maxMana = UnitManaMax("player")
	
	-- Check if the Player is a Paladin
    local _, playerClass = UnitClass("player")
	
	-- Scan Talents First (Permanent Bonuses before gear)
	if playerClass == "PALADIN" then
		-- Scan talents
		local MAX_TABS = GetNumTalentTabs()
	
		for tab=1, MAX_TABS do
			local MAX_TALENTS = GetNumTalents(tab)
		
			for talent=1, MAX_TALENTS do
				BCS_Tooltip:SetTalent(tab, talent)
				local MAX_LINES = BCS_Tooltip:NumLines()	
			
				for line=1, MAX_LINES do
					local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				
					if left:GetText() then
						-- Paladin
						-- Divine Concentration
						local _,_, regenInterval = strfind(left:GetText(), "Regenerates 1%% of your total Mana every (%d+) seconds.")
						local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
						if regenInterval and rank > 0 then
							regenInterval = tonumber(regenInterval)
							local regenPercent = 0.01 -- 1% mana
						
							paladinManaTick = floor(maxMana * regenPercent * (2 / regenInterval)) -- 2 sec tick
							paladinManaRegen = floor(maxMana * regenPercent * (5 / regenInterval)) -- MP5 equivalent
							line = MAX_LINES
						end
						
						 -- Divine Grace (Blessing of Wisdom Modifier)
                        local _,_, bonusPercent = strfind(left:GetText(), "Increases the effect of your Seal and Judgement of Light, your Seal and Judgement of Wisdom, your Blessing of Wisdom, and your Blessing of Light by (%d+)%%.")
                        if bonusPercent and rank > 0 then
                            bonusPercent = tonumber(bonusPercent) / 100 --Convert 10% or 20% to 1.1 or 1.2
                            divineGraceBonus = 1 + bonusPercent
                            --DEFAULT_CHAT_FRAME:AddMessage("Divine Grace detected! Bonus: " .. (divineGraceBonus * 100) .. "%")
							line = MAX_LINES
						end
					end
				end
			end
		end
	end
	
	--
	if playerClass == "DRUID" then
		
		local MAX_TABS = GetNumTalentTabs()
		
			for tab=1, MAX_TABS do
				local MAX_TALENTS = GetNumTalents(tab)
				
				for talent=1, MAX_TALENTS do
					BCS_Tooltip:SetTalent(tab, talent)
					local MAX_LINES = BCS_Tooltip:NumLines()
					
					for line=1, MAX_LINES do
						local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
						
						if left:GetText() then
						--Druid
						--Dreamstate
						local _,_, regenPercent = strfind(left:GetText(), "Regenerates (%d+)%% of your total Mana every 10 seconds.")
						local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
						if regenPercent and rank > 0 then
							regenPercent = tonumber(regenPercent) / 100 -- Convert to decimal (1% → 0.01, 2% → 0.02, 3% → 0.03)
							local regenInterval = 10 -- 10 seconds
							
							druidManaTick = floor(maxMana * regenPercent * (2 / regenInterval)) -- 2 sec tick
							druidManaRegen = floor(maxMana * regenPercent * (5 / regenInterval))-- MP5 equivalent
							line = MAX_LINES
						end
					end
				end
			end
		end
	end
	
	--Fetch Updated Mana Spring Totem value
	local manaSpringTotemMP2 = BCS:UpdateManaSpringTotem()
	
	local manaSpringBonus = 1
	
	if playerClass == "SHAMAN" then
		
		local MAX_TABS = GetNumTalentTabs()
		
			for tab=1, MAX_TABS do
				local MAX_TALENTS = GetNumTalents(tab)
				
				for talent=1, MAX_TALENTS do
					BCS_Tooltip:SetTalent(tab, talent)
					local MAX_LINES = BCS_Tooltip:NumLines()
					
					for line=1, MAX_LINES do
						local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
						
						if left:GetText() then
						--Shaman
						--Restorative Totems (Mana Spring Totem Modifier)
						local _,_, bonusPercent = strfind(left:GetText(), "Increases the effect of your Mana Tide, Mana Spring and Healing Stream Totems by (%d+)%%")
						local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
						if bonusPercent and rank > 0 then
							bonusPercent = tonumber(bonusPercent) / 100 --Convert 30% or 50% to 1.3 or 1.5
							manaSpringBonus = 1 + bonusPercent
							--DEFAULT_CHAT_FRAME:AddMessage("Mana Spring Totem Detected! Bonus: " .. (manaSpringBonus * 100) .. "%")
							line = MAX_LINES
						end
					end
				end
			end
		end
	end
	
	-- ***MOVED ZG BONUS TO ITS OWN SNAPSHOT FUNCTION ABOVE BCS:GetGearSetBonus()***
	local MAX_INVENTORY_SLOTS = 19
	
	for slot=0, MAX_INVENTORY_SLOTS do
		local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
		
		if hasItem then
			for line=1, BCS_Tooltip:NumLines() do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				
				-- Ensure 'left' exists and has valid text before using it
				local text = left and left:GetText() or ""
				text = strlower(text) -- Convert to lowercase for better matching
				-- Debugging output
				--DEFAULT_CHAT_FRAME:AddMessage("Scanning Tooltip: " .. text)
				local _,_, value = strfind(text, "^mana regen %+(%d+)")
				if value then
					mp5 = mp5 + tonumber(value)
				end
				
				-- Fix: Directly match lowercase tooltip text
				_,_, value = strfind(text, "equip: restores (%d+) mana per 5 sec%.?")
				if value then
					mp5 = mp5 + tonumber(value)
					-- Debugging output
					--DEFAULT_CHAT_FRAME:AddMessage("Found MP5 from gear: " .. value)
				end
				
				_,_, value = strfind(text, "^%+(%d+) mana every 5 sec%.?")
				if value then
					mp5 = mp5 + tonumber(value)
				end
				
				---- Fix: Match both "heath" (game typo) and "health" (expected)
				_,_, value = strfind(text, "(%d+) hea[lth]+ and mana per 5 sec%.?")
				if value then
					mp5 = mp5 + tonumber(value)
					-- Debugging output
					--DEFAULT_CHAT_FRAME:AddMessage("Found MP5 from enchant: " .. value)				
				end
			end
		end
	end
	-- Apply Bonuses and Maintain Snapshot
    local finalBoWMP5 = floor(blessingOfWisdomMP5 * divineGraceBonus * lastGearBonus)
	--DEFAULT_CHAT_FRAME:AddMessage("Blessing of Wisdom (Displayed MP5): " .. finalBoWMP5)
	
	-- Finalized math fixes here namely Blessing of Wisdom tooltip being off by 1 mana per 5:
	if finalBoWMP5 == 43 then 
		finalBoWMP5 = 42 -- BoW (Rank 6) WoW math fix 43 to 42 rounded down without messing up other correct ranks
	elseif finalBoWMP5 == 33 then
		finalBoWMP5 = 32 -- BoW (Rank 4) WoW math fix 33 to 32 rounded down without messing up other correct ranks
	end
	
	local finalMtSVal = floor(manaSpringTotemMP2 * manaSpringBonus)
	
		-- Can finalize Mana Spring Totem values here for correct ingame rounding in combat log but
		-- I do not have 2 piece Ten Storms on my shaman (contact Luthering or Lokiy and see if
		-- one of them can help you get correct values per rank like you did for BoW).
		-- ***I still have to setup Ten Storms SNAPSHOT too next update will be so.***

	-- buffs (Depreciated CODE --'ed out )
	-- local _, _, mp5FromAura = BCS:GetPlayerAura("Increases hitpoints by 300. Movement, attack and casting speed increased by 5%. 30 mana regen every 5 seconds.")
	--if mp5FromAura then
	--	mp5 = mp5 + 10
	--end
	
	return base, casting, mp5, paladinManaTick, paladinManaRegen, druidManaTick, druidManaRegen, finalBoWMP5, finalMtSVal
end

function BCS:GetResilienceChance()
	local resilience = 0;
	
	local MAX_INVENTORY_SLOTS = 19
	local resilience_Set_Bonus = {}
	
	for slot=0, MAX_INVENTORY_SLOTS do
		local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)

		if hasItem then
			local SET_NAME
			
			for line=1, BCS_Tooltip:NumLines() do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L["(%d+)%% Resilience"])
					if value then
						resilience = resilience + tonumber(value)
					end

					-- ! Set needed?
					--[[
					_,_, value = strfind(left:GetText(), "(.+) %(%d/%d%)")
					if value then
						SET_NAME = value
					end
					
					_, _, value = strfind(left:GetText(), L["^Set: Increases damage and healing done by magical spells and effects by up to (%d+)%."])
					if value and SET_NAME and not tContains(resilience_Set_Bonus, SET_NAME) then
						tinsert(resilience_Set_Bonus, SET_NAME)
						resilience = resilience + tonumber(value)
					end]]					
				end
			end
		end
	end
	
	-- scan talents
	local MAX_TABS = GetNumTalentTabs()
	
	for tab=1, MAX_TABS do
		local MAX_TALENTS = GetNumTalents(tab)		
		
		for talent=1, MAX_TALENTS do
			BCS_Tooltip:SetTalent(tab, talent)
			local MAX_LINES = BCS_Tooltip:NumLines()			
			
			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				
				if left:GetText() then
					-- Druid
					-- Survival Instincts
					local _,_, value, value2 = strfind(left:GetText(), L["Reduces the chance you'll be critically hit by melee attacks by (%d+)%%. In addition, your critical strikes restore (%d+)%% of your maximum health. This effect can only occur once every 5 sec."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						resilience = resilience + tonumber(value)
						line = MAX_LINES
					end

					-- Rogue
					-- Sleight of Hand
					local _,_, value, value2 = strfind(left:GetText(), L["Reduces the chance you are critically hit by melee and ranged attacks by (%d+)%% and increases the threat reduction of your Feint ability by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						resilience = resilience + tonumber(value)
						line = MAX_LINES
					end			

					-- Shaman / Warrior
					-- Nature's Guardian / Anticipation
					local _,_, value, value2 = strfind(left:GetText(), L["Reduces the chance you are critically hit by (%d+)%%"])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						resilience = resilience + tonumber(value)
						line = MAX_LINES
					end						
				end				
			end			
		end
	end	

	return resilience
end

function BCS:GetSpellPen()
	local spellPen = 0;
	
	local MAX_INVENTORY_SLOTS = 19
	local spellPen_Set_Bonus = {}
	
	for slot=0, MAX_INVENTORY_SLOTS do
		local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)

		if hasItem then
			local SET_NAME
			
			for line=1, BCS_Tooltip:NumLines() do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L["Equip: Decreases the magical resistances of your spell targets by (%d+)."])
					if value then
						spellPen = spellPen + tonumber(value)
					end

					--Set needed?				
					_,_, value = strfind(left:GetText(), "(.+) %(%d/%d%)")
					if value then
						SET_NAME = value
					end
					
					_, _, value = strfind(left:GetText(), L["^Set: Decreases the magical resistances of your spell targets by (%d+)."])
					if value and SET_NAME and not tContains(spellPen_Set_Bonus, SET_NAME) then
						tinsert(spellPen_Set_Bonus, SET_NAME)
						spellPen = spellPen + tonumber(value)
					end			
				end
			end
		end
	end
	
	-- scan talents
	local MAX_TABS = GetNumTalentTabs()
	
	for tab=1, MAX_TABS do
		local MAX_TALENTS = GetNumTalents(tab)		
		
		for talent=1, MAX_TALENTS do
			BCS_Tooltip:SetTalent(tab, talent)
			local MAX_LINES = BCS_Tooltip:NumLines()			
			
			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				
				if left:GetText() then
					-- Mage
					-- Arcane Subtlety
					local _,_, value, value2 = strfind(left:GetText(), L["Reduces your target's resistance to all your spells by (%d+) and reduces the threat caused by your Arcane spells by (%d+)."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						spellPen = spellPen + tonumber(value)
						line = MAX_LINES
					end

					-- Priest
					-- Spell Focus
					local _,_, value, value2 = strfind(left:GetText(), L["Improves your chance to hit with spells by (%d+)%% and reduces your target's resistance to all your spells by (%d+)."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value2 and rank > 0 then
						spellPen = spellPen + tonumber(value2)
						line = MAX_LINES
					end			
				end				
			end			
		end
	end	

	return spellPen
end

function BCS:GetWeaponEnchant()
	local spell_power = 0
	local healing_power = 0

	local hasItem = BCS_Tooltip:SetInventoryItem("player", 16) -- main hand enchant
	if hasItem then
		local MAX_LINES = BCS_Tooltip:NumLines()
		for line=1, MAX_LINES do
			local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
			if left:GetText() then
				-- Flametongue Weapon
				local _,_, value = strfind(left:GetText(), L["Flametongue (%d+)"])
				if value then
					if value == "6" then
						spell_power = spell_power + 100
					elseif value == "5" then
						spell_power = spell_power + 71
					elseif value == "4" then
						spell_power = spell_power + 48
					elseif value == "3" then
						spell_power = spell_power + 33
					elseif value == "2" then
						spell_power = spell_power + 23
					elseif value == "1" then
						spell_power = spell_power + 15
					end
					line = MAX_LINES
				end

				-- Flametongue Totem
				local _,_, value = strfind(left:GetText(), L["Flametongue Totem (%d+)"])
				if value then
					if value == "4" then
						spell_power = spell_power + 40
					elseif value == "3" then
						spell_power = spell_power + 27
					elseif value == "2" then
						spell_power = spell_power + 19
					elseif value == "1" then
						spell_power = spell_power + 13
					end
					line = MAX_LINES
				end

				-- Rockbiter Weapon
				_,_, value = strfind(left:GetText(), L["Rockbiter (%d+)"])
				if value then
					if value == "7" then
						healing_power = healing_power + 130
					elseif value == "6" then
						healing_power = healing_power + 101
					elseif value == "5" then
						healing_power = healing_power + 66
					elseif value == "4" then
						healing_power = healing_power + 42
					elseif value == "3" then
						healing_power = healing_power + 28
					elseif value == "2" then
						healing_power = healing_power + 19
					elseif value == "1" then
						healing_power = healing_power + 9
					end
					line = MAX_LINES
				end

			end
		end
	end
	
	return spell_power, healing_power
end