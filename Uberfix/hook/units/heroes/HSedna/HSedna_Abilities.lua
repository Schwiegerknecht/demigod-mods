--HotY applies Yeti buffs as army bonuses, so existing Yetis will have their buffs upgraded with the ability increase.
--In addition, the level IV buff is now correctly applied at level IV of the ability, instead of the level III buff.
for i=2, 4 do
    local abilYeti = Ability['HSednaYeti0'..i]
    local buffNameYeti = 'HSednaYetiBuff0'..i
    if abilYeti and abilYeti.YetiBuff and Buffs[buffNameYeti] then
        abilYeti.YetiBuff = nil
        local armyBonusYeti = 'HSednaYetiBonus0'..i
        ArmyBonusBlueprint {
            Name = armyBonusYeti,
            ApplyArmies = 'Single',
            UnitCategory = 'YETI',
            RemoveOnUnitDeath = true,
            Buffs = { buffNameYeti },
        }
        abilYeti.OnAbilityAdded = function(self, unit)
            unit:GetAIBrain():AddArmyBonus(armyBonusYeti, unit)
        end
        abilYeti.OnRemoveAbility = function(self, unit)
            unit:GetAIBrain():RemoveArmyBonus(armyBonusYeti, unit)
        end
    end
end