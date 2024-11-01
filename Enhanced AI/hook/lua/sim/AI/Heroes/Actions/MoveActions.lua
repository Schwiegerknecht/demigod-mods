local AIGlobals = import('/lua/sim/ai/AIGlobals.lua')
local GetReadyAbility = AIAbility.GetReadyAbility

HeroAIActionTemplates['Move To Health Statue'] = {
    Name = 'Move To Health Statue',
    DisableActions = table.append( SprintDisables, MoveDisables ),
    GoalSets = {
        Flee = true,
        MakeItemPurchases = false,
    },
    ActionFunction = function(unit, action)
        local debug = false

        local aiBrain = unit:GetAIBrain()
		
        # Get all defenses; find closest
        local statue = aiBrain:GetHealthStatue()

        if not statue or statue:IsDead() then
            WaitSeconds(1)
            LOG('*AI DEBUG: Could not find HEALTHSTATUE near hero unit')
            return
        end

        local path = AIUtils.GetSafePathBetweenPoints(aiBrain, unit.Position, statue.Position, 50)

        if not path then
            path = { statue.Position }
        end

        # Move along the path
        local cmd = false
        for k,v in path do
            cmd = IssueMove( {unit}, v )
        end
        # cmd = IssueMove( {unit}, statue.Position )

        local durationTimer = 0
        while not IsCommandDone(cmd) and durationTimer < 60 do
            if debug then
                AIUtils.AIUtils.DrawPath(path, unit:GetAIBrain().Name, unit.Position )
            end
            WaitSeconds(1)
            durationTimer = durationTimer + 1
            if unit:IsDead() then
                return
            end
			

			local PotionSearchRange = 30
			local potion, healVal = AIUtils.GetHighestValuePotion( unit:GetPosition(), PotionSearchRange, 'Health' )
			if potion then
				#WARN('Abort Retreat Found Health Potion - Move Loop')
				return false
			end
			
			if unit:GetHealthPercent() > 0.8 then
				return false
			end
			
            local distance = VDist3XZSq( unit.Position, statue.Position )
            if distance < 64 then
                return true
            end
        end
    end,
    InstantStatusFunction = function(unit, action)
        local aiBrain = unit:GetAIBrain()
		
        # -- local towerThreat = aiBrain:GetThreatAtPosition( unit.Position, 1, 'Structures', 'Enemy' )
		# -- local heroThreat = aiBrain:GetThreatAtPosition(unit.Position, 1, 'Hero', 'Enemy')
		# -- WARN(aiBrain.Nickname..' Towers: ' ..towerThreat..' Heroes: '..heroThreat)
		if unit:GetHealthPercent() > 0.8 then
            return false
		end
		local PotionSearchRange = 30
		local potion, healVal = AIUtils.GetHighestValuePotion( unit:GetPosition(), PotionSearchRange, 'Health' )
		if potion then
			#WARN('Abort Retreat Found Health Potion')
			return false
		end

        local asset = action.StrategicAsset
        local distance = asset:GetDistance( 'HEALTHSTATUE', 'Ally' )
        if not distance then
            return false
        end

        local statue = aiBrain:GetHealthStatue()
        if not statue or statue:IsDead() then
            return false
        end

        if not unit.GOAP.StatuePosition then
            unit.GOAP.StatuePosition = table.copy(statue.Position)
        end
        action.Distance = distance

        return true
    end,
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
		#[MOD] TE
		# -- if GetGameTimeSeconds() < 20 then
			# -- return false
		# -- end
        if not agent.WorldStateData.CanMove then
            return false
        end

        if not initialAgent.GOAP.StatuePosition then
            return false
        end

        local distance = initialAgent.GOAP.Actions[action.ActionName].Distance
        if agent.AgentHasMoved then
            distance = VDist3XZ( agent.Position, initialAgent.GOAP.StatuePosition )
        end

        if distance < 15 then
            return false
        end
		
		if distance > 80 then
			local abilities = AIGlobals.TeleportAbilities
			local ready = GetReadyAbility( initialAgent, abilities )
			if ready then
				#WARN('Disabled moved to health stone')
				return false
			end			
		end
		
		local multiplyer = 0
		local myHealth = initialAgent:GetHealthPercent()
		if myHealth > .8 then
		multiplyer = 0
		elseif myHealth > .65 then
		multiplyer = 0
		elseif myHealth > .5 then
		multiplyer = 0
		elseif myHealth > .4 then
		multiplyer = 1
		elseif myHealth <= .4 then
		multiplyer = 18
		end
		
        local time = distance / agent.Speed

        agent:SetPosition( initialAgent.GOAP.StatuePosition )

        return { Health = -4 * multiplyer, Survival = -4 * multiplyer, }, time
    end,
}
