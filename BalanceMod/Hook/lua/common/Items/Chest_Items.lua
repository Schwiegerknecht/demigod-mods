Ability.Item_Chest_060_WeaponProc.ArmorProcChance = 3 -- Increase Playemail of the Crusader proc chance to 3% from 1%
Ability.Item_Chest_070_WeaponProc.ArmorProcChance = 5 -- Increase Groffling armor proc chance to 5% up from 1%

-- Add +10 health per second to Armor of Vengance and adjust description
Buffs.Item_Chest_050.Affects.Regen = {Add = 10}
Items.Item_Chest_050.GetRegenBonus = function(self) return Buffs['Item_Chest_050'].Affects.Regen.Add end
table.insert(Items.Item_Chest_050.Tooltip.Bonuses, '+[GetRegenBonus] Health Per Second')

