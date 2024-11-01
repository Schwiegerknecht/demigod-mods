--Mithy: Override Ooze OnAuraPulse to check health level and deactivate Ooze before doing self damage
local NewAuraPulse = function(self, unit, params)
    if unit.AbilityData.OozeOn then
        if unit:GetHealth() < 100 then
            local params = { AbilityName = 'HEPA01OozeOff'}
            Abil.HandleAbility(unit, params)
        else
            Buff.ApplyBuff(unit, 'HEPA01OozeSelf' .. string.sub(self.Name, -2), unit)
        end
    end
end
Ability.HEPA01Ooze01.OnAuraPulse = NewAuraPulse
Ability.HEPA01Ooze02.OnAuraPulse = NewAuraPulse
Ability.HEPA01Ooze03.OnAuraPulse = NewAuraPulse
Ability.HEPA01Ooze04.OnAuraPulse = NewAuraPulse

--Mithy: Ooze self-kill prevention (functional code in ForgeUnit, Weapon, BuffAffects)
Buffs.HEPA01OozeSelf01.CannotKillSelf = true
Buffs.HEPA01OozeSelf02.CannotKillSelf = true
Buffs.HEPA01OozeSelf03.CannotKillSelf = true
Buffs.HEPA01OozeSelf04.CannotKillSelf = true