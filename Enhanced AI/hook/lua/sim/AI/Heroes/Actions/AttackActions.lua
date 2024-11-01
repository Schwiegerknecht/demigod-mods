#  [MOD]  Reduce attack duratioins
#  [MOD]  Increase Weights of better actions

HeroAIActionTemplates.AttackClosestInfantry =  {
    Name = 'AttackClosestInfantry',
    GoalSets = {
        Attack = true,
		#Assassinate = true,
    },
    ActionDuration = 3,
    DisableActions = table.append( AttackDisables, DefaultDisables ),
    ActionFunction = function(unit, action)
        local actionBp = HeroAIActionTemplates[action.ActionName]
        local attackPriorities = {
            categories.GIANT,
            categories.HEALER,
            categories.ARTILLERY,
            categories.ARCHER * categories.GRUNT,
            categories.GRUNT,
        }
        unit.HeroUnitPlatoon:SetPrioritizedTargetList('attack', attackPriorities )

        local cmd
        local target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Enemy', true, unit.Position, unit.MoveCutoffRange * 0.9 )
        if not target then
            target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Enemy', true, unit.Position, unit.MoveCutoffRange * 1.4)
        end
        if not target then
            target = unit.HeroUnitPlatoon:FindClosestUnit( 'attack', 'Enemy', true, categories.MOBILE + categories.DEFENSE  ) #
        end

        if not target then
            WaitSeconds(0.5)
            return false
        end

        cmd = IssueAttack( {unit}, target, true )
        cmd = IssueAggressiveMove( {unit}, target:GetPosition(), true )
        local lastTarget = target

        local durationTimer = 0
        while not unit:IsDead() and durationTimer < actionBp.ActionDuration do
            WaitSeconds(1)
            durationTimer = durationTimer + 1
            if unit:IsDead() then
                return
            end
            target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Enemy', true, unit.Position, unit.MoveCutoffRange * 0.9 )
            if not target then
                target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Enemy', true, unit.Position, unit.MoveCutoffRange * 1.4)
            end
            if not target then
                target = unit.HeroUnitPlatoon:FindClosestUnit( 'attack', 'Enemy', true, categories.MOBILE + categories.DEFENSE ) # 
            end
            if not target then
                break
            end

            if target != lastTarget then
                lastTarget = target
                IssueClearCommands( {unit} )
                cmd = IssueAttack( {unit}, target, true )
                cmd = IssueAggressiveMove( {unit}, target:GetPosition(), true )
            end
        end
    end,
    StatusTrigger = function(unit,action)
        local aiBrain = unit:GetAIBrain()
        
        # For this ability, we only want to engage in combat if there are no friends nearby
        # IF there are friends nearby, there are better abilities to use
        local teamBrain = aiBrain:GetTeamArmy()
        local friendlyPlatoons = teamBrain:GetPlatoonsAroundPoint(unit.Position, 24)
        if table.empty(friendlyPlatoons) then
            return true
        end

        return false
        
        #for k,v in friendlyPlatoons do
        #    if v:IsAttacking('Attack') then
        #        return false
        #    end
        #end
        
        #return true
    end,
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
        if not agent.WorldStateData.CanAttack or not agent.WorldStateData.CanMove then
            return false
        end

        local threat = aiBrain:GetThreatAtPosition( agent.Position, 1, 'LandNoHero', 'Enemy' )

        local actionBp = HeroAIActionTemplates[action.ActionName]
        if threat >= 1 then
            return { KillUnits = -5 + agent.WorldStateData.GruntKillBonus } #, actionBp.ActionDuration
        end

        return false
    end,
}

HeroAIActionTemplates['Attack Closest Infantry with friendly Creep'] = {
    Name = 'Attack Closest Infantry with friendly Creep',
    GoalSets = {
        Attack = true,
        MoveToFriendly = true,
        CarefulAttack = true,
    },
    ActionSets = {
        MeleeHero = true,
    },
    DisableActions = table.append( AttackDisables, DefaultDisables ),
    ActionDuration = 3,
    ActionFunction = function(unit, action)
        local aiBrain = unit:GetAIBrain()
        local actionBp = HeroAIActionTemplates[action.ActionName]
        local friendPriorities = {
            categories.GRUNT + categories.HERO  + categories.DEFENSE ,  #
        }
        unit.HeroUnitPlatoon:SetPrioritizedTargetList('attack', friendPriorities )

        local cmd
        local durationTimer = 0
        local maxDuration = actionBp.ActionDuration

        # Find friendly units and move to them first

        # We look around for threats that we want to fight
        local query = CreateThreatQuery(unit.Army)
        query:GetThreatsAroundPoint( unit.Position, 2, 'LandNoHero', 'Enemy' )
        query:SortClosestToFurthest()
        local threats = query:GetResults()

        if not threats then
            return false
        end

        local target = false
        # find the friend to move to based on distance and threat
        for k,v in threats do
            if v[3] <= 0 then
                continue
            end

            local threatPos = { v[1], 0, v[2] }
            # Some friends in the area; find the best friend to hang out with
            if aiBrain:GetThreatAtPosition( threatPos, 0, 'LandNoHero', 'Ally' ) < 0 then
                target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Ally', false, threatPos, 5 )
                if not target then
                    target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Ally', false, threatPos, 10 )
                end
                if not target then
                    target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Ally', false, threatPos, 15 )
                end
                if target then
                    break
                end
            end
        end

        # No friend; leave action
        if not target then
            return false
        end

        if VDist3XZSq( target.Position, unit.Position ) > 25 then
            # Move to friend
            cmd = IssueMove( {unit}, target.Position )
            while not IsCommandDone(cmd) and not target:IsDead() and VDist3XZSq( target.Position, unit.Position ) > 25 and durationTimer < maxDuration do
                durationTimer = durationTimer + 1
                WaitSeconds(1)
                if unit:IsDead() then
                    return
                end
            end
        end
        
        local attackPriorities = {
            categories.GIANT,
            categories.HEALER,
            categories.ARTILLERY,
            categories.ARCHER * categories.GRUNT,
            categories.GRUNT,
        }
        unit.HeroUnitPlatoon:SetPrioritizedTargetList('attack', attackPriorities )

        # Now that we are close to friendlies, attack nearby enemies
        local target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Enemy', true, unit.Position, unit.MoveCutoffRange * 0.4 )
        if not target then
            target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Enemy', true, unit.Position, unit.MoveCutoffRange * 0.9)
        end
        if not target then
            target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Enemy', true, unit.Position, unit.MoveCutoffRange * 1.4)
        end
        if not target then
            target = unit.HeroUnitPlatoon:FindClosestUnit( 'attack', 'Enemy', true, categories.MOBILE + categories.DEFENSE  )  #
        end

        if not target then
            WaitSeconds(0.2)
            return false
        end

        cmd = IssueAttack( {unit}, target, true )
        cmd = IssueAggressiveMove( {unit}, target.Position, true )
        local lastTarget = target

        while durationTimer < maxDuration do
            WaitSeconds(0.5)
            durationTimer = durationTimer + 0.5
            if unit:IsDead() then
                return
            end
            target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Enemy', true, unit.Position, unit.MoveCutoffRange * 0.4 )
            if not target then
                target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Enemy', true, unit.Position, unit.MoveCutoffRange * 0.9)
            end
            if not target then
                target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Enemy', true, unit.Position, unit.MoveCutoffRange * 1.4)
            end
            if not target then
                target = unit.HeroUnitPlatoon:FindClosestUnit( 'attack', 'Enemy', true, categories.MOBILE + categories.DEFENSE )  #
            end
            if not target then
                break
            end

            if target != lastTarget then
                lastTarget = target
                IssueClearCommands( {unit} )
                cmd = IssueAttack( {unit}, target, true )
                cmd = IssueAggressiveMove( {unit}, target.Position, true )
            end
        end
    end,
    StatusTrigger = function(unit,action)
        local aiBrain = unit:GetAIBrain()
        
        local teamBrain = aiBrain:GetTeamArmy()
        local friendlyPlatoons = teamBrain:GetPlatoonsAroundPoint(unit.Position, 32)
        if table.empty(friendlyPlatoons) then
            return false
        end

        return true
        
        #for k,v in friendlyPlatoons do
        #    if v:IsAttacking('Attack') then
        #        return true
        #    end
        #end
        
        #return false
    end,
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
        if not agent.WorldStateData.CanAttack or not agent.WorldStateData.CanMove then
            return false
        end

        local actionBp = HeroAIActionTemplates[action.ActionName]
        
        return { AttackWithHelp = -10, KillUnits = -15 + agent.WorldStateData.GruntKillBonus, Survival = -5 }#, actionBp.ActionDuration
    end,
}

# -- local function FindBackRowPosition(unit, aiBrain)
    # -- local backCategory = categories.DEFENSE + ( categories.HEALER + categories.ARCHER + categories.ARTILLERY ) * categories.GRUNT
    # -- local backrow = aiBrain:GetUnitsAroundPoint( backCategory, unit.Position, 20, 'Ally' )
    # -- if table.empty(backrow) then
        # -- return false
    # -- end
    
    # -- local enemyCategory = categories.MOBILE * categories.LAND

    # -- # There are enemies within 20 o-grids, but no enemies are really close to the hero; we don't really need to move
    # -- local closeEnemyUnits = aiBrain:GetBlipsAroundPoint( enemyCategory, unit.Position, 5, 'Enemy' )
    # -- local enemyUnits = aiBrain:GetBlipsAroundPoint( enemyCategory, unit.Position, 15, 'Enemy' )
    # -- if table.empty(closeEnemyUnits) and not table.empty(enemyUnits) then
        # -- return unit.Position
    # -- end

    # -- local lowestInRange = false
    # -- local lowestCount = 0
    # -- local bestPosition = false
    # -- if table.getn(enemyUnits) > 0 then
        # -- lowestInRange = true
        # -- bestPosition = unit.Position
        # -- lowestCount = table.getn(closeEnemyUnits)
    # -- end

    # -- for k,v in backrow do
        # -- enemyUnits = aiBrain:GetBlipsAroundPoint( enemyCategory, v.Position, 15, 'Enemy' )
        # -- # We want to fight where enemies are in range; if we already have a unit with enemies in range ignore those that don't
        # -- # have enemies in range
        # -- if lowestInRange and table.empty( enemyUnits ) then
            # -- continue
        # -- end
        
        # -- local tempRange = table.getn(enemyUnits)
        # -- enemyUnits = FilterEntitiesFurtherThan(v.Position,enemyUnits,5)
        # -- local tempCount = table.getn(enemyUnits)
        
        # -- if tempCount == 0 and tempRange > 0 then
            # -- bestPosition = table.copy( v.Position )
            # -- break
        # -- elseif (not lowestCount or tempCount < lowestCount ) and (not lowestInRange or tempRange > 0) then
            # -- lowestCount = tempCount
            # -- bestPosition = table.copy( v.Position )
            # -- if tempRange > 0 then
                # -- lowestInRange = true
            # -- end
        # -- end
    # -- end

    # -- return bestPosition
# -- end

HeroAIActionTemplates['Attack from back line'] = {
    Name = 'Attack from back line',
    GoalSets = {
        Attack = true,
        MoveToFriendly = true,
        CarefulAttack = true,
		#Assassinate = true,
    },
    ActionSets = {
        RangeHero = true,
    },
    ActionDuration = 3,
    DisableActions = table.append( AttackDisables, DefaultDisables ),
    ActionFunction = function(unit, action)
        local aiBrain = unit:GetAIBrain()
        local actionBp = HeroAIActionTemplates[action.ActionName]

        local attackPriorities = {
			categories.DEFENSE,
            categories.HEALER * categories.GRUNT,
            categories.HERO,
            categories.GIANT,
            categories.ARTILLERY * categories.GRUNT,
            categories.ARCHER * categories.GRUNT,
            categories.GRUNT,
            categories.STRUCTURE,
        }
        unit.HeroUnitPlatoon:SetPrioritizedTargetList('attack', attackPriorities )

        local bestPosition = FindBackRowPosition(unit, aiBrain)
        if not bestPosition then
            return
        end
        local durationTimer = 0

        if unit.Position[1] != bestPosition[1] or unit.Position[3] != bestPosition[3] then
            local cmd = IssueMove( {unit}, bestPosition )
            while not IsCommandDone(cmd) and durationTimer < actionBp.ActionDuration and VDist3XZSq( bestPosition, unit.Position ) > 16 do
                WaitSeconds(1)
                durationTimer = durationTimer + 1
                if unit:IsDead() then
                    return
                end
            end
        end

        # Now that we are close to friendlies, attack nearby enemies
        local target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Enemy', true, unit.Position, unit.MoveCutoffRange * 0.4 )
        if not target then
            target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Enemy', true, unit.Position, unit.MoveCutoffRange * 0.9)
        end
        if not target then
            target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Enemy', true, unit.Position, unit.MoveCutoffRange * 1.4)
        end
        if not target then
            target = unit.HeroUnitPlatoon:FindClosestUnit( 'attack', 'Enemy', true, categories.MOBILE + categories.DEFENSE )  #
        end

        if not target then
            WaitSeconds(0.2)
            return false
        end

        cmd = IssueAttack( {unit}, target, true)
        cmd = IssueAggressiveMove( {unit}, target.Position, true )
        local lastTarget = target

        while durationTimer < actionBp.ActionDuration do
            WaitSeconds(1)
            durationTimer = durationTimer + 1
            if unit:IsDead() then
                return
            end
            target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Enemy', true, unit.Position, unit.MoveCutoffRange * 0.4 )
            if not target then
                target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Enemy', true, unit.Position, unit.MoveCutoffRange * 0.9)
            end
            if not target then
                target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Enemy', true, unit.Position, unit.MoveCutoffRange * 1.4)
            end
            if not target then
                target = unit.HeroUnitPlatoon:FindClosestUnit( 'attack', 'Enemy', true, categories.MOBILE + categories.DEFENSE  )  #
            end
            if not target then
                break
            end

            if target != lastTarget then
                lastTarget = target
                IssueClearCommands( {unit} )
                cmd = IssueAttack( {unit}, target, true )
                cmd = IssueAggressiveMove( {unit}, target.Position, true )
            end
        end
    end,
    InstantStatusFunction = function(unit, action)
        local aiBrain = unit:GetAIBrain()

        local bestPosition = FindBackRowPosition(unit, aiBrain)

        if not bestPosition then
            return false
        end

        return true
    end,
    CalculateWeights = function(action, aiBrain, agent, initialAgent )
        local actionBp = HeroAIActionTemplates[action.ActionName]
        if not agent.WorldStateData.CanAttack or not agent.WorldStateData.CanMove then
            return false
        end

        return { AttackWithHelp = -10, KillUnits = -5 + agent.WorldStateData.GruntKillBonus, Survival = -5 }#, actionBp.ActionDuration
    end,
}

# -- local function AttackSquadTarget(unit, action)
    # -- local target = unit.GOAP.AttackTarget
    # -- if not target or target:IsDead() then
        # -- return false
    # -- end

    # -- local target = AIUtils.FilterRunningAwayUnits( unit, {target} )
    # -- if not target then
        # -- return false
    # -- end

    # -- local cmd = IssueAttack( {unit}, target, true )

    # -- local durationTimer = 0
    # -- while not unit:IsDead() and durationTimer < 3 and not target:IsDead() do
        # -- WaitSeconds(0.5)
        # -- durationTimer = durationTimer + 0.5
        # -- if unit:IsDead() then
            # -- return
        # -- end
    # -- end
# -- end

HeroAIActionTemplates['Attack Squad Target'] = {
    Name = 'Attack Squad Target',
    DisableActions = table.append( MoveAndAttackDisables, DefaultDisables ),
    GoalSets = {
        SquadKill = true,
    },
    TargetTypes = { 'STRUCTURE', 'HERO', 'MOBILE' },
    InstantStatusFunction = AIAbility.CheckTargetTypes,
    ActionFunction = AttackSquadTarget,
    ActionDuration = 3,
    CalculateWeights = function( action, aibrain, agent, initialAgent )
        if not agent.WorldStateData.CanAttack or not agent.WorldStateData.CanMove then
            return false
        end

        if not initialAgent.GOAP.SquadTargetHealth then
            return false
        end

        local actionBp = HeroAIActionTemplates[action.ActionName]

        local numAttacks = math.floor( actionBp.ActionDuration / agent.AttackSpeed )
        local damageDone = agent.DamageRating * numAttacks

        returnValue = 0

        local enemyHps = initialAgent.GOAP.SquadTargetHealth
        local damageRatio = enemyHps / damageDone
        if damageRatio < 1.0 then
            returnValue = -25
        elseif damageRatio < 2 then
            returnValue = -20
        elseif damageRatio < 3.0 then
            returnValue = -15
        else
            returnValue = -10
        end

        return { KillSquadTarget = 0 }#, actionBp.ActionDuration  #returnValue + agent.WorldStateData.HeroKillBonus
    end,
}

HeroAIActionTemplates['Attack Closest Hero - Ranged Hero'] = {
    Name = 'Attack Closest Hero - Ranged Hero',
    DisableActions = table.append( AttackDisables, DefaultDisables ),
    ActionSets = {
        RangeHero = true,
    },
    GoalSets = {
        Assassinate = true,
    },
    ActionDuration = 3,
    ActionFunction = function(unit, action)
        local aiBrain = unit:GetAIBrain()
        local actionBp = HeroAIActionTemplates[action.ActionName]

        local attackTargetCategory = categories.HERO
        local enemyHeroes = aiBrain:GetBlipsAroundPoint( attackTargetCategory, unit:GetPosition(), unit.MoveCutoffRange * 1.5, 'Enemy' )

		if unit:GetHealth() < 1500 then
            return false
        end		
		
        if table.getn(enemyHeroes) == 0 then
            return false
        end

        local target = AIUtils.GetNearbyWeakHero(unit, 30)  #FilterRunningAwayUnits( unit, enemyHeroes )
        if not target then
            return false
        end
        local lastTarget = target


		
        local cmd = IssueAttack( {unit}, target, true )
		
		#WARN('Peppe  --- Attack 1')
		
        local durationTimer = 0
        while not unit:IsDead() and durationTimer < actionBp.ActionDuration do
            WaitSeconds(0.5)
            durationTimer = durationTimer + 0.5
            if unit:IsDead() then
                return
            end

            enemyHeroes = aiBrain:GetBlipsAroundPoint( attackTargetCategory, unit:GetPosition(), unit.MoveCutoffRange * 1.5, 'Enemy' )

            if table.getn(enemyHeroes) == 0 then
                return false
            end
		if unit:GetHealth() < 1500 then
            return false
        end	
			
            target = AIUtils.GetNearbyWeakHero(unit, 30) #FilterRunningAwayUnits( unit, enemyHeroes )
            if not target or target:IsDead() then
                return false
            end
			
			local  towerThreat = aiBrain:GetBlipsAroundPoint( categories.DEFENSE  - categories.ROOKTOWER, unit.Position, 16, 'Enemy' )
			if table.getn(towerThreat) > 0 and target:GetHealth() > 400 or unit:GetHealth() < 1500    then
				return false
			end

		#WARN('Peppe  --- Attack Loop')

            if lastTarget != target then
                lastTarget = target
                IssueClearCommands( {unit} )
                cmd = IssueAttack( {unit}, target, true )
            end
        end
    end,
    InstantStatusFunction = function(unit,action)
        if not unit.GOAP.NearbyEnemyHeroes or unit.GOAP.NearbyEnemyHeroes.ClosestDistance > unit.MoveCutoffRange * 3 then
            return false
        end
        local aiBrain = unit:GetAIBrain()
        local  towerThreat = aiBrain:GetBlipsAroundPoint( categories.DEFENSE  - categories.ROOKTOWER, unit.Position, 16, 'Enemy' )
		# -- if table.getn(towerThreat) > 0 then
			# -- return false
        # -- end
		if (unit:GetHealth() / 1500) < table.getn(towerThreat) then
			return false
		end

        return true
    end,
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
        if not agent.WorldStateData.CanAttack or not agent.WorldStateData.CanMove then
            return false
        end

        if not initialAgent.GOAP.NearbyEnemyHeroes then
            return false
        end

		
        #initialAgent.GOAP.NearbyEnemyHeroes = {
        #    WeakestHealth = false,
        #    WeakestDistance = false,
        #    WeakestLevel = false,
        #    ClosestHealth = false,
        #    ClosestDistance = false,
        #    ClosestLevel = false
        #}
        local actionBp = HeroAIActionTemplates[action.ActionName]

        local numAttacks = math.floor( actionBp.ActionDuration / agent.AttackSpeed )
        local damageDone = agent.DamageRating * numAttacks

        returnValue = 0

        local enemyHps = initialAgent.GOAP.NearbyEnemyHeroes.WeakestHealth 
        local damageRatio = enemyHps / damageDone
        if damageRatio < 1.0 then
            returnValue = -10
        elseif damageRatio < 2 then
            returnValue = -7
        elseif damageRatio < 3.0 then
            returnValue = -5
        else
            returnValue = -3
        end

        return { KillHero = returnValue + agent.WorldStateData.HeroKillBonus }
    end,
}

HeroAIActionTemplates['Attack Closest Hero - Melee Hero'] = {
    Name = 'Attack Closest Hero - Melee Hero',
    DisableActions = table.append( AttackDisables, DefaultDisables ),
    ActionSets = {
        MeleeHero = true,
    },
    GoalSets = {
        Assassinate = true,
    },
    ActionDuration = 3,
    ActionFunction = function(unit, action)
        local aiBrain = unit:GetAIBrain()
        local actionBp = HeroAIActionTemplates[action.ActionName]

        local cmd
        local attackTargetCategory = categories.HERO

        local enemyHeroes = aiBrain:GetBlipsAroundPoint( attackTargetCategory, unit:GetPosition(), unit.MoveCutoffRange * 3, 'Enemy' )

        if table.getn(enemyHeroes) == 0 then
            return false
        end
		if unit:GetHealth() < 1500 then
            return false
        end	
        local target = AIUtils.GetNearbyWeakHero(unit, 30) #FilterRunningAwayUnits( unit, enemyHeroes )
        local lastTarget = target
        if not target then
            return false
        end



		
        cmd = IssueAttack( {unit}, target, true )

        local durationTimer = 0
        while not unit:IsDead() and durationTimer < actionBp.ActionDuration do
            WaitSeconds(0.5)
            durationTimer = durationTimer + 0.5
            if unit:IsDead() then
                return
            end

            if target and not target:IsDead() then
                target = AIUtils.GetNearbyWeakHero(unit, 30)  #FilterRunningAwayUnits( unit, {target} )
            end

            if not target or target:IsDead() then
                local enemyHeroes = aiBrain:GetBlipsAroundPoint( attackTargetCategory, unit:GetPosition(), unit.MoveCutoffRange * 3, 'Enemy' )

                if table.getn(enemyHeroes) == 0 then
                    return false
                end
		if unit:GetHealth() < 1500 then
            return false
        end	
                target = AIUtils.GetNearbyWeakHero(unit, 30)  #FilterRunningAwayUnits( unit, enemyHeroes )
                if not target or target:IsDead() then
                    return false
                end
            end

			local  towerThreat = aiBrain:GetBlipsAroundPoint( categories.DEFENSE  - categories.ROOKTOWER, unit.Position, 16, 'Enemy' )
			if table.getn(towerThreat) > 0 and target:GetHealth() > 400 or unit:GetHealth() < 1500    then
				return false
			end

	

            if target != lastTarget then
                lastTarget = target
                IssueClearCommands( {unit} )
                cmd = IssueAttack( {unit}, target, true )
            end
        end
    end,
    InstantStatusFunction = function(unit,action)
        if not unit.GOAP.NearbyEnemyHeroes or unit.GOAP.NearbyEnemyHeroes.ClosestDistance > unit.MoveCutoffRange * 3 then
            return false
        end
        local aiBrain = unit:GetAIBrain()
        local  towerThreat = aiBrain:GetBlipsAroundPoint( categories.DEFENSE  - categories.ROOKTOWER, unit.Position, 16, 'Enemy' )
		# -- if table.getn(towerThreat) > 0 then
			# -- return false
        # -- end
		if (unit:GetHealth() / 1500) < table.getn(towerThreat) then
			return false
		end
		

        return true
    end,
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
        if not agent.WorldStateData.CanAttack or not agent.WorldStateData.CanMove then
            return false
        end

        if not initialAgent.GOAP.NearbyEnemyHeroes then
            return false
        end


		
        local actionBp = HeroAIActionTemplates[action.ActionName]

        local numAttacks = math.floor( actionBp.ActionDuration / agent.AttackSpeed )
        local damageDone = agent.DamageRating * numAttacks

        returnValue = 0

        local enemyHps = initialAgent.GOAP.NearbyEnemyHeroes.WeakestHealth 
        local damageRatio = enemyHps / damageDone
        if damageRatio < 1.0 then
            returnValue = -10
        elseif damageRatio < 2 then
            returnValue = -7
        elseif damageRatio < 3.0 then
            returnValue = -5
        else
            returnValue = -3
        end

        if agent.WorldStateData.WeakHeroNearby then
            returnValue = returnValue - 2
        end

        return { KillHero = returnValue + agent.WorldStateData.HeroKillBonus }#, actionBp.ActionDuration
    end,
}


HeroAIActionTemplates['Attack Closest Building'] = {
    Name = 'Attack Closest Building',
    DisableActions = table.append( AttackDisables, DefaultDisables ),
    GoalSets = {
        CapturePoint = true,
        DestroyStructures = true,
        Attack = true,
    },
    ActionDuration = 3,
    ActionFunction = function(unit, action)
      local actionBp = HeroAIActionTemplates[action.ActionName]
        local attackPriorities = {
            categories.DEFENSE,
            categories.STRONGHOLD,
            categories.STRUCTURE,
        }
        unit.HeroUnitPlatoon:SetPrioritizedTargetList('attack', attackPriorities )

        local cmd
# 0.27.04 increased unit.movecutoffrange from 1.2 to 2.5
        local target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Enemy', true, unit:GetPosition(), unit.MoveCutoffRange * 2.5 )
        if not target then
            target = unit.HeroUnitPlatoon:FindClosestUnit( 'attack', 'Enemy', true, categories.ALLUNITS )
        end
        local lastTarget = target

        if not target then
            WaitSeconds(0.5)
            return false
        end
		
		local aiBrain = unit:GetAIBrain()
		#WARN(  LOC(aiBrain.Nickname) .. ' Attacking Structures' )
        cmd = IssueAttack( {unit}, target, true )
        cmd = IssueAggressiveMove( {unit}, target:GetPosition(), true )

        local durationTimer = 0
        while not unit:IsDead() and durationTimer < actionBp.ActionDuration do
            WaitSeconds(1)
            durationTimer = durationTimer + 1
            if unit:IsDead() then
                return
            end
# 0.27.04 increased unit.movecutoffrange from 1.2 to 2.5
            target = unit.HeroUnitPlatoon:FindPrioritizedUnit('attack', 'Enemy', true, unit:GetPosition(), unit.MoveCutoffRange * 2.5 )
            if not target then
                target = unit.HeroUnitPlatoon:FindClosestUnit( 'attack', 'Enemy', true, categories.ALLUNITS )
            end
            if not target then
                break
            end

            if target != lastTarget then
                lastTarget = target
                IssueClearCommands( {unit} )
                cmd = IssueAttack( {unit}, target, true )
                cmd = IssueAggressiveMove( {unit}, target:GetPosition(), true )
            end
        end
    end,
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
        if not agent.WorldStateData.CanAttack or not agent.WorldStateData.CanMove then
            return false
        end

		local towerCount = aiBrain:GetBlipsAroundPoint( categories.DEFENSE  - categories.ROOKTOWER, agent.Position, 20, 'Enemy' ) 
		if table.empty(towerCount) then
			return false
		end
		
		if agent.GOAP.NearbyEnemyHeroes and agent.GOAP.NearbyEnemyHeroes.ClosestDistance < 30 then
            return false
        end
		
		if initialAgent:GetHealthPercent() < .6 then
			return false
		end
		
		local allies = aiBrain:GetUnitsAroundPoint( categories.HERO, agent.Position, 20, 'Ally' )

		local multiplier = table.getn(allies)
		multiplier = (multiplier) * aiBrain.Score.HeroLevel
		#WARN( ' structure '  .. multiplier )

		

		
        local actionBp = HeroAIActionTemplates[action.ActionName]		


        # -- local numAttacks = math.floor( actionBp.ActionDuration / agent.AttackSpeed )
        # -- local damageDone = agent.DamageRating * numAttacks

        # -- returnValue = 0

        # -- local enemyHps = initialAgent.GOAP.NearbyEnemyStructures.WeakestHealth 
        # -- local damageRatio = enemyHps / damageDone
        # -- if damageRatio < 1.0 then
            # -- returnValue = -10
        # -- elseif damageRatio < 2 then
            # -- returnValue = -7
        # -- elseif damageRatio < 3.0 then
            # -- returnValue = -5
        # -- else
            # -- returnValue = -3
        # -- end

        return { KillStructures = -2 * multiplier }#, actionBp.ActionDuration
    end,
}
