--Clunky override of EnahncedAI's priorities... will fix up later

#AI sensor wants to shop
#Sensor asks FriendlyAsset for a sorted list of upgrades, SortCitadelUpgradePriorities(unit)
#FriendlyAsset asks AIshoputilities for GetUpgradesList()
#AIshoputilities gets the list of upgrades from AIglobals
CitadelUpgradeWeights = {
    # Fortified Structure - upgrades based on team fortress health, whether enemy has certain troops, warrank, and warscore (Fs1)
    CBuildingHealth01 = {
        PriorityFunction = function(unit)

            if unit:GetAIBrain().Score.WarScore  >= 100 then  
                return 50
			else
			    return 15
            end       
     end,
    },

    CBuildingHealth02 = { 
	PriorityFunction = function(unit) 
	#local priority = 0 
		if GetCitadelHealth(unit) < 0.8 then 
			return 200 
		elseif EnemyHasUpgrade(unit, 'CTroopNumber03') then 
			return 40
		elseif unit:GetAIBrain().Score.WarRank >= 5 or GetEnemyTeamBrain(unit).Score.WarRank >= 5 then 
			return 25
		else
			return 15
		end 
	end,
    },

    CBuildingHealth03 = { 
	PriorityFunction = function(unit) 
	#local priority = 0 
		if GetCitadelHealth(unit) < 0.8 then 
			return 200 
		elseif EnemyHasUpgrade(unit, 'CTroopNumber04') then 
			return 40
		elseif unit:GetAIBrain().Score.WarRank >= 7 or GetEnemyTeamBrain(unit).Score.WarRank >= 7 then 
			return 25
		else
			return 15
		end 
	end,
   },

    CBuildingHealth04 = { 
	PriorityFunction = function(unit) 
	#local priority = 0 
		if GetCitadelHealth(unit) < 0.8 then 
			return 200 
		elseif EnemyHasUpgrade(unit, 'CTroopNumber04') then 
			return 40 
		elseif unit:GetAIBrain().Score.WarRank >= 10 or GetEnemyTeamBrain(unit).Score.WarRank >= 10 then 
			return 25 
		else 
			return 15
		end 
    	end, 
   }, 

    # Building Firepower - upgrades based on troop types possessed by team or enemy team, warrank, and citadel structure upgrades (trebuchet and Finger of God)
    CBuildingStrength01 = { 
	PriorityFunction = function(unit)
	if EnemyHasUpgrade(unit, 'CTroopNumber03') then
		return 40
	else
		return 15
	end       
     end,
   }, 

    CBuildingStrength02 = { 
	PriorityFunction = function(unit) 
	#local priority = 0 
		if EnemyHasUpgrade(unit, 'CTroopNumber04') then 
			return 40
		elseif TeamHasUpgrade(unit, 'CBuildingStrength03') then 
			return 35 
		elseif unit:GetAIBrain().Score.WarRank >= 6 or GetEnemyTeamBrain(unit).Score.WarRank >= 6 then 
			return 25 
		else 
			return 15
		end 
	end, 
}, 

    CBuildingStrength03 = { 
	PriorityFunction = function(unit) 
	#local priority = 0 
		if EnemyHasUpgrade(unit, 'CTroopNumber06') then 
			return 40
		elseif TeamHasUpgrade(unit, 'CUpgradeStructure04') then 
			return 35 
		elseif unit:GetAIBrain().Score.WarRank >= 7 or GetEnemyTeamBrain(unit).Score.WarRank >= 7 then 
			return 35 
		else
			return 10
		end 
	end, 
}, 

    CBuildingStrength04 = { 
	PriorityFunction = function(unit) 
	#local priority = 0 
		if EnemyHasUpgrade(unit, 'CTroopNumber06') then 
			return 30
		elseif TeamHasUpgrade(unit, 'CUpgradeStructure04') then 
			return 25 
		elseif unit:GetAIBrain().Score.WarRank >= 10 or GetEnemyTeamBrain(unit).Score.WarRank >= 10 then 
			return 25
		else
			return 0
		end 
	end, 
},

	# Currency - timed priorities
	CGoldIncome01 = {
		Priority = 110,
	},
	CGoldIncome02 = { --7/11 minute cutoff for normal AI on normal/high gold, 15/22 min for nightmare AI, starting pri 30/60
		Priority = 100,
--~ 		PriorityFunction = function(unit)
--~ 			local mult = 4 * math.floor(GetMinute())
--~ 			local base = 30 * GetGoldMult() * (GetAIDifficulty(unit)/2)
--~ 			local priority = math.max(0, base - mult)
--~ 			--LOG("mithy: CitadelUpgradeWeights: CGoldIncome02: "..repr(unit:GetAIBrain():GetTeamArmy().Name)..": "..repr(base).." - "..repr(mult).." = "..repr(priority))
--~ 			return priority
--~ 		end,
	},
	CGoldIncome03 = { --5/7 min for normal, 10/15 for nightmare, starting pri 20/40
		Priority = 15,
--~ 		PriorityFunction = function(unit)
--~ 			local mult = 4 * math.floor(GetMinute())
--~ 			local base = 20 * GetGoldMult() * (GetAIDifficulty(unit)/2)
--~ 			local priority = math.max(0, base - mult)
--~ 			--LOG("mithy: CitadelUpgradeWeights: CGoldIncome03: "..repr(unit:GetAIBrain():GetTeamArmy().Name)..": "..repr(base).." - "..repr(mult).." = "..repr(priority))
--~ 			return priority
--~ 		end,
	},


    # Blacksmith - match enemy upgrades, ultra-prioritize if either team has giants 
    CTroopStrength01 = { 
	PriorityFunction = function(unit) 
		if TeamHasUpgrade(unit, 'CTroopNumber03') or EnemyHasUpgrade(unit, 'CTroopNumber03') then 
			return 100
		elseif EnemyHasUpgrade(unit, 'CTroopStrength01') then 
			return 30 
		elseif unit:GetAIBrain().Score.WarRank >= 6 then 
			return 30 
		else 
			return 10 
		end 
     end, 
}, 

    CTroopStrength02 = { 
	PriorityFunction = function(unit) 
		if TeamHasUpgrade(unit, 'CTroopNumber04') or EnemyHasUpgrade(unit, 'CBuildingHealth03') then 
			return 50
		elseif TeamHasUpgrade(unit, 'CTroopNumber03') or EnemyHasUpgrade(unit, 'CTroopStrength02') then 
			return 30 
		elseif unit:GetAIBrain().Score.WarRank >= 8 then 
			return 40 
		else 
			return 10 
		end 
    end, 
}, 

    CTroopStrength03 = { 
	PriorityFunction = function(unit) 
		if TeamHasUpgrade(unit, 'CTroopNumber06') or EnemyHasUpgrade(unit, 'CTroopNumber06') then 
			return 50 
		elseif TeamHasUpgrade(unit, 'CTroopNumber04') or EnemyHasUpgrade(unit, 'CTroopStrength04') then 
			return 40 
		elseif unit:GetAIBrain().Score.WarRank >= 9 then 
			return 30 
		else 
			return 10 
		end 
    end, 
}, 

    CTroopStrength04 = { 
	PriorityFunction = function(unit) 
		if TeamHasUpgrade(unit, 'CTroopNumber06') or EnemyHasUpgrade(unit, 'CTroopNumber06') then 
			return 40
		elseif EnemyHasUpgrade(unit, 'CTroopStrength04') then 
			return 35 
		elseif unit:GetAIBrain().Score.WarRank >= 10 then 
			return 15 
		else 
			return 10 
		end 
    end, 
}, 

    # Armory - match enemy upgrades, ultra-prioritize if either team has giants 

    CTroopArmor01 = { 
	PriorityFunction = function(unit) 
		if TeamHasUpgrade(unit, 'CTroopNumber03') then 
			return 100
		elseif EnemyHasUpgrade(unit, 'CBuildingStrength01') then 
			return 25 
		elseif unit:GetAIBrain().Score.WarRank >= 4 then 
			return 40 
		else 
			return 10 
		end 
    end, 
}, 

    CTroopArmor02 = { 
	PriorityFunction = function(unit) 
		if TeamHasUpgrade(unit, 'CTroopNumber06') or EnemyHasUpgrade(unit, 'CTroopNumber06') then 
			return 50
		elseif EnemyHasUpgrade(unit, 'CBuildingStrength02') then 
			return 30 
		elseif unit:GetAIBrain().Score.WarRank >= 7 then 
			return 50 
		else 
			return 15 
		end 
    end, 
}, 

    CTroopArmor03 = { 
	PriorityFunction = function(unit) 
		if TeamHasUpgrade(unit, 'CTroopNumber06') or EnemyHasUpgrade(unit, 'CTroopNumber06') then 
			return 70
		elseif TeamHasUpgrade(unit, 'CTroopNumber04') or EnemyHasUpgrade(unit, 'CTroopArmor04') then 
			return 35 
		elseif unit:GetAIBrain().Score.WarRank >= 9 then 
			return 15 
		else 
			return 10 
		end 
    end, 
}, 

    CTroopArmor04 = { 
	PriorityFunction = function(unit) 
		if TeamHasUpgrade(unit, 'CTroopNumber06') or EnemyHasUpgrade(unit, 'CTroopNumber06') then 
			return 70
		elseif EnemyHasUpgrade(unit, 'CTroopArmor04') then 
			return 35 
		elseif unit:GetAIBrain().Score.WarRank >= 10 then 
			return 15 
		else 
			return 10 
		end 
    end, 
}, 
	CPortalFrequency01 = {
		PriorityFunction = function(unit)
		if EnemyHasUpgrade(unit, 'CTroopNumber03') then
			return 200
		else
			return 20
		end
	end,
    },

 	CPortalFrequency02 = {
	PriorityFunction = function(unit)
		if EnemyHasUpgrade(unit, 'CTroopNumber04') then
			return 50
		else
			return 10
		end
	end,
--~ 		PriorityFunction = function(unit)
--~ 			local mult = 3 * math.floor( (GetMinute() + GetAverageLevel(unit)) )
--~ 			local base = math.floor( 60 / GetXPMult() ) * (GetAIDifficulty(unit)/2)
--~ 			local priority = math.max(0, base - mult)
--~ 			--LOG("mithy: CitadelUpgradeWeights: CPortalFrequency02: "..repr(unit:GetAIBrain():GetTeamArmy().Name)..": "..repr(base).." - "..repr(mult).." = "..repr(priority))
--~ 			return priority
--~ 		end,
	},
	CPortalFrequency03 = {
	PriorityFunction = function(unit)
		if EnemyHasUpgrade(unit, 'CTroopNumber06') then
			return 25
		else
			return 10
		end
	end,
--~ 		PriorityFunction = function(unit)
--~ 			local mult = 3 * math.floor( (GetMinute() + GetAverageLevel(unit)) )
--~ 			local base = math.floor( 45 / GetXPMult() ) * (GetAIDifficulty(unit)/2)
--~ 			local priority = math.max(0, base - mult)
--~ 			--LOG("mithy: CitadelUpgradeWeights: CPortalFrequency03: "..repr(unit:GetAIBrain():GetTeamArmy().Name)..": "..repr(base).." - "..repr(mult).." = "..repr(priority))
--~ 			return priority
--~ 		end,
	},
	CPortalFrequency04 = {
	Priority = 10,
--~ 		PriorityFunction = function(unit)
--~ 			local mult = 3 * math.floor( (GetMinute() + GetAverageLevel(unit)) )
--~ 			local base = math.floor( 30 / GetXPMult() ) * (GetAIDifficulty(unit)/2)
--~ 			local priority = math.max(0, base - mult)
--~ 			--LOG("mithy: CitadelUpgradeWeights: CPortalFrequency04: "..repr(unit:GetAIBrain():GetTeamArmy().Name)..": "..repr(base).." - "..repr(mult).." = "..repr(priority))
--~ 			return priority
--~ 		end,
	},

	# Graveyard - priority based on death penalty, number of team deaths, average team level, and AI difficulty.
	CDeathPenalty01 = {
		PriorityFunction = function(unit)
			local mult = 4 * math.floor(GetTeamDeaths(unit) + GetAverageLevel(unit))
			local minimum = math.floor( 100 / GetDeathMult() / (GetAIDifficulty(unit)/2) )
			local priority = math.max(0, mult - minimum)
			--LOG("mithy: CitadelUpgradeWeights: CDeathPenalty01: "..repr(unit:GetAIBrain():GetTeamArmy().Name)..": " ..repr(mult).." - "..repr(minimum).." = "..repr(priority))
			return priority
		end,
	},
	CDeathPenalty02 = {
		PriorityFunction = function(unit)
			local mult = 4 * math.floor(GetTeamDeaths(unit) + GetAverageLevel(unit))
			local minimum = math.floor( 200 / GetDeathMult() / (GetAIDifficulty(unit)/2) )
			local priority = math.max(0, mult - minimum)
			--LOG("mithy: CitadelUpgradeWeights: CDeathPenalty02: "..repr(unit:GetAIBrain():GetTeamArmy().Name)..": " ..repr(mult).." - "..repr(minimum).." = "..repr(priority))
			return priority
		end,
	},
	CDeathPenalty03 = {
		PriorityFunction = function(unit)
			if GetDeathMult() >= 1 then
			local mult = 4 * math.floor(GetTeamDeaths(unit) + GetAverageLevel(unit))
				local minimum = math.floor( 300 / GetDeathMult() / (GetAIDifficulty(unit)/2) )
				local priority = math.max(0, mult - minimum)
				--LOG("mithy: CitadelUpgradeWeights: CDeathPenalty03: "..repr(unit:GetAIBrain():GetTeamArmy().Name)..": " ..repr(mult).." - "..repr(minimum).." = "..repr(priority))
				return priority
			else
				return 0
			end
		end,
	},
	
    # Additional troops - AI will now attempt to match troop upgrades with their opponent even before WR 8
    # This keeps AI games from becoming too one-sided once one team gets priests+
    # Priests
    CTroopNumber03 = {
    PriorityFunction = function(unit)
	if TeamHasUpgrade(unit, 'CPortalFrequency01') or unit:GetAIBrain().Score.WarRank >= 8 then
	return 100
        elseif TeamHasUpgrade(unit, 'CGoldIncome01') then
            return 50
        else
            return 0
        end
    end,
    },
    # Angels
    CTroopNumber05 = {
         PriorityFunction = function(unit)
            if EnemyHasUpgrade(unit, 'CTroopNumber04') or unit:GetAIBrain().Score.WarRank >= 9 then
                return 100
            else
                return 30
            end
        end,
    },
    # Catapults
    CTroopNumber04 = {
         PriorityFunction = function(unit)
            if EnemyHasUpgrade(unit, 'CTroopNumber04') or unit:GetAIBrain().Score.WarRank >= 9 then
                return 100
            else
                return 10
            end
        end,
    },
    # Giants
    CTroopNumber06 = {
         PriorityFunction = function(unit)
            if EnemyHasUpgrade(unit, 'CTroopNumber06') or unit:GetAIBrain().Score.WarRank >= 10 then
                return 100
            else
                return 10
            end
        end,
    },

# Trebuchets - match, prioritize vs catapults+, take into account fort totals
CUpgradeStructure01 = {
	PriorityFunction = function(unit)
		local priority = 10
		local ourForts = unit:GetAIBrain():GetTeamArmy():GetListOfUnits(categories.FORT, false)
		if table.getn(ourForts) < 2 then
			return 30
		end

		local enemyForts = GetEnemyTeamBrain(unit):GetListOfUnits(categories.FORT, false)
		if EnemyHasUpgrade(unit, 'CTroopNumber04') and not TeamHasUpgrade(unit, 'CTroopNumber04') then
			priority = 15
		elseif EnemyHasUpgrade(unit, 'CUpgradeStructure02') then
			priority = 2 * table.getn(enemyForts)
		end

		return priority * table.getn(ourForts) * GoldThreshold(unit, UpgradeCost('CUpgradeStructure02'))
	end,
},

# Finger of God - match, prioritize vs catapults+ 
    CUpgradeStructure02 = { 
	PriorityFunction = function(unit) 
	#local priority = 0 
		if EnemyHasUpgrade(unit, 'CUpgradeStructure02') or EnemyHasUpgrade(unit, 'CTroopNumber04') then 
			return 30 
		elseif GetEnemyTeamBrain(unit).Score.WarRank >= 9 then 
			return 20 
		else
			return 10
		end 
   end, 
},
}