# Before merging `Overhaul` into master

- Remove `BCS:DebugGearStatBonus` from `helper.lua` (temporary debug helper added
  while diagnosing the set-bonus double-counting issue in `BCS:GetGearStatBonus`).
  Usage was: `/script BCS:DebugGearStatBonus("Stamina")`
- Remove `BCS:DebugSpellHaste` from `helper.lua` (temporary debug helper used to
  confirm the real Haste tooltip wording: "Increases your attack and casting
  speed by X%." on items, "Increases your casting speed by X%." on talents).
- Remove `BCS:DebugBuffs` from `helper.lua` (temporary debug helper used to
  confirm Bloodlust's actual buff tooltip wording: "Attack and casting speed
  increased by X%." -- differs from the items/talents wording above).

# Possible future features

- Weapon Expertise (Bow/Gun/Crossbow Specialization talents) -- currently NOT
  tracked anywhere in the addon:
  - Hunter: "Gives you a 1% chance to launch an extra arrow to the same
    target after dealing damage with your Bow."
  - Rogue: "Increases your chance to get a critical strike with Crossbows
    by 1%." (GetRangedCritChance only has a generic "ranged weapons" talent
    pattern, no per-weapon-type Bow/Gun/Crossbow breakdown like melee has
    for Axe/Dagger/Fist/Polearm.)
  - Hunter: "Causes your shots to ignore up to 2 per level of your target's
    Armor when carrying a Gun." (no armor-penetration tracking exists
    anywhere.)
  - Warrior: Weapon Expertise talent(s) -- exact tooltip text not yet
    gathered, needs the specific wording before it can be implemented.
