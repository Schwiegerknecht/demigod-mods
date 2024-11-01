-- Assassin's footguards; add 10% chance to do 1.5X crit, modify description
Items.Item_Boot_030.GetCritChance = function(self) return Ability['Item_Boot_030_Crit'].CritChance end
Items.Item_Boot_030.GetCritDamage = function(self) return Ability['Item_Boot_030_Crit'].CritMult end
if not Items.Item_Boot_030.Tooltip.Passives then 
	Items.Item_Boot_030.Tooltip.Passives = '[GetCritChance]% chance to deal a critical strike for [GetCritDamage]x damage.'
end
table.insert(Items.Item_Boot_030.Abilities, AbilityBlueprint {
	Name = 'Item_Boot_030_Crit',
	AbilityType = 'WeaponCrit',
	CritChance = 10,
	CritMult = 1.5,
})

-- Desperate boots increase trigger % to 50, up from 30 and increase dodge amount to 30% up from 20
Ability.Item_Boot_060_Desperation.HealthPercentTrigger = 0.50
Buffs.Item_Boot_060_Desperation.Affects.Evasion.Add = 30

-- Add 450 base armor and 1050 base mana to iron walkers and adjust description
table.insert(Items.Item_Boot_070.Abilities, AbilityBlueprint {
            Name = 'Item_Boot_070_Base',
            AbilityType = 'Quiet',
            FromItem = 'Item_Boot_070',
            Icon = 'NewIcons/Boots/Boot4',
            Buffs = {
               BuffBlueprint {
			Name = 'Item_Boot_070_Base',
			BuffType = 'ITEM_BOOT_070_BASE',
			Debuff = false,
			EntityCategory = 'ALLUNITS',
			Stacks = 'ALWAYS',
			Duration = -1,
			Affects = {
				Armor = {Add = 450},
				MaxEnergy = {Add = 1050, AdjustEnergy = false},
			}
		}
	}
})

	
Items.Item_Boot_070.GetBaseArmor = function(self) return Buffs['Item_Boot_070_Base'].Affects.Armor.Add end
Items.Item_Boot_070.GetBaseMana = function(self) return Buffs['Item_Boot_070_Base'].Affects.MaxEnergy.Add end
if not Items.Item_Boot_070.Tooltip.Bonuses then 
	Items.Item_Boot_070.Tooltip.Bonuses = {}
end
table.insert(Items.Item_Boot_070.Tooltip.Bonuses, '+[GetBaseArmor] Armor')
table.insert(Items.Item_Boot_070.Tooltip.Bonuses, '+[GetBaseMana] Mana')
