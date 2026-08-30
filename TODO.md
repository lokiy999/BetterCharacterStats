# BetterCharacterStats -- TODO / known issues

Findings from a review pass on the `fixes` branch. Nothing here is a crash;
the addon works. Grouped by type, roughly most to least important.

## Correctness gaps

- [x] **`GetSpellHaste` ignores casting-speed slows.** Now scans HARMFUL for
      Curse of Tongues / Mind-numbing Poison / Slow wordings and subtracts.
      Verify the pattern list matches this server's actual debuff tooltips.
- [x] **`GetSpellHaste` only counts one haste buff.** New `SumAuraMatches`
      helper loops all buffs (and all debuffs for slows) and sums the first
      matching pattern per aura, so multiple haste buffs / multiple slows stack.
- [ ] **`GetSpellHaste` gear scan wordings.** Matches
      `Increases your attack and casting speed by X%.`,
      `Increases your casting speed by X%.`, `+X% Haste` and `Haste +X%` (with
      set-bonus dedup, "Use:" lines skipped). Add more custom Vanilla+ phrasings
      as they turn up.
- [ ] **`SetRangedAttackSpeed` has a large dead block.** `BetterCharacterStats.lua`
      `SetRangedAttackSpeed` lines ~1073-1117 compute and set a damage range into
      `damageText`, which is then unconditionally overwritten with the attack
      speed at the end. The tooltip built mid-function is never shown (no
      `OnEnter` is set). Decide: wire up the tooltip, or delete the damage math
      (keep only what feeds `.damage` / `.dps` if anything reads them).
- [x] **BoW "math fix" hardcodes.** Removed. Combat log (2026-08-30) shows BoW is
      a 5s periodic energize for its exact tooltip value, with the spirit tick
      unchanged -- so BoW now goes into `periodicMp5`, not `flatMp5`, and
      `finalBoWMP5` is used as-is. See `docs/mana-regen.md`.
- [x] **Mana Spring Totem bucketing.** Combat log (2026-08-30, Shaman) shows a
      separate `+10` next to the `+40` spirit tick -> moved to `periodicMp5`.
- [ ] **Warchief's / Winsor's bucketing.** Moved to `periodicMp5` by inference
      from the "30 mana regen every 5 seconds" wording (same as BoW / Mana
      Spring). Still needs a combat-log check; if it's actually combined, move
      the `warchiefsRegenmp5` / `winsorsRegenmp5` terms back into `flatMp5`.
- [ ] **Mana Spring / BoW are detected two different ways.**
      `SetSpellManaRegen` checks `BCS:GetPlayerAuraTexture(icon)` while
      `UpdateManaSpringTotem` / `UpdateBlessingOfWisdom` check
      `BCS:GetPlayerAuraValue(tooltip text)`. If the server's icon or tooltip
      wording differs from one path, the two disagree (one adds the value, the
      other shows/hides the line). Consolidate on one detection method.
- [ ] **Meditation / Arcane Meditation / Reflection at partial talent ranks.**
      Vanilla talent tooltips sometimes show the *next* rank's value at 1-2/3.
      Run `/script BCS:DebugCastingRegenTalent()` at each rank investment: it
      prints `rank/maxRank` next to the % the SetTalent tooltip shows. If they
      disagree (e.g. Reflection 1/3 -> "15%"), switch `GetManaRegen`'s scan to
      `rank * 5` (all three are 5%/rank) instead of trusting the tooltip number.

## Correctness gaps (cont.)

- [x] **`GetSpellPower` double-counts some damage auras.** The Zandalarian Hero
      Charm aura and the Moonkin Form spell-damage bonus were added to both
      `spellPower` and `damagePower`; `SetSpellPower` shows `spellPower +
      damagePower`, so they counted twice. Now `damagePower` only.
- [x] **`SetSpellPower` per-school branch is broken.** Removed -- the per-school
      breakdown is already in the Bonus Damage hover tooltip, so the dead
      `if school then` branch (undefined `fromSchool`) was redundant.

## Code smells (work, but should be cleaned)

- [x] **Dead block in `GetHitRating`.** Removed the commented-out cached-talent
      scan and the `Localization.lua` line only it referenced; the live talent
      loop was also refactored (see next item).
- [x] **Dead `GetSpellPower_old`.** Removed (~230-line commented-out block).
- [x] **Implicit globals from `GetTalentInfo`.** The `GetHitRating` live loop
      wrote `name/rank/...` as globals in 3 places; rewritten to fetch `rank`
      once per talent as a local. Everything else already used `local`.
- [x] **Implicit global `value` / `value2`.** Added `local value, value2` at the
      top of `GetSpellHitRating`, `GetSpellCritChance` and `GetHealingPower`, so
      the bare `_,_, value[, value2] = strfind(...)` scans no longer leak.
- [x] **`lastMsTVal` is an implicit global.** Now a file-local next to
      `lastBlessingOfWisdomMP5` / `lastGearBonus`.
- [x] **Duplicate `stat4` lines in `UpdatePaperdollStats`.** Replaced the reset
      block with a `for i = 1, 7` loop (also now resets `OnLeave`).
- [ ] **`BCS.SPELLHIT = { -- soon(tm) }`** in `BetterCharacterStats.lua` -- empty
      placeholder table, either use or remove.

## Stale docs / comments

- [x] **README.md** "Haste rating still not implemented" -- removed; README now
      points at this file.
- [x] **`helper.lua` `GetManaRegen`** `-- to-maybe-do: apply buffs/talents` --
      removed (talents/buffs are applied now).
- [x] **`Localization.lua`** the `-- ! Deprecated ["Increases hit chance by
      ..."]` commented line -- removed with the dead `GetHitRating` block.
- [x] **`Localization.lua`** unreferenced `"...15% haste to melee attacks..."`
      (Warchief's) entry removed -- `GetMeleeHaste` derives from swing speed.

## Melee Haste (added -- verify)

- [ ] `GetMeleeHaste` derives % from `base weapon speed / UnitAttackSpeed`.
      Verify against known setups. Handled: unarmed (2.0), Cat Form (1.0),
      Bear/Dire Bear Form (2.5, detected by `Ability_Druid_CatForm` /
      `Ability_Racial_BearForm` buff icons -- confirmed on this client). NOT
      handled: off-hand shown separately, servers that show haste-modified
      speed in the weapon tooltip.

## Before merging `fixes` -> master

- [ ] Remove the `DEBUG HELPERS` block in `helper.lua` (`DebugBuffs`,
      `DebugGearStatBonus`, `DebugSpellHaste`, `DebugManaRegen`,
      `DebugCastingRegenTalent`). Also drop the `docs/mana-regen.md` reference to
      `DebugManaRegen` if it goes.

## Features not implemented anywhere

- [ ] Mana Spring Totem **gear snapshot** / **Ten Storms 2-pc** bonus
      (`helper.lua` `UpdateManaSpringTotem` / `GetGearSetBonus`). Shaman only.
- [ ] **Weapon Expertise** talents (Bow/Gun/Crossbow Specialization) -- no
      per-weapon-type ranged crit/hit breakdown, unlike melee's Axe/Dagger/
      Fist/Polearm handling.
- [ ] **Armor penetration** -- Hunter "shots ignore X armor with a Gun", etc.
      Not tracked anywhere.
- [ ] Warrior Weapon Expertise talent(s) -- exact tooltip wording still needs to
      be gathered before it can be added.
- [ ] Spell Tap (Priest) talent tooltip vs. proc-buff tooltip -- only the proc
      buff wording is currently matched; confirm the talent itself doesn't also
      need a pattern.
