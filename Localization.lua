BCS = BCS or {}

BCS["L"] = {

	["([%d.]+)%% chance to crit"] = "([%d.]+)%% chance to crit",

	["^Set: Improves your chance to hit by (%d)%%."] = "^Set: Improves your chance to hit by (%d)%%.",
	["^Set: Improves your chance to get a critical strike with spells by (%d)%%."] = "^Set: Improves your chance to get a critical strike with spells by (%d)%%.",
	["^Set: Improves your chance to hit with spells by (%d)%%."] = "^Set: Improves your chance to hit with spells by (%d)%%.",
	["^Set: Increases damage and healing done by magical spells and effects by up to (%d+)%."] = "^Set: Increases damage and healing done by magical spells and effects by up to (%d+)%.",
	["^Set: Increases healing done by spells and effects by up to (%d+)%."] = "^Set: Increases healing done by spells and effects by up to (%d+)%.",
	["^Set: Improves your critical strike chance for all attacks and spells by (%d)%%."] = "^Set: Improves your critical strike chance for all attacks and spells by (%d)%%.",
	["^Set: Decreases the magical resistances of your spell targets by (%d+)."] = "^Set: Decreases the magical resistances of your spell targets by (%d+).",

	-- Hit
	["Equip: Improves your chance to hit by (%d)%%."] = "Equip: Improves your chance to hit by (%d)%%.",
	["Equip: Improves your chance to hit with spells by (%d)%%."] = "Equip: Improves your chance to hit with spells by (%d)%%.",
	["Equip: Improves your chance to hit with attacks and spells by (%d+)%%."] = "Equip: Improves your chance to hit with attacks and spells by (%d+)%%.",
	["Increases your chance to hit with melee attacks and spells by (%d+)%%."] = "Increases your chance to hit with melee attacks and spells by (%d+)%%.",
	["Increases your chance to hit with melee weapons by (%d)%%."] = "Increases your chance to hit with melee weapons by (%d)%%.",
	["Improves your chance to hit with spells by (%d+)%%."] = "Improves your chance to hit with spells by (%d+)%%.",
	-- ! Deprecated ["Increases hit chance by (%d)%% and increases the chance movement impairing effects will be resisted by an additional %d+%%."] = "Increases hit chance by (%d)%% and increases the chance movement impairing effects will be resisted by an additional %d+%%.",
	["%+(%d+)%% Hit"] = "%+(%d+)%% Hit",
	["+(%d)%% Hit"] = "+(%d)%% Hit",

	-- Crit
	["Equip: Improves your chance to get a critical strike with spells by (%d)%%."] = "Equip: Improves your chance to get a critical strike with spells by (%d)%%.",
	["Equip: Improves your critical strike chance for all attacks and spells by (%d)%%."] = "Equip: Improves your critical strike chance for all attacks and spells by (%d)%%.",	
	["Increases your critical strike chance with ranged weapons by (%d)%%."] = "Increases your critical strike chance with ranged weapons by (%d)%%.",
	["Increases your critical strike chance with all attacks by (%d)%%."] = "Increases your critical strike chance with all attacks by (%d)%%.",

	["Increases the critical effect chance of your Arcane spells by (%d+)%%."] = "Increases the critical effect chance of your Arcane spells by (%d+)%%.",
	["Increases the critical effect chance of your Fire spells by (%d+)%%."] = "Increases the critical effect chance of your Fire spells by (%d+)%%.",
	["Increases the critical effect chance of your Frost spells by (%d+)%%."] = "Increases the critical effect chance of your Frost spells by (%d+)%%.",
	["Increases the critical effect chance of your Holy spells by (%d+)%%."] = "Increases the critical effect chance of your Holy spells by (%d+)%%.",
	["Increases the critical effect chance of your Nature spells by (%d+)%%."] = "Increases the critical effect chance of your Nature spells by (%d+)%%.",
	["Increases the critical effect chance of your Shadow spells by (%d+)%%."] = "Increases the critical effect chance of your Shadow spells by (%d+)%%.",

	["Improves your chance to get a critical strike with Arcane spells by (%d+)%%."] = "Increases the critical effect chance of your Nature spells by (%d+)%%.",
	["Improves your chance to get a critical strike with Fire spells by (%d+)%%."] = "Increases the critical effect chance of your Nature spells by (%d+)%%.",
	["Improves your chance to get a critical strike with Frost spells by (%d+)%%."] = "Increases the critical effect chance of your Nature spells by (%d+)%%.",
	["Improves your chance to get a critical strike with Holy spells by (%d+)%%."] = "Increases the critical effect chance of your Nature spells by (%d+)%%.",
	["Improves your chance to get a critical strike with Nature spells by (%d+)%%."] = "Increases the critical effect chance of your Nature spells by (%d+)%%.",
	["Improves your chance to get a critical strike with Shadow spells by (%d+)%%."] = "Increases the critical effect chance of your Nature spells by (%d+)%%.",
	
	["Equip: Increases damage done by Arcane spells and effects by up to (%d+)."] = "Equip: Increases damage done by Arcane spells and effects by up to (%d+).",
	["Equip: Increases damage done by Fire spells and effects by up to (%d+)."] = "Equip: Increases damage done by Fire spells and effects by up to (%d+).",
	["Equip: Increases damage done by Frost spells and effects by up to (%d+)."] = "Equip: Increases damage done by Frost spells and effects by up to (%d+).",
	["Equip: Increases damage done by Holy spells and effects by up to (%d+)."] = "Equip: Increases damage done by Holy spells and effects by up to (%d+).",
	["Equip: Increases damage done by Nature spells and effects by up to (%d+)."] = "Equip: Increases damage done by Nature spells and effects by up to (%d+).",
	["Equip: Increases damage done by Shadow spells and effects by up to (%d+)."] = "Equip: Increases damage done by Shadow spells and effects by up to (%d+).",
	
	["Increases spell critical chance by (%d+)%%"] = "Increases spell critical chance by (%d+)%%",
	["Spell critical chance increased by (%d+)%%."] = "Spell critical chance increased by (%d+)%%.",
	
	-- Damage
	["Shadow Damage %+(%d+)"] = "Shadow Damage %+(%d+)",
	["Spell Damage %+(%d+)"] = "Spell Damage %+(%d+)",
	["Fire Damage %+(%d+)"] = "Fire Damage %+(%d+)",
	["Frost Damage %+(%d+)"] = "Frost Damage %+(%d+)",
	["Healing Spells %+(%d+)"] = "Healing Spells %+(%d+)",
		
	-- Random Bonuses // https://wow.gamepedia.com/index.php?title=SuffixId&oldid=204406
	["^%+(%d+) Damage and Healing Spells"] = "^%+(%d+) Damage and Healing Spells",
	["^%+(%d+) Arcane Spell Damage"] = "^%+(%d+) Arcane Spell Damage",
	["^%+(%d+) Fire Spell Damage"] = "^%+(%d+) Fire Spell Damage",
	["^%+(%d+) Frost Spell Damage"] = "^%+(%d+) Frost Spell Damage",
	["^%+(%d+) Holy Spell Damage"] = "^%+(%d+) Holy Spell Damage",
	["^%+(%d+) Nature Spell Damage"] = "^%+(%d+) Nature Spell Damage",
	["^%+(%d+) Shadow Spell Damage"] = "^%+(%d+) Shadow Spell Damage",
	["^%+(%d+) mana every 5 sec."] = "^%+(%d+) mana every 5 sec.",

	-- Mana
	["Equip: Restores (%d+) mana per 5 sec."] = "Equip: Restores (%d+) mana per 5 sec.",

	-- Enchants
	["Flametongue (%d+)"] = "Flametongue (%d+)",
	["Rockbiter (%d+)"] = "Rockbiter (%d+)",

	-- Totems
	["Flametongue Totem (%d+)"] = "Flametongue Totem (%d+)",

	-- snowflakes ZG enchants
	["/Hit %+(%d+)"] = "/Hit %+(%d+)",
	["/Spell Hit %+(%d+)"] = "/Spell Hit %+(%d+)",
	["^Mana Regen %+(%d+)"] = "^Mana Regen %+(%d+)",
	["^%+(%d+) Healing Spells"] = "^%+(%d+) Healing Spells",
	["^%+(%d+) Spell Damage and Healing"] = "^%+(%d+) Spell Damage and Healing",
	
	["Equip: Increases damage and healing done by magical spells and effects by up to (%d+)."] = "Equip: Increases damage and healing done by magical spells and effects by up to (%d+).",
	["Equip: Increases healing done by spells and effects by up to (%d+)."] = "Equip: Increases healing done by spells and effects by up to (%d+).",

	-- Talents
	["^Increases your spell damage by (%d+)%% and the critical strike chance of your offensive spells by (%d+)%%."] = "^Increases your spell damage by (%d+)%% and the critical strike chance of your offensive spells by (%d+)%%.",
	["Increases spell damage and healing by up to (%d+)%% of your total Strength."] = "Increases spell damage and healing by up to (%d+)%% of your total Strength.",
	["Increases your chance to hit with melee attacks and spells by (%d+)%%."] = "Increases your chance to hit with melee attacks and spells by (%d+)%%.",
	["Increases your chance to get a critical strike with attacks and offensive spells by (%d+)%%."] = "Increases your chance to get a critical strike with attacks and offensive spells by (%d+)%%.",
	["Increases spell damage and healing by up to (%d+)%% of your total Spirit."] = "Increases spell damage and healing by up to (%d+)%% of your total Spirit.",
	["Reduces your target's chance to resist your Shadow spells by (%d+)%%."] = "Reduces your target's chance to resist your Shadow spells by (%d+)%%.",
	["Regenerates 1% of your total Mana every (%d+) seconds."] = "Regenerates 1% of your total Mana every (%d+) seconds.",	
	
	-- ! Test if works in-game
	["Reduces the chance that the opponent can resist your Frost and Fire spells by (%d)%%."] = "Reduces the chance that the opponent can resist your Frost and Fire spells by (%d)%%.",
	["Reduces the chance that the opponent can resist your Arcane spells by (%d+)%% and gives you a (%d+)%% chance to avoid interruption caused by damage while channeling Arcane Missiles."] = "Reduces the chance that the opponent can resist your Arcane spells by (%d+)%% and gives you a (%d+)%% chance to avoid interruption caused by damage while channeling Arcane Missiles.",
	["Increases hit and crit chance by (%d+)%% for both you and your pet."] = "Increases hit and crit chance by (%d+)%% for both you and your pet.",
	["Increases your chance to hit with all attacks and spells by (%d+)%%."] = "Increases your chance to hit with all attacks and spells by (%d+)%%.",
	["Increases your chance to hit with Fire, Frost and Nature spells by (%d+)%%."] = "Increases your chance to hit with Fire, Frost and Nature spells by (%d+)%%.",
	["Increases your spell damage and critical strike chance by (%d+)%%."] = "Increases your spell damage and critical strike chance by (%d+)%%.",
	["Increases the critical strike chance of your Fire spells by (%d+)%%."] = "Increases the critical strike chance of your Fire spells by (%d+)%%.",
	["Improves your chance to get a critical strike with spells by (%d+)%%, but increases the threat generated by your critical hits by (%d+)%%."] = "Improves your chance to get a critical strike with spells by (%d+)%%, but increases the threat generated by your critical hits by (%d+)%%.",
	["Increases the critical strike chance of your Frost spells by (%d+)%% and the chance you are hit by melee and ranged attacks reduced by (%d+)%%."] = "Increases the critical strike chance of your Frost spells by (%d+)%% and the chance you are hit by melee and ranged attacks reduced by (%d+)%%.",
	["Increases the range of your Affliction spells by (%d+) yds and reduces the chance for enemies to resist your Affliction spells by (%d+)%%."] = "Increases the range of your Affliction spells by (%d+) yds and reduces the chance for enemies to resist your Affliction spells by (%d+)%%.",
	["Reduces the chance for enemies to resist your Destruction spells by (%d+)%% and gives you a (%d+)%% chance to resist interruption caused by damage while casting or channeling any Destruction spell."] = "Reduces the chance for enemies to resist your Destruction spells by (%d+)%% and gives you a (%d+)%% chance to resist interruption caused by damage while casting or channeling any Destruction spell.",
	["Increases the critical strike chance of your Destruction spells by (%d+)%%."] = "Increases the critical strike chance of your Destruction spells by (%d+)%%.",
	["Reduces the chance you'll be critically hit by melee attacks by (%d+)%%. In addition, your critical strikes restore (%d+)%% of your maximum health. This effect can only occur once every 5 sec."] = "Reduces the chance you'll be critically hit by melee attacks by (%d+)%%. In addition, your critical strikes restore (%d+)%% of your maximum health. This effect can only occur once every 5 sec.",
	["Reduces the chance you are critically hit by melee and ranged attacks by (%d+)%% and increases the threat reduction of your Feint ability by (%d+)%%."] = "Reduces the chance you are critically hit by melee and ranged attacks by (%d+)%% and increases the threat reduction of your Feint ability by (%d+)%%.",
	["Reduces the chance you are critically hit by (%d+)%%"] = "Reduces the chance you are critically hit by (%d+)%%",
	["Improves your chance to get a critical strike with your weapon attacks and Shock spells by (%d+)%%."] = "Improves your chance to get a critical strike with your weapon attacks and Shock spells by (%d+)%%.",
	["Increases your chance to get a critical strike with Axe, Fist and Dagger weapons by (%d+)%%."] = "Increases your chance to get a critical strike with Axe, Fist and Dagger weapons by (%d+)%%.",
	["Increases your chance to get a critical strike with Axes and Polearms by (%d+)%%."] = "Increases your chance to get a critical strike with Axes and Polearms by (%d+)%%.",
	["Improves your chance to hit with Taunt, Challenging Shout and Mocking Blow abilities by (%d+)%%."] = "Improves your chance to hit with Taunt, Challenging Shout and Mocking Blow abilities by (%d+)%%.", 
	["Improves your chance to hit with spells by (%d+)%% and reduces your target's resistance to all your spells by (%d+)."] = "Improves your chance to hit with spells by (%d+)%% and reduces your target's resistance to all your spells by (%d+).",
	["Reduces your target's resistance to all your spells by (%d+) and reduces the threat caused by your Arcane spells by (%d+)."] = "Reduces your target's resistance to all your spells by (%d+) and reduces the threat caused by your Arcane spells by (%d+).",


	["Increases the critical strike damage bonus of your offensive spells by (%d+)%% and for your feral abilities by (%d+)%%d."] = "Increases the critical strike damage bonus of your offensive spells by (%d+)%% and for your feral abilities by (%d+)%%d.",
	["Increases the critical strike damage bonus of your Holy spells by (%d+)%% and increases damage dealt to Undead or Demons by (%d+)%%."] = "Increases the critical strike damage bonus of your Holy spells by (%d+)%% and increases damage dealt to Undead or Demons by (%d+)%%.",
	["Increases the critical strike damage bonus of your Destruction spells by (%d+)%%."] = "Increases the critical strike damage bonus of your Destruction spells by (%d+)%%.",
	["Increases the critical strike damage bonus of your Searing, Magma, and Fire Nova Totems, and your Fire, Frost and Nature spells by (%d+)%%."] = "Increases the critical strike damage bonus of your Searing, Magma, and Fire Nova Totems, and your Fire, Frost and Nature spells by (%d+)%%.",
	["Increases the critical strike damage bonus of your spells by (%d+)%%."] = "Increases the critical strike damage bonus of your spells by (%d+)%%.",
	["Increases the critical strike damage bonus of your Frost spells by (%d+)%%."] = "Increases the critical strike damage bonus of your Frost spells by (%d+)%%.",


	-- V+ Specific Items
	["^Equip: Increases spell damage by up to (%d+)%% of your total Intellect and healing done by up to (%d+)%% of your total Spirit."] = "^Equip: Increases spell damage by up to (%d+)%% of your total Intellect and healing done by up to (%d+)%% of your total Spirit.",

	-- V+ Specific Enchants
	["(%d+)%% Resilience"] = "(%d+)%% Resilience",

	-- items
	["Equip: Decreases the magical resistances of your spell targets by (%d+)."] = "Equip: Decreases the magical resistances of your spell targets by (%d+).",

	-- auras, buffs, etc.
	["Chance to hit increased by (%d)%%."] = 														"Chance to hit increased by (%d)%%.",
	["Magical damage dealt is increased by up to (%d+)."] = 										"Magical damage dealt is increased by up to (%d+).",
	["Healing done by magical spells is increased by up to (%d+)."] = 								"Healing done by magical spells is increased by up to (%d+).",
	["Chance to hit reduced by (%d+)%%."] = 														"Chance to hit reduced by (%d+)%%.",
	["Chance to hit decreased by (%d+)%% and %d+ Nature damage every %d+ sec."] = 					"Chance to hit decreased by (%d+)%% and %d+ Nature damage every %d+ sec.",
	["Lowered chance to hit."] = 																	"Lowered chance to hit.", -- 5917	Fumble (25%)
	["Increases hitpoints by 300. 15%% haste to melee attacks. 10 mana regen every 5 seconds."] = 	"Increases hitpoints by 300. 15%% haste to melee attacks. 10 mana regen every 5 seconds.",
	["Improves your chance to hit by (%d+)%%."] = 													"Improves your chance to hit by (%d+)%%.",
	["Chance for a critical hit with a spell increased by (%d+)%%."] = 								"Chance for a critical hit with a spell increased by (%d+)%%.",
	["While active, target's critical hit chance with spells and attacks increases by 10%%."] = 	"While active, target's critical hit chance with spells and attacks increases by 10%%.",
	["Increases attack power by %d+ and chance to hit by (%d+)%%."] = 								"Increases attack power by %d+ and chance to hit by (%d+)%%.",
	["Holy spell critical hit chance increased by (%d+)%%."] = 										"Holy spell critical hit chance increased by (%d+)%%.",
	["Destruction spell critical hit chance increased by (%d+)%%."] = 								"Destruction spell critical hit chance increased by (%d+)%%.",
	["Arcane spell critical hit chance increased by (%d+)%%.\r\nArcane spell critical hit damage increased by (%d+)%%."] = "Arcane spell critical hit chance increased by (%d+)%%.\r\nArcane spell critical hit damage increased by (%d+)%%.",
	["Spell hit chance increased by (%d+)%%."] = 													"Spell hit chance increased by (%d+)%%.",
	
	["Increases chance for a melee, ranged, or spell critical by (%d+)%% and all attributes by %d+."] = "Increases chance for a melee, ranged, or spell critical by (%d+)%% and all attributes by %d+.",
	["Melee critical-hit chance reduced by (%d+)%%.\r\nSpell critical-hit chance reduced by (%d+)%%."] = "Melee critical-hit chance reduced by (%d+)%%.\r\nSpell critical-hit chance reduced by (%d+)%%.",
	["Increases critical chance of spells by 10%%, melee and ranged by 5%% and grants 140 attack power. 120 minute duration."] = "Increases critical chance of spells by 10%%, melee and ranged by 5%% and grants 140 attack power. 120 minute duration.",
	["Holy spell critical hit chance increased by (%d+)%%."] = "Holy spell critical hit chance increased by (%d+)%%.",
	["Destruction spell critical hit chance increased by (%d+)%%."] = "Destruction spell critical hit chance increased by (%d+)%%.",
	["Critical strike chance with spells and melee attacks increased by (%d+)%%."] = "Critical strike chance with spells and melee attacks increased by (%d+)%%.",
	
	-- Headers or Tooltips
	["HIT_TOOLTIP_HEADER"] = [[|cffffffffHit Rating      %s|r]],
	["HIT_TOOLTIP"] = "Increases your %s chance to hit a target of level %d by %s\r\n",

	["ATTACK_POWER_TOOLTIP"] = "Increase damage with %s \r\nweapons by %.1f damage per second.",

	["SPELL_POWER_TOOLTIP_HEADER"] = [[|cffffffffBonus Damage %d|r]],
	["SPELL_CRIT_TOOLTIP_HEADER"] = [[|cffffffffSpell Crit      %s|r]],
	["CRIT_TOOLTIP_HEADER"] = [[|cffffffffCrit      %s|r]],

	["SPELL_HEALING_POWER_TOOLTIP_HEADER"] = [[|cffffffffHealing Power %d|r]],
	["SPELL_HEALING_POWER_TOOLTIP"] = "Increases your healing by %d.",	
	
	["SPELL_MANA_REGEN_TOOLTIP_HEADER"] = [[|cffffffffMana Regen|r]],
	["SPELL_MANA_REGEN_TOOLTIP"] = "%d mana regenerated every 5 \r\nseconds while not casting.",
	
	["ROGUE_MELEE_HIT_TOOLTIP"] = [[
	
	+5% hit to always hit enemy players.
	+8% hit to always hit with your special abilities against a raid boss.
	+24.6% hit to always hit a raid boss.]],

	["MANA_SPRING_TOTEM"] = "\n|cff0099ff%s|cff00ff00 per tick from Mana Spring Totem |cff0099ff%s|cff00ff00 mp5.|r",
	["BRILLIANCE_AURA"] = "\n|cff0099ff%s|cff00ff00 per tick from Brilliance Aura |cff0099ff%s|cff00ff00 mp5.|r",
	["BLESSING_OF_WISDOM"] = "\n|cff0099ff%s|cff00ff00 per tick from Blessing of Wisdom |cff0099ff%s|cff00ff00 mp5.|r",
	["WINSORS_WBUFF"] = "\n|cff0099ff%s|cff00ff00 per tick from Winsor's Sacrifice |cff0099ff%s|cff00ff00 mp5.|r",

	--Talent Tooltips
	["DIVINE_CONCENTRATION"] = "\n|cff0099ff%s|cff00ff00 per tick from Divine Concentration. |cff0099ff%s|cff00ff00 mp5.|r",
	["DREAMSTATE"] = "\n|cff0099ff%s|cff00ff00 per tick from Dreamstate. |cff0099ff%s|cff00ff00 mp5.|r",
		

	PLAYERSTAT_BASE_STATS = "Base Stats",
	PLAYERSTAT_DEFENSES = "Defenses",
	PLAYERSTAT_MELEE_COMBAT = "Melee",
	PLAYERSTAT_RANGED_COMBAT = "Ranged",
	PLAYERSTAT_SPELL_COMBAT = "Spell",
	
	MELEE_HIT_RATING_COLON = "Hit Rating:",
	RANGED_HIT_RATING_COLON = "Hit Rating:",
	SPELL_HIT_RATING_COLON = "Hit Rating:",
	MELEE_CRIT_COLON = "Crit%:",
	RANGED_CRIT_COLON = "Crit%:",
	SPELL_CRIT_COLON = "Crit%:",
	DODGE_COLON = DODGE .. ":",
	PARRY_COLON = PARRY .. ":",
	BLOCK_COLON = BLOCK .. ":",
	RESILIENCE_COLON = "Resilience:",
	
	
	SPELL_POWER_COLON = "Bonus Damage:",
	HEAL_POWER_COLON = "Bonus Healing:",
	MANA_REGEN_COLON = "Mana Regen:",
	SPELL_PEN_COLON = "Spell Pen:",
	
	SPELL_SCHOOL_ARCANE = "Arcane",
	SPELL_SCHOOL_FIRE = "Fire",
	SPELL_SCHOOL_FROST = "Frost",
	SPELL_SCHOOL_HOLY = "Holy",
	SPELL_SCHOOL_NATURE = "Nature",
	SPELL_SCHOOL_SHADOW = "Shadow",
	
}