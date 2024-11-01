Buffs.Item_Helm_070.Affects.EnergyRegen.Mult = 0.7 --Increase Theurgist's Hat regen to 70% up from 35%
Ability.Item_Helm_070_WeaponProc.WeaponProcChance = 10 -- Increase Theurgist's Hat proc chance to 10 up from 5
Ability.Item_Helm_050_WeaponProc.ArmorProcChance = 5 --Increase Vinling Proc Chance to 5% up from 3%

--Add 260 mana to Plate visor and adjust description
Buffs.Item_Helm_020.Affects.MaxEnergy = {Add = 260, AdjustEnergy = false}
Items.Item_Helm_020.GetManaBonus = function(self) return Buffs['Item_Helm_020'].Affects.MaxEnergy.Add end
table.insert(Items.Item_Helm_020.Tooltip.Bonuses, '+[GetManaBonus] Mana')

