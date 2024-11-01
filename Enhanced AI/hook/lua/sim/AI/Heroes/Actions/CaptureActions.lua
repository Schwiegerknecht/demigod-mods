#  [MOD]  Higher weight.  
#  [MOD]  Ignore everything at flag except enemy towers when selecting a flag to capture.
#  [MOD]  Capture nuetral flags first
# [version .23] increased AI desire to capture flags, especially portals

# -- local AIUtils = import('/lua/sim/ai/aiutilities.lua')
# -- local MoveDisables = import('/lua/sim/ai/AIGlobals.lua').MoveDisables
# -- local DefaultDisables = import('/lua/sim/ai/AIGlobals.lua').DefaultDisables
local Utils = import('/lua/utilities.lua')
local AIAbility = import('/lua/sim/ai/AIAbilityUtilities.lua')
local GetReadyAbility = AIAbility.GetReadyAbility
local TeleportAbilities = import('/lua/sim/ai/AIGlobals.lua').TeleportAbilities
local GetEnemyTeamBrain = import('/lua/sim/ai/AIGlobals.lua').GetEnemyTeamBrain
HeroAIActionTemplates['Capture Anything'] = {
    Name = 'Capture Anything',
    GoalSets = {
        CapturePoint = true,
        DestroyStructures = true,
        Attack = true,
    },
    DisableActions = table.append( MoveDisables, DefaultDisables ),
    GlobalTimeout = 30,
    ActionFunction = function(unit, action)
        local aiBrain = unit:GetAIBrain()
        local actionBp = HeroAIActionTemplates[action.ActionName]
        local nearFlag = action.Flag
		
		
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
		local aflags = allyTeamBrain:GetListOfUnits(categories.FLAG, false)
		local nPortals = neutCivBrain:GetListOfUnits(categories.PORTAL, false)
		local ePortals = enemyTeamBrain:GetListOfUnits(categories.PORTAL, false)
		local aPortals = allyTeamBrain:GetListOfUnits(categories.PORTAL, false)		


		
		local unitPosition = unit:GetPosition()
		
		local countAP = table.getn(aPortals) 
		local countEP = table.getn(ePortals)
		local countNP =  table.getn(nPortals)
		
		if aiBrain.Score.WarRank >= 8 and countEP > 0 and  table.getn(eflags) <= table.getn(aflags) then
			countAP = countAP - 1
		end

		local balancePortals = true
		if aiBrain.Score.WarRank >= 7 or math.mod( countAP + countEP + countNP , 2) == 0 then
		  balancePortals = true
		else
		  balancePortals = false
		end
		
		if ( balancePortals and countAP < countEP )  then
			local captureFlags = Utils.TableCat(nflags, eflags)
			captureFlags = SortEntitiesByDistanceXZ(unitPosition, captureFlags)
		
			if not table.empty(captureFlags) and captureFlags[1].CanBeCaptured and VDist3XZSq(unitPosition, captureFlags[1].Position) < 800 then
				nearFlag = captureFlags[1]
			end
		
			if not nearFlag then 
				local capturePortal = Utils.TableCat(nPortals, ePortals)
				capturePortal = SortEntitiesByDistanceXZ(unitPosition, capturePortal)
				if  capturePortal[1].Position and VDist3XZSq(unitPosition, capturePortal[1].Position) > ( VDist3XZSq(unitPosition, aiBrain:GetStronghold():GetPosition()) / 4 ) then
					capturePortal = SortEntitiesByDistanceXZ(aiBrain:GetStronghold():GetPosition(), capturePortal)
				end
				local findFlag = Utils.TableCat(nflags, eflags)
				findFlag = SortEntitiesByDistanceXZ(capturePortal[1].Position,  findFlag)				
				nearFlag =  findFlag[1]
			end
		elseif table.getn(eflags) > 0 or table.getn(nflags) > 0 then
			local captureFlags = Utils.TableCat(nflags, eflags)
			captureFlags = SortEntitiesByDistanceXZ(unitPosition, captureFlags)
			if not table.empty(captureFlags) and captureFlags[1].CanBeCaptured  and captureFlags[1].Position and VDist3XZSq(unitPosition, captureFlags[1].Position) < 800 then
				nearFlag = captureFlags[1]
			elseif not table.empty(captureFlags) then 
				local intFlagSearch = table.getn(captureFlags) #math.min(4, table.getn(captureFlags))
				local maxTowerThreat = false
				for i = 1,intFlagSearch do 
					local towerCount = aiBrain:GetBlipsAroundPoint( categories.DEFENSE  - categories.ROOKTOWER, captureFlags[i].Position, 25, 'Enemy' ) 
					local towerThreat = table.getn(towerCount)
					#WARN('Flag Tower threat: '..i..' = '..towerThreat)
					if not maxTowerThreat then
						maxTowerThreat = towerThreat
					elseif towerThreat < maxTowerThreat then
						maxTowerThreat = towerThreat
					end
				end
				
				#WARN('maxTowerThreat = '..maxTowerThreat)
				local finalFlags = {}
				for i = 1,intFlagSearch do 
					local towerCount = aiBrain:GetBlipsAroundPoint( categories.DEFENSE  - categories.ROOKTOWER, captureFlags[i].Position, 25, 'Enemy' ) 
					local towerThreat = table.getn(towerCount)
					if maxTowerThreat == towerThreat and captureFlags[i].CanBeCaptured then
						table.insert(finalFlags, captureFlags[i])
					end
				end
				#WARN('Select randomly from: '..table.getn(finalFlags) )
				
				finalFlags = SortEntitiesByDistanceXZ(unitPosition, finalFlags)
				
				if aiBrain.Score.WarRank > 1 then  #and maxTowerThreat == 0 
					nearFlag = finalFlags[1]
					# -- if table.getn(finalFlags) > 1 then
						# -- nearFlag = finalFlags[math.random(1,2)]	
					# -- else
						# -- nearFlag = finalFlags[1]
					# -- end
				else
					nearFlag = finalFlags[math.random( 1, table.getn(finalFlags) )]	
				end
					
			end
		end
		
		if not nearFlag then
			unit.GOAP:UpdateGoal( 'KillStructures', 100 )
            WaitSeconds(1)
            return false
        end
		



        if not nearFlag then
            WaitSeconds(1)
            return
        end
		
        local position = unit:FindEmptySpotNear(nearFlag.Position)
		# [MOD] TE Move along path (fix move to capture issue on some maps)
		local path = AIUtils.GetSafePathBetweenPoints(aiBrain, unit.Position, position, 10)

        if not path then
            path = { position}
        end
		
		local scanArea = function(unit)
            local enemies = nil  
			if  aiBrain.Score.WarRank >= 8 then
				enemies = aiBrain:GetBlipsAroundPoint( categories.HERO, unit.Position, 20, 'Enemy' )
			else
				enemies = aiBrain:GetBlipsAroundPoint( categories.HERO + categories.DEFENSE - categories.ROOKTOWER, unit.Position, 20, 'Enemy' )
			end 

			if aiBrain.Score.WarRank >= 8 or GetEnemyTeamBrain(unit).Score.WarRank >= 8 then		
				local abilities = TeleportAbilities
				local ready = GetReadyAbility( unit, abilities )
				local threatFlag = nil
				if ready then
					for k,v in aflags do 
						local captureUnits = v:GetCaptureList()
						for k,ptv in captureUnits do
							if (ptv == 'ugbportal01') or (ptv == 'unbidol01')  then
								local heroThreat = aiBrain:GetThreatAtPosition( v.Position,   1.2, 'Hero', 'Enemy' )
								if heroThreat > 0 then
									threatFlag = v
								end	
							end
						end
						if threatFlag then
							#WARN('Flag Threatened abort capture')
							return false
						end	
					end		
				end	
			end
			if table.empty(enemies) then
                return true
            end
			#WARN('Enemies detected = '.. table.getn(enemies) )


			return false
        end		

        # Move along the path
        local cmd = false
        for k,v in path do
            cmd = IssueAggressiveMove( {unit}, v )
        end

		local bp = nearFlag:GetBlueprint()
		local distance = bp.DetectionRadius or 10
		local distanceSq = (distance * distance) - 10
		#WARN('Wait to get to Flag')		
		while not (VDist3XZSq(unit.Position, nearFlag.Position) < distanceSq)  do
            if unit:IsDead() then
                return
            end
            if not nearFlag or (nearFlag and nearFlag:IsDead()) then
                return
            end		
		
			if not scanArea(unit) then
                return
            end		
			if aiBrain.Score.WarRank <= 7 and unit:GetHealthPercent() < .6 then
				return false
			end		
		
			WaitSeconds(1)
		end
		#WARN('At Flag')
		
		while not IsDestroyed( nearFlag ) do
			
			if aiBrain.Score.HeroId == 'hrook' then
				local CreateTowerAbilities = {
					'HRookTower01',
					'HRookTower02',
					'HRookTower03',
					'HRookTower04',
				}			
				local ready =  GetReadyAbility( unit, CreateTowerAbilities )
				if ready then
					local location = aiBrain:FindNearestSpotToBuildOn(unit, 'UGBDefense02', nearFlag.Position)
					#WARN('Create Tower in capture action')
					AIAbility.UseTargetedAbility( unit, ready, location, 3 )
				end
			end 
		

			WaitSeconds(.5)
            if unit:IsDead() then
                return
            end
	
		
			if not scanArea(unit) then
                return
            end		
			if aiBrain.Score.WarRank <= 7 and unit:GetHealthPercent() < .6 then
				return false
			end		
		end
		
		WaitSeconds( math.random(3, 6) )

		local flags = aiBrain:GetUnitsAroundPoint( categories.FLAG, unit:GetPosition(), 16, 'Ally' )	
		nearFlag = flags[1]
		if(nearFlag and not nearFlag:IsDead()) then
			local ready = GetReadyAbility(unit, {'Item_Consumable_030'})	
			#WARN("In Capture Action")
			if nearFlag.CanBeCaptured and ready then 
				#WARN("Flag can be captured")
				local result = false
				local captureUnits = nearFlag:GetCaptureList()
				for k,v in captureUnits do
					if (v == 'ugbportal01')  then
						# -- local announcement = "Capture and Lock Portal flag."
						# -- WARN("Capture and Lock Portal flag.")
						# -- AIUtils.AIChat(unit, announcement)		
						result = true				
					elseif (v == 'unbidol01') then
						# -- local announcement = "Capture and Lock Valor flag."
						# -- WARN("Capture and Lock Valor flag.")
						# -- AIUtils.AIChat(unit, announcement)
						result = true		
					else
						#Do nothing
					end
				end	


				if(result) then
					#WARN("Locking in capture action")
					AIAbility.UseTargetedAbility(unit, ready, nearFlag, 5)
				end
			end
		end
		

		
    end,


	InstantStatusFunction = function(unit,action)
        local aiBrain = unit:GetAIBrain()
        local nearFlag = nil
        action.Distance = false
		action.Flag = false

		local enemies = nil  
		if  aiBrain.Score.WarRank >= 8 then
			enemies = aiBrain:GetBlipsAroundPoint( categories.HERO, unit.Position, 20, 'Enemy' )
		else
			enemies = aiBrain:GetBlipsAroundPoint( categories.HERO + categories.DEFENSE - categories.ROOKTOWER, unit.Position, 20, 'Enemy' )
		end 
		if table.getn(enemies) > 0 then
			return false
		end	

		
		if aiBrain.Score.WarRank <= 7 and unit:GetHealthPercent() < .6 then
			return false
		end

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

		if table.getn(eflags) > 0 or table.getn(nflags) > 0 then
			return true
		else
			return false
		end

    end,   
   
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
        if not agent.WorldStateData.CanMove then
            return false
        end
		
		local enemies = nil  
		if  aiBrain.Score.WarRank >= 8 then
			enemies = aiBrain:GetBlipsAroundPoint( categories.HERO, initialAgent.Position, 20, 'Enemy' )
		else
			enemies = aiBrain:GetBlipsAroundPoint( categories.HERO + categories.DEFENSE - categories.ROOKTOWER, initialAgent.Position, 20, 'Enemy' )
		end 
		if table.getn(enemies) > 0 then
			return false
		end	
		
		if aiBrain.Score.WarRank <= 7 and  initialAgent:GetHealthPercent() < .6 then
			return false
		end
		
		# -- local distance = initialAgent.GOAP.Actions[action.ActionName].Distance
        # -- if agent.AgentHasMoved then
            # -- distance = VDist3XZ( agent.Position, initialAgent.GOAP.Flag.Position )
        # -- end
		
		
        local weight = -30
		# -- local time = (distance / agent.Speed) + 10

        return { CaptureFlag = weight}, 30 #[version .23]
    end,
}


HeroAIActionTemplates['Capture Closest Flag'] = {
    Name = 'Capture Closest Flag',
    GoalSets = {
        CapturePoint = true,
        DestroyStructures = true,
        Attack = true,
    },
    DisableActions = table.append( MoveDisables, DefaultDisables ),
    GlobalTimeout = 10,
    ActionFunction = function(unit, action)

        local aiBrain = unit:GetAIBrain()
        local actionBp = HeroAIActionTemplates[action.ActionName]

        local nearFlag = nil
		
		if 1 == 1 then
			return false
		end

        if not nearFlag then
            WaitSeconds(1)
            return
        end

        local position = unit:FindEmptySpotNear(nearFlag.Position)
        local cmd = IssueAggressiveMove( {unit}, position )

        local scanArea = function(unit)
            local enemies = aiBrain:GetBlipsAroundPoint( categories.MOBILE * categories.LAND + categories.DEFENSE - categories.ROOKTOWER, unit.Position, 16, 'Enemy' )
            if table.empty(enemies) then
                return true
            end

            return false
        end

        local counter = 0
        while not IsCommandDone(cmd) do
            WaitSeconds(1)
            counter = counter + 1
            if unit:IsDead() then
                return
            end
            if not scanArea(unit) then
                return
            end

            if(nearFlag and not nearFlag:IsDead()) then
                local bp = nearFlag:GetBlueprint()
                local distance = bp.DetectionRadius or 10
                local distanceSq = distance * distance
                if(VDist3XZSq(unit.Position, nearFlag.Position) < distanceSq) then
                    break
                end
            else
                return
            end
        end

        while counter < actionBp.GlobalTimeout do
            WaitSeconds(1)
            counter = counter + 1
            if unit:IsDead() then
                return
            end
            if not scanArea(unit) then
                return
            end
            if not nearFlag or (nearFlag and nearFlag:IsDead()) then
                return
            end
        end
    end,
    InstantStatusFunction = function(unit,action)

        local aiBrain = unit:GetAIBrain()
        local nearFlag = nil
        action.FlagPosition = false

        if not nearFlag then
            return false
        end

        action.FlagPosition = nearFlag.Position
        return true
    end,
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
		if 1 == 1 then
			return false
		end
	
        if not agent.WorldStateData.CanMove then
            return false
        end

        local goapAction = initialAgent.GOAP.Actions[action.ActionName]
        if not goapAction.FlagPosition then
            return false
        end

        agent:SetPosition( goapAction.FlagPosition )

        # -- local weight = -10
        # -- local towerThreat = aiBrain:GetThreatAtPosition( goapAction.FlagPosition, 0, 'Structures', 'Enemy' )
        # -- local heroThreat = aiBrain:GetThreatAtPosition( goapAction.FlagPosition, 0, 'Hero', 'Enemy' )
        # -- local mobileThreat = aiBrain:GetThreatAtPosition( goapAction.FlagPosition, 0, 'LandNoHero', 'Enemy' )
        # -- if(towerThreat > 0 or heroThreat > 0 or mobileThreat > 10) then
            # -- weight = 0
        # -- end

        return { CaptureFlag = 0 }, 10
    end,
}


