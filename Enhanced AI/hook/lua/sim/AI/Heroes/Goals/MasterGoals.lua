#  [MOD]  Increase Weights of capturing and move to friendly
#  [MOD]  Increase health loss required to consider flee.

# -- # All these should add up to 2 with goal weights
# -- #     We want the goals to scale properly more than the master goals

# -- local AIGlobals = import('/lua/sim/AI/AIGlobals.lua')
local Utils = import('/lua/utilities.lua')

# -- HeroAIGoalTemplates.Attack = {
    # -- Name = 'Attack',
    # -- MasterGoal = true,
    # -- GoalStatusFunction = function(goal, unit)
        # -- local numEnemies = unit:GetAIBrain():GetNumUnitsAroundPoint( categories.MOBILE - categories.AIR, unit.Position, 25, 'Enemy' )
        # -- if numEnemies == 0 then
            # -- return false
        # -- end
        
        # -- local enemyThreat = unit:GetAIBrain():GetThreatAtPosition( unit.Position, 1, 'Land', 'Enemy' )
        # -- if enemyThreat <= 0 then
            # -- return false
        # -- end
        
        # -- return true
    # -- end,
    # -- MasterGoalWeights = {
        # -- KillUnits = 3.0,
    # -- }
# -- }

# -- HeroAIGoalTemplates.CarefulAttack = {
    # -- Name = 'CarefulAttack',
    # -- MasterGoal = true,
    # -- GoalStatusFunction = function(goal, unit)
        # -- local enemyThreat = unit:GetAIBrain():GetThreatAtPosition( unit.Position, 1, 'Land', 'Enemy' )
        # -- if enemyThreat <= 0 then
            # -- return false
        # -- end
        
        # -- if unit:GetHealthPercent() < 0.3 then
            # -- return false
        # -- end
        
        # -- return true
    # -- end,
    # -- MasterGoalWeights = {
        # -- KillUnits = 2.0,
        # -- Survival = 1.0,
    # -- }
# -- }

HeroAIGoalTemplates.MoveToFriendly = {
    Name = 'MoveToFriendly',
    MasterGoal = true,
    MasterGoalWeights = {
        Survival = 0.5,
        AttackWithHelp = 1.5,
    },
    GoalStatusFunction = function(goal, unit)
        local numFriendlyGrunts = unit:GetAIBrain():GetNumUnitsAroundPoint(categories.LAND * categories.GRUNT, unit.Position, 10, 'Ally')
        if numFriendlyGrunts > 0 then
            return false
        end
        
        local numFriendlyHeroes = unit:GetAIBrain():GetNumUnitsAroundPoint(categories.HERO, unit.Position, 10, 'Ally')
        if numFriendlyHeroes > 1 then
            return false
        end
        
        local numFriendlyDefenses = unit:GetAIBrain():GetNumUnitsAroundPoint(categories.DEFENSE, unit.Position, 5, 'Ally')
        if numFriendlyDefenses > 0 then
            return false
        end
        
        return true
    end,
}

# 0.27.09 - enabled the code, but no changes made
HeroAIGoalTemplates.Assassinate = {
    Name = 'Assassinate',
    MasterGoal = true,
    GoalStatusFunction = function(goal, unit)
        unit.GOAP.NearbyEnemyHeroes = false

        local enemyHeroes = unit:GetAIBrain():GetBlipsAroundPoint( categories.HERO, unit.Position, 30, 'Enemy' )
        if not enemyHeroes or table.getn( enemyHeroes ) <= 0 then
            return false
        end

        unit.GOAP.NearbyEnemyHeroes = {
            WeakestHealth = false,
            WeakestDistance = false,
            WeakestLevel = false,
            ClosestHealth = false,
            ClosestDistance = false,
            ClosestLevel = false
        }
        
        # Store out all them enemy demigods for use by weights
        for k,v in enemyHeroes do
            if v:IsDead() then
                continue
            end

            # We need the non-squared distance here; CalculateWeights will use division of distance
            # by speed
            local tempDist = VDist3XZ( unit.Position, v.Position )
            local tempHealth = v:GetHealth()
            local tempLevel = v:GetLevel()

            if not unit.GOAP.NearbyEnemyHeroes.WeakestHealth or tempHealth < unit.GOAP.NearbyEnemyHeroes.WeakestHealth then
                unit.GOAP.NearbyEnemyHeroes.WeakestHealth = tempHealth
                unit.GOAP.NearbyEnemyHeroes.WeakestDistance = tempDist
                unit.GOAP.NearbyEnemyHeroes.WeakestLevel = tempLevel
            end

            if not unit.GOAP.NearbyEnemyHeroes.ClosestDistance or tempDist < unit.GOAP.NearbyEnemyHeroes.ClosestDistance then
                unit.GOAP.NearbyEnemyHeroes.ClosestHealth = tempHealth
                unit.GOAP.NearbyEnemyHeroes.ClosestDistance = tempDist
                unit.GOAP.NearbyEnemyHeroes.ClosestLevel = tempLevel
            end
        end

        if not unit.GOAP.NearbyEnemyHeroes.WeakestHealth then
            return false
        end
        
        return true
    end,
    MasterGoalWeights = {
        KillHero = 1.0,
    }
}

# -- HeroAIGoalTemplate {
    # -- Name = 'DestroyStructures',
    # -- MasterGoal = true,
    # -- GoalStatusFunction = function(goal, unit)
        # -- unit.GOAP.NearbyEnemyStructures = false

        # -- local enemyStructures = unit:GetAIBrain():GetBlipsAroundPoint( categories.STRUCTURE - categories.UNTARGETABLE, unit.Position, 30, 'Enemy' )
        # -- if not enemyStructures or table.getn( enemyStructures ) <= 0 then
            # -- return false
        # -- end

        # -- unit.GOAP.NearbyEnemyStructures = {
            # -- WeakestHealth = false,
            # -- WeakestDistance = false,
            # -- ClosestHealth = false,
            # -- ClosestDistance = false,
        # -- }
        
        # -- # Store out all them enemy demigods for use by weights
        # -- for k,v in enemyStructures do
            # -- if v:IsDead() then
                # -- continue
            # -- end

            # -- #local unitIds = {
            # -- #    ugbdefense01 = true,
            # -- #    ugbdefense02 = true,
            # -- #    ugbfort01 = true,
            # -- #    ugbfort02 = true,
            # -- #    hrooktoweroflight = true,
            # -- #    hrooktoweroflight02 = true,
            # -- #    hrooktoweroflight03 = true,
            # -- #    hrooktoweroflight04 = true,
            # -- #    stronghold01 = true,
            # -- #    stronghold02 = true,
            # -- #    stronghold03 = true,
            # -- #}

            # -- #local unitId = v:GetUnitId()
            # -- #if not unitIds[unitId] then
            # -- #    LOG('*AI DEBUG: UNIT ID = ' .. unitId)
            # -- #end

            # -- # We need the non-squared distance here; CalculateWeights will use division of distance
            # -- # by speed
            # -- local tempDist = VDist3XZ( unit.Position, v.Position )
            # -- local tempHealth = v:GetHealth()

            # -- if not unit.GOAP.NearbyEnemyStructures.WeakestHealth or tempHealth < unit.GOAP.NearbyEnemyStructures.WeakestHealth then
                # -- unit.GOAP.NearbyEnemyStructures.WeakestHealth = tempHealth
                # -- unit.GOAP.NearbyEnemyStructures.WeakestDistance = tempDist
            # -- end

            # -- if not unit.GOAP.NearbyEnemyStructures.ClosestDistance or tempDist < unit.GOAP.NearbyEnemyStructures.ClosestDistance then
                # -- unit.GOAP.NearbyEnemyStructures.ClosestHealth = tempHealth
                # -- unit.GOAP.NearbyEnemyStructures.ClosestDistance = tempDist
            # -- end
        # -- end

        # -- if not unit.GOAP.NearbyEnemyStructures.WeakestHealth then
            # -- return false
        # -- end
        
        # -- return true
    # -- end,
    # -- MasterGoalWeights = {
        # -- KillStructures = 2,
    # -- }
# -- }

HeroAIGoalTemplates.Flee = {
    Name = 'Flee',
    MasterGoal = true,
    MasterGoalWeights = {
        Health = 1,
        Survival = 1,
    },
    GoalStatusFunction = function(goal, unit)
# 0.27.09 reduced health pecent from .75 to .50
        if unit:GetHealthPercent() > .75  then 
            return false
        end
        
        return true
    end,
}

# -- HeroAIGoalTemplate {
    # -- Name = 'SquadMove',
    # -- MasterGoal = true,
    # -- GoalStatusFunction = function(goal, unit)
        # -- if not unit.GOAP.SquadLocation or VDist3XZSq( unit.Position, unit.GOAP.SquadLocation ) < AIGlobals.AISquadLocationDistSq then
            # -- return false
        # -- end
        
        # -- return true
    # -- end,
    # -- MasterGoalWeights = {
        # -- MoveToSquadLocation = 2.0,
    # -- }
# -- }

HeroAIGoalTemplates['WaitMasterGoal'] =  {
    Name = 'WaitMasterGoal',
    MasterGoal = true,
	GoalStatusFunction = function(goal, unit)
		local enemyHeroes = unit:GetAIBrain():GetBlipsAroundPoint( categories.HERO, unit.Position, 60, 'Enemy' )
        if  enemyHeroes and table.getn( enemyHeroes ) > 0 then
            return false
        end
	end,
    MasterGoalWeights = {
        WaitGoal = 2.0,
    },
}

# -- HeroAIGoalTemplate {
    # -- Name = 'SquadKill',
    # -- MasterGoal = true,
    # -- GoalStatusFunction = function(goal, unit)
        # -- unit.GOAP.SquadTargetHealth = false

        # -- if not unit.GOAP.AttackTarget or unit.GOAP.AttackTarget:IsDead() then
            # -- return false
        # -- end
    
        # -- local strategicGoap = unit:GetAIBrain():GetTeamArmy().GOAP
        # -- if (unit.GOAP.TargetType == 'HERO') and (not strategicGoap:CheckEnemyHeroIntel(unit.GOAP.AttackTarget)) then
            # -- return false
        # -- end
        
        # -- if VDist3XZSq( unit.Position, unit.GOAP.AttackTarget.Position ) > 1600 then
            # -- return false
        # -- end

        # -- unit.GOAP.SquadTargetHealth = unit.GOAP.AttackTarget:GetHealth()
        
        # -- return true
    # -- end,
    # -- MasterGoalWeights = {
        # -- KillSquadTarget = 2.0,
    # -- }
# -- }

HeroAIGoalTemplates.CapturePoint = {
    Name = 'CapturePoint',
    GoalStatusFunction = function(goal, unit)
		#[MOD]  Increase Range to search for flags.
        local aiBrain = unit:GetAIBrain()		
		local enemyTeamBrain
		local neutCivBrain
		local allyTeamBrain
		
		for k, brain in ArmyBrains do
			if brain.TeamBrain and IsEnemy(aiBrain:GetArmyIndex(), brain:GetArmyIndex()) then
				enemyTeamBrain = brain
			elseif brain.TeamBrain and IsAlly(aiBrain:GetArmyIndex(), brain:GetArmyIndex()) then
				allyTeamBrain = brain
			elseif brain.Name == 'NEUTRAL_CIVILIAN' then
				neutCivBrain = brain
			end
		end
		

		local nflags = neutCivBrain:GetListOfUnits(categories.FLAG, false)
		local eflags = enemyTeamBrain:GetListOfUnits(categories.FLAG, false)
		#local aflags = allyTeamBrain:GetListOfUnits(categories.FLAG, false)
		
		if table.getn(eflags) > 0 or table.getn(nflags) > 0 then
			return true
		end
        
        return false
    end,
    MasterGoal = true,
    MasterGoalWeights = {
        CaptureFlag = 2.0,
    }
}

# -- HeroAIGoalTemplate {
    # -- Name = 'CTF',
    # -- MasterGoal = true,
    # -- Victory = 'capturetheflag',
    # -- MasterGoalWeights = {
        # -- CTFGoal = 2.0,
    # -- }
# -- }

# -- HeroAIGoalTemplate {
    # -- Name = 'MakeItemPurchases',
    # -- MasterGoal = true,
    # -- MasterGoalWeights = {
        # -- PurchaseItems = 2.0,
    # -- },
    # -- GoalStatusFunction = function(goal, unit)
        # -- for k,v in unit.ShopInformation.CanBuyItem do
            # -- if v then
                # -- return true
            # -- end
        # -- end
        # -- return false
    # -- end,
# -- }

