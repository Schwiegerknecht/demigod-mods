--AI movement stutter fix; arrow blueprint ROF quartered, so the poison chance needs to be increased
--Chance per second is theoretically the same, except for the fact that with 2s ROF, the arrows only get
--one volley in per debuff, making the buff less likely to stay on (~80% some chance, from ~99% chance),
--so the duration is increased 1s to 4s, giving a similar ~97% chance per second for the debuff to stay on.
Ability.HRookPoison.TriggerChance = 30 --from 15
Buffs.HRookPoison.Duration = 4 --from 3