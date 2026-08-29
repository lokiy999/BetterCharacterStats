# Before merging `Overhaul` into master

- Remove the "DEBUG HELPERS" block near the top of `helper.lua` (right after
  `tContains`) before merging. It groups three temporary debug functions:
  - `BCS:DebugGearStatBonus(statName)` -- used while diagnosing the set-bonus
    double-counting issue in `BCS:GetGearStatBonus`.
    Usage: `/script BCS:DebugGearStatBonus("Stamina")`
  - `BCS:DebugSpellHaste()` -- used to confirm the real Haste tooltip wording
    ("Increases your attack and casting speed by X%." on items, "Increases
    your casting speed by X%." on talents).
    Usage: `/script BCS:DebugSpellHaste()`
  - `BCS:DebugBuffs()` -- used to confirm Bloodlust's actual buff tooltip
    wording ("Attack and casting speed increased by X%." -- differs from the
    items/talents wording above).
    Usage: `/script BCS:DebugBuffs()`
  - `BCS:DebugManaRegen()` -- used to trace mp5 gear/enchant lines the scanner
    in `GetManaRegen` misses (in-game tick higher than the tooltip).
    Usage: `/script BCS:DebugManaRegen()`

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
