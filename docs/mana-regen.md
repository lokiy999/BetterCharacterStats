# Mana regen calculation

This documents **why** `BCS:SetSpellManaRegen` (in `BetterCharacterStats.lua`)
combines mana-regen sources the way it does. If the displayed number ever turns
out wrong on some server, start here.

## How the server computes mana regen (Vanilla / Vanilla+)

Mana regenerates in **ticks every 2 seconds**. Two kinds of sources feed it:

### 1. The single combined rate (`SPELL_AURA_MOD_POWER_REGEN` + Spirit)

The server keeps **one** floating-point rate, `m_modManaRegen`, built from:

- **Spirit regen** — `OCTRegenMPPerSpirit()`, per class:
  - Druid / Hunter / Paladin / Warlock: `Spirit / 5 + 15`
  - Mage / Priest:                       `Spirit / 4 + 12.5`
  - Shaman:                              `Spirit / 5 + 17`
  (These are per-2s-tick values. `Spirit` is the effective value incl. buffs.)
- **Every flat `mana per 5 sec` effect**, all of which are
  `SPELL_AURA_MOD_POWER_REGEN`: gear, enchants, set bonuses, weapon mana oils,
  "well fed" food buffs, **Blessing of Wisdom**, **Mana Spring Totem**,
  **Warchief's Blessing / Winsor's Sacrifice** mana component.

Each 2s tick the server does **ONE** conversion and **ONE** floor on the sum:

```
tick_gain = floor( spirit_regen  +  sum_of_all_flat_mp5 * 2/5 )
```

There is **no fractional carry-over** between ticks on this server (verified
in-game: a 3.6/tick value pays 3 every tick, forever, never 4). So the fraction
is simply lost each tick.

While casting (within the five-second rule) the Spirit part is scaled by the
"% of mana regeneration continues while casting" total (Meditation, Arcane
Meditation, Reflection, Mage Armor, Transcendence 2-set, Aura of the Blue
Dragon, Spirit Tap), capped at 100%. The flat mp5 part is **not** reduced:

```
tick_gain_casting = floor( spirit_regen * pct/100  +  sum_of_all_flat_mp5 * 2/5 )
```

### 2. Separate periodic-energize effects

These are **not** part of `m_modManaRegen`. Each is its own periodic aura that
fires on its own timer and is floored independently:

- **Brilliance Aura** — 1% of max mana every 10s
- **Divine Concentration** (Paladin talent) — 1% of max mana every N s
- **Dreamstate** (Druid talent) — X% of max mana every 10s

## What the addon must therefore do

- Sum Spirit regen and **all** flat mp5 sources **before** flooring, and floor
  **once**. Never convert a single source to mp5 and round it on its own — the
  fractions from Spirit (`Spirit/4` is rarely whole) and from each mp5 source
  would drift and the headline would read 1-2 high or low.
- Keep Brilliance / Divine Concentration / Dreamstate outside that combined
  floor and add them separately (they already are).
- Headline number = `floor(combined_tick) * 2.5  +  periodic sources`.
- Tooltip "while not casting" / "while casting" lines = the combined floored
  tick (Spirit + every flat mp5), with the per-buff lines below as a breakdown.
- `mp5:` line shows the raw summed flat mp5; the `(+N mp5 to next tick)` hint is
  `(1 - frac(combined_tick)) * 2.5` — how much more flat mp5 raises the tick by
  one. With the combined floor, "wasted" mp5 is usually < 1 tick because
  Spirit's own fraction fills most of the gap.

## Assumptions (break these and the number will be off)

| Assumption                                   | Notes                                |
|----------------------------------------------|--------------------------------------|
| Regen tick is exactly 2.0 s                  | confirmed in-game                    |
| Mana-regen rate multiplier = 1.0             | `CONFIG_FLOAT_RATE_POWER_MANA`; a server-wide buff to mana regen would need a multiplier here |
| No fractional-mana carry-over                | confirmed in-game                    |
| No `SPELL_AURA_MOD_POWER_REGEN_PERCENT` auras | none common in Vanilla; would scale the Spirit part |
| BoW / Mana Spring per-rank values are right  | `GetManaRegen` has empirical "off by 1" fixes for some BoW ranks; if combined-flooring makes those fixes wrong, revisit them |

## History

- Originally each source was converted to an mp5 number and rounded separately,
  then summed. This drifted 0-2 vs the game. Reworked to the single-combined-
  floor model above (see PR "Fixes", branch `fixes`).
