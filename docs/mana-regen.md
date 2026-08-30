# Mana regen calculation

This documents **why** `BCS:SetManaRegen` (in `BetterCharacterStats.lua`)
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
- **Flat `mana per 5 sec` from gear**: gear, enchants, set bonuses, weapon mana
  oils, "well fed" food buffs. These are true `SPELL_AURA_MOD_POWER_REGEN`.

**Not** in the combined rate on this server: **Blessing of Wisdom**, **Mana
Spring Totem**, **Warchief's Blessing / Winsor's Sacrifice** — all of these are
separate periodic energizes (see below).

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
- **Blessing of Wisdom** — the full tooltip value ("Restores N mana every 5
  seconds") every 5s. Verified in-game 2026-08-30: combat log shows a discrete
  "N mana from Blessing of Wisdom" every 5s, the 2s spirit tick is unchanged
  by the buff, and it keeps firing at full value while casting. So BoW is added
  straight to the periodic total (`+ blessingRegenmp5` in `periodicMp5`), not to
  `flatMp5`. The old per-rank "off by 1" fixes (43→42, 33→32) were compensating
  for the wrong model and have been removed — `finalBoWMP5` is used as-is.
- **Mana Spring Totem** — full tooltip value (10) every 2s. Verified in-game
  2026-08-30 on a Shaman: combat log shows separate `+40` (spirit tick) and
  `+10` (Mana Spring) events. Added to `periodicMp5` as `manaSpringmp5`
  (= `10 * 5/2` = 25 mp5), not to `flatMp5`.
- **Warchief's Blessing / Winsor's Sacrifice** — "30 mana regen every 5 seconds".
  Same wording family as BoW; carried in `periodicMp5` by inference, not yet
  combat-log-verified. If it turns out to be combined instead, move the two
  `warchiefsRegenmp5` / `winsorsRegenmp5` terms back into `flatMp5`.

## What the addon must therefore do

- Sum Spirit regen and the **gear/enchant/set/oil/food** flat mp5 **before**
  flooring, and floor **once**. Never convert a single gear source to mp5 and
  round it on its own — the fractions from Spirit (`Spirit/4` is rarely whole)
  and from each mp5 source would drift and the headline would read 1-2 high/low.
- Every other source (BoW, Mana Spring, Warchief's/Winsor's, Brilliance, Divine
  Concentration, Dreamstate) is added on top as `periodicMp5` — each already an
  integer mp5 amount floored on its own timer.
- Headline number = `floor(combined_tick * 2.5) + periodicMp5`.
- Tooltip layout:
  - `N mana every 2 sec while not casting  (= floor(N*2.5) mp5)` — the combined
    Spirit+gear tick and its rate. The rate is shown so `rate + periodic = total`
    adds up on screen.
  - `M mana every 2 sec while casting` — same tick with the Spirit part scaled by
    the five-second-rule %.
  - `Gear & enchants: G mp5 (breakpoint B, next X)` — only when `G > 0`. `B` is
    the flat mp5 at which the current tick level starts, `X` the flat mp5 that
    raises it by one. Both shift with Spirit's own fraction.
  - `Already in the total:` then one `+K mp5` line per active
    periodic source. No total line -- the headline stat (labelled
    `Regen (mp5):`) already is the grand total.

## Assumptions (break these and the number will be off)

| Assumption                                   | Notes                                |
|----------------------------------------------|--------------------------------------|
| Regen tick is exactly 2.0 s                  | confirmed in-game                    |
| Mana-regen rate multiplier = 1.0             | `CONFIG_FLOAT_RATE_POWER_MANA`; a server-wide buff to mana regen would need a multiplier here |
| No fractional-mana carry-over                | confirmed in-game                    |
| No `SPELL_AURA_MOD_POWER_REGEN_PERCENT` auras | none common in Vanilla; would scale the Spirit part |
| BoW / Mana Spring are periodic, not combined | confirmed in-game 2026-08-30 (combat log) |
| Warchief's / Winsor's are periodic too       | inferred from wording; not yet combat-log-verified |

## History

- Originally each source was converted to an mp5 number and rounded separately,
  then summed. This drifted 0-2 vs the game. Reworked to the single-combined-
  floor model above (see PR "Fixes", branch `fixes`).
- Then BoW was moved out of the combined tick into the periodic total after the
  combat log showed it energizing on its own 5s timer with the spirit tick
  untouched (2026-08-30). The 43→42 / 33→32 rank hacks were removed with it.
- Mana Spring Totem moved the same way (separate `+10` in the combat log next to
  the spirit tick, 2026-08-30). Warchief's / Winsor's moved along with them by
  the shared "mana every 5 sec" wording. Only gear/enchant/set/oil/food mp5 now
  feeds the combined tick.
