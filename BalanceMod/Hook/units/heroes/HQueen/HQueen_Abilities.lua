--Increase Compost Shambler Damage 4,6,8,10,15,20 (normally 4,6,8,10,12,14)
-- level 1 = 4-10 (6 point spread) level 2 = 6-15 (9 point spread), level 3 = 8-20 (12 point spread)
Buffs.HQueenCompostPowerBuffMinion01.Affects.DamageRating.Add = 4
Buffs.HQueenCompostPowerBuffMinion02.Affects.DamageRating.Add = 6
Buffs.HQueenCompostPowerBuffMinion03.Affects.DamageRating.Add = 8
Buffs.HQueenCompostPowerBuffMinion04.Affects.DamageRating.Add = 10
Buffs.HQueenCompostPowerBuffMinion05.Affects.DamageRating.Add = 15
Buffs.HQueenCompostPowerBuffMinion06.Affects.DamageRating.Add = 20

-- Restore Compopst buff levels to increase QoT range, as seen in beta
-- Buffs.HQueenCompostPowerBuff01.Affects.MaxRadius = {Add = 1}
-- Buffs.HQueenCompostPowerBuff02.Affects.MaxRadius = {Add = 2}
-- Buffs.HQueenCompostPowerBuff03.Affects.MaxRadius = {Add = 3}
-- Buffs.HQueenCompostPowerBuff04.Affects.MaxRadius = {Add = 4}
-- Buffs.HQueenCompostPowerBuff05.Affects.MaxRadius = {Add = 5}
-- Buffs.HQueenCompostPowerBuff06.Affects.MaxRadius = {Add = 6}

--Update Skill Derscriptions
Buffs.HQueenCompostPowerBuff01.Description = 'Shambler and Uproot damage increased.'
Buffs.HQueenCompostPowerBuff02.Description = 'Shambler and Uproot damage increased.'
Buffs.HQueenCompostPowerBuff03.Description = 'Shambler and Uproot damage increased.'
Buffs.HQueenCompostPowerBuff04.Description = 'Shambler and Uproot damage increased.'
Buffs.HQueenCompostPowerBuff05.Description = 'Shambler and Uproot damage increased.'
Buffs.HQueenCompostPowerBuff06.Description = 'Shambler and Uproot damage increased.'

-- Ability.HQueenCompost01.Description = 'As nearby enemies die, their bodies nourish Queen of Thorns. For every 3 enemies killed, Uproot increases in damage. Queen of Thorns Weapon Range increases. Shamblers gain Weapon Damage and Health. The effects cap at 9 enemies killed, and the effects diminish over time.'
-- Ability.HQueenCompost02.Description = 'As nearby enemies die, their bodies nourish Queen of Thorns. For every 3 enemies killed, Uproot increases in damage. Queen of Thorns Weapon Range increases. Shamblers gain Weapon Damage and Health. The effects cap at 9 enemies killed, and the effects diminish over time.'
-- Ability.HQueenCompost03.Description = 'As nearby enemies die, their bodies nourish Queen of Thorns. For every 3 enemies killed, Uproot increases in damage. Queen of Thorns Weapon Range increases. Shamblers gain Weapon Damage and Health. The effects cap at 9 enemies killed, and the effects diminish over time.'

-- Increase uproot range from 20 to match Rook's Treb Hat (range 35)
Ability.HQueenUproot01.RangeMax = 20
Ability.HQueenUproot02.RangeMax = 25
Ability.HQueenUproot03.RangeMax = 30
Ability.HQueenUproot04.RangeMax = 35

-- Entourage increase damage to 10 (from 6) 
Buffs.HQueenEntourageBuff01.Affects.DamageRating.Add = 10
Buffs.HQueenEntourageBuff02.Affects.DamageRating.Add = 20
Buffs.HQueenEntourageBuff03.Affects.DamageRating.Add = 30

--Reduce Spikewave III to 10 second cooldown from 15
Ability.HQueenSpikeWave03.Cooldown = 10

--Reduce Groundspike I to 425 mana down from 500 mana (so mana cost per level scales now 425,500,675,750)
Ability.HQueenGroundSpikes01.EnergyCost = 425

--Reduce consume delay to damage (0.5 seconds down from 2)
#################################################################################################################
# CE: Consume Shambler
#################################################################################################################
function Consume(abilityDef, unit, params)
    local target = params.Targets[1]
    if not target:IsDead() then
        target.Mulch = true
        if not target.KillData then
            target.KillData = {}
        end
        target:Kill()
        Buff.ApplyBuff(unit, abilityDef.RegenBuffName, unit)

        # Temp consume effects at target
        AttachEffectAtBone( target, 'Queenofthorns', 'MulchTarget01', -2 )

        # Create uproot cast effects at Queen
        AttachEffectAtBone( unit, 'Queenofthorns', 'MulchCast01', -2 )
    
        local pos = target:GetPosition()
        local data = {
            Instigator = unit,
            InstigatorBp = unit:GetBlueprint(),
            InstigatorArmy = unit:GetArmy(),
            Amount = abilityDef.DamageAmt,
            Type = 'Spell',
            DamageAction = abilityDef.Name,
            Radius = abilityDef.DamageArea,
            DamageSelf = false,
            Origin = pos,
            CanDamageReturn = false,
            CanCrit = false,
            CanBackfire = false,
            CanBeEvaded = false,
            CanMagicResist = true,
            ArmorImmune = true,
            NoFloatText = false,
            Group = "UNITS",
        }
        WaitSeconds(0.5) -- Normally 2
        DamageArea(data)
    end
end