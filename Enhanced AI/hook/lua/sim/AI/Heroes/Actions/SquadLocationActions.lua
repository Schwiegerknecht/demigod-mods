#  [MOD] Wait times reduced.  Weight increased.



# -- local AIUtils = import('/lua/sim/ai/aiutilities.lua')
# -- local AIAbility = import('/lua/sim/ai/AIAbilityUtilities.lua')

# -- local AIGlobals = import('/lua/sim/ai/AIGlobals.lua')
# -- local DefaultDisables = AIGlobals.DefaultDisables

# -- local MoveDisables = AIGlobals.MoveDisables

# -- local ValidateShop = import('/lua/common/ValidateShop.lua')
# -- local ValidateInventory = import('/lua/common/ValidateInventory.lua')
# -- local ValidateAbility = import('/lua/common/ValidateAbility.lua')
# -- local AIAbility = import('/lua/sim/ai/AIAbilityUtilities.lua')
# -- local GetReadyAbility = AIAbility.GetReadyAbility


HeroAIActionTemplates['Move - Squad defined location'] = {
    Name = 'Move - Squad defined location',
    GoalSets = {
        SquadMove = true,
    },
    DisableActions = table.append( MoveDisables, DefaultDisables ),
    ActionFunction = function(unit, action)
        local debug = false
        if ScenarioInfo.Options.DebugAI then
            debug = true
        end
        local aiBrain = unit:GetAIBrain()

        # Make sure there is a squad location and that we are not close to it
        if not unit.GOAP.SquadLocation or VDist3XZSq( unit.GOAP.SquadLocation, unit.Position ) < 100 then
            return
        end
        local location = table.copy(unit.GOAP.SquadLocation)

        # Find the safest path to get to the point
        local path = AIUtils.GetSafePathBetweenPoints(aiBrain, unit.Position, location)
        if not path then
            path = { location }
        end

        # Move along the path
        local cmd = false
        for k,v in path do
            cmd = IssueMove( {unit}, v )
        end

		#  [MOD] Wait time
        # If we have no command; leave this action
        if not cmd then
            WaitSeconds(.5)
            return
        end

        local durationTimer = 0
        #local lastPosition = table.copy(unit.Position)
        #local stuckCount = 0
        while not IsCommandDone(cmd) and durationTimer < 10 do
            if debug then
                AIUtils.DrawPath(path, unit:GetAIBrain().Name, unit.Position )
            end
            WaitSeconds(0.2)
            durationTimer = durationTimer + 0.2
            if unit:IsDead() then
                return
            end

            # Location moved too much
            if not unit.GOAP.SquadLocation or VDist3XZSq( location, unit.GOAP.SquadLocation ) > 100 then
                return
            end

            local threat = aiBrain:GetThreatAtPosition( unit.Position, 0, 'Hero', 'Enemy' )
            if VDist3XZSq( unit.Position, location ) < 100 or threat > 5 then
                return
            end

            #if lastPosition[1] == unit.Position[1] and lastPosition[3] == unit.Position[3] then
            #    stuckCount = stuckCount + 1
            #    if stuckCount == 10 then
            #        return
            #    end
            #else
            #    stuckCount = 0
            #end

            #lastPosition = table.copy(unit.Position)
        end
    end,
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
        if not agent.WorldStateData.CanMove then
            return false
        end
        local location = initialAgent.GOAP.SquadLocation
        if not location then
            return false
        end

        # If the agent's posisiont puts him within 10 o-grids; we don't need to move
        local distance = VDist3XZSq( agent.Position, location )
        if distance < 100 then
            return false
        end

        local threat = aiBrain:GetThreatAtPosition( agent.Position, 0, 'Hero', 'Enemy' )
        if threat > 5 then
            return false
        end

        return { MoveToSquadLocation = -5, }, distance / agent.Speed
    end,
}

# -- HeroAIActionTemplate {
    # -- Name = 'Move - Infantry near Squad defined location',
    # -- GoalSets = {
        # -- SquadMove = true,
    # -- },
    # -- UnitDistance = 15,
    # -- DisableActions = table.append( MoveDisables, DefaultDisables ),
    # -- ActionFunction = function(unit, action)
        # -- local aiBrain = unit:GetAIBrain()

        # -- local teamBrain = aiBrain:GetTeamArmy()
        # -- local unitDistance = HeroAIActionTemplates[action.ActionName].UnitDistance

        # -- local debug = false
        # -- if ScenarioInfo.Options.DebugAI then
            # -- debug = true
        # -- end

        # -- # Make sure there is a location adn taht we aren't already near it
        # -- if not unit.GOAP.SquadLocation or VDist3XZSq( unit.GOAP.SquadLocation, unit.Position ) < 100 then
            # -- return
        # -- end
        # -- local location = table.copy(unit.GOAP.SquadLocation)

        # -- # Find a grunt near the location to move to
        # -- local gruntCategory = categories.MOBILE * categories.LAND * categories.GRUNT
        # -- local friendlies = aiBrain:GetUnitsAroundPoint( gruntCategory, location, unitDistance, 'Ally' )
        # -- friendlies = FilterUnitsByArmy( teamBrain:GetArmyIndex(), friendlies )
        # -- if table.empty(friendlies) then
            # -- return
        # -- end

        # -- friendlies = SortEntitiesByDistanceXZ(unit.Position, friendlies)

        # -- local closest = friendlies[1]

        # -- # Get safest path to unit's position
        # -- local path = AIUtils.GetSafePathBetweenPoints(aiBrain, unit.Position, closest.Position)
        # -- if not path then
            # -- path = { closest.Position }
        # -- end

        # -- # Move along the path
        # -- local cmd = false
        # -- for k,v in path do
            # -- cmd = IssueMove( {unit}, v )
        # -- end

        # -- if not cmd then
            # -- WaitSeconds(1)
            # -- return
        # -- end

        # -- local durationTimer = 0
        # -- while not IsCommandDone(cmd) and durationTimer < 10 do
            # -- if debug then
                # -- AIUtils.DrawPath(path, unit:GetAIBrain().Name, unit.Position )
            # -- end
            # -- WaitSeconds(0.2)
            # -- durationTimer = durationTimer + 0.2
            # -- if unit:IsDead() then
                # -- return
            # -- end

            # -- # If all friendlies at location are dead; return out
            # -- friendlies = aiBrain:GetUnitsAroundPoint( gruntCategory, location, unitDistance, 'Ally' )
            # -- friendlies = FilterUnitsByArmy( teamBrain:GetArmyIndex(), friendlies )
            # -- if table.empty(friendlies) then
                # -- return
            # -- end

            # -- # Location moved; leave if too far away or we lost our location
            # -- if not unit.GOAP.SquadLocation or VDist3XZSq(location, unit.GOAP.SquadLocation) > 100 then
                # -- return
            # -- end

            # -- # We are close to the position; leave
            # -- local distance = VDist3XZSq( unit.Position, location )
            # -- if distance < 100 then
                # -- return
            # -- end

            # -- local threat = aiBrain:GetThreatAtPosition( unit.Position, 0, 'Land', 'Enemy' )
            # -- threat = threat + aiBrain:GetThreatAtPosition( unit.Position, 0, 'Structures', 'Enemy' )
            # -- if threat > 5 then
                # -- return
            # -- end

            # -- # We are pretty close to the position and friends are nearby; leave
            # -- if distance < 225 and aiBrain:GetNumUnitsAroundPoint( gruntCategory, unit.Position, 10, 'Ally' ) > 0 then
                # -- return
            # -- end
        # -- end
    # -- end,
    # -- InstantStatusFunction = function(unit, action)
        # -- local aiBrain = unit:GetAIBrain()
        # -- local location = unit.GOAP.SquadLocation

        # -- # Make sure there is a location; adn that we aren't already pretty close to it
        # -- if not location or VDist3XZSq( unit.Position, location ) < 400 then
            # -- return
        # -- end

        # -- # Make sure there are team army units near the position
        # -- local unitDistance = HeroAIActionTemplates[action.ActionName].UnitDistance
        # -- local gruntCategory = (categories.MOBILE * categories.LAND) * categories.GRUNT
        # -- local friendlies = aiBrain:GetUnitsAroundPoint( gruntCategory, location, unitDistance, 'Ally' )

        # -- local teamBrain = aiBrain:GetTeamArmy()
        # -- friendlies = FilterUnitsByArmy( teamBrain:GetArmyIndex(), friendlies )

        # -- if table.empty(friendlies) then
            # -- return false
        # -- end

        # -- return true
    # -- end,
    # -- CalculateWeights = function( action, aiBrain, agent, initialAgent )
        # -- if not agent.WorldStateData.CanMove then
            # -- return false
        # -- end
        # -- local location = initialAgent.GOAP.SquadLocation
        # -- if not location then
            # -- return false
        # -- end

        # -- local distance = VDist3XZSq( agent.Position, location )
        # -- if distance < 100 then
            # -- return false
        # -- end

        # -- return { MoveToSquadLocation = -9, }, distance / agent.Speed
    # -- end,
# -- }

# -- HeroAIActionTemplate {
    # -- Name = 'Move - Defense near Squad defined location',
    # -- GoalSets = {
        # -- SquadMove = true,
    # -- },
    # -- UnitDistance = 20,
    # -- DisableActions = table.append( MoveDisables, DefaultDisables ),
    # -- ActionFunction = function(unit, action)
        # -- local debug = false
        # -- if ScenarioInfo.Options.DebugAI then
            # -- debug = true
        # -- end
        # -- local aiBrain = unit:GetAIBrain()

        # -- # Make sure there is a location adn taht we aren't already near it
        # -- if not unit.GOAP.SquadLocation or VDist3XZSq( unit.GOAP.SquadLocation, unit.Position ) < 100 then
            # -- return
        # -- end
        # -- local location = table.copy(unit.GOAP.SquadLocation)

        # -- # Find a structure nearby to move to
        # -- local defenseCat = categories.DEFENSE
        # -- local unitDistance = HeroAIActionTemplates[action.ActionName].UnitDistance
        # -- local friendlies = aiBrain:GetUnitsAroundPoint( defenseCat, location, unitDistance, 'Ally' )
        # -- if table.empty(friendlies) then
            # -- return
        # -- end

        # -- friendlies = SortEntitiesByDistanceXZ(unit.GOAP.SquadLocation, friendlies)

        # -- local closest = friendlies[1]

        # -- # Get a safe path to the point
        # -- local path = AIUtils.GetSafePathBetweenPoints(aiBrain, unit.Position, closest.Position)
        # -- if not path then
            # -- path = { closest.Position }
        # -- end

        # -- # Move along the path
        # -- local cmd = false
        # -- for k,v in path do
            # -- cmd = IssueMove( {unit}, v )
        # -- end

        # -- if not cmd then
            # -- WaitSeconds(1)
            # -- return
        # -- end

        # -- local durationTimer = 0
        # -- while not IsCommandDone(cmd) and durationTimer < 10 do
            # -- if debug then
                # -- AIUtils.DrawPath(path, unit:GetAIBrain().Name, unit.Position )
            # -- end
            # -- WaitSeconds(0.2)
            # -- durationTimer = durationTimer + 0.2
            # -- if unit:IsDead() then
                # -- return
            # -- end

            # -- # If all friendlies at location are dead; return out
            # -- friendlies = aiBrain:GetUnitsAroundPoint( defenseCat, location, unitDistance, 'Ally' )
            # -- if table.empty(friendlies) then
                # -- return
            # -- end

            # -- # Location moved a lot; leave
            # -- if not unit.GOAP.SquadLocation or VDist3XZSq(location, unit.GOAP.SquadLocation) > 100 then
                # -- return
            # -- end

            # -- # We are close to the position; leave
            # -- local distance = VDist3XZSq( unit.Position, location )
            # -- if distance < 225 then
                # -- return
            # -- end

            # -- local threat = aiBrain:GetThreatAtPosition( unit.Position, 0, 'Land', 'Enemy' )
            # -- threat = threat + aiBrain:GetThreatAtPosition( unit.Position, 0, 'Structures', 'Enemy' )
            # -- if threat > 5 then
                # -- return
            # -- end

            # -- # We are pretty close to the position and friends are nearby; leave
            # -- if distance < 225 and aiBrain:GetNumUnitsAroundPoint( defenseCat, unit.Position, 10, 'Ally' ) > 0then
                # -- return
            # -- end
        # -- end
    # -- end,
    # -- InstantStatusFunction = function(unit, action)
        # -- local aiBrain = unit:GetAIBrain()

        # -- # See if there is a location and make sure we aren't already pretty close to it
        # -- local location = unit.GOAP.SquadLocation
        # -- if not location or VDist3XZSq(unit.Position, location) < 400 then
            # -- return
        # -- end

        # -- # Make sure there are defenses near the point
        # -- local unitDistance = HeroAIActionTemplates[action.ActionName].UnitDistance
        # -- local defenseCat = categories.DEFENSE
        # -- local friendlies = aiBrain:GetUnitsAroundPoint( defenseCat, location, unitDistance, 'Ally' )
        # -- if table.empty(friendlies) then
            # -- return false
        # -- end
        # -- friendlies = SortEntitiesByDistanceXZ(unit.GOAP.SquadLocation, friendlies)

        # -- # If we are closer to the squad location than this tower, return out
        # -- if VDist3XZSq(unit.Position, unit.GOAP.SquadLocation) < VDist3XZSq(friendlies[1].Position, unit.GOAP.SquadLocation) then
            # -- return false
        # -- end

        # -- return true
    # -- end,
    # -- CalculateWeights = function( action, aiBrain, agent, initialAgent )
        # -- if not agent.WorldStateData.CanMove then
            # -- return false
        # -- end
        # -- local location = initialAgent.GOAP.SquadLocation
        # -- if not location then
            # -- return false
        # -- end

        # -- local distance = VDist3XZSq( agent.Position, location )
        # -- if distance < 100 then
            # -- return false
        # -- end

        # -- return { MoveToSquadLocation = -7, }, distance / agent.Speed
    # -- end,
# -- }


HeroAIActionTemplates['Teleport to Structure near Squad Location'] = {
    Name = 'Teleport to Structure near Squad Location',
    DisableActions = table.append( MoveDisables, DefaultDisables ),
    UninterruptibleAction = true,
    GoalSets = {
        SquadMove = true,
    },
    Abilities = AIGlobals.TeleportAbilities,
    ActionTimeout = 7.5,
    ActionFunction = function(unit, action)
        local structure = false
        local actionBp = HeroAIActionTemplates[action.ActionName]

        # If we have a target in the action, use it
        if unit.GOAP.RallyStructure and not unit.GOAP.RallyStructure:IsDead() then
            structure = unit.GOAP.RallyStructure
        end

        # Find the location of nearest structure
        if not structure then
            return false
        end


        # Don't teleport there if within 25 o-grids
        if VDist3XZSq( unit.Position, structure.Position ) < 1200 then
            return false
        end

        # If either found; teleport
        if not AIAbility.TargetedActionFunction( unit, action, structure, actionBp.ActionTimeout ) then
            return false
        end

        if unit:GetAIBrain().CurrentSquad then
            unit:GetAIBrain().CurrentSquad:UpdateSquadHero(unit)
        end

        action.StrategicAsset:ClearDistances()

        # We want reset some data on where the agent is; some distance sensors will give false insistence
        # when the demigod teleports.  Reset those sensors now that we have moved and reset the distances
        unit.GOAP:SensorTypeRefresh( 'Distance' )
    end,
    InstantStatusFunction = function( unit, action )
        if not unit.GOAP.RallyStructure or unit.GOAP.RallyStructure:IsDead() then
            return false
        end
		
		
        
        if not ScenarioInfo.CanTeleportToSquadLocation then
            if GetGameTimeSeconds() > 40 then
                ScenarioInfo.CanTeleportToSquadLocation = true
            else
                return false
            end
        end

        action.RallyStructure = unit.GOAP.RallyStructure
        if not IsAlly( action.RallyStructure:GetArmy(), unit:GetArmy() ) then
            WARN('*AI ERROR: Cannot warp to enemy structure - ' .. action.ActionName)
            return false
        end

        return AIAbility.DefaultStatusFunction(unit,action)
    end,
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
        if not agent.WorldStateData.CanUseAbilities then
            return false
        end
		# [MOD] TE Disable this teleport (others are better)
		if 1 == 1 then
			return false
		end

        local goapAction = initialAgent.GOAP.Actions[action.ActionName]
        if not goapAction.RallyStructure then
            LOG('*AI DEBUG: Error in Structure port thing')
        end

        # Make sure there is a reason to do this
        local distance = AIUtils.GetPathDistanceBetweenPoints( aiBrain, agent.Position, goapAction.RallyStructure.Position )
		
		#  [MOD]  Distance 50->80
        if distance < 80 then
            return false
        end

        # Set agent to location of tower
        agent:SetPosition( goapAction.RallyStructure.Position )

        return { MoveToSquadLocation = 0, }, Ability[action.Ability].CastingTime
    end,
}

HeroAIActionTemplates['Two Second Wait - near squad location'] = {
    Name = 'Two Second Wait - near squad location',
    GoalSets = {
        SquadMove = true,
    },
    ActionFunction = function(unit, action)
        local location = unit.GOAP.SquadLocation
        if not location then
            return false
        end

        local distance = VDist3XZSq( unit.Position, location )

        if distance > 100 then
            return
        end

        local durationTimer = 0

        WaitSeconds(2)
    end,
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
        local location = initialAgent.GOAP.SquadLocation
        if not location then
            return false
        end

        local distance = VDist3XZSq( agent.Position, location )

        if distance > 100 then
            return false
        end

        return { MoveToSquadLocation = -7, }, 2
    end,
}

