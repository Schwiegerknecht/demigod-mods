--Mithy: Fix for Raise Dead Ward skill crossover issue
Buffs.HOAKSpiritOfWar01.Stacks = 'REPLACE'
Buffs.HOAKSpiritOfWar02.Stacks = 'REPLACE'
Buffs.HOAKSpiritOfWar03.Stacks = 'REPLACE'
Buffs.HOAKSpiritOfWar04.Stacks = 'REPLACE'

--Mithy: Fix for Raise Dead Ward raising Spirits from Ball Lightning and Nightwalkers
local newTargetCat = 'MOBILE - UNTARGETABLE - HERO - SPIRIT - VAMPIRE - BALLLIGHTNING'
Ability.HOAKSpiritOfWar01.TargetCategory = newTargetCat
Ability.HOAKSpiritOfWar02.TargetCategory = newTargetCat
Ability.HOAKSpiritOfWar03.TargetCategory = newTargetCat
Ability.HOAKSpiritOfWar04.TargetCategory = newTargetCat

--Mithy: Assign Soul Power buffs the correct level icons
for i = 1, 6 do
	Buffs['HOakSoulPowerBuff0'..i].Icon = '/DGOak/NewOakSoulPower01_0'..i
end