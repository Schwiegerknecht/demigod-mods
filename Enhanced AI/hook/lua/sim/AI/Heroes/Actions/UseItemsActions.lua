#  [MOD] Sigil trigger health modified
#  [MOD] Teleport set to use even if enemy is near
#  [MOD] Capture Lock range reduced 50% to save usage for flags with enemies close

-- local AIAbility = import('/lua/sim/ai/AIAbilityUtilities.lua')
-- local AIUtils = import('/lua/sim/ai/aiutilities.lua')
-- local GetReadyAbility = AIAbility.GetReadyAbility
-- local AIGlobals = import('/lua/sim/ai/AIGlobals.lua')

-- local DefaultDisables = AIGlobals.DefaultDisables
local Utils = import('/lua/utilities.lua')
local MoveDisables = AIGlobals.MoveDisables


-- # ------------------------------------------------------------------------------
-- # HEALTH POTION
-- # ------------------------------------------------------------------------------
-- local HealthPotionAbilities = {
    -- 'AchievementAEHeal',
    -- 'Item_Large_Health_Potion',
    -- 'AchievementPotion',
    -- 'Item_Health_Potion',
    -- 'Item_Health_Potion_Art',
    -- 'Item_Large_Health_Potion_Art',
-- }

-- # ----------------------------
-- # Use Health Potion
-- # ----------------------------
HeroAIActionTemplates['Use Health Potion'] = {
    Name = 'Use Health Potion',
    Abilities = HealthPotionAbilities,
    DisableActions = table.append(DefaultDisables, AIGlobals.HealthDisables),
    GoalSets = {
        All = true,
    },
    UninterruptibleAction = true,
# 0.27.09 Added action timeout of 3 to hopefully keep the AI from sigiling immediately after if their HP was low when they started casting the pot
	ActionTimeout = 3,
    ActionFunction = function(unit,action)
        local aiBrain = unit:GetAIBrain()

        local statue = aiBrain:GetHealthStatue()
        if statue and VDist3XZSq( unit.Position, statue.Position ) < 400 then
            return false
        end

        return AIAbility.InstantActionFunction(unit,action)
    end,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        if not agent.WorldStateData.CanUseAbilities then
            return false
        end

        if Buffs[action.Ability].Affects.Health.Add then
            local maxHealth = initialAgent:GetMaxHealth()
            local healValue = Buffs[action.Ability].Affects.Health.Add

            local healPct = healValue / maxHealth
            return { Health = -15 * healPct, Survival = -15 * healPct, }, Ability[action.Ability].CastingTime
        end

        return {Health = -5, Survival = -5}, Ability[action.Ability].CastingTime
    end,
    InstantStatusFunction = function(unit, action)
        action.Ability = false
        local actionBp = HeroAIActionTemplates[action.ActionName]

        local aiBrain = unit:GetAIBrain()

		
		#  [MOD] Distance to check for enemies  [MOD] TE No distance check on heal
        # -- if unit.GOAP.NearbyEnemyHeroes and unit.GOAP.NearbyEnemyHeroes.ClosestDistance < 15 then
            # -- return false
        # -- end
		
        # If there's a statue nearby, return false since we can heal at the statue
        local statue = aiBrain:GetHealthStatue()
        if statue and VDist3XZSq( unit.Position, statue.Position ) < 400 then
            return false
        end

        local ready = GetReadyAbility( unit, actionBp.Abilities )

        if not ready then
            return false
        end

        if Buffs[ready].Affects.Health.Add then
            if unit:GetHealthPercent() > 0.6 then   # [MOD] TE  and unit:GetMaxHealth() - unit:GetHealth() <= ( Buffs[ready].Affects.Health.Add * 0.4 ) 
                return false
            end
        elseif Ability[ready].RegenAmount then
            if unit:GetHealthPercent() > 0.6 then
                return false
            end
        else
            return false
        end

        action.Ability = ready
        return true
    end,
}

-- # ------------------------------------------------------------------------------
-- # ENERGY POTION
-- # ------------------------------------------------------------------------------
-- local EnergyPotionAbilities = {
    -- 'Item_Large_Mana_Potion',
    -- 'Item_Mana_Potion',
    -- 'Item_Mana_Potion_Art',
    -- 'Item_Large_Mana_Potion_Art',
-- }

-- # ----------------------------
-- # Use Energy Potion
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Use Energy Potion',
    -- Abilities = EnergyPotionAbilities,
    -- DisableActions = table.append(DefaultDisables, AIGlobals.EnergyDisables),
    -- GoalSets = {
        -- All = true,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = function(unit,action)
        -- local aiBrain = unit:GetAIBrain()

        -- local statue = aiBrain:GetHealthStatue()
        -- if statue and VDist3XZSq( unit.Position, statue.Position ) < 400 then
            -- return false
        -- end

        -- return AIAbility.InstantActionFunction(unit,action)
    -- end,
    -- CalculateWeights = function( action, aiBrain, agent, initialAgent )
        -- if not agent.WorldStateData.CanUseAbilities then
            -- return false
        -- end

        -- agent.Energy = agent.Energy + Buffs[action.Ability].Affects.Energy.Add
        -- if agent.Energy > agent.EnergyMax then
            -- agent.Energy = agent.EnergyMax
        -- end

        -- return {Energy = -5}, Ability[action.Ability].CastingTime
    -- end,
    -- InstantStatusFunction = function( unit, action )
        -- action.Ability = false
        -- local actionBp = HeroAIActionTemplates[action.ActionName]

        -- local aiBrain = unit:GetAIBrain()

        -- # If there's a statue nearby, return false since we can heal at the statue
        -- local statue = aiBrain:GetHealthStatue()
        -- if statue and VDist3XZSq( unit.Position, statue.Position ) < 400 then
            -- return false
        -- end

        -- local ready = GetReadyAbility( unit, actionBp.Abilities )

        -- if not ready then
            -- return false
        -- end

        -- if unit:GetMaxEnergy() - unit:GetEnergy()<= ( Buffs[ready].Affects.Energy.Add * 0.4 ) then
            -- return false
        -- end

        -- action.Ability = ready
        -- return true
    -- end,
-- }

-- # ------------------------------------------------------------------------------
-- # REJUVENATION POTION
-- # ------------------------------------------------------------------------------
-- local RejuvenationPotionAbilities = {
    -- 'Item_Large_Rejuv_Elixir',
    -- 'Item_Rejuv_Elixir',
    -- 'Item_Rejuv_Elixir_Art',
    -- 'Item_Large_Rejuv_Elixir_Art',
-- }
-- local RejuvenationPotionDisables = table.append( DefaultDisables,
    -- {
        -- 'Use Rejuvenation Potion',
        -- 'Use Health Potion',
        -- 'Use Energy Potion',
        -- 'Use Heart of Life',
    -- }
-- )
-- # ----------------------------
-- # Use Rejuvenation Potion
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Use Rejuvenation Potion',
    -- Abilities = RejuvenationPotionAbilities,
    -- DisableActions = RejuvenationPotionDisables,
    -- GoalSets = {
        -- All = true,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = function(unit,action)
        -- local aiBrain = unit:GetAIBrain()

        -- local statue = aiBrain:GetHealthStatue()
        -- if statue and VDist3XZSq( unit.Position, statue.Position ) < 400 then
            -- return false
        -- end

        -- return AIAbility.InstantActionFunction(unit,action)
    -- end,
    -- CalculateWeights = function( action, aiBrain, agent, initialAgent )
        -- if not agent.WorldStateData.CanUseAbilities then
            -- return false
        -- end

        -- agent.Energy = agent.Energy + Buffs[action.Ability].Affects.Energy.Add
        -- if agent.Energy > agent.EnergyMax then
            -- agent.Energy = agent.EnergyMax
        -- end

        -- return {Health = -5, Survival = -5, Energy = -5}, Ability[action.Ability].CastingTime
    -- end,
    -- InstantStatusFunction = function( unit, action )
        -- action.Ability = false
        -- local actionBp = HeroAIActionTemplates[action.ActionName]

        -- local aiBrain = unit:GetAIBrain()

        -- # If there's a statue nearby, return false since we can heal at the statue
        -- local statue = aiBrain:GetHealthStatue() 
        -- if statue and VDist3XZSq( unit.Position, statue.Position ) < 400 then
            -- return false
        -- end

        -- local ready = GetReadyAbility( unit, actionBp.Abilities )

        -- if not ready then
            -- return false
        -- end

        -- local buffAffects = Buffs[ready].Affects

        -- if (buffAffects.Energy and unit:GetMaxEnergy() - unit:GetEnergy() <= ( Buffs[ready].Affects.Energy.Add * 0.4 )) or
                -- (buffAffects.Health and unit:GetMaxHealth() - unit:GetHealth() <= ( Buffs[ready].Affects.Health.Add * 0.4 )) then
            -- return false
        -- end

        -- action.Ability = ready
        -- return true
    -- end,
-- }

# ------------------------------------------------------------------------------
# SIGIL OF VITALITY (max health buff and temporary heal)
# ------------------------------------------------------------------------------

# ----------------------------
# Use Sigil of Vitality
# ----------------------------


HeroAIActionTemplates['Use Sigil of Vitality'] = {
    Name = 'Use Sigil of Vitality',
    Abilities = {'Item_Consumable_110'},
    DisableActions = table.append(DefaultDisables, {'Item_Consumable_110'}),
    GoalSets = {
        All = true,
    },
    UninterruptibleAction = true,
    ActionFunction = AIAbility.InstantActionFunction,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        if not agent.WorldStateData.CanUseAbilities then
            return false
        end
		if initialAgent:GetHealthPercent() > .5 then
            return false
        end

        return {Health = -200, Survival = -200}, 1
    end,
    InstantStatusFunction = function(unit, action)
        action.Ability = false
        local actionBp = HeroAIActionTemplates[action.ActionName]

        local aiBrain = unit:GetAIBrain()

        # If there's a statue nearby, return false since we can heal at the statue
        local statue = aiBrain:GetHealthStatue()
        if statue and VDist3XZSq( unit.Position, statue.Position ) < 400 then
            return false
        end

        local ready = GetReadyAbility( unit, actionBp.Abilities )

        if not ready then
            return false
        end

# 0.27.07 increased sigil health % from .45 to .5
        if unit:GetHealthPercent() > .5 then
            return false
        end
		
       
		
		if not unit.GOAP.NearbyEnemyHeroes and unit.GOAP.NearbyEnemyHeroes.ClosestDistance > 30  then
			if unit:GetHealth() > 1500 then
				return false
			end
        end
       		

		# -- unit.GOAP:UpdateGoal( 'Health', 500 )
		# -- unit.GOAP:UpdateGoal( 'Survival', 500 ) 
        action.Ability = ready
        return true
    end,
}

# ------------------------------------------------------------------------------
# SCROLL OF TELEPORTING & AMULET OF TELEPORTATION
# ------------------------------------------------------------------------------
# ----------------------------
# Teleport to Shop
# ----------------------------

HeroAIActionTemplate {
    Name = 'Teleport to Shop',
    DisableActions = table.append( MoveDisables, DefaultDisables ),
    UninterruptibleAction = true,
    GoalSets = {
		#Flee = true,
		MakeItemPurchases = true,
    },
    Abilities = AIGlobals.TeleportAbilities,
    ActionTimeout = 10,
    ActionFunction = function(unit, action)
        local aiBrain = unit:GetAIBrain()
        local actionBp = HeroAIActionTemplates[action.ActionName]

		local shop = aiBrain.GoalPlanner:GetFriendlyShop('ugbshop01', unit.Position)
		
		
		#WARN("PEPPETEST Teleport to Shop: " .. tostring(shop) )
        if not shop or shop:IsDead() then
            return false
        end

        local abilities = AIGlobals.TeleportAbilities

        local ready = GetReadyAbility( unit, abilities )

        if not AIAbility.UseTargetedAbility( unit, ready, shop, actionBp.ActionTimeout ) then
            return false
        end

        action.StrategicAsset:ClearDistances()
    end,
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
        if not agent.WorldStateData.CanUseAbilities then
            return false
        end

		local shop = aiBrain.GoalPlanner:GetFriendlyShop('ugbshop01', agent.Position)
		local shopPos = shop:GetPosition()
		
		
        local distance
		if not agent.AgentHasMoved then
			distance = initialAgent.GOAP.BrainAsset:GetDistance('ugbshop01', 'Ally' )
		else
			distance = VDist3XZ( agent.Position, shopPos )
		end
		
        if distance <  160 then
            return false
        end

		agent:SetPosition( shopPos )

        local time = Ability[action.Ability].CastingTime

        return { PurchaseItems = -25}, time
    end,
    InstantStatusFunction = function( unit, action )
        local aiBrain = unit:GetAIBrain()
		local shop = aiBrain.GoalPlanner:GetFriendlyShop('ugbshop01', unit.Position)

        #LOG("PEPPETEST Instant Teleport to Shop: ", shop)
        if not shop or shop:IsDead() then
            return false
        end

        local distance = action.StrategicAsset:GetDistance( 'ugbshop01', 'Ally' )
        if distance < 160 then
            return false
        end
        
		# -- local announcement = "Shop: TP/Run"
        # -- AIUtils.AIChat(unit, announcement)
        
		#LOG("PEPPETEST Teleport Success: Shop = ", shop, ", Distance = " , distance)
        return AIAbility.DefaultStatusFunction(unit, action)
    end,
}

# ----------------------------
# Teleport to Health Statue
# ----------------------------
HeroAIActionTemplates['Teleport to Health Statue'] = {
    Name = 'Teleport to Health Statue',
    Abilities = AIGlobals.TeleportAbilities,
    FinalAction = true,
    GoalSets = {
        Flee = true,
        MakeItemPurchases = true,
    },

    UninterruptibleAction = true,
    ActionTimeout = 10,
    ActionFunction = function(unit, action)
        local aiBrain = unit:GetAIBrain()
        local actionBp = HeroAIActionTemplates[action.ActionName]

        local statue = aiBrain:GetHealthStatue()
        if not statue or statue:IsDead() then
            return false
        end

        local abilities = AIGlobals.TeleportAbilities

        local ready = GetReadyAbility( unit, abilities )

        if not AIAbility.UseTargetedAbility( unit, ready, statue, actionBp.ActionTimeout ) then
            return false
        end

        action.StrategicAsset:ClearDistances()
    end,
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
        if not agent.WorldStateData.CanUseAbilities then
            return false
        end
		
		if initialAgent:GetHealthPercent() > 0.4 then   # [MOD] TE  and unit:GetMaxHealth() - unit:GetHealth() <= ( Buffs[ready].Affects.Health.Add * 0.4 ) 
			return false
		end
        
		if not initialAgent.GOAP.StatuePosition then
            return false
        end

        local distance
        if not agent.AgentHasMoved then
            distance = initialAgent.GOAP.BrainAsset:GetDistance( 'HEALTHSTATUE', 'Ally' )
        else
            # TODO: nearby.Position shoudl be the position of the closest health statue
            # TODO: need to update all health statue distance checks to get the closest statue since statues will be capturable
            #distance = VDist3XZ( agent.Position, nearby.Position )
            return false
        end


		# -- if distance / agent.Speed < 20 then
			# -- return false
		# -- end
		
        if distance < 80 then
            return false
        end

        agent:SetPosition( initialAgent.GOAP.StatuePosition )

        local time = Ability[action.Ability].CastingTime

        return { Health = -100, Survival = -100, }, time
    end,
    InstantStatusFunction = function( unit, action )
        local aiBrain = unit:GetAIBrain()
        local statue = aiBrain:GetHealthStatue()
        
		
		
		#  [MOD] Distance to check for enemies 
        # -- if unit.GOAP.NearbyEnemyHeroes and unit.GOAP.NearbyEnemyHeroes.ClosestDistance < 20 then
            # -- return false
        # -- end
        
        if not statue or statue:IsDead() then
            return false
        end

        if not unit.GOAP.StatuePosition then
            unit.GOAP.StatuePosition = table.copy(statue.Position)
        end

        local distance = action.StrategicAsset:GetDistance( 'HEALTHSTATUE', 'Ally' )
        if distance < 80 then
            return false
        end
        
        # -- if AIUtils.EnemyTowerRange(unit, aiBrain) > 0 then
            # -- return false
        # -- end            

		
		# -- local announcement = "TP/Run to Heal"
        # -- AIUtils.AIChat(unit, announcement)
		
        return AIAbility.DefaultStatusFunction(unit, action)
    end,
}

--[[ ]]--
# ----------------------------
# Teleport to Portal
# ----------------------------
HeroAIActionTemplates['Teleport to Portal'] = {
    Name = 'Teleport to Portal',
    Abilities = AIGlobals.TeleportAbilities,
    FinalAction = true,
    GoalSets = {
		#All = true,
         Assassinate = true,
         Attack = true,
         Defend = true,
		 MoveToFriendly = true,
		 CapturePoint = true,
    },
	
    GoalWeights = {
        CaptureFlag = -150,
        KillHero = -150,
		SupportAlly = -150,
		PurchaseItems = -150,
		KillUnits = -150,
    },
    UninterruptibleAction = true,
    ActionTimeout = 10,
    ActionFunction = function(unit, action)
        local aiBrain = unit:GetAIBrain()
        local actionBp = HeroAIActionTemplates[action.ActionName]

        local nearFlag = nil	
		local myStronghold = unit:GetPosition()
		if aiBrain:GetStronghold() then
			myStronghold = aiBrain:GetStronghold():GetPosition() #aiBrain:GetStronghold():GetPosition()	 #unit:GetPosition()
		end

        local lightArmy = GetArmyBrain('TEAM_1')
        local darkArmy = GetArmyBrain('TEAM_2')
        local neutralArmy = GetArmyBrain('NEUTRAL_CIVILIAN')
		
		local lightFlags =  lightArmy:GetListOfUnits( categories.FLAG, false) 
		local darkFlags =	darkArmy:GetListOfUnits( categories.FLAG, false) 
		local nuetralFlags = neutralArmy:GetListOfUnits( categories.FLAG, false) 
		
		local captureFlags = Utils.TableCat(nuetralFlags, lightFlags, darkFlags )
		

		       
		if not table.empty(captureFlags) then
			captureFlags = SortEntitiesByDistanceXZ(myStronghold, captureFlags)
			for k,v in captureFlags do       			
				if IsAlly( v:GetArmy(), unit:GetArmy() ) then
				
					local captureUnits = v:GetCaptureList()
					for k,ptv in captureUnits do
						if (ptv == 'ugbportal01') or (ptv == 'unbidol01')  then
							local heroThreat = aiBrain:GetThreatAtPosition( v.Position, 1.2, 'Hero', 'Enemy' )
							if heroThreat > 0 then
								nearFlag = v
							end	
						end
					end
					
					if nearFlag then
						break
					end
				end
			end		
		end
		
		if not nearFlag then
			WaitTicks(1)
            return false 
        end
		
		local flagbp = nearFlag:GetBlueprint()	
		
	#[version .23] enabled the statement immediately below so that AI demigods would not teleport very short distances

		 local distance = AIUtils.GetPathDistanceBetweenPoints( aiBrain, unit.Position, nearFlag.Position )
         if distance < 30 then
			local cmd = IssueAggressiveMove( {unit}, nearFlag.Position, true )
			
			while not IsCommandDone(cmd) do
				WaitSeconds(.5)
			end
			return false
         end
		
        local abilities = AIGlobals.TeleportAbilities

        local ready = GetReadyAbility( unit, abilities )

		local announcement = "Portal/Valor Flag Threatened."
		AIUtils.AIChat(unit, announcement)
        if not AIAbility.UseTargetedAbility( unit, ready, nearFlag, actionBp.ActionTimeout ) then
            return false
        end
		unit.GOAP:UpdateGoal( 'PurchaseItems', -500 )
		unit.GOAP:UpdateGoal( 'Survival', -500 ) 
		unit.GOAP:UpdateGoal( 'Health', -500 ) 
		# unit.GOAP:UpdateGoal( 'Health', -500 ) 
		unit.GOAP:UpdateGoal( 'CaptureFlag', -500 )
		
		unit.GOAP:UpdateGoal( 'KillUnits',  500 )		
		unit.GOAP:UpdateGoal( 'KillHero',  500 )
		unit.GOAP:UpdateGoal( 'KillStructures',  500 )
		
	    unit.GOAP:SensorTypeRefresh( 'Distance' )
		#WARN(aiBrain.Nickname..'Teleport to portal/valor complete')
		WaitSeconds(1)
    end,
     CalculateWeights = function(action, aiBrain, agent, initialAgent)
        local actionBp = HeroAIActionTemplates[action.ActionName]

		if initialAgent:GetHealthPercent() < 0.5 then   # [MOD] TE  and unit:GetMaxHealth() - unit:GetHealth() <= ( Buffs[ready].Affects.Health.Add * 0.4 ) 
			return false
		end
		#WARN('Enmey Warrank ' .. tostring(AIGlobals.GetEnemyTeamBrain(initialAgent).Score.WarRank) )
		if aiBrain.Score.WarRank <= 7 and AIGlobals.GetEnemyTeamBrain(initialAgent).Score.WarRank <= 7 then
			return false
		end
        if aiBrain:GetThreatAtPosition(agent.Position,   1.2, 'Hero', 'Enemy' ) > 0 then
            local retTable = {}
            for k,v in actionBp.GoalWeights do
                retTable[k] = v * 2
            end
            return retTable, 1
        end

        return actionBp.GoalWeights, 10
    end,
    InstantStatusFunction = function( unit, action )
        local aiBrain = unit:GetAIBrain()

        local nearFlag = nil		
		local myStronghold = unit:GetPosition()
		if aiBrain:GetStronghold() then
			myStronghold = aiBrain:GetStronghold():GetPosition() #aiBrain:GetStronghold():GetPosition()	 #unit:GetPosition()
		end
        local lightArmy = GetArmyBrain('TEAM_1')
        local darkArmy = GetArmyBrain('TEAM_2')
        local neutralArmy = GetArmyBrain('NEUTRAL_CIVILIAN')
		
		local lightFlags =  lightArmy:GetListOfUnits( categories.FLAG, false) 
		local darkFlags =	darkArmy:GetListOfUnits( categories.FLAG, false) 
		local nuetralFlags = neutralArmy:GetListOfUnits( categories.FLAG, false) 
		
		local captureFlags = Utils.TableCat(nuetralFlags, lightFlags, darkFlags )
     
		if not table.empty(captureFlags) then
			captureFlags = SortEntitiesByDistanceXZ(myStronghold, captureFlags)
			for k,v in captureFlags do       			
				if IsAlly( v:GetArmy(), unit:GetArmy() ) then
				
					local captureUnits = v:GetCaptureList()
					for k,ptv in captureUnits do
						if (ptv == 'ugbportal01') or (ptv == 'unbidol01')  then
							local heroThreat = aiBrain:GetThreatAtPosition( v.Position,   1.2, 'Hero', 'Enemy' )
							if heroThreat > 0 then
								nearFlag = v
							end	
						end
					end
					
					if nearFlag then
						break
					end
				end
			end		
		end
		
		if not nearFlag then
            return false 
        end

        return AIAbility.DefaultStatusFunction(unit, action)
    end,
}

HeroAIActionTemplates['Teleport to Tower'] = {
    Name = 'Teleport to Tower',
    Abilities = AIGlobals.TeleportAbilities,
    FinalAction = true,
    GoalSets = {
		#All = true,
         Assassinate = true,
         Attack = true,
         Defend = true,
		 MoveToFriendly = true,
		 CapturePoint = true,
    },
	
    GoalWeights = {
        CaptureFlag = -50,
        KillHero = -50,
		SupportAlly = -50,
    },
    UninterruptibleAction = true,
    ActionTimeout = 10,
    ActionFunction = function(unit, action)
        local aiBrain = unit:GetAIBrain()
        local actionBp = HeroAIActionTemplates[action.ActionName]
        local nearTarget = nil
		
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
		

		local aflags = allyTeamBrain:GetListOfUnits(categories.FLAG, false)
		local aPortals = allyTeamBrain:GetListOfUnits(categories.PORTAL, false)
		local aTowers = allyTeamBrain:GetListOfUnits(categories.DEFENSE - categories.WALL, false)
		local unitPosition = unit:GetPosition()
		
	
		
		local defendTargets = Utils.TableCat(aflags, aPortals, aTowers )
		 
		if not table.empty(defendTargets) then
			defendTargets = SortEntitiesByDistanceXZ(unitPosition, defendTargets)
			for k,v in defendTargets do       			
				local heroThreat = aiBrain:GetThreatAtPosition( v.Position, .75, 'Hero', 'Enemy' )
				local towerThreat = aiBrain:GetThreatAtPosition( v.Position, .5, 'Structures', 'Enemy' )
				if heroThreat > 0 or towerThreat > 0 then
					nearTarget = v
				end							
				if nearTarget then
					break
				end
			end		
		end
		
		if not nearTarget then
			WaitTicks(1)
            return false 
        end
		
		local nearTargetBP = nearTarget:GetBlueprint()	


		
        local abilities = AIGlobals.TeleportAbilities

        local ready = GetReadyAbility( unit, abilities )
			
		# -- local announcement = "Tower Threatened, TP: "..LOC(flagbp.Name)
		# -- AIUtils.AIChat(unit, announcement)

			#[version .23] enabled the statement immediately below so that AI demigods would not teleport very short

		
		local distance = AIUtils.GetPathDistanceBetweenPoints( aiBrain, unit.Position, nearTarget.Position )
		#WARN( LOC(aiBrain.Nickname) .. ' - Teleport to allied asset - Distance: '.. distance) 
        if distance < 90 then
			local position = unit:FindEmptySpotNear(nearTarget.Position)
			# [MOD] TE Move along path (fix move to capture issue on some maps)
			local path = AIUtils.GetSafePathBetweenPoints(aiBrain, unit.Position, position, 10)

			if not path then
				path = { position}
			end

			# Move along the path
			local cmd = false
			for k,v in path do
				cmd = IssueAggressiveMove( {unit}, v )
			end

			
			local counter = 0
			while not IsCommandDone(cmd) do
				WaitSeconds(1)
				counter = counter + 1
				if unit:IsDead() then
					return
				end
				
			
				if(nearTarget and not nearTarget:IsDead()) then
					local bp = nearTarget:GetBlueprint()
					local distance = bp.DetectionRadius or 10
					local distanceSq = distance * distance
					if(VDist3XZSq(unit.Position, nearTarget.Position) < distanceSq) then
						break
					end
				else
					return
				end
			end


			return false
        end

				
		if not AIAbility.UseTargetedAbility( unit, ready, nearTarget, actionBp.ActionTimeout ) then 
			return false
		end
		
		unit.GOAP:UpdateGoal( 'PurchaseItems', -500 )
		unit.GOAP:UpdateGoal( 'Survival', -500 ) 
		unit.GOAP:UpdateGoal( 'Health', -500 ) 
		unit.GOAP:UpdateGoal( 'Health', -500 ) 
		unit.GOAP:UpdateGoal( 'CaptureFlag', -500 )
		
		unit.GOAP:UpdateGoal( 'KillUnits',  500 )		
		unit.GOAP:UpdateGoal( 'KillHero',  500 )
		unit.GOAP:UpdateGoal( 'KillStructures',  500 )
		
		unit.GOAP:SensorTypeRefresh( 'Distance' )
		#WARN(aiBrain.Nickname..' Teleport to tower complete')
		WaitSeconds(1)
    end,
     CalculateWeights = function(action, aiBrain, agent, initialAgent)
        local actionBp = HeroAIActionTemplates[action.ActionName]
		if initialAgent:GetHealthPercent() < 0.5 then   # [MOD] TE  and unit:GetMaxHealth() - unit:GetHealth() <= ( Buffs[ready].Affects.Health.Add * 0.4 ) 
			return false
		end		
		
		local heroThreat = aiBrain:GetThreatAtPosition( agent.Position,  .75, 'Hero', 'Enemy' )
		local towerThreat = aiBrain:GetThreatAtPosition( agent.Position, .5, 'Structures', 'Enemy' )
		if heroThreat > 0 or towerThreat > 0 then
            local retTable = {}
            for k,v in actionBp.GoalWeights do
                retTable[k] = v * 2
            end
            return retTable, 1
        end

        return actionBp.GoalWeights, 10
    end,
    InstantStatusFunction = function( unit, action )
		if unit.GOAP.NearbyEnemyHeroes and unit.GOAP.NearbyEnemyHeroes.ClosestDistance < 30 then
            return false
        end
        local aiBrain = unit:GetAIBrain()
        #action.TargetPosition = false
		local nearTarget = nil
		
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
		

		local aflags = allyTeamBrain:GetListOfUnits(categories.FLAG, false)
		local aPortals = allyTeamBrain:GetListOfUnits(categories.PORTAL, false)
		local aTowers = allyTeamBrain:GetListOfUnits(categories.DEFENSE - categories.WALL, false)
		local unitPosition = unit:GetPosition()
		
	
		
		local defendTargets = Utils.TableCat(aflags, aPortals, aTowers )
		 
		if not table.empty(defendTargets) then
			defendTargets = SortEntitiesByDistanceXZ(unitPosition, defendTargets)
			for k,v in defendTargets do       			
				local heroThreat = aiBrain:GetThreatAtPosition( v.Position,  .75, 'Hero', 'Enemy' )
				local towerThreat = aiBrain:GetThreatAtPosition( v.Position, .5, 'Structures', 'Enemy' )
				if heroThreat > 0 or towerThreat > 0 then
					nearTarget = v
				end							
				if nearTarget then
					break
				end
			end		
		end
		
		if not nearTarget then
            return false 
        end
		
		#action.nearTarget = nearTarget.Position
        return AIAbility.DefaultStatusFunction(unit, action)
    end,
}


-- # ------------------------------------------------------------------------------
-- # TOTEM OF REVELATION
-- # Use: Place an observer ward that can reveal cloaked enemies. Can also reveal mines.
-- # ------------------------------------------------------------------------------
-- local RevelationAbilities = {
    -- 'Item_Consumable_020',
-- }
-- local RevelationDisables = table.append( DefaultDisables,
    -- {
        -- 'Totem of Revelation - Squad Target',
    -- }
-- )
-- local RevelationTime = 3

-- # ----------------------------
-- # Totem of Revelation - Squad Target
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Totem of Revelation - Squad Target',
    -- Abilities = RevelationAbilities,
    -- DisableActions = RevelationDisables,
    -- GoalSets = {
        -- SquadMove = true,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = function(unit, action)
        -- local result = false
        -- local actionBp = HeroAIActionTemplates[action.ActionName]

        -- local ready = GetReadyAbility(unit, actionBp.Abilities)
        -- if(ready) then
            -- local range = Ability[ready].RangeMax * 1.5
            -- range = range * range
            -- if(unit.GOAP.SquadLocation and VDist3XZSq(unit.Position, unit.GOAP.SquadLocation) <= range) then
                -- result = true
            -- end
        -- end

        -- if(result) then
            -- return AIAbility.UseTargetedAbility(unit, ready, unit.GOAP.SquadLocation, actionBp.ActionTimeout)
        -- else
            -- return false
        -- end
    -- end,
    -- ActionTimeout = 7,
    -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        -- if not agent.WorldStateData.CanUseAbilities then
            -- return false
        -- end

        -- local result = false

        -- if(action.Ability) then
            -- local range = Ability[action.Ability].RangeMax * 1.5
            -- local units = aiBrain:GetUnitsAroundPoint(categories.ugbshop01ward01, initialAgent.Position, range, 'Ally')
            -- if(table.empty(units)) then
                -- range = range * range
                -- if(initialAgent.GOAP.SquadLocation and VDist3XZSq(initialAgent.Position, initialAgent.GOAP.SquadLocation) <= range) then
                    -- result = true
                -- end
            -- end
        -- end

        -- if(result) then
            -- return {MoveToSquadLocation = -5}, RevelationTime
        -- else
            -- return result
        -- end
    -- end,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ------------------------------------------------------------------------------
-- # Capture Lock
-- # Use: Selected ally flag cannot be captured by the enemy for 30 seconds.
-- # ------------------------------------------------------------------------------
# -- local CaptureLockAbilities = {
     # -- 'Item_Consumable_030',
 # -- }
 # -- local CaptureLockDisables = table.append( DefaultDisables,
     # -- {
		# -- 'Use Capture Lock',
     # -- }
# -- )

# ----------------------------
# Use Capture Lock
# ----------------------------
HeroAIActionTemplates['Use Capture Lock'] = {
    Name = 'Use Capture Lock',
    Abilities = CaptureLockAbilities,
    DisableActions = CaptureLockDisables,
    GoalSets = {
        Attack = true,
        CapturePoint = true,
        DestroyStructures = true,
    },
    GoalWeights = {
        CaptureFlag = -50,
        KillUnits = -50,
        KillHero = -50,
    },
    ForceGoalWeights = true,
    UninterruptibleAction = true,
    ActionTimeOut = 5,
# 0.27.07 Added new action function from mithy - this should keep ai's from attempting to lock flags at the same time
     ActionFunction = function(unit, action)
        local result = false
        local actionBp = HeroAIActionTemplates[action.ActionName]
        local aiBrain = unit:GetAIBrain()

-- Check to see if there is a nearby flag that we control - if not, then don't continue
        local flags = aiBrain:GetUnitsAroundPoint( categories.FLAG, unit:GetPosition(), 32, 'Ally' )
        if table.empty(flags) then
            return
        end

        flags = SortEntitiesByDistanceXZ(unit.Position, flags)
--# 0.27.07 added local flag = false per miri - this SHOULD keep the ai from recasting locks on locked flags
        local flag = false
        for k,v in flags do --Mithy: Add check for being locked before proceeding
            if aiBrain:GetBlipsAroundPoint( categories.HERO, v.Position, 20, 'Enemy' ) > 0 and v.CanBeCaptured and not v.BeingLocked then
                flag = v
                break
            end
        end

        if not flag then
            return
        end



        local ready = GetReadyAbility(unit, actionBp.Abilities)
        if(ready) then
            result = true
        end

        if(result) then
            local captureUnits = flag:GetCaptureList()
            for k,v in captureUnits do
                if (v == 'ugbportal01')  then
                    local announcement = "Lock Portal flag."
                    AIUtils.AIChat(unit, announcement)
                elseif (v == 'unbidol01') then
                    local announcement = "Lock Valor flag."
                    AIUtils.AIChat(unit, announcement)
                else
                #Do nothing
                end
            end

            --Mithy: Mark this flag as being locked until we're done casting (at which point it will be non-capturable)
            flag.BeingLocked = true
            local endResult = AIAbility.UseTargetedAbility(unit, ready, flag, actionBp.ActionTimeout)
            flag.BeingLocked = nil
            return endResult
        else
            return false
        end
    end,
	
	
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        local actionBp = HeroAIActionTemplates[action.ActionName]

        if aiBrain:GetThreatAtPosition(agent.Position, 1, 'Hero', 'Enemy' ) > 0 then
            local retTable = {}
            for k,v in actionBp.GoalWeights do
                retTable[k] = v * 2
            end
            return retTable, 5
        end
	
        return actionBp.GoalWeights, 5 # [version .23] was 5
    end,

# 0.27.07 Added new instant status function from mithy - this should keep ai's from attempting to lock flags at the same time
    InstantStatusFunction = function(unit, action)
        local aiBrain = unit:GetAIBrain()

        local flags = aiBrain:GetUnitsAroundPoint( categories.FLAG, unit.Position, 32, 'Ally' )
        if table.empty(flags) then
            return false
        else
            --Mithy: Check for existing locks
            local numflags, numlocked = table.getn(flags), 0
            for k, v in flags do
                if not v.CanBeCaptured or v.BeingLocked then
                    numlocked = numlocked + 1
                end
            end
            if numlocked == numflags then
                return false
            end
        end

        if aiBrain:GetThreatAtPosition(flags[1].Position, 1, 'Hero', 'Enemy' ) <= 0 then
            return false
        end

        return AIAbility.DefaultStatusFunction(unit, action)
    end,
}



-- # ------------------------------------------------------------------------------
-- # SLUDGE SLINGER
-- # Use: Decreases target's attack speed.
-- # ------------------------------------------------------------------------------
-- local SludgeSlingerAbilities = {
    -- 'Item_Consumable_040',
-- }
-- local SludgeSlingerDisables = table.append( DefaultDisables,
    -- {
        -- 'Sludge Slinger - Hero',
        -- 'Sludge Slinger - Squad Target',
    -- }
-- )

-- # ----------------------------
-- # Sludge Slinger - Hero
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Sludge Slinger - Hero',
    -- Abilities = SludgeSlingerAbilities,
    -- DisableActions = SludgeSlingerDisables,
    -- GoalSets = {
        -- Assassinate = true,
        -- Attack = true,
    -- },
    -- GoalWeights = {
        -- KillHero = -1,
    -- },
    -- ForceGoalWeights = true,
    -- UninterruptibleAction = true,
    -- WeightTime = 1,
    -- ActionFunction = AIAbility.TargetedAttackHeroFunction,
    -- ActionTimeOut = 5,
    -- CalculateWeights = AIAbility.TargetedAttackWeightsHero,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ----------------------------
-- # Sludge Slinger - Squad Target
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Sludge Slinger - Squad Target',
    -- Abilities = SludgeSlingerAbilities,
    -- DisableAction = SludgeSlingerDisables,
    -- GoalSets = {
        -- SquadKill = true,
    -- },
    -- GoalWeights = {
        -- KillSquadTarget = -1,
    -- },
    -- TargetTypes = {'HERO'},
    -- ForceGoalWeights = true,
    -- UninterruptibleAction = true,
    -- WeightTime = 1,
    -- ActionFunction = AIAbility.TargetedAbilitySquadTargetFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = AIAbility.TargetedAbilitySquadTargetWeights,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ------------------------------------------------------------------------------
-- # SCROLL OF SPRINTING
-- # Use: Increase Base Run Speed by 30%.
-- # ------------------------------------------------------------------------------
-- local SprintAbilities = {
    -- 'Item_Consumable_050',
-- }
-- local SprintDisables = table.append( DefaultDisables, AIGlobals.SprintDisables )
-- local SprintTime = 0

-- local function SprintSpeed(ability)
    -- if AIGlobals.AbilityDamage[ability] then
        -- return AIGlobals.AbilityDamage[ability]
    -- end

    -- local runMult = 0

    -- local abilDef = Ability[ability]
    -- local found = false
    -- for _,buffName in abilDef.Buffs do
        -- for buffType,buffData in Buffs[buffName].Affects do
            -- if buffType != 'MoveMult' then
                -- continue
            -- end

            -- runMult = runMult + buffData.Mult
            -- found = true
        -- end
        -- if not found then
            -- WARN('*AI WARNING: Could not find a new damage mult for ability - ' .. ability)
        -- end
    -- end

    -- AIGlobals.AbilityDamage[ability] = runMult
    -- return runMult
-- end

-- function SprintWeights(action, aiBrain, agent, initialAgent)
    -- if not agent.WorldStateData.CanUseAbilities then
        -- return false
    -- end

    -- local result = false
    -- local actionBp = HeroAIActionTemplates[action.ActionName]

    -- if(action.Ability) then
        -- if(AIAbility.TestEnergy(agent, action.Ability)) then
            -- result = true
        -- end
    -- end

    -- if aiBrain:GetThreatAtPosition(  agent.Position, 1, 'Hero', 'Enemy' ) <= 0 then
        -- return false
    -- end

    -- agent.Speed = agent.Speed * ( 1 + SprintSpeed(action.Ability) )

    -- if(result) then
        -- return actionBp.GoalWeights, SprintTime
    -- else
        -- return result
    -- end
-- end

-- # ----------------------------
-- # Sprint - Flee
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Sprint - Flee',
    -- Abilities = SprintAbilities,
    -- DisableAction = SprintDisables,
    -- GoalSets = {
        -- Flee = true,
    -- },
    -- GoalWeights = {
        -- Survival = -2,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = AIAbility.InstantActionFunction,
    -- CalculateWeights = SprintWeights,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ----------------------------
-- # Sprint - Attack
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Sprint - Attack',
    -- Abilities = SprintAbilities,
    -- DisableAction = SprintDisables,
    -- GoalSets = {
        -- Assassinate = true,
        -- SquadKill = true,
    -- },
    -- GoalWeights = {
        -- KillHero = -2,
        -- KillSquadTarget = -2,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = AIAbility.InstantActionFunction,
    -- CalculateWeights = SprintWeights,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ------------------------------------------------------------------------------
-- # TARGETING DUMMY
-- # Use: Draws fire from towers of light when placed nearby.
-- # ------------------------------------------------------------------------------
-- local TargetingDummyAbilities = {
    -- 'Item_Consumable_060',
-- }
-- local TargetingDummyDisables = table.append( DefaultDisables,
    -- {
        -- 'Targeting Dummy - Structure',
        -- 'Targeting Dummy - Squad Target',
    -- }
-- )
-- local TargetingDummyTime = 2

-- function TargetingDummyAction(unit, action, target)
    -- local result = false
    -- local aiBrain = unit:GetAIBrain()
    -- local actionBp = HeroAIActionTemplates[action.ActionName]
    -- local location = nil

    -- local abilities = actionBp.Abilities
    -- local ready = GetReadyAbility(unit, abilities)
    -- if(ready) then
        -- local range = Ability[ready].RangeMax * 1.2
        -- local target = nil
        -- if(actionBp.SquadTarget and initialAgent.GOAP.AttackTarget) then
            -- if(EntityCategoryContains(categories.LIGHTTOWER * categories.STRUCTURE, initialAgent.GOAP.AttackTarget)) then
                -- target = initialAgent.GOAP.AttackTarget
            -- end
        -- else
            -- local units = aiBrain:GetBlipsAroundPoint(categories.LIGHTTOWER * categories.STRUCTURE, unit:GetPosition(), range, 'Enemy')
            -- target = AIUtils.GetWeakestUnit(units)
        -- end

        -- if(target) then
            -- location = aiBrain:FindNearestSpotToBuildOn(unit, 'UGBShop01TOLSink', target:GetPosition())
            -- result = true
        -- end
    -- end

    -- if(result) then
        -- return AIAbility.UseTargetedAbility(unit, ready, location, actionBp.ActionTimeout)
    -- else
        -- return result
    -- end
-- end

-- # ----------------------------
-- # Targeting Dummy - Structure
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Targeting Dummy - Structure',
    -- Abilities = TargetingDummyAbilities,
    -- DisableAction = TargetingDummyDisables,
    -- GoalSets = {
        -- DestroyStructures = true,
    -- },
    -- GoalWeights = {
        -- KillStructures = -5,
    -- },
    -- UninterruptibleAction = true,
    -- WeightTime = TargetingDummyTime,
    -- ActionFunction = TargetingDummyAction,
    -- ActionTimeout = 5,
    -- CalculateWeights = AIAbility.TargetedAttackWeightsDefense,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ----------------------------
-- # Targeting Dummy - Squad Target
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Targeting Dummy - Squad Target',
    -- Abilities = TargetingDummyAbilities,
    -- DisableAction = TargetingDummyDisables,
    -- GoalSets = {
        -- SquadKill = true,
    -- },
    -- GoalWeights = {
        -- KillSquadTarget = -5,
    -- },
    -- TargetTypes = {'STRUCTURE'},
    -- UninterruptibleAction = true,
    -- WeightTime = TargetingDummyTime,
    -- ActionFunction = TargetingDummyAction,
    -- ActionTimeout = 5,
    -- CalculateWeights = AIAbility.TargetedAbilitySquadTargetWeights,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

----------------------------------------------------------------------------
# -- # WARP
# -- # Use: Warp to a nearby location.
----------------------------------------------------------------------------
# -- local WarpAbilities = {
    # -- 'Item_Consumable_070',
    # -- 'Item_Artifact_050',
    # -- 'AchievementMinionInvis',
# -- }
# -- local WarpDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Warp to Weak Hero',
        # -- 'Warp to Squad Target',
        # -- 'Warp to Safe Position',
    # -- }
# -- )

--------------------------
# -- # Warp to Weak Hero
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Warp to Weak Hero',
    # -- Abilities = WarpAbilities,
    # -- DisableActions = WarpDisables,
    # -- GoalSets = {
        # -- Assassinate = true,
        # -- Attack = true,
    # -- },
    # -- ActionTimeout = 5,
    # -- ActionFunction = function(unit, action)
        # -- local actionBp = HeroAIActionTemplates[action.ActionName]

        # -- local ready = GetReadyAbility(unit, actionBp.Abilities)
        # -- if(ready) then
            # -- local target = AIUtils.GetNearbyWeakHero(unit, 30)
            # -- if(target) then
                # -- if(VDist3XZSq(unit:GetPosition(), target:GetPosition()) >= 7 * 7) then
                    # -- AIAbility.WarpNearTarget(unit, ready, target, actionBp.ActionTimeout)
                    # -- action.Status = false
                # -- end
            # -- end
        # -- end
    # -- end,
    # -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        # -- if not agent.WorldStateData.CanUseAbilities then
            # -- return false
        # -- end

        # -- local result = false

        # -- if(action.Ability) then
            # -- if(AIAbility.TestEnergy(agent, action.Ability)) then
                # -- result = true
            # -- end
        # -- end

        # -- if(result) then
            # -- # If I warp then I'll be near a weak hero
            # -- agent.WorldStateData.WeakHeroNearby = true
            # -- agent.WorldStateConsistent = false
            # -- return { KillHero = -1 }, Ability[action.Ability].CastingTime
        # -- else
            # -- return result
        # -- end
    # -- end,
    # -- InstantStatusFunction = function(unit, action)
        # -- local target = AIUtils.GetNearbyWeakHero(unit, 30)

        # -- # if i have a target and i'm not already near a weak hero
        # -- if(target and not unit.WorldStateData.WeakHeroNearby) then
            # -- return AIAbility.DefaultStatusFunction(unit, action)
        # -- else
            # -- return false
        # -- end
    # -- end,
# -- }

--------------------------
# -- # Warp to Squad Target
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Warp to Squad Target',
    # -- Abilities = WarpAbilities,
    # -- DisableActions = WarpDisables,
    # -- GoalSets = {
        # -- SquadKill = true,
    # -- },
    # -- ActionTimeout = 5,
    # -- ActionFunction = function(unit, action)
        # -- local actionBp = HeroAIActionTemplates[action.ActionName]

        # -- local ready = GetReadyAbility(unit, actionBp.Abilities)
        # -- if(ready and unit.GOAP.AttackTarget) then
            # -- if(VDist3XZSq(unit:GetPosition(), unit.GOAP.AttackTarget:GetPosition()) >= 25) then
                # -- local actionBp = HeroAIActionTemplates[action.ActionName]
                # -- AIAbility.WarpNearTarget(unit, ready, unit.GOAP.AttackTarget, actionBp.ActionTimeout)
                # -- action.Status = false
            # -- end
        # -- end
    # -- end,
    # -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        # -- if not agent.WorldStateData.CanUseAbilities then
            # -- return false
        # -- end

        # -- local result = false

        # -- if(action.Ability and initialAgent.GOAP.AttackTarget) then
            # -- if(AIAbility.TestEnergy(agent, action.Ability)) then
                # -- result = true
            # -- end
        # -- end

        # -- if(result) then
            # -- agent.WorldStateData.SquadTargetNearby = true
            # -- agent.WorldStateConsistent = false
            # -- return { KillSquadTarget = -1 }, Ability[action.Ability].CastingTime
        # -- else
            # -- return result
        # -- end
    # -- end,
    # -- InstantStatusFunction = function(unit, action)
        # -- if(unit.GOAP.AttackTarget and not unit.WorldStateData.SquadTargetNearby) then
            # -- return AIAbility.DefaultStatusFunction(unit, action)
        # -- else
            # -- return false
        # -- end
    # -- end,
# -- }

--------------------------
# -- # Warp to Flee
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Warp to Safe Position',
    # -- Abilities = WarpAbilities,
    # -- DisableActions = WarpDisables,
    # -- GoalSets = {
        # -- Attack = true,
        # -- Assassinate = true,
        # -- MoveToFriendly = true,
        # -- Flee = true,
        # -- SquadKill = true,
    # -- },
    # -- ActionTimeout = 5,
    # -- ActionFunction = function(unit, action)
        # -- local aiBrain = unit:GetAIBrain()
        # -- local actionBp = HeroAIActionTemplates[action.ActionName]

        # -- local ready = GetReadyAbility(unit, actionBp.Abilities)
        # -- local position = AIUtils.FindSafePosition(unit, aiBrain)

        # -- if VDist3XZSq(unit.Position, position) < 12 * 12 then
            # -- return false
        # -- end

        # -- if (ready and position) then
            # -- local actionBp = HeroAIActionTemplates[action.ActionName]
            # -- AIAbility.WarpNearPosition(unit, ready, position, actionBp.ActionTimeout)
            # -- action.Status = false
        # -- end
    # -- end,
    # -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        # -- if not agent.WorldStateData.CanUseAbilities then
            # -- return false
        # -- end

        # -- local result = false

        # -- if(action.Ability and initialAgent.GOAP.AttackTarget) then
            # -- if(AIAbility.TestEnergy(agent, action.Ability)) then
                # -- result = true
            # -- end
        # -- end

        # -- if(result) then
            # -- return { Survival = -5 }, 0.5
        # -- else
            # -- return result
        # -- end
    # -- end,
    # -- InstantStatusFunction = function(unit, action)
        # -- local aiBrain = unit:GetAIBrain()
        # -- if aiBrain:GetNumUnitsAroundPoint( categories.MOBILE + categories.DEFENSE, unit.Position, 10, 'Enemy' ) <= 0 then
            # -- return false
        # -- end

        # -- if unit.SafePosition == nil then
            # -- unit.SafePosition = AIUtils.FindSafePosition(unit, aiBrain)
        # -- end

        # -- if not unit.SafePosition or VDist3XZSq(unit.Position, unit.SafePosition) < 12 * 12 then
            # -- return false
        # -- end

        # -- return AIAbility.DefaultStatusFunction(unit, action)
    # -- end,
# -- }


-- # ------------------------------------------------------------------------------
-- # UNIVERSAL GADGET
-- # Use: Heal an allied unit for 500 or damage an enemy unit for 500.
-- # ------------------------------------------------------------------------------
-- local UniversalGadgetAbilities = {
    -- 'Item_Consumable_080',
-- }
-- local UniversalGadgetDisables = table.append( DefaultDisables,
    -- {
        -- 'Universal Gadget - Self',
        -- 'Universal Gadget - Friendly Hero',
        -- 'Universal Gadget - Enemy Hero',
        -- 'Universal Gadget - Enemy Structure',
        -- 'Universal Gadget - Squad Target',
    -- }
-- )

-- local function GadgetDamage(ability)
    -- if AIGlobals.AbilityDamage[ability] then
        -- return AIGlobals.AbilityDamage[ability]
    -- end

    -- local damage = 0

    -- local buff = Buffs['Item_Consumable_080_Damage']

    -- if buff then
        -- for buffType,buffData in buff.Affects do
            -- if buffType == 'Health' then
                -- damage = damage + math.abs(buffData.Add)
            -- end
        -- end
    -- else
        -- WARN('*AI ERROR: Could not find buff for - ' .. ability )
    -- end

    -- AIGlobals.AbilityDamage[ability] = damage
    -- return damage
-- end

-- # ----------------------------
-- # Universal Gadget - Self
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Universal Gadget - Self',
    -- Abilities = UniversalGadgetAbilities,
    -- DisableActions = UniversalGadgetDisables,
    -- GoalSets = {
        -- All = true,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = AIAbility.TargetedSelfHeroFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        -- if not agent.WorldStateData.CanUseAbilities then
            -- return false
        -- end

        -- local result = false

        -- if(action.Ability) then
            -- if(initialAgent:GetHealthPercent() < 0.6) then
                -- # Make sure statue is too far away
                -- local statue = aiBrain:GetHealthStatue()
                -- if(statue and VDist3XZSq(initialAgent.Position, statue.Position) >= 400) then
                    -- result = true
                -- end
            -- end
        -- end

        -- if(result == true) then
            -- return {Health = -5, Survival = -5}, Ability[action.Ability].CastingTime
        -- else
            -- return result
        -- end
    -- end,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ----------------------------
-- # Universal Gadget - Friendly Hero
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Universal Gadget - Friendly Hero',
    -- Abilities = UniversalGadgetAbilities,
    -- DisableActions = UniversalGadgetDisables,
    -- GoalSets = {
        -- All = true,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = AIAbility.TargetedWeakFriendHeroFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        -- if not agent.WorldStateData.CanUseAbilities then
            -- return false
        -- end

        -- if(action.Ability) then
            -- return {SupportAlly = -5}, Ability[action.Ability].CastingTime
        -- else
            -- return false
        -- end
    -- end,
    -- InstantStatusFunction = function(unit, action)
        -- local result = false

        -- if(AIAbility.DefaultStatusFunction(unit, action)) then
            -- local allies = unit:GetAIBrain():GetUnitsAroundPoint(categories.HERO, unit.Position, 25, 'Ally')
            -- for k, v in allies do
                -- if(v != unit and v:GetHealthPercent() < 0.5) then
                    -- result = true
                    -- break
                -- end
            -- end
        -- end

        -- return result
    -- end,
-- }

-- # ----------------------------
-- # Universal Gadget - Enemy Hero
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Universal Gadget - Enemy Hero',
    -- Abilities = UniversalGadgetAbilities,
    -- DisableActions = UniversalGadgetDisables,
    -- GoalSets = {
        -- Assassinate = true,
        -- Attack = true,
    -- },
    -- GoalWeights = {
        -- KillHero = -5,
    -- },
    -- UninterruptibleAction = true,
    -- DamageCalculationFunction = GadgetDamage,
    -- ActionFunction = AIAbility.TargetedAttackHeroFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = AIAbility.TargetedAttackWeightsHero,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ----------------------------
-- # Universal Gadget - Enemy Structure
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Universal Gadget - Enemy Structure',
    -- Abilities = UniversalGadgetAbilities,
    -- DisableActions = UniversalGadgetDisables,
    -- GoalSets = {
        -- DestroyStructures = true,
    -- },
    -- GoalWeights = {
        -- KillStructures = -5,
    -- },
    -- UninterruptibleAction = true,
    -- DamageCalculationFunction = GadgetDamage,
    -- ActionFunction = AIAbility.TargetedAttackDefenseFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = AIAbility.TargetedAttackWeightsDefense,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ----------------------------
-- # Universal Gadget - Squad Target
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Universal Gadget - Squad Target',
    -- Abilities = UniversalGadgetAbilities,
    -- DisableActions = UniversalGadgetDisables,
    -- GoalSets = {
        -- Assassinate = true,
        -- Attack = true,
    -- },
    -- GoalWeights = {
        -- KillSquadTarget = -5,
    -- },
    -- TargetTypes = {'HERO', 'STRUCTURE'},
    -- UninterruptibleAction = true,
    -- DamageCalculationFunction = GadgetDamage,
    -- ActionFunction = AIAbility.TargetedAbilitySquadTargetFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = AIAbility.TargetedAbilitySquadTargetWeights,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ------------------------------------------------------------------------------
-- # RESTORATIVE SCROLL
-- # Use: Any negative effects on your army are removed.
-- # ------------------------------------------------------------------------------

-- # ----------------------------
-- # Use Restorative Scroll
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Use Restorative Scroll',
    -- Abilities = {'Item_Consumable_090'},
    -- DisableActions = table.append(DefaultDisables, {'Use Restorative Scroll'}),
    -- GoalSets = {
        -- All = true,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = AIAbility.InstantActionFunction,
    -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        -- if(agent.WorldStateData.CanUseAbilities) then
            -- return {Survival = -5}, 1
        -- else
            -- return false
        -- end
    -- end,
    -- InstantStatusFunction = function(unit, action)
        -- local result = false
        -- local count = 0

        -- for k, v in unit.Minions do
             -- for buffType, buffTbl in v.Buffs.BuffTable do
                -- for buffName, buffDef in buffTbl do
                    -- if(Buffs[buffName].Debuff == true and Buffs[buffName].CanBeDispelled == true) then
                        -- count = count + 1
                    -- end
                -- end
            -- end
        -- end

        -- if(count >= 2) then
            -- result = true
        -- end

        -- if(result) then
            -- return AIAbility.DefaultStatusFunction(unit, action)
        -- else
            -- return result
        -- end
    -- end,
-- }

-- # ------------------------------------------------------------------------------
-- # TWIG OF LIFE
-- # Use: Your army restores 25% of their maximum Health.
-- # ------------------------------------------------------------------------------

-- # ----------------------------
-- # Use Twig of Life
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Use Twig of Life',
    -- Abilities = {'Item_Consumable_120'},
    -- DisableActions = table.append(DefaultDisables, {'Use Twig of Life'}),
    -- GoalSets = {
        -- All = true,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = AIAbility.InstantActionFunction,
    -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        -- if(agent.WorldStateData.CanUseAbilities) then
            -- return {Survival = -5}, 1
        -- else
            -- return false
        -- end
    -- end,
    -- InstantStatusFunction = function(unit, action)
        -- local result = false
        -- local aiBrain = unit:GetAIBrain()

        -- # If there's a statue nearby, return false since we can heal at the statue
        -- local statue = aiBrain:GetHealthStatue()
        -- if statue and VDist3XZSq( unit.Position, statue.Position ) < 400 then
            -- return false
        -- end

        -- local actionBp = HeroAIActionTemplates[action.ActionName]
        -- local ready = GetReadyAbility(unit, actionBp.Abilities)

        -- if(not ready) then
            -- return false
        -- end

        -- local count = 0
        -- local percent = Ability[ready].RegenAmount
        -- for k, v in unit.Minions do
            -- if(v and not v:IsDead() and v:GetHealthPercent() < percent) then
                -- count = count + 1
            -- end
        -- end

        -- if(count >= 2) then
            -- result = true
        -- end

        -- if(result) then
            -- return AIAbility.DefaultStatusFunction(unit, action)
        -- else
            -- return result
        -- end
    -- end,
-- }

-- # ------------------------------------------------------------------------------
-- # MAGUS ROD
-- # Use: The cost of abilities is reduced by 50% for 5 seconds.
-- # ------------------------------------------------------------------------------

-- # ----------------------------
-- # Use Magus Rod
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Use Magus Rod',
    -- Abilities = {'Item_Consumable_140'},
    -- DisableActions = table.append(DefaultDisables, AIGlobals.EnergyDisables),
    -- GoalSets = {
        -- All = true,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = AIAbility.InstantActionFunction,
    -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        -- if not agent.WorldStateData.CanUseAbilities then
            -- return false
        -- end

        -- return {Energy = -5, KillUnits = -5, KillHero = -5, KillStructures = -5, KillSquadTarget = -5}, Ability[action.Ability].CastingTime or 1
    -- end,
    -- InstantStatusFunction = function(unit, action)
        -- local result = false

        -- # If not near a health statue
        -- local brain = unit:GetAIBrain()
        -- local healthStatues = brain:GetUnitsAroundPoint(categories.HEALTHSTATUE, unit.Position, 20, 'Ally')
        -- if(table.empty(healthStatues)) then
            -- # Make sure there is a threat nearby
            -- if(brain:GetThreatAtPosition(unit.Position, 1, nil, 'Enemy') > 0) then
                -- result = true
            -- end
        -- end

        -- if(result) then
            -- return AIAbility.DefaultStatusFunction(unit, action)
        -- else
            -- return result
        -- end
    -- end,
-- }

# ------------------------------------------------------------------------------
# ORB OF DEFIANCE
# Use: Become invulnerable for 5 seconds. Cannot move, attack or use abilities.
# ------------------------------------------------------------------------------

# ----------------------------
# Use Orb of Defiance
# ----------------------------
HeroAIActionTemplates['Use Orb of Defiance'] = {
    Name = 'Use Orb of Defiance',
    Abilities = {'Item_Consumable_150_Use'},
    DisableActions = table.append(DefaultDisables,
        {
            'Use Orb of Defiance',
        }
    ),
    GoalSets = {
        All = true,
    },
    UninterruptibleAction = true,
    ActionFunction = AIAbility.InstantActionFunction,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        if not agent.WorldStateData.CanUseAbilities then
            return false
        end

        return {Health = -5, Survival = -5}, Ability[action.Ability].CastingTime
    end,

    InstantStatusFunction = function(unit, action)
        action.Ability = false
        local actionBp = HeroAIActionTemplates[action.ActionName]
        local aiBrain = unit:GetAIBrain()

        # If there's a statue nearby, return false since we can heal at the statue
        local statue = aiBrain:GetHealthStatue()
        if statue and VDist3XZSq( unit.Position, statue.Position ) < 400 then
            return false
        end

        local ready = GetReadyAbility( unit, actionBp.Abilities )

        if not ready then
            return false
        end

# 0.27.06 changed health requirement from 0.4 to 0.6 to hopefully trigger this before sigils
        if unit:GetHealthPercent() > 0.6 then
            return false
        end

# 0.27.06 removed grunt check as a qualifier
--[[
        if(aiBrain:GetThreatAtPosition(unit.Position, 1, 'Land', 'Enemy') < 15) then
            return false
        end
--]]
# 0.27.06 added enemy hero check - if no enemies nearby, do not use		
		if not unit.GOAP.NearbyEnemyHeroes then
			return false
		end
        action.Ability = ready
        return true
    end,
}

-- # ------------------------------------------------------------------------------
-- # HEART OF LIFE
-- # Use: Restore 3000 Health and 3000 Mana over 10 seconds. Any damage will break this effect.
-- # +15 Health Regeneration
-- # +50% Mana Regeneration
-- # ------------------------------------------------------------------------------

-- # ----------------------------
-- # Use Heart of Life
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Use Heart of Life',
    -- Abilities = {'Item_Consumable_160_Use'},
    -- DisableActions = RejuvenationPotionDisables,
    -- GoalSets = {
        -- All = true,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = AIAbility.InstantActionFunction,
    -- CalculateWeights = function( action, aiBrain, agent, initialAgent )
        -- if not agent.WorldStateData.CanUseAbilities then
            -- return false
        -- end

        -- return {Health = -10, Survival = -10, Energy = -10}, Ability[action.Ability].CastingTime or 0.1
    -- end,
    -- InstantStatusFunction = function( unit, action )
        -- local result = false

        -- # If my health or mana percentage is below 40% and not near a health statue
        -- if(unit:GetHealthPercent() < 0.4 or (unit:GetEnergy()/unit:GetMaxEnergy() < 0.4)) then
            -- local brain = unit:GetAIBrain()
            -- local healthStatues = brain:GetUnitsAroundPoint(categories.HEALTHSTATUE, unit.Position, 20, 'Ally')
            -- if(table.empty(healthStatues)) then
                -- result = true
            -- end

            -- local enemyUnits = brain:GetBlipsAroundPoint(categories.MOBILE + categories.DEFENSE, unit.Position, 15, 'Enemy')
            -- if table.getn(enemyUnits) > 0 then
                -- result = false
            -- end
        -- end

        -- if(result) then
            -- return AIAbility.DefaultStatusFunction(unit, action)
        -- else
            -- return result
        -- end
    -- end,
-- }

-- # ------------------------------------------------------------------------------
-- # PARASITE EGG
-- # Use: Infest target Demigod with a parasite. Whenever you deal damage to that Demigod, their army takes damage as well. The effects lasts 10 seconds.
-- # ------------------------------------------------------------------------------
-- local ParasiteEggAbilities = {
    -- 'Item_Consumable_170_Use',
-- }
-- local ParasiteEggDisables = table.append( DefaultDisables,
    -- {
        -- 'Parasite Egg - Hero',
        -- 'Parasite Egg - Squad Target',
    -- }
-- )
-- local ParasiteEggTime = 1

-- # ----------------------------
-- # Parasite Egg - Hero
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Parasite Egg - Hero',
    -- Abilities = ParasiteEggAbilities,
    -- DisableActions = ParasiteEggDisables,
    -- GoalSets = {
        -- Assassinate = true,
        -- Attack = true,
    -- },
    -- GoalWeights = {
        -- KillHero = -5,
        -- KillUnits = -5,
    -- },
    -- ForceGoalWeights = true,
    -- UninterruptibleAction = true,
    -- WeightTime = ParasiteEggTime,
    -- TargetCategory = categories.GENERAL,
    -- ActionFunction = AIAbility.TargetedAttackHeroFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = AIAbility.TargetedAttackWeightsHero,
    -- InstantStatusFunction = function( unit, action )

        -- # make sure there is a general nearby before using this on them
        -- local enemyHeroes = unit:GetAIBrain():GetBlipsAroundPoint( categories.HERO, unit.Position, 20, 'Enemy' )
        -- for k,v in enemyHeroes do
            -- if EntityCategoryContains( categories.GENERAL, v ) then
                -- return AIAbility.DefaultStatusFunction(unit,action)
            -- end
        -- end
        
        -- return false
    -- end,
-- }

-- # ----------------------------
-- # Parasite Egg - Squad Target
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Parasite Egg - Squad Target',
    -- Abilities = ParasiteEggAbilities,
    -- DisableActions = ParasiteEggDisables,
    -- GoalSets = {
        -- SquadKill = true,
    -- },
    -- GoalWeights = {
        -- KillSquadTarget = -5,
    -- },
    -- ForceGoalWeights = true,
    -- TargetTypes = {'HERO'},
    -- UninterruptibleAction = true,
    -- WeightTime = ParasiteEggTime,
    -- ActionFunction = AIAbility.TargetedAbilitySquadTargetFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = AIAbility.TargetedAbilitySquadTargetWeights,
    -- InstantStatusFunction = function(unit, action)
        -- local target = unit.GOAP.AttackTarget

        -- if not target or target:IsDead() then
            -- return false
        -- end

        -- if EntityCategoryContains( categories.GENERAL, target ) then
            -- return AIAbility.DefaultStatusFunction(unit, action)
        -- end

        -- return false
    -- end,
-- }

-- # ------------------------------------------------------------------------------
-- # HEX SCROLL
-- # Use: Weapon damage dealt by the targeted Demigod and their army reduced by 25% for 10 seconds.
-- # ------------------------------------------------------------------------------
-- local HexScrollAbilities = {
    -- 'Item_Consumable_100',
-- }
-- local HexScrollDisables = table.append( DefaultDisables,
    -- {
        -- 'Hex Scroll - Hero',
        -- 'Hex Scroll - Squad Target',
    -- }
-- )
-- local HexScrollTime = 1

-- # ----------------------------
-- # Hex Scroll - Hero
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Hex Scroll - Hero',
    -- Abilities = HexScrollAbilities,
    -- DisableActions = HexScrollDisables,
    -- GoalSets = {
        -- Assassinate = true,
        -- Attack = true,
    -- },
    -- GoalWeights = {
        -- KillHero = -5,
    -- },
    -- ForceGoalWeights = true,
    -- UninterruptibleAction = true,
    -- WeightTime = HexScrollTime,
    -- ActionFunction = AIAbility.TargetedAttackHeroFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = AIAbility.TargetedAttackWeightsHero,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ----------------------------
-- # Hex Scroll - Squad Target
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Hex Scroll - Squad Target',
    -- Abilities = HexScrollAbilities,
    -- DisableActions = HexScrollDisables,
    -- GoalSets = {
        -- SquadKill = true,
    -- },
    -- GoalWeights = {
        -- KillSquadTarget = -5,
    -- },
    -- ForceGoalWeights = true,
    -- TargetTypes = {'HERO'},
    -- UninterruptibleAction = true,
    -- WeightTime = HexScrollTime,
    -- ActionFunction = AIAbility.TargetedAbilitySquadTargetFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = AIAbility.TargetedAbilitySquadTargetWeights,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ------------------------------------------------------------------------------
-- # Warlord's Punisher
-- # Use: Cast a bolt of lightning at the target, dealing 250 damage and arcing to nearby enemies. Demigods struck also lose 400 Mana.
-- # ------------------------------------------------------------------------------
-- local WarlordsPunisherAbilities = {
    -- 'Item_Consumable_130',
-- }
-- local WarlordsPunisherDisables = table.append( DefaultDisables,
    -- {
        -- 'Warlord\'s Punisher - Hero',
        -- 'Warlord\'s Punisher - Squad Target',
    -- }
-- )
-- local WarlordsPunisherTime = 1

-- # ----------------------------
-- # Warlord's Punisher - Hero
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Warlord\'s Punisher - Hero',
    -- Abilities = WarlordsPunisherAbilities,
    -- DisableActions = WarlordsPunisherDisables,
    -- GoalSets = {
        -- Assassinate = true,
        -- Attack = true,
    -- },
    -- GoalWeights = {
        -- KillHero = -3,
    -- },
    -- UninterruptibleAction = true,
    -- WeightTime = WarlordsPunisherTime,
    -- ActionFunction = AIAbility.TargetedAttackHeroFunction,
    -- ActionTimeOut = 5,
    -- CalculateWeights = AIAbility.TargetedAttackWeightsHero,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ----------------------------
-- # Warlord's Punisher - Squad Target
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Warlord\'s Punisher - Squad Target',
    -- Abilities = WarlordsPunisherAbilities,
    -- DisableAction = WarlordsPunisherDisables,
    -- GoalSets = {
        -- SquadKill = true,
    -- },
    -- GoalWeights = {
        -- KillSquadTarget = -5,
    -- },
    -- TargetTypes = {'HERO'},
    -- UninterruptibleAction = true,
    -- WeightTime = WarlordsPunisherTime,
    -- ActionFunction = AIAbility.TargetedAbilitySquadTargetFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = AIAbility.TargetedAbilitySquadTargetWeights,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ------------------------------------------------------------------------------
-- # BRACELET OF RAGE
-- # Use: Nearby allied units gain +200% Weapon Damage for 10 seconds.
-- # ------------------------------------------------------------------------------
-- local BraceletRageAbilities = {
    -- 'Item_Artifact_010',
-- }
-- local BraceletRageDisables = table.append( DefaultDisables,
    -- {
        -- 'Bracelet of Rage',
    -- }
-- )
-- local BraceletRageTime = 1

-- local function BraceletRageMultiplier(ability)
    -- if AIGlobals.AbilityDamage[ability] then
        -- return AIGlobals.AbilityDamage[ability]
    -- end

    -- local damageMult = 1

    -- local abilDef = Ability[ability]
    -- for _,buffName in abilDef.Buffs do
        -- if Buffs[buffName].EntityCategory != 'HERO' then
            -- continue
        -- end

        -- for buffType,buffData in Buffs[buffName].Affects do
            -- if buffType != 'DamageRating' then
                -- continue
            -- end

            -- damageMult = damageMult + buffData.Mult
        -- end
        -- if damageMult == 1 then
            -- WARN('*AI WARNING: Could not find a new damage mult for ability - ' .. ability)
        -- end
    -- end

    -- AIGlobals.AbilityDamage[ability] = damageMult
    -- return damageMult
-- end

-- # ----------------------------
-- # Bracelet of Rage
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Bracelet of Rage',
    -- Abilities = BraceletRageAbilities,
    -- DisableActions = BraceletRageDisables,
    -- GoalSets = {
        -- Assassinate = true,
        -- Attack = true,
        -- DestroyStructures = true,
        -- SquadKill = true,
    -- },
    -- UninterruptibleAction = true,
    -- ActionTimeout = 5,
    -- ActionFunction = AIAbility.InstantActionFunction,
    -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        -- if not agent.WorldStateData.CanUseAbilities then
            -- return false
        -- end

        -- if not AIAbility.TestEnergy( agent, action.Ability ) then
            -- return false
        -- end

        -- agent.DamageRating = BraceletRageMultiplier(action.Ability) * agent.DamageRating

        -- local enemyThreat = aiBrain:GetThreatAtPosition( agent.Position, 1, nil, 'Enemy' )

        -- if enemyThreat >= 15 then
            -- return {}, BraceletRageTime
        -- end

        -- return false
    -- end,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ------------------------------------------------------------------------------
-- # CLOAK OF INVISIBILITY
-- # Use: Turn invisible for 20 seconds.
-- # ------------------------------------------------------------------------------
-- local CloakInvisibilityAbilities = {
    -- 'Item_Artifact_030',
-- }
-- local CloakInvisibilityDisables = table.append( DefaultDisables, AIGlobals.InvisibilityDisables )
-- local CloakInvisibilityTime = 1

-- # ----------------------------
-- # Cloak of Invisibility - Flee
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Cloak of Invisibility - Flee',
    -- Abilities = CloakInvisibilityAbilities,
    -- DisableAction = CloakInvisibilityDisables,
    -- GoalSets = {
        -- Flee = true,
    -- },
    -- GoalWeights = {
        -- Survival = -1,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = AIAbility.InstantActionFunction,
    -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        -- if not agent.WorldStateData.CanUseAbilities then
            -- return false
        -- end

        -- if(action.Ability) then
            -- return {Survival = -1}, CloakInvisibilityTime
        -- else
            -- return false
        -- end
    -- end,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ------------------------------------------------------------------------------
-- # CLOAK OF FLAMES
-- # Use: Cast a ring of fire around yourself, damaging enemies for 600 damage over 10 seconds.
-- # ------------------------------------------------------------------------------
-- local CloakFlamesAbilities = {
    -- 'Item_Artifact_040_2',
-- }
-- local CloakFlamesDisables = table.append( DefaultDisables,
    -- {
        -- 'Cloak of Flames - Hero',
        -- 'Cloak of Flames - Units',
        -- 'Cloak of Flames - Structure',
        -- 'Cloak of Flames - Squad Target',
    -- }
-- )
-- local CloakFlamesTime = 3

-- function CloakFlamesWeights(action, aiBrain, agent, initialAgent)
    -- if not agent.WorldStateData.CanUseAbilities then
        -- return false
    -- end

    -- local actionBp = HeroAIActionTemplates[action.ActionName]
    -- local result = false

    -- if(action.Ability) then
        -- if(actionBp.ThreatType and actionBp.ThreatAmount) then
            -- if(aiBrain:GetThreatAtPosition(agent.Position, 1, actionBp.ThreatType, 'Enemy') > actionBp.ThreatAmount) then
                -- result = true
            -- end
        -- end
        -- if(actionBp.SquadTarget and initialAgent.GOAP.AttackTarget) then
            -- result = true
        -- end
    -- end

    -- if(result) then
        -- return actionBp.GoalWeights, CloakFlamesTime
    -- else
        -- return result
    -- end
-- end

-- # ----------------------------
-- # Cloak of Flames - Hero
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Cloak of Flames - Hero',
    -- Abilities = CloakFlamesAbilities,
    -- DisableActions = CloakFlamesDisables,
    -- GoalSets = {
        -- Assassinate = true,
        -- Attack = true,
    -- },
    -- GoalWeights = {
        -- KillHero = -2,
    -- },
    -- ThreatAmount = 0,
    -- ThreatType = 'Hero',
    -- ActionCategory = 'HERO',
    -- ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    -- ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = CloakFlamesWeights,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ----------------------------
-- # Cloak of Flames - Units
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Cloak of Flames - Units',
    -- Abilities = CloakFlamesAbilities,
    -- DisableActions = CloakFlamesDisables,
    -- GoalSets = {
        -- Attack = true,
    -- },
    -- GoalWeights = {
        -- KillUnits = -5,
    -- },
    -- ThreatAmount = 0,
    -- ThreatType = 'LandNoHero',
    -- ActionCategory = 'GRUNT',
    -- ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    -- ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = CloakFlamesWeights,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ----------------------------
-- # Cloak of Flames - Structure
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Cloak of Flames - Structure',
    -- Abilities = CloakFlamesAbilities,
    -- DisableActions = CloakFlamesDisables,
    -- GoalSets = {
        -- DestroyStructures = true,
    -- },
    -- GoalWeights = {
        -- KillStructures = -5,
    -- },
    -- ThreatAmount = 0,
    -- ThreatType = 'Structures',
    -- ActionCategory = 'STRUCTURE',
    -- ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    -- ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = CloakFlamesWeights,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ----------------------------
-- # Cloak of Flames - Squad Target
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Cloak of Flames - Squad Target',
    -- Abilities = CloakFlamesAbilities,
    -- DisableActions = CloakFlamesDisables,
    -- GoalSets = {
        -- SquadKill = true,
    -- },
    -- GoalWeights = {
        -- KillSquadTarget = -5,
    -- },
    -- SquadTarget = true,
    -- TargetTypes = {'HERO', 'GRUNT', 'STRUCTURE'},
    -- UninterruptibleAction = true,
    -- ActionCategory = 'HERO, GRUNT, STRUCTURE',
    -- ActionCleanupFunction = AIAbility.PointBlankAreaTargetAttackCleanup,
    -- ActionFunction = AIAbility.PointBlankAreaTargetAttackFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = CloakFlamesWeights,
    -- InstantStatusFaction = AIAbility.DefaultStatusFunction,
-- }

-- # ------------------------------------------------------------------------------
-- # CLOAK OF ELFINKIND
-- # Use: Warp to a targeted location.
-- # Item_Artifact_050
-- # ------------------------------------------------------------------------------


-- # ------------------------------------------------------------------------------
-- # UNMAKER
-- # Use: Deal +250% Weapon Damage for 10 seconds.
-- # ------------------------------------------------------------------------------
-- local UnmakerAbilities = {
    -- 'Item_Artifact_060',
-- }
-- local UnmakerDisables = table.append( DefaultDisables,
    -- {
        -- 'Unmaker',
    -- }
-- )

-- local function UnmakerMultiplier(ability)
    -- if AIGlobals.AbilityDamage[ability] then
        -- return AIGlobals.AbilityDamage[ability]
    -- end

    -- local damageMult = 1

    -- local abilDef = Ability[ability]
    -- for _,buffName in abilDef.Buffs do
        -- for buffType,buffData in Buffs[buffName].Affects do
            -- if buffType != 'DamageRating' then
                -- continue
            -- end

            -- damageMult = damageMult + buffData.Mult
        -- end
        -- if damageMult == 1 then
            -- WARN('*AI WARNING: Could not find a new damage mult for ability - ' .. ability)
        -- end
    -- end

    -- AIGlobals.AbilityDamage[ability] = damageMult
    -- return damageMult
-- end

-- # ----------------------------
-- # Unmaker - Hero/Structures
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Unmaker',
    -- Abilities = UnmakerAbilities,
    -- DisableActions = UnmakerDisables,
    -- GoalSets = {
        -- Assassinate = true,
        -- Attack = true,
        -- Defend = true,
        -- DestroyStructures = true,
        -- SquadKill = true,
    -- },
    -- UninterruptibleAction = true,
    -- UnitCutoffThreshold = 1,
    -- ActionTimeout = 5,
    -- ActionFunction = AIAbility.InstantActionFunction,
    -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        -- if not agent.WorldStateData.CanUseAbilities then
            -- return false
        -- end

        -- if not AIAbility.TestEnergy( agent, action.Ability ) then
            -- return false
        -- end

        -- agent.DamageRating = UnmakerMultiplier(action.Ability) * agent.DamageRating

        -- local enemyThreat = aiBrain:GetThreatAtPosition( agent.Position, 1, nil, 'Enemy' )

        -- if enemyThreat >= 15 then
            -- return {}, BraceletRageTime
        -- end

        -- return false
    -- end,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ------------------------------------------------------------------------------
-- # DEATHBRINGER
-- # Use: Silence target, preventing any abilities for 8 seconds.
-- # ------------------------------------------------------------------------------
-- local DeathbringerAbilities = {
    -- 'Item_Artifact_070_Target01',
-- }
-- local DeathbringerDisables = table.append( DefaultDisables,
    -- {
        -- 'Deathbringer - Hero',
        -- 'Deathbringer - Squad Target',
    -- }
-- )
-- local DeathbringerTime = 2

-- # ----------------------------
-- # Deathbringer - Hero
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Deathbringer - Hero',
    -- Abilities = DeathbringerAbilities,
    -- DisableActions = DeathbringerDisables,
    -- GoalSets = {
        -- Assassinate = true,
        -- Attack = true,
    -- },
    -- GoalWeights = {
        -- KillHero = -5,
    -- },
    -- ForceGoalWeights = true,
    -- UninterruptibleAction = true,
    -- WeightTime = DeathbringerTime,
    -- ActionFunction = AIAbility.TargetedAttackHeroFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = AIAbility.TargetedAttackWeightsHero,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ----------------------------
-- # Deathbringer - Squad Target
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Deathbringer - Squad Target',
    -- Abilities = DeathbringerAbilities,
    -- DisableActions = DeathbringerDisables,
    -- GoalSets = {
        -- SquadKill = true,
    -- },
    -- GoalWeights = {
        -- KillSquadTarget = -5,
    -- },
    -- ForceGoalWeights = true,
    -- TargetTypes = {'HERO'},
    -- UninterruptibleAction = true,
    -- WeightTime = DeathbringerTime,
    -- ActionFunction = AIAbility.TargetedAbilitySquadTargetFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = AIAbility.TargetedAbilitySquadTargetWeights,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ------------------------------------------------------------------------------
-- # ORB OF VEILED STORMS
-- # Use: Unleash a wave of pure force in an area, dealing 500 damage.
-- # ------------------------------------------------------------------------------
-- local VeiledStormsAbilities = {
    -- 'Item_Artifact_110',
-- }
-- local VeiledStormsDisables = table.append( DefaultDisables,
    -- {
        -- 'Orb of Veiled Storms - Hero',
        -- 'Orb of Veiled Storms - Units',
        -- 'Orb of Veiled Storms - Structure',
        -- 'Orb of Veiled Storms - Squad Target',
    -- }
-- )
-- local VeiledStormsTime = 3

-- function VeiledStormsWeights(action, aiBrain, agent, initialAgent)
    -- if not agent.WorldStateData.CanUseAbilities then
        -- return false
    -- end

    -- local actionBp = HeroAIActionTemplates[action.ActionName]
    -- local result = false

    -- if(action.Ability) then
        -- if(actionBp.ThreatType and actionBp.ThreatAmount) then
            -- if(aiBrain:GetThreatAtPosition(agent.Position, 1, actionBp.ThreatType, 'Enemy') > actionBp.ThreatAmount) then
                -- result = true
            -- end
        -- end
        -- if(actionBp.SquadTarget and initialAgent.GOAP.AttackTarget) then
            -- result = true
        -- end
    -- end

    -- if(result) then
        -- return actionBp.GoalWeights, VeiledStormsTime
    -- else
        -- return result
    -- end
-- end

-- # ----------------------------
-- # Orb of Veiled Storms - Hero
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Orb of Veiled Storms - Hero',
    -- Abilities = VeiledStormsAbilities,
    -- DisableActions = VeiledStormsDisables,
    -- GoalSets = {
        -- Assassinate = true,
        -- Attack = true,
    -- },
    -- GoalWeights = {
        -- KillHero = -3,
    -- },
    -- ThreatAmount = 0,
    -- ThreatType = 'Hero',
    -- UnitCutoffThreshold = 1,
    -- ActionCategory = 'HERO',
    -- ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    -- ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = VeiledStormsWeights,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ----------------------------
-- # Orb of Veiled Storms - Units
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Orb of Veiled Storms - Units',
    -- Abilities = VeiledStormsAbilities,
    -- DisableActions = VeiledStormsDisables,
    -- GoalSets = {
        -- Attack = true,
        -- Defend = true,
    -- },
    -- GoalWeights = {
        -- KillUnits = -5,
    -- },
    -- ThreatAmount = 15,
    -- ThreatType = 'LandNoHero',
    -- UnitCutoffThreshold = 1,
    -- ActionCategory = 'GRUNT',
    -- ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    -- ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = VeiledStormsWeights,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ----------------------------
-- # Orb of Veiled Storms - Structure
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Orb of Veiled Storms - Structure',
    -- Abilities = VeiledStormsAbilities,
    -- DisableActions = VeiledStormsDisables,
    -- GoalSets = {
        -- DestroyStructures = true,
    -- },
    -- GoalWeights = {
        -- KillStructures = -5,
    -- },
    -- ThreatAmount = 0,
    -- ThreatType = 'Structures',
    -- UnitCutoffThreshold = 1,
    -- ActionCategory = 'STRUCTURE',
    -- ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    -- ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = VeiledStormsWeights,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ----------------------------
-- # Orb of Veiled Storms - Squad Target
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Orb of Veiled Storms - Squad Target',
    -- Abilities = VeiledStormsAbilities,
    -- DisableActions = VeiledStormsDisables,
    -- GoalSets = {
        -- SquadKill = true,
    -- },
    -- GoalWeights = {
        -- KillSquadTarget = -5,
    -- },
    -- SquadTarget = true,
    -- TargetTypes = {'STRUCTURE', 'HERO', 'GRUNT'},
    -- ActionCategory = 'STRUCTURE, HERO, GRUNT',
    -- ActionCleanupFunction = AIAbility.PointBlankAreaTargetAttackCleanup,
    -- ActionFunction = AIAbility.PointBlankAreaTargetAttackFunction,
    -- ActionTimeout = 5,
    -- CalculateWeights = VeiledStormsWeights,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

-- # ------------------------------------------------------------------------------
-- # MINIONS
-- # ------------------------------------------------------------------------------
# -- function SummonMinionWeights(action, aiBrain, agent, initialAgent)
    # -- if not agent.WorldStateData.CanUseAbilities then
        # -- return false
    # -- end

    # -- local result = false
    # -- local actionBp = HeroAIActionTemplates[action.ActionName]

    # -- if(action.Ability) then
        # -- if(AIAbility.TestEnergy(agent, action.Ability)) then
            # -- result = true
        # -- end
    # -- end

    # -- if(result) then
        # -- return actionBp.GoalWeights, Ability[action.Ability].CastingTime
    # -- else
        # -- return result
    # -- end
# -- end

function SummonMinionStatusFunction(unit, action)
    if not AIAbility.DefaultStatusFunction(unit, action) then
        return false
    end


	
    if unit:GetHealthPercent() < 0.5 then # and unit.GOAP.NearbyEnemyHeroes and unit.GOAP.NearbyEnemyHeroes.ClosestDistance < 5 
        return false
    end
        

    local actionBp = HeroAIActionTemplates[action.ActionName]
    local abilBp = Ability[action.Ability]
    local minionCategory = ParseEntityCategory( actionBp.MinionCategory )
	# -- WARN('Minion Category = ' .. minionCategory )
	# -- if minionCategory == 'HIGHPRIEST' then
	 # -- #highpriest01 do stuff
	# -- end
	
	
    if unit:GetAIBrain():GetCurrentUnits( minionCategory ) < abilBp.MaxUnits then
        return true
    else
        return false
    end
end

-- # ----------------------------
-- # Summon Minotaur Captain
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Summon Minotaur Captain',
    -- Abilities = {
        -- 'Item_Minotaur_Captain_040',
        -- 'Item_Minotaur_Captain_030',
        -- 'Item_Minotaur_Captain_020',
        -- 'Item_Minotaur_Captain_010',
    -- },
    -- MinionCategory = 'MINOCAPTAIN',
    -- DisableAction = DefaultDisables,
    -- GoalSets = {
        -- Assassinate = true,
        -- SquadKill = true,
        -- Attack = true,
        -- MakeItemPurchases = false,
        -- CapturePoint = true,
        -- Flee = false,
        -- SquadMove = true,
        -- DestroyStructures = true,
        -- WaitMasterGoal = true,
    -- },
    -- GoalWeights = {
        -- KillHero = -3,
        -- KillStructures = -1,
        -- KillUnits = -5,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = AIAbility.InstantActionFunction,
    -- CalculateWeights = SummonMinionWeights,
    -- InstantStatusFunction = SummonMinionStatusFunction,
-- }

-- # ----------------------------
-- # Summon Siege Archer
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Summon Siege Archer',
    -- Abilities = {
        -- 'Item_Siege_Archer_040',
        -- 'Item_Siege_Archer_030',
        -- 'Item_Siege_Archer_020',
        -- 'Item_Siege_Archer_010',
    -- },
    -- MinionCategory = 'SIEGEARCHER',
    -- DisableAction = DefaultDisables,
    -- GoalSets = {
        -- Assassinate = true,
        -- SquadKill = true,
        -- Attack = true,
        -- MakeItemPurchases = false,
        -- CapturePoint = true,
        -- Flee = false,
        -- SquadMove = true,
        -- DestroyStructures = true,
        -- WaitMasterGoal = true,
    -- },
    -- GoalWeights = {
        -- KillHero = -3,
        -- KillStructures = -5,
        -- KillUnits = -1,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = AIAbility.InstantActionFunction,
    -- CalculateWeights = SummonMinionWeights,
    -- InstantStatusFunction = SummonMinionStatusFunction,
-- }

-- # ----------------------------
-- # Summon High Priest
-- # ----------------------------
-- HeroAIActionTemplate {
    -- Name = 'Summon High Priest',
    -- Abilities = {
        -- 'Item_High_Priest_040',
        -- 'Item_High_Priest_030',
        -- 'Item_High_Priest_020',
        -- 'Item_High_Priest_010',
    -- },
    -- MinionCategory = 'HIGHPRIEST',
    -- DisableAction = DefaultDisables,
    -- GoalSets = {
        -- Assassinate = true,
        -- SquadKill = true,
        -- Attack = true,
        -- MakeItemPurchases = false,
        -- CapturePoint = true,
        -- Flee = false,
        -- SquadMove = true,
        -- DestroyStructures = true,
        -- WaitMasterGoal = true,
    -- },
    -- GoalWeights = {
        -- KillHero = -5,
        -- KillStructures = -1,
        -- KillUnits = -3,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = AIAbility.InstantActionFunction,
    -- CalculateWeights = SummonMinionWeights,
    -- InstantStatusFunction = SummonMinionStatusFunction,
-- }
