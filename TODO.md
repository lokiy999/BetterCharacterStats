# BetterCharacterStats -- TODO / known issues

Findings from a review pass on the `fixes` branch. Nothing here is a crash;
the addon works. Grouped by type, roughly most to least important.

## Correctness gaps

- [x] **`GetSpellHaste` ignores casting-speed slows.** Now scans HARMFUL for
      Curse of Tongues / Mind-numbing Poison / Slow wordings and subtracts.
      Verify the pattern list matches this server's actual debuff tooltips.
- [ ] **`GetSpellHaste` only counts one haste buff.** The buff scan uses
      `BCS:GetPlayerAura(...)`, which returns the first match. Two simultaneous
      haste buffs (trinket + Mind Quickening, etc.) undercount. Needs a loop
      over all buffs like the crit scan does, or repeated patterns.
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
- [ ] **BoW "math fix" hardcodes.** `helper.lua` `GetManaRegen`:
      `if finalBoWMP5 == 43 then finalBoWMP5 = 42` (and `33 -> 32`). Fragile, and
      now that the mana-regen headline floors the *combined* value these may
      double-correct or become wrong. Re-test every BoW / Greater BoW rank
      against the in-game tick and remove the hacks if the combined floor
      already produces the right number. See `docs/mana-regen.md`.
- [ ] **Mana Spring / BoW are detected two different ways.**
      `SetSpellManaRegen` checks `BCS:GetPlayerAuraTexture(icon)` while
      `UpdateManaSpringTotem` / `UpdateBlessingOfWisdom` check
      `BCS:GetPlayerAuraValue(tooltip text)`. If the server's icon or tooltip
      wording differs from one path, the two disagree (one adds the value, the
      other shows/hides the line). Consolidate on one detection method.
- [ ] **Arcane Meditation at partial talent ranks.** Vanilla talent tooltips
      sometimes show the *next* rank's value when a talent is 1-2/3. Verify
      `BCS_Tooltip:SetTalent` returns the *current* rank's % for
      Meditation / Arcane Meditation / Reflection in `GetManaRegen`'s
      casting-regen scan; adjust if it reads the wrong rank.

## Code smells (work, but should be cleaned)

- [ ] **Dead block in `GetHitRating`.** `helper.lua` lines ~715-779 are a
      commented-out `--[[ ]]` cached-talent scan. Remove it (and the
      `Localization.lua` line it references, below).
- [ ] **Implicit globals from `GetTalentInfo`.** ~7 spots in `helper.lua` do
      `name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq
      = GetTalentInfo(...)` with no `local`, leaking `rank`, `name`, etc. to the
      global namespace. Add `local`.
- [ ] **`lastMsTVal` is an implicit global.** `helper.lua`
      `UpdateManaSpringTotem`. Make it a file-local like `lastBlessingOfWisdomMP5`
      / `lastGearBonus` at the top of the file.
- [ ] **Duplicate `stat4` lines in `UpdatePaperdollStats`.**
      `BetterCharacterStats.lua` ~1168-1193 clears `stat4`'s `OnEnter` /
      `.tooltip` / `.tooltipSubtext` twice each and never a missing one --
      harmless copy-paste, just tidy it (a loop over `stat1..stat7` would do).
- [ ] **`BCS.SPELLHIT = { -- soon(tm) }`** in `BetterCharacterStats.lua` -- empty
      placeholder table, either use or remove.
- [ ] **No hover tooltip on Haste / Spell Pen / Dodge / Parry.** Dodge/Parry
      matching Blizzard is fine; a Haste breakdown (gear vs talent vs buff, like
      the crit tooltip) would be nice.

## Stale docs / comments

- [ ] **README.md** "Haste rating still not implemented" -- spell Haste *is*
      implemented (Spell tab). Update the Known Issues list.
- [ ] **`helper.lua` `GetManaRegen`** `-- to-maybe-do: apply buffs/talents` --
      casting-regen talents/buffs are applied now; reword or drop.
- [ ] **`Localization.lua`** the `-- ! Deprecated ["Increases hit chance by
      ..."]` commented line -- only referenced by the dead `GetHitRating` block;
      remove with it.
- [ ] **`Localization.lua:183`** `"...15% haste to melee attacks..."` (Warchief's
      wording) is unreferenced. `GetMeleeHaste` derives haste from swing speed
      instead of scanning, so this entry can be removed.

## Melee Haste (added -- verify)

- [ ] `GetMeleeHaste` derives % from `base weapon speed / UnitAttackSpeed`.
      Verify against known setups. Edge cases handled: unarmed (2.0), Cat Form
      (1.0), Bear/Dire Bear Form (2.5). NOT handled: off-hand shown separately,
      non-melee druid forms (Moonkin/Travel fall through to weapon speed),
      servers that show haste-modified speed in the weapon tooltip.

## Before merging `fixes` -> master

- [ ] Remove the `DEBUG HELPERS` block in `helper.lua` (`DebugBuffs`,
      `DebugGearStatBonus`, `DebugSpellHaste`, `DebugManaRegen`). Also drop the
      `docs/mana-regen.md` reference to `DebugManaRegen` if it goes.

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
