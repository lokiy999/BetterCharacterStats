# Before merging `Overhaul` into master

- Remove `BCS:DebugGearStatBonus` from `helper.lua` (temporary debug helper added
  while diagnosing the set-bonus double-counting issue in `BCS:GetGearStatBonus`).
  Usage was: `/script BCS:DebugGearStatBonus("Stamina")`
