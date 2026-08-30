BCS = BCS or {}
BCSConfig = BCSConfig or {}

local L, IndexLeft, IndexRight
L = BCS.L

BCS.PLAYERSTAT_DROPDOWN_OPTIONS = {
	"PLAYERSTAT_BASE_STATS",
	"PLAYERSTAT_MELEE_COMBAT",
	"PLAYERSTAT_RANGED_COMBAT",
	"PLAYERSTAT_SPELL_COMBAT",
	"PLAYERSTAT_DEFENSES",
}

BCS.MELEEHIT = {
	["ROGUE"] = {
		5, -- pvp
		8, -- yellow cap
		24.6, -- white cap
	},
}

BCS.PaperDollFrame = PaperDollFrame

BCS.Debug = false
BCS.DebugStack = {}

function BCS:DebugTrace(start, limit)
	BCS.Debug = nil
	local length = getn(BCS.DebugStack)
	if not start then start = 1 end
	if start > length then start = length end
	if not limit then limit = start + 30 end
	
	BCS:Print("length: " .. length)
	BCS:Print("start: " .. start)
	BCS:Print("limit: " .. limit)
	
	for i = start, length, 1 do
		BCS:Print("[" .. i .. "] Event: " .. BCS.DebugStack[i].E)
		BCS:Print(format(
			"[%d] `- Arguments: %s, %s, %s, %s, %s",
			i,
			BCS.DebugStack[i].arg1,
			BCS.DebugStack[i].arg2,
			BCS.DebugStack[i].arg3,
			BCS.DebugStack[i].arg4,
			BCS.DebugStack[i].arg5
		))
		if i >= limit then i = length end
	end
	
end

function BCS:Print(message)
	ChatFrame2:AddMessage("[BCS] " .. message, 0.63, 0.86, 1.0)
end

function BCS:OnLoad()
	CharacterAttributesFrame:Hide()
	PaperDollFrame:UnregisterEvent('UNIT_DAMAGE')
	PaperDollFrame:UnregisterEvent('PLAYER_DAMAGE_DONE_MODS')
	PaperDollFrame:UnregisterEvent('UNIT_ATTACK_SPEED')
	PaperDollFrame:UnregisterEvent('UNIT_RANGEDDAMAGE')
	PaperDollFrame:UnregisterEvent('UNIT_ATTACK')
	PaperDollFrame:UnregisterEvent('UNIT_STATS')
	PaperDollFrame:UnregisterEvent('UNIT_ATTACK_POWER')
	PaperDollFrame:UnregisterEvent('UNIT_RANGED_ATTACK_POWER')
	
	self.Frame = BCSFrame
	self.needUpdate = nil

	self.Frame:RegisterEvent("ADDON_LOADED")
	self.Frame:RegisterEvent("UNIT_INVENTORY_CHANGED") -- fires when equipment changes
	self.Frame:RegisterEvent("CHARACTER_POINTS_CHANGED") -- fires when learning talent
	self.Frame:RegisterEvent("PLAYER_AURAS_CHANGED") -- buffs/warrior stances
	
	local _, classFileName = UnitClass("Player")
	self.playerClass = strupper(classFileName)
end

function BCS:OnEvent()
	--[[if BCS.Debug then
		local t = {
			E = event,
			arg1 = arg1 or "nil",
			arg2 = arg2 or "nil",
			arg3 = arg3 or "nil",
			arg4 = arg4 or "nil",
			arg5 = arg5 or "nil",
		}
		tinsert(BCS.DebugStack, t)
	end]]
	
	if
		event == "PLAYER_AURAS_CHANGED" or
		event == "CHARACTER_POINTS_CHANGED"
	then
		if BCS.PaperDollFrame:IsVisible() then
			BCS:UpdateStats()
		else
			BCS.needUpdate = true
		end
	elseif event == "UNIT_INVENTORY_CHANGED" and arg1 == "player" then
		if BCS.PaperDollFrame:IsVisible() then
			BCS:UpdateStats()
		else
			BCS.needUpdate = true
		end
	elseif event == "ADDON_LOADED" and arg1 == "BetterCharacterStats" then
		IndexLeft = BCSConfig["DropdownLeft"] or BCS.PLAYERSTAT_DROPDOWN_OPTIONS[1]
		IndexRight = BCSConfig["DropdownRight"] or BCS.PLAYERSTAT_DROPDOWN_OPTIONS[2]

		UIDropDownMenu_SetSelectedValue(PlayerStatFrameLeftDropDown, IndexLeft)
		UIDropDownMenu_SetSelectedValue(PlayerStatFrameRightDropDown, IndexRight)
	end
end

function BCS:OnShow()
	if BCS.needUpdate then
		BCS.needUpdate = nil
		BCS:UpdateStats()
	end
end

-- debugging / profiling
--local avgV = {}
--local avg = 0
function BCS:UpdateStats()
	--[[if BCS.Debug then
		local e = event or "nil"
		BCS:Print("Update due to " .. e)
	end
	local beginTime = debugprofilestop()]]
	
	BCS:UpdatePaperdollStats("PlayerStatFrameLeft", IndexLeft)
	BCS:UpdatePaperdollStats("PlayerStatFrameRight", IndexRight)

	--[[local timeUsed = debugprofilestop()-beginTime
	table.insert(avgV, timeUsed)
	avg = 0
	
	for i,v in ipairs(avgV) do
		avg = avg + v
	end
	avg = avg / getn(avgV)
	
	BCS:Print(format("Average: %d (%d results), Exact: %d", avg, getn(avgV), timeUsed))]]
end

function BCS:SetStat(statFrame, statIndex)
	local label = getglobal(statFrame:GetName().."Label")
	local text = getglobal(statFrame:GetName().."StatText")
	local stat
	local effectiveStat
	local posBuff
	local negBuff
	local statIndexTable = {
		"STRENGTH",
		"AGILITY",
		"STAMINA",
		"INTELLECT",
		"SPIRIT",
	}
	-- Tooltip words used by item/enchant lines (e.g. "+15 Stamina"), used to
	-- split gear/enchant bonuses out of the generic UnitStat buff total.
	local statNameTable = {
		L["Strength"],
		L["Agility"],
		L["Stamina"],
		L["Intellect"],
		L["Spirit"],
	}

	statFrame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(this.tooltip)
		if this.tooltipLines then
			for i = 1, getn(this.tooltipLines) do
				GameTooltip:AddLine(this.tooltipLines[i])
			end
		end
		GameTooltip:Show()
	end)

	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	label:SetText(TEXT(getglobal("SPELL_STAT"..(statIndex-1).."_NAME"))..":")
	stat, effectiveStat, posBuff, negBuff = UnitStat("player", statIndex)

	local statLabel = getglobal("SPELL_STAT"..(statIndex-1).."_NAME")

	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		text:SetText(effectiveStat)
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..statLabel.." "..effectiveStat..FONT_COLOR_CODE_CLOSE
		statFrame.tooltipLines = nil
	else
		-- Split the combined "posBuff" total into gear/enchant, talent, and
		-- temporary-buff portions by scanning items and talents for flat bonuses.
		local gearBonus = BCS:GetGearStatBonus(statNameTable[statIndex])
		if ( gearBonus > posBuff ) then
			gearBonus = posBuff -- clamp in case of an unexpected tooltip match
		end
		local talentBonus = BCS:GetTalentStatBonus(statNameTable[statIndex], statIndex)
		if ( talentBonus > posBuff - gearBonus ) then
			talentBonus = posBuff - gearBonus -- clamp in case of an unexpected tooltip match
		end
		local tempBuff = posBuff - gearBonus - talentBonus
		local trueBase = stat - posBuff - negBuff

		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..statLabel.." "..effectiveStat..FONT_COLOR_CODE_CLOSE

		local lines = {}
		tinsert(lines, "Base: "..trueBase)
		if ( gearBonus > 0 ) then
			tinsert(lines, "|cffffff00Gear/Enchant: +"..gearBonus..FONT_COLOR_CODE_CLOSE)
		end
		if ( talentBonus > 0 ) then
			tinsert(lines, "|cff00ccffTalent: +"..talentBonus..FONT_COLOR_CODE_CLOSE)
		end
		if ( tempBuff > 0 ) then
			tinsert(lines, GREEN_FONT_COLOR_CODE.."Buff: +"..tempBuff..FONT_COLOR_CODE_CLOSE)
		end
		if ( negBuff < 0 ) then
			tinsert(lines, RED_FONT_COLOR_CODE.."Debuff: "..negBuff..FONT_COLOR_CODE_CLOSE)
		end
		statFrame.tooltipLines = lines

		-- If there are any negative buffs then show the main number in red even if there are
		-- positive buffs. Otherwise show in green.
		if ( negBuff < 0 ) then
			text:SetText(RED_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE)
		else
			text:SetText(GREEN_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE)
		end
	end
end

function BCS:SetArmor(statFrame)
	local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player")
	local totalBufs = posBuff + negBuff
	local frame = statFrame
	local label = getglobal(frame:GetName() .. "Label")
	local text = getglobal(frame:GetName() .. "StatText")

	PaperDollFormatStat(ARMOR, base, posBuff, negBuff, frame, text)
	label:SetText(TEXT(ARMOR_COLON))
	
	local playerLevel = UnitLevel("player")
	local armorReduction = effectiveArmor/((85 * playerLevel) + 400)
	armorReduction = 100 * (armorReduction/(armorReduction + 1))
	
	frame.tooltipSubtext = format(ARMOR_TOOLTIP, playerLevel, armorReduction)
	
	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(this.tooltip)
		GameTooltip:AddLine(this.tooltipSubtext, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

end

function BCS:SetDamage(statFrame)
	local label = getglobal(statFrame:GetName() .. "Label")
	label:SetText(TEXT(DAMAGE_COLON))
	local damageText = getglobal(statFrame:GetName() .. "StatText")
	local damageFrame = statFrame
	
	damageFrame:SetScript("OnEnter", CharacterDamageFrame_OnEnter)
	damageFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	local speed, offhandSpeed = UnitAttackSpeed("player")
	
	local minDamage
	local maxDamage 
	local minOffHandDamage
	local maxOffHandDamage 
	local physicalBonusPos
	local physicalBonusNeg
	local percent
	minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = UnitDamage("player")
	local displayMin = max(floor(minDamage),1)
	local displayMax = max(ceil(maxDamage),1)

	minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg
	maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg

	local baseDamage = (minDamage + maxDamage) * 0.5
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent
	local totalBonus = (fullDamage - baseDamage)
	local damagePerSecond = (max(fullDamage,1) / speed)
	local damageTooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1)
	
	local colorPos = "|cff20ff20"
	local colorNeg = "|cffff2020"
	if ( totalBonus == 0 ) then
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(displayMin.." - "..displayMax)	
		else
			damageText:SetText(displayMin.."-"..displayMax)
		end
	else
		
		local color
		if ( totalBonus > 0 ) then
			color = colorPos
		else
			color = colorNeg
		end
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(color..displayMin.." - "..displayMax.."|r")	
		else
			damageText:SetText(color..displayMin.."-"..displayMax.."|r")
		end
		if ( physicalBonusPos > 0 ) then
			damageTooltip = damageTooltip..colorPos.." +"..physicalBonusPos.."|r"
		end
		if ( physicalBonusNeg < 0 ) then
			damageTooltip = damageTooltip..colorNeg.." "..physicalBonusNeg.."|r"
		end
		if ( percent > 1 ) then
			damageTooltip = damageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r"
		elseif ( percent < 1 ) then
			damageTooltip = damageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r"
		end
		
	end
	damageFrame.damage = damageTooltip
	damageFrame.attackSpeed = speed
	damageFrame.dps = damagePerSecond
	
	-- If there's an offhand speed then add the offhand info to the tooltip
	if ( offhandSpeed ) then
		minOffHandDamage = (minOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg
		maxOffHandDamage = (maxOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg

		local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5
		local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percent
		local offhandDamagePerSecond = (max(offhandFullDamage,1) / offhandSpeed)
		local offhandDamageTooltip = max(floor(minOffHandDamage),1).." - "..max(ceil(maxOffHandDamage),1)
		if ( physicalBonusPos > 0 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorPos.." +"..physicalBonusPos.."|r"
		end
		if ( physicalBonusNeg < 0 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorNeg.." "..physicalBonusNeg.."|r"
		end
		if ( percent > 1 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r"
		elseif ( percent < 1 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r"
		end
		damageFrame.offhandDamage = offhandDamageTooltip
		damageFrame.offhandAttackSpeed = offhandSpeed
		damageFrame.offhandDps = offhandDamagePerSecond
	else
		damageFrame.offhandAttackSpeed = nil
	end
	
end

function BCS:SetAttackSpeed(statFrame)
	local speed, offhandSpeed = UnitAttackSpeed("player")
	speed = format("%.2f", speed)
	if ( offhandSpeed ) then
		offhandSpeed = format("%.2f", offhandSpeed)
	end
	local text	
	if ( offhandSpeed ) then
		text = speed.." / "..offhandSpeed
	else
		text = speed
	end
	
	local label = getglobal(statFrame:GetName() .. "Label")
	local value = getglobal(statFrame:GetName() .. "StatText")
	
	label:SetText(TEXT(SPEED)..":")
	value:SetText(text)

	--[[statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..text..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(CR_HASTE_RATING_TOOLTIP, GetCombatRating(CR_HASTE_MELEE), GetCombatRatingBonus(CR_HASTE_MELEE));]]
	
	statFrame:Show()
end

function BCS:SetAttackPower(statFrame)	
	local base, posBuff, negBuff = UnitAttackPower("player")

	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(TEXT(ATTACK_POWER_COLON))

	PaperDollFormatStat(MELEE_ATTACK_POWER, base, posBuff, negBuff, frame, text)
	frame.tooltipSubtext = format(L["ATTACK_POWER_TOOLTIP"], "melee", max(0,base + posBuff + negBuff)/ATTACK_POWER_MAGIC_NUMBER);

	frame:SetScript("OnEnter", function()
			GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
			GameTooltip:SetText(this.tooltip)
			GameTooltip:AddLine(this.tooltipSubtext)
			GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function BCS:SetSpellPower(statFrame)
	local frame = statFrame
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")

	local power, schools, dmg = BCS:GetSpellPower()

	power = power + dmg

	label:SetText(L.SPELL_POWER_COLON)
	text:SetText(power)

	frame.tooltip = format(L["SPELL_POWER_TOOLTIP_HEADER"], power)

	local damagePercent = BCS:GetHolyPowerTalentModifiers()
	local moonkinAuraPercent = BCS:GetMoonkinAuraBonus()
	local frostDamagePercent = BCS:GetFrostDamageTalentBonus()

	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(this.tooltip)
		-- Per school: the effective total for that school (main number + the
		-- school-specific bonus), with the bonus itself in brackets.
		for k, v in pairs(schools) do
			if (v > 0) then
				GameTooltip:AddDoubleLine(k, format("%d |cff20ff20(+%d)|r", power + v, v))
			end
		end
		if damagePercent ~= 0 then
			GameTooltip:AddLine(format("Holy Damage (Talent): %+d%%", damagePercent), 1, 1, 1)
		end
		if moonkinAuraPercent ~= 0 then
			GameTooltip:AddLine(format("Damage (Moonkin Aura): +%d%%", moonkinAuraPercent), 1, 1, 1)
		end
		if frostDamagePercent ~= 0 then
			GameTooltip:AddLine(format("Frost Damage (Talent): +%d%%", frostDamagePercent), 1, 1, 1)
		end
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function BCS:SetRating(statFrame, ratingType)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(L.MELEE_HIT_RATING_COLON)
	frame.tooltip = L["HIT_TOOLTIP_HEADER"]
	
	local colorPos = "|cff20ff20"
	local colorNeg = "|cffff2020"
	
	if ratingType == "MELEE" then
		local rating = BCS:GetHitRating()
		if BCS.MELEEHIT[BCS.playerClass] then
			if rating < BCS.MELEEHIT[BCS.playerClass][1] then
				rating = colorNeg .. rating .. "%|r"
			elseif rating >= BCS.MELEEHIT[BCS.playerClass][2] then
				rating = colorPos .. rating .. "%|r"
			else
				rating = rating .. "%"
			end
		else
			rating = rating .. "%"
		end
		text:SetText(rating)
		
		frame.tooltipSubtext = format(L["HIT_TOOLTIP"], "melee", UnitLevel("player"), rating);
		if L[BCS.playerClass .. "_MELEE_HIT_TOOLTIP"] then
			frame.tooltipSubtext = frame.tooltipSubtext..L[BCS.playerClass .. "_MELEE_HIT_TOOLTIP"]
		end

		frame.tooltip = format(L["HIT_TOOLTIP_HEADER"], rating)

		frame:SetScript("OnEnter", function()
			GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
			GameTooltip:AddLine(this.tooltip)
			GameTooltip:AddLine(this.tooltipSubtext, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
			GameTooltip:Show()
		end)

	elseif ratingType == "RANGED" then
		local rating = BCS:GetRangedHitRating()
		if BCS.MELEEHIT[BCS.playerClass] then
			if rating < BCS.MELEEHIT[BCS.playerClass][1] then
				rating = colorNeg .. rating .. "%|r"
			elseif rating >= BCS.MELEEHIT[BCS.playerClass][2] then
				rating = colorPos .. rating .. "%|r"
			else
				rating = rating .. "%"
			end
		else
			rating = rating .. "%"
		end
		text:SetText(rating)
		
		frame.tooltipSubtext = format(L["HIT_TOOLTIP"], "ranged", UnitLevel("player"), rating);
		if L[BCS.playerClass .. "_RANGED_HIT_TOOLTIP"] then
			frame.tooltipSubtext = frame.tooltipSubtext..L[BCS.playerClass .. "_RANGED_HIT_TOOLTIP"]
		end		

	elseif ratingType == "SPELL" then
		local spell_hit, schools = BCS:GetSpellHitRating()
		
		frame.tooltipSubtext = L.SPELL_HIT_TOOLTIP
		text:SetText(spell_hit.."%")
		frame.tooltip = format(L["HIT_TOOLTIP_HEADER"], spell_hit .. "%")

		frame:SetScript("OnEnter", function()
			GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
			GameTooltip:AddLine(this.tooltip)
			for k, v in pairs(schools) do
				if (v > 0) then
					GameTooltip:AddDoubleLine(k, v .. "%")
				end
			end
			GameTooltip:AddLine(this.tooltipSubtext, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
			GameTooltip:Show()
		end)
	end

	if not ratingType == "SPELL" then
	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:AddLine(this.tooltip)
		GameTooltip:AddLine(this.tooltipSubtext, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		GameTooltip:Show()
	end)
	end
	
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	
end

function BCS:SetMeleeCritChance(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	local crit, schools = BCS:GetCritChance()
	crit = format("%.2f%%", crit)
	frame.tooltip = format(L["CRIT_TOOLTIP_HEADER"], crit)

	label:SetText(L.MELEE_CRIT_COLON)
	text:SetText(crit)

	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:AddLine(this.tooltip)
		if (schools ~= nil) then
			for k, v in pairs(schools) do
				if (v > 0) then
					GameTooltip:AddDoubleLine(k, v .. "%")
				end
			end
		end
		GameTooltip:Show()
	end)	
	
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function BCS:SetSpellCritChance(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")	
	local spell_crit, spell_crit_schools, spell_crit_damage_schools = BCS:GetSpellCritChance()
	spell_crit = format("%.2f%%", spell_crit)

	frame.tooltip = format(L["SPELL_CRIT_TOOLTIP_HEADER"], spell_crit)
	
	label:SetText(L.SPELL_CRIT_COLON)
	text:SetText(spell_crit)

	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:AddLine(this.tooltip)
		for k, v in pairs(spell_crit_schools) do
			if (v > 0) then
				GameTooltip:AddDoubleLine(k, v .. "%")
			end		
		end
		-- change V so that's the color is white?
		GameTooltip:AddDoubleLine("Critical Strike Damage")
		for k, v in pairs(spell_crit_damage_schools) do
			if (v > 0) then
				GameTooltip:AddDoubleLine(k, v .. "%")
			end		
		end
		GameTooltip:Show()
	end)	
	
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function BCS:SetRangedCritChance(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(L.RANGED_CRIT_COLON)
	text:SetText(format("%.2f%%", BCS:GetRangedCritChance()))
end

function BCS:SetHealing(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	local power = BCS:GetSpellPower()
	local heal = BCS:GetHealingPower()
	local healingPower = power + heal

	label:SetText(L.HEAL_POWER_COLON)
	text:SetText(healingPower)

	frame.tooltip = format(L["SPELL_HEALING_POWER_TOOLTIP_HEADER"], healingPower)

	local _, healPercent = BCS:GetHolyPowerTalentModifiers()
	local moonkinAuraPercent = BCS:GetMoonkinAuraBonus()

	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(this.tooltip)
		if healPercent ~= 0 then
			GameTooltip:AddLine(format("Healing (Talent): %+d%%", healPercent), 1, 1, 1)
		end
		if moonkinAuraPercent ~= 0 then
			GameTooltip:AddLine(format("Healing (Moonkin Aura): +%d%%", moonkinAuraPercent), 1, 1, 1)
		end
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function BCS:SetManaRegen(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	local floor = math.floor
	
	label:SetText(L.MANA_REGEN_COLON)
	
	-- Only Warriors and Rogues have no mana pool at all. Other classes (notably
	-- Druids) keep their mana pool while shapeshifted even though UnitPowerType
	-- reports the form's resource (Rage/Energy) as currently active, so check
	-- the class instead of the active power type.
	local _, playerClass = UnitClass("player")
	if playerClass == "WARRIOR" or playerClass == "ROGUE" then
		text:SetText(NOT_APPLICABLE);
		frame.tooltip = nil;
		return
	end
	
	local base, casting, mp5, paladinManaTick, paladinManaRegen, druidManaTick, druidManaRegen, finalBoWMP5, finalMtSVal, castingRegenPercent = BCS:GetManaRegen()
	
	-- All of the buffs below are detected by the buff-tooltip TEXT (the addon's
	-- dominant pattern), not by icon -- icons get reskinned / shared between ranks
	-- on custom servers. Mana Spring / BoW piggyback on GetManaRegen's own scan
	-- (finalMtSVal / finalBoWMP5 are > 0 only while the buff is up); the rest scan
	-- here via BCS:GetPlayerAura.

	-- Mana Spring Totem -- finalMtSVal is the per-2s value.
	local finalMtSVal = finalMtSVal or 0
	local manaSpringmp5 = 0
	local manaSpringText = ""
	if finalMtSVal > 0 then
		manaSpringmp5 = floor(finalMtSVal * 5 / 2)
		manaSpringText = format(L["MANA_SPRING_TOTEM"], manaSpringmp5)
	end

	-- Blessing of Wisdom -- finalBoWMP5 is already the mp5 value.
	local finalBoWMP5 = finalBoWMP5 or 0
	local blessingRegenmp5 = 0
	local blessingRegenText = ""
	if finalBoWMP5 > 0 then
		blessingRegenmp5 = finalBoWMP5
		blessingRegenText = format(L["BLESSING_OF_WISDOM"], blessingRegenmp5)
	end

	-- Warchief's Blessing / Winsor's Sacrifice -- identical "N mana regen every 5
	-- seconds" line and identical effect; only the world-buff icon tells them
	-- apart, so match the text and show one combined line.
	local warchiefsRegenmp5 = 0
	local warchiefsRegenText = ""
	local _, _, wcRegen = BCS:GetPlayerAura("(%d+) mana regen every 5 seconds")
	if wcRegen then
		warchiefsRegenmp5 = tonumber(wcRegen)
		warchiefsRegenText = format(L["WARCHIEFS_WBUFF"], warchiefsRegenmp5)
	end

	-- Brilliance Aura -- X% of max mana every 10s, percent parsed from the text.
	local maxMana = UnitManaMax("player")
	local brillRegenmp5 = 0
	local brillRegenText = ""
	local _, _, brillPct = BCS:GetPlayerAura("Regenerates (%d+)%% of your Mana every 10 sec")
	if brillPct then
		brillRegenmp5 = floor(maxMana * (tonumber(brillPct) / 100) * (5 / 10))
		brillRegenText = format(L["BRILLIANCE_AURA"], brillRegenmp5)
	end

	-- Ensure paladinManaRegen and paladinManaTick always have a default value
	paladinManaRegen = paladinManaRegen or 0
	paladinManaTick = paladinManaTick or 0
	druidManaRegen = druidManaRegen or 0
	druidManaTick = druidManaTick or 0

	-- ==========================================================================
	-- Mana regen model -- see docs/mana-regen.md for the full rationale.
	--
	-- The server keeps ONE combined rate (SPELL_AURA_MOD_POWER_REGEN + spirit),
	-- and every 2s tick it does a SINGLE floor on that combined value. So Spirit
	-- regen and the flat "mana per 5 sec" from gear/enchant/set/oil/food must be
	-- summed FIRST and floored ONCE -- never rounded per source, or the fractions
	-- drift and the headline reads 1-2 high/low.
	--
	-- Everything else regenerates on its OWN timer with its own independent floor
	-- and is added on top as a flat mp5 amount (periodicMp5): Blessing of Wisdom,
	-- Mana Spring Totem, Warchief's/Winsor's, Brilliance Aura, Divine
	-- Concentration, Dreamstate. Combat-log confirmed for BoW (5s) and Mana Spring
	-- (2s) on this server; see docs/mana-regen.md.
	-- ==========================================================================

	-- Flat mp5 that the server folds into the single combined tick. Only true
	-- SPELL_AURA_MOD_POWER_REGEN (gear/enchant/set/oil/food) lives here. Buff
	-- "mana every N sec" effects are separate energizes on this server -- see
	-- periodicMp5 below and docs/mana-regen.md.
	local flatMp5 = mp5

	local flatMp5Tick = flatMp5 * 2 / 5   -- per 2s tick, UNfloored
	local spiritTick = base               -- per 2s tick, UNfloored
	local spiritTickCasting = casting     -- already base * castingRegenPercent/100

	-- The server's single per-tick floor.
	local tickNotCasting = floor(spiritTick + flatMp5Tick)
	local tickCasting = floor(spiritTickCasting + flatMp5Tick)

	 -- **Check if player is Paladin before adding Divine Concentration**
    local _, playerClass = UnitClass("player")
    local paladinText = ""
	local druidText = ""

	if playerClass == "PALADIN" and paladinManaRegen > 0 then
        paladinText = format(L["DIVINE_CONCENTRATION"], paladinManaRegen)
    end

	if playerClass == "DRUID" and druidManaRegen > 0 then
		druidText = format(L["DREAMSTATE"], druidManaRegen)
	end

	-- Separate periodic-energize sources, each floored on its own timer and
	-- independent of the spirit tick / casting state. Combat log confirmed on
	-- this server: Blessing of Wisdom (5s), Mana Spring Totem (2s). Warchief's /
	-- Winsor's carried here too by the same "mana every 5 sec" wording.
	local periodicMp5 = brillRegenmp5 + paladinManaRegen + druidManaRegen + blessingRegenmp5 + manaSpringmp5 + warchiefsRegenmp5

	-- Headline: the combined tick as a rate (x 2.5), plus the periodic sources.
	text:SetText(format("%d", floor(tickNotCasting * 5 / 2 + periodicMp5)))

	-- Flat-mp5 breakpoints against the REAL combined tick: "breakpoint" is the
	-- flat mp5 at which the current tick level starts (drop below it and the
	-- tick falls by 1), "next" is the flat mp5 that raises the tick by 1. Both
	-- account for Spirit's own fractional part, so they shift with Spirit.
	local mp5Breakpoint = ""
	if flatMp5 > 0 then
		local bp = ceil((tickNotCasting - spiritTick) * 5 / 2)
		local nextBp = ceil((tickNotCasting + 1 - spiritTick) * 5 / 2)
		if bp < 0 then bp = 0 end
		mp5Breakpoint = format(L["MANA_REGEN_MP5_BREAKPOINT"], bp, nextBp)
	end

	-- Gear/enchant mp5 line (only when there is any, with the tick-breakpoint hint).
	local gearLine = ""
	if flatMp5 > 0 then
		gearLine = format(L["MANA_REGEN_GEAR_LINE"], floor(flatMp5), mp5Breakpoint)
	end

	-- Periodic-energize breakdown: header + one "+N mp5" line per active source.
	-- The headline stat is already the grand total, so no total line here.
	local periodicText = paladinText .. druidText .. blessingRegenText .. manaSpringText .. brillRegenText .. warchiefsRegenText
	local periodicBlock = ""
	if periodicText ~= "" then
		periodicBlock = L["MANA_REGEN_PERIODIC_HEADER"] .. periodicText
	end

	frame.tooltip = L["SPELL_MANA_REGEN_TOOLTIP_HEADER"]
	frame.tooltipSubtext = format(L["SPELL_MANA_REGEN_TOOLTIP"], tickNotCasting, floor(tickNotCasting * 5 / 2), tickCasting) .. gearLine .. periodicBlock
	
	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(this.tooltip)
		GameTooltip:AddLine(this.tooltipSubtext)
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function BCS:SetMoveSpeed(statFrame)
	local frame = statFrame
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")

	label:SetText(L.MOVE_SPEED_COLON)

	local runSpeed, mountSpeedBonus, mountedTotal = BCS:GetMovementSpeedBonus()
	text:SetText(format("%d%%", runSpeed))

	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText("Movement Speed")
		GameTooltip:AddLine(format("Walking/Running: %d%%", runSpeed), 1, 1, 1)
		if mountedTotal then
			GameTooltip:AddLine(format("Mounted: %d%% (+%d%% bonus)", mountedTotal, mountSpeedBonus), 1, 1, 1)
		else
			GameTooltip:AddLine(format("Mounted Bonus: +%d%%", mountSpeedBonus), 1, 1, 1)
		end
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function BCS:SetDodge(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(L.DODGE_COLON)
	text:SetText(format("%.2f%%", GetDodgeChance()))
end

function BCS:SetParry(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(L.PARRY_COLON)
	text:SetText(format("%.2f%%", GetParryChance()))
end

function BCS:SetBlock(statFrame)
	local frame = statFrame
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")

	label:SetText(L.BLOCK_COLON)
	text:SetText(format("%.2f%%", GetBlockChance()))

	frame.tooltip = format("Block Value: %d", BCS:GetBlockValue())
	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(this.tooltip)
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function BCS:SetSpellHaste(statFrame)
	local frame = statFrame
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")

	label:SetText(L.SPELL_HASTE_COLON)
	text:SetText(format("%.2f%%", BCS:GetSpellHaste()))
end

function BCS:SetMeleeHaste(statFrame)
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")

	label:SetText(L.SPELL_HASTE_COLON)
	-- Whole % only: this value is derived from base-vs-current swing speed, and
	-- the game reports those to ~2 decimals, so the division carries fractional
	-- noise (a true 2% reads as ~2.04%). Real melee haste comes in whole chunks.
	text:SetText(format("%.0f%%", BCS:GetMeleeHaste()))
end

function BCS:SetSpellPen(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(L.SPELL_PEN_COLON)
	text:SetText(BCS:GetSpellPen())
end

-- Resilience converts directly to Defense in this ruleset: 1 Resilience = 12.5 Defense.
local RESILIENCE_TO_DEFENSE = 12.5

function BCS:SetDefense(statFrame)
	local base, modifier = UnitDefense("player")

	local frame = statFrame
	local label = getglobal(statFrame:GetName() .. "Label")
	local text = getglobal(statFrame:GetName() .. "StatText")

	label:SetText(TEXT(DEFENSE_COLON))

	local resilience = BCS:GetResilienceChance()
	local resilienceDefense = resilience * RESILIENCE_TO_DEFENSE
	-- Round down only for the displayed Defense number; the tooltip below keeps full precision.
	local resilienceDefenseRounded = floor(resilienceDefense)

	local posBuff = resilienceDefenseRounded
	local negBuff = 0
	if ( modifier > 0 ) then
		posBuff = posBuff + modifier
	elseif ( modifier < 0 ) then
		negBuff = modifier
	end
	PaperDollFormatStat(DEFENSE_COLON, base, posBuff, negBuff, frame, text)

	frame.tooltipSubtext = format("Resilience: %.2f%% (+%.1f Defense)", resilience, resilienceDefense)
	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(this.tooltip)
		GameTooltip:AddLine(this.tooltipSubtext, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function BCS:SetRangedDamage(statFrame)
	local label = getglobal(statFrame:GetName() .. "Label")
	local damageText = getglobal(statFrame:GetName() .. "StatText")
	local damageFrame = statFrame
	
	label:SetText(TEXT(DAMAGE_COLON))
	
	damageFrame:SetScript("OnEnter", CharacterRangedDamageFrame_OnEnter)
	damageFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	-- If no ranged attack then set to n/a
	if ( PaperDollFrame.noRanged ) then
		damageText:SetText(NOT_APPLICABLE)
		damageFrame.damage = nil
		return
	end

	local rangedAttackSpeed, minDamage, maxDamage, physicalBonusPos, physicalBonusNeg, percent = UnitRangedDamage("player")
	local displayMin = max(floor(minDamage),1)
	local displayMax = max(ceil(maxDamage),1)

	minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg
	maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg

	local baseDamage = (minDamage + maxDamage) * 0.5
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent
	local totalBonus = (fullDamage - baseDamage)
	local damagePerSecond = (max(fullDamage,1) / rangedAttackSpeed)
	local tooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1)

	if ( totalBonus == 0 ) then
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(displayMin.." - "..displayMax)	
		else
			damageText:SetText(displayMin.."-"..displayMax)
		end
	else
		local colorPos = "|cff20ff20"
		local colorNeg = "|cffff2020"
		local color
		if ( totalBonus > 0 ) then
			color = colorPos
		else
			color = colorNeg
		end
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(color..displayMin.." - "..displayMax.."|r")	
		else
			damageText:SetText(color..displayMin.."-"..displayMax.."|r")
		end
		if ( physicalBonusPos > 0 ) then
			tooltip = tooltip..colorPos.." +"..physicalBonusPos.."|r"
		end
		if ( physicalBonusNeg < 0 ) then
			tooltip = tooltip..colorNeg.." "..physicalBonusNeg.."|r"
		end
		if ( percent > 1 ) then
			tooltip = tooltip..colorPos.." x"..floor(percent*100+0.5).."%|r"
		elseif ( percent < 1 ) then
			tooltip = tooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r"
		end
		damageFrame.tooltip = tooltip.." "..format(TEXT(DPS_TEMPLATE), damagePerSecond)
	end
	damageFrame.attackSpeed = rangedAttackSpeed
	damageFrame.damage = tooltip
	damageFrame.dps = damagePerSecond
end

function BCS:SetRangedAttackSpeed(startFrame)
	local label = getglobal(startFrame:GetName() .. "Label")
	local damageText = getglobal(startFrame:GetName() .. "StatText")
	local damageFrame = startFrame
	
	label:SetText(TEXT(SPEED)..":")

	-- If no ranged attack then set to n/a
	if ( PaperDollFrame.noRanged ) then
		damageText:SetText(NOT_APPLICABLE)
		damageFrame.damage = nil
		return
	end

	-- UnitRangedDamage's first return is the speed Blizzard already computed
	-- (weapon speed with all haste applied) -- just display it. This frame has
	-- no hover handler, so there is no tooltip / dps to build here; the Ranged
	-- Damage stat (SetRangedDamage) owns that.
	local rangedAttackSpeed = UnitRangedDamage("player")
	damageText:SetText(format("%.2f", rangedAttackSpeed))
end

function BCS:SetRangedAttackPower(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(TEXT(ATTACK_POWER_COLON))
	
	-- If no ranged attack then set to n/a
	if ( PaperDollFrame.noRanged ) then
		text:SetText(NOT_APPLICABLE)
		frame.tooltip = nil
		return
	end
	if ( HasWandEquipped() ) then
		text:SetText("--")
		frame.tooltip = nil
		return
	end

	local base, posBuff, negBuff = UnitRangedAttackPower("player")
	PaperDollFormatStat(RANGED_ATTACK_POWER, base, posBuff, negBuff, frame, text)
	frame.tooltipSubtext = format(L["ATTACK_POWER_TOOLTIP"], "ranged", max(0,base + posBuff + negBuff)/ATTACK_POWER_MAGIC_NUMBER);
	frame:SetScript("OnEnter", function()
			GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
			GameTooltip:SetText(this.tooltip)
			GameTooltip:AddLine(this.tooltipSubtext)
			GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function BCS:UpdatePaperdollStats(prefix, index)
	local stats = {}
	for i = 1, 7 do
		local s = getglobal(prefix..i)
		stats[i] = s
		s:SetScript("OnEnter", nil)
		s:SetScript("OnLeave", nil)
		s.tooltip = nil
		s.tooltipSubtext = nil
		s:Show()
	end
	local stat1, stat2, stat3, stat4, stat5, stat6, stat7 =
		stats[1], stats[2], stats[3], stats[4], stats[5], stats[6], stats[7]

	if ( index == "PLAYERSTAT_BASE_STATS" ) then
		BCS:SetStat(stat1, 1)
		BCS:SetStat(stat2, 2)
		BCS:SetStat(stat3, 3)
		BCS:SetStat(stat4, 4)
		BCS:SetStat(stat5, 5)
		BCS:SetArmor(stat6)
		BCS:SetMoveSpeed(stat7)
	elseif ( index == "PLAYERSTAT_MELEE_COMBAT" ) then
		BCS:SetDamage(stat1)
		BCS:SetAttackSpeed(stat2)
		BCS:SetAttackPower(stat3)
		BCS:SetRating(stat4, "MELEE")
		BCS:SetMeleeCritChance(stat5)
		BCS:SetMeleeHaste(stat6)
		stat7:Hide()
	elseif ( index == "PLAYERSTAT_RANGED_COMBAT" ) then
		BCS:SetRangedDamage(stat1)
		BCS:SetRangedAttackSpeed(stat2)
		BCS:SetRangedAttackPower(stat3)
		BCS:SetRating(stat4, "RANGED")
		BCS:SetRangedCritChance(stat5)
		stat6:Hide()
		stat7:Hide()
	elseif ( index == "PLAYERSTAT_SPELL_COMBAT" ) then
		BCS:SetSpellPower(stat1)
		BCS:SetHealing(stat2)
		BCS:SetRating(stat3, "SPELL")
		BCS:SetSpellCritChance(stat4)
		BCS:SetManaRegen(stat5)
		BCS:SetSpellPen(stat6)
		BCS:SetSpellHaste(stat7)
	elseif ( index == "PLAYERSTAT_DEFENSES" ) then
		BCS:SetArmor(stat1)
		BCS:SetDefense(stat2)
		BCS:SetDodge(stat3)
		BCS:SetParry(stat4)
		BCS:SetBlock(stat5)
		stat6:Hide()
		stat7:Hide()
	end
end

local function PlayerStatFrameLeftDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(getglobal(this.owner), this.value)
	IndexLeft = this.value
	BCSConfig["DropdownLeft"] = IndexLeft
	BCS:UpdatePaperdollStats("PlayerStatFrameLeft", this.value)
end

local function PlayerStatFrameRightDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(getglobal(this.owner), this.value)
	IndexRight = this.value
	BCSConfig["DropdownRight"] = IndexRight
	BCS:UpdatePaperdollStats("PlayerStatFrameRight", this.value)
end

local function PlayerStatFrameLeftDropDown_Initialize()
	local info = {}
	local checked = nil
	for i=1, getn(BCS.PLAYERSTAT_DROPDOWN_OPTIONS) do
		info.text = BCS.L[BCS.PLAYERSTAT_DROPDOWN_OPTIONS[i]]
		info.func = PlayerStatFrameLeftDropDown_OnClick
		info.value = BCS.PLAYERSTAT_DROPDOWN_OPTIONS[i]
		info.checked = checked
		info.owner = UIDROPDOWNMENU_OPEN_MENU
		UIDropDownMenu_AddButton(info)
	end
end

local function PlayerStatFrameRightDropDown_Initialize()
	local info = {}
	local checked = nil
	for i=1, getn(BCS.PLAYERSTAT_DROPDOWN_OPTIONS) do
		info.text = BCS.L[BCS.PLAYERSTAT_DROPDOWN_OPTIONS[i]]
		info.func = PlayerStatFrameRightDropDown_OnClick
		info.value = BCS.PLAYERSTAT_DROPDOWN_OPTIONS[i]
		info.checked = checked
		info.owner = UIDROPDOWNMENU_OPEN_MENU
		UIDropDownMenu_AddButton(info)
	end
end

function PlayerStatFrameLeftDropDown_OnLoad()
	RaiseFrameLevel(this)
	RaiseFrameLevel(getglobal(this:GetName() .. "Button"))
	UIDropDownMenu_Initialize(this, PlayerStatFrameLeftDropDown_Initialize)
	UIDropDownMenu_SetWidth(99, this)
	UIDropDownMenu_JustifyText("LEFT")
end

function PlayerStatFrameRightDropDown_OnLoad()
	RaiseFrameLevel(this)
	RaiseFrameLevel(getglobal(this:GetName() .. "Button"))
	UIDropDownMenu_Initialize(this, PlayerStatFrameRightDropDown_Initialize)
	UIDropDownMenu_SetWidth(99, this)
	UIDropDownMenu_JustifyText("LEFT")
end
