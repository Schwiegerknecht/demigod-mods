--Override Mist Form's OnAuraPulse for the correct shutoff level

local MistPulse = function(self, unit, params)
    if(unit.AbilityData.MistOn) then
        Buff.ApplyBuff(unit, 'HVampireMistSelf01', unit)
    end
    if unit.Sync.Energy < 125 then
        local params = { AbilityName = 'HVampireMistOff'}
        Abil.HandleAbility(unit, params)
        unit.Character:PlayAction('MistEnd')
    end
end

# Mist Form I
Ability.HVampireMist01.OnAuraPulse = MistPulse
# Mist Form II
Ability.HVampireMist02.OnAuraPulse = MistPulse
# Mist Form III
Ability.HVampireMist03.OnAuraPulse = MistPulse
# Mist Form IV
Ability.HVampireMist04.OnAuraPulse = MistPulse


--Mithy: Fix for Conversion Aura raising nightwalkers from Spirits and Ball Lightning
local newTargetCat = 'MOBILE - UNTARGETABLE - NOBUFFS - VAMPIRE - SPIRIT - BALLLIGHTNING'
Ability.HVampireConversion00.TargetCategory = newTargetCat
Ability.HVampireConversion01.TargetCategory = newTargetCat
Ability.HVampireConversion02.TargetCategory = newTargetCat
Ability.HVampireConversion03.TargetCategory = newTargetCat