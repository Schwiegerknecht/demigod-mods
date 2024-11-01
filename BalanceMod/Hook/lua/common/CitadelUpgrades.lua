--Troop armor put on Building Strength price track
Upgrades.Tree.CTroopArmor01.Cost = 500 -- normally 600
Upgrades.Tree.CTroopArmor02.Cost = 1500 -- normally 1800	
Upgrades.Tree.CTroopArmor03.Cost = 2500 --  normally 3000
Upgrades.Tree.CTroopArmor04.Cost = 3500 -- normally 4800

--Death Reduction put on Building Strength price track
Upgrades.Tree.CDeathPenalty01.Cost = 500 --Reduced from 600
Upgrades.Tree.CDeathPenalty02.Cost = 1500 -- Reduced form 1800
Upgrades.Tree.CDeathPenalty03.Cost = 3500 --Reduced from 5400 

--Siege put on Building Strength price track
Upgrades.Tree.CUpgradeStructure01.Cost = 2500 --Reduced from 3200 to normalize price curve
Upgrades.Tree.CUpgradeStructure02.Cost = 3500 --Reduced from 4000 to normalize price curve

--Restore beta gold income to normalize cost/benefit ratios
Buffs.CGoldIncome02.Affects.GoldProduction.Add = 8
Buffs.CGoldIncome03.Affects.GoldProduction.Add = 12

__moduleinfo.auto_reload = true