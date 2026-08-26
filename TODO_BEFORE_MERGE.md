# Before merging `Overhaul` into master

- Remove `BCS:DebugGearStatBonus` from `helper.lua` (temporary debug helper added
  while diagnosing the set-bonus double-counting issue in `BCS:GetGearStatBonus`).
  Usage was: `/script BCS:DebugGearStatBonus("Stamina")`
- Remove `BCS:DebugSpellHaste` from `helper.lua` (temporary debug helper used to
  confirm the real Haste tooltip wording: "Increases your attack and casting
  speed by X%." on items, "Increases your casting speed by X%." on talents).
