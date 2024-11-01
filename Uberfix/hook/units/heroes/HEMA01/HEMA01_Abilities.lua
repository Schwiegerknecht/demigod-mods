--Mithy: Torchbearer Permafrost rate of fire debuff fix
--ROF debuff progression is -3/10/15% at levels I/II/III, while Fire Aura (and every other similar buff or debuff)
--is 5/10/15%.  Consensus is that -5/10/15% was developer intent for this debuff, and the presence of an intended -0.03
--movement speed affect on the next line down in the same debuff is the likely cause of this error.
Buffs.HEMA01FrostAura01.Affects.RateOfFire.Mult = -0.05 # from -0.03

--Frost Nova slow duration increase to account for time frozen
--According to the ability's description and visual effects, you would expect the slow to last for a full 5 seconds
--after being unfrozen; however, the 5 second duration for the slow buffs begins at the same time as the freeze,
--resulting in a 4s slow at level I, and only a 2s slow at level III.  There are multiple factors that strongly
--suggest that this is not the intended functionality of the slow, not the least of which being the decrease in
--effectiveness at higher levels.
Buffs.HEMA01NovaSlow01.Duration = 6 # from 5
Buffs.HEMA01NovaSlow02.Duration = 7 # from 5
Buffs.HEMA01NovaSlow03.Duration = 8 # from 5
--Adjust lowest and highest VFX buff durations inward to match
Buffs.HEMA01NovaSlowFx01.Duration = 6 # from 5
Buffs.HEMA01NovaSlowFx03.Duration = 8 # from 10

--Torchbearer reversed modal buff name fix
Buffs.HEMA01FrozenHeart.DisplayName = '<LOC ABILITY_HEMA01_0002>Soul of Ice'
Buffs.HEMA01ReliveImmolation.DisplayName = '<LOC ABILITY_HEMA01_0006>Heart of Fire'