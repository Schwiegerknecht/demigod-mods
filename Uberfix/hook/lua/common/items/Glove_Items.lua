--LO: Correct Wyrmskin Gauntlets ranged proc chance to match all others
Ability.Item_Glove_040_WeaponProc.WeaponProcChanceRanged = 10 --8

--LO: Display hidden attack speed bonus for gloves of despair
Items.Item_Glove_030.GetAttackSpeedBonus = function(self) return math.floor( Buffs['Item_Glove_030'].Affects.RateOfFire.Mult * 100 ) end
table.insert(Items.Item_Glove_030.Tooltip.Bonuses, '+[GetAttackSpeedBonus]% Attack Speed')