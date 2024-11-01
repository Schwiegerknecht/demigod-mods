--Summon Shambler applies Shambler buffs as army bonuses, so existing Shamblers will have their buffs upgraded with the ability increase.
for i=2, 4 do
    local abilShambler = Ability['HQueenShambler0'..i]
    local buffNameShambler = 'HQueenShamblerBuff0'..i
    if abilShambler and abilShambler.ShamblerBuff and Buffs[buffNameShambler] then
        abilShambler.ShamblerBuff = nil
        local armyBonusShambler = 'HQueenShamblerBonus0'..i
        ArmyBonusBlueprint {
            Name = armyBonusShambler,
            ApplyArmies = 'Single',
            UnitCategory = 'ENT',
            RemoveOnUnitDeath = true,
            Buffs = { buffNameShambler },
        }
        abilShambler.OnAbilityAdded = function(self, unit)
            unit:GetAIBrain():AddArmyBonus(armyBonusShambler, unit)
        end
        abilShambler.OnRemoveAbility = function(self, unit)
            unit:GetAIBrain():RemoveArmyBonus(armyBonusShambler, unit)
        end
    end
end


--Mithy: Fix compost ranks so they go from 1 to 3 like Soul Power instead of 0 to 2
for i=1, 3 do
    --Create a new upvalue for each iteration so all ranks don't get set to 3
    local num = i
    local compostAbil = Ability['HQueenCompost0'..num]
    local prevOAA = compostAbil.OnAbilityAdded
    if compostAbil then
        compostAbil.OnAbilityAdded = function(self, unit)
            prevOAA(self, unit)
            --Post-set CompostRank to match the ability level
            unit.AbilityData.CompostRank = num
            if not unit.AbilityData.CombinedCompost then
                unit.AbilityData.CombinedCompost = 0
            end
        end
    end
end


--Mithy: New icons for Compost IV-VI buffs
Buffs.HQueenCompostPowerBuff04.Icon = '/dgqueenofthorns/NewQueenCompost01_04'
Buffs.HQueenCompostPowerBuff05.Icon = '/dgqueenofthorns/NewQueenCompost01_05'
Buffs.HQueenCompostPowerBuff06.Icon = '/dgqueenofthorns/NewQueenCompost01_06'


--Mithy: Re-write of CompostUnit to better handle kills at max level (it was inappropriately
--decrementing the compost level) and to better clarify the whole compost process and massively
--reduce ArmyBonus/Buff add/remove overhead
function CompostUnit(unit, killedunit)
    # Is Queen even alive? Delete her Compost count if she is.
    if unit.Dead then
        unit.AbilityData.Compost = 0
        return
    end

    # If CompostUnit is called on an OnKilled callback, it will have a killedunit, and Compost will increment.
    # Otherwise, it was called on the AuraPulse, and the counter will decrement.
    --Mithy: This was not actually the case, and AbilityData.Compost would be decremented any time it was at 9,
    --even when a killedunit was present.  This is likely why CompostLevel below had 1 added to it.

    --Change ability check to a simple AbilityData lookup instead of a totally unnecessary triple Validate.HasAbility
    if unit.AbilityData.CompostRank then
        local CompostRank = unit.AbilityData.CompostRank
        local LastCombined = unit.AbilityData.CombinedCompost
        local LastCompost = unit.AbilityData.Compost
        if killedunit then
            --If a unit is killed, only increment (up to 10, 9 effective)
            unit.AbilityData.Compost = math.min(unit.AbilityData.Compost + 1, unit.AbilityData.CompostMax or 10)
            # Create trigger effects on killed unit
            local endPos = table.copy(killedunit:GetPosition())
            local startPos = table.copy(unit:GetPosition())
            FxCompost01(startPos,endPos)
        elseif unit.AbilityData.Compost > 0 then
            --Otherwise decrement
            unit.AbilityData.Compost = unit.AbilityData.Compost - 1
        end
        if unit.AbilityData.Compost == 0 then
        	CompostRank = 0
        end

        --Added support for AbilityData override
        local killsPerLevel = unit.AbilityData.KillsPerLevel or 3
        --CompostLevel is now calculated directly from kills, rather than kills + 1
        local CompostLevel = math.min(math.floor(unit.AbilityData.Compost / killsPerLevel), unit.AbilityData.MaxLevel or 3)

        --Total combined Compost level, max 6 (this determines which buff/armybonus is used)
        --Like Soul Power, 1-2 kills gives you the basic buff determined by your skill rank (1-3)
        --with subsequent levels determined by rank + kills/3
        local CombinedCompost = math.min(CompostRank + CompostLevel, unit.AbilityData.MaxCombined or 6)

        --Only re-apply buffs/armybonuses if combined compost level has changed to reduce overhead
        if LastCombined ~= CombinedCompost then
        	if LastCombined > 0 then
                Buff.RemoveBuffsByType(unit, 'HQUEENCOMPOSTQUEENBUFF')
            	unit:GetAIBrain():RemoveArmyBonus('HQueenCompostPowerBuffMinion0'..LastCombined)
            end
            if CombinedCompost > 0 then
                Buff.ApplyBuff(unit, 'HQueenCompostPowerBuff0'.. CombinedCompost, unit)
                unit:GetAIBrain():AddArmyBonus('HQueenCompostPowerBuffMinion0'..CombinedCompost, unit)
            end
        end
        unit.AbilityData.CombinedCompost = CombinedCompost
    end
end