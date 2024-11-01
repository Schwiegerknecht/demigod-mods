Buffs.Item_Ring_020.Affects.LifeSteal.Add = 0.04 --Increase bloodtone ring lifesteal to 4% up from 3%

-- Add 10% Attack Speed bonus Ring of the Ancients and adjust description
Buffs.Item_Ring_040.Affects.RateOfFire = {Mult = 0.10}
Items.Item_Ring_040.GetAttackSpeedBonus = function(self) return math.floor( Buffs['Item_Ring_040'].Affects.RateOfFire.Mult * 100 ) end,
table.insert(Items.Item_Ring_040.Tooltip.Bonuses, '+[GetAttackSpeedBonus]% Attack Speed')

