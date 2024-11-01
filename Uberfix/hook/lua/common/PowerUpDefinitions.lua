--Mithy: Make Erebus' poisoned potions act like normal healing potions for self/teammates

--Define two new dummy buffs that check team and choose between existing damage or heal buffs, to maintain compatibility
--with any mods that change heal/damage amounts.  Audio is also moved to the check logic, playing via the activating unit
--(as I'm not aware of how to get a handle to the actual powerup itself).
PowerUps.HVampirePoisonedBlood01.Audio = nil
PowerUps.HVampirePoisonedBlood01.Buffs = {
    BuffBlueprint {
        Name = 'HVampirePoisonedBlood01Check',
        Debuff = false,
        Stacks = 'ALWAYS',
        BuffType = 'POISONBLOODCHECK',
        OnApplyBuff = function(self, unit, instigator)
            if IsEnemy(unit:GetArmy(), instigator:GetArmy()) then
                Buff.ApplyBuff( unit, 'HVampirePoisonedBlood01', instigator )
                unit:PlaySound('Forge/ITEMS/Lootdrops/snd_item_lootdrops_poisoned')
            else
                Buff.ApplyBuff( unit, 'LootHealth01', instigator )
                unit:PlaySound('Forge/ITEMS/Lootdrops/snd_item_lootdrops_health')
            end
        end,
    },
}
PowerUps.HVampirePoisonedBlood02.Audio = nil
PowerUps.HVampirePoisonedBlood02.Buffs = {
    BuffBlueprint {
        Name = 'HVampirePoisonedBlood02Check',
        Debuff = false,
        Stacks = 'ALWAYS',
        BuffType = 'POISONBLOODCHECK',
        OnApplyBuff = function(self, unit, instigator)
            if IsEnemy(unit:GetArmy(), instigator:GetArmy()) then
                Buff.ApplyBuff( unit, 'HVampirePoisonedBlood02', instigator )
                unit:PlaySound('Forge/ITEMS/Lootdrops/snd_item_lootdrops_poisoned')
            else
                Buff.ApplyBuff( unit, 'LootHealth02', instigator )
                unit:PlaySound('Forge/ITEMS/Lootdrops/snd_item_lootdrops_health')
            end
        end,
    },
}