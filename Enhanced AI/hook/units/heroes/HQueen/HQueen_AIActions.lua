# -- local ValidateAbility = import('/lua/common/ValidateAbility.lua')
# -- local AIUtils = import('/lua/sim/ai/aiutilities.lua')
# -- local AIAbility = import('/lua/sim/ai/AIAbilityUtilities.lua')
# -- local AIGlobals = import('/lua/sim/ai/AIGlobals.lua')
# -- local Buff = import('/lua/sim/Buff.lua')

# -- local DefaultDisables = AIGlobals.DefaultDisables

# -- local PackedAbilities = {
    # -- 'Packed',
    # -- 'Unpacked',
    # -- 'Shambler',
    # -- 'Mulch Shambler',
    # -- 'Shield - Self',
    # -- 'Shield - Friendly Hero',
# -- }

# -- local UnpackedAbilities = {
    # -- 'Packed',
    # -- 'Unpacked',
    # -- 'Ground Spikes - Hero',
    # -- 'Ground Spikes - Units',
    # -- 'Ground Spikes - Structures',
    # -- 'Ground Spikes - Squad Target',
    # -- 'Spike Wave - Hero',
    # -- 'Spike Wave - Units',
    # -- 'Spike Wave - Structures',
    # -- 'Spike Wave - Squad Target',
    # -- 'Uproot - Structures',
    # -- 'Uproot - Squad Target',
# -- }

----------------------------------------------------------------------------
# -- # PACKED
----------------------------------------------------------------------------
# -- local PackedDisables = table.append( DefaultDisables, UnpackedAbilities )
# -- local PackedTime = 1.9

HeroAIActionTemplates['Packed'] =  {
    Name = 'Packed',
    UnitId = 'hqueen',
    Abilities = {'HQueenPack'},
    DisableActions = PackedDisables,
    GoalSets = {
		# -- All = true,
        Assassinate = false,
        DestroyStructures = true,
		Flee = true,
		SquadMove = true,
		WaitMasterGoal = true,
		CapturePoint = true,
		MakeItemPurchases = true,

        # -- Attack = true,
        # -- Defend = true,

        SquadKill = true,
    },
    UninterruptibleAction = true,
    ActionFunction = function(unit,action)
        AIAbility.InstantActionFunction(unit,action)

        while not Buff.HasBuff(unit, 'HQueenPackedWeaponDisable') do
            WaitTicks(1)
        end

        return true
    end,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        local result = false

        if(not agent.WorldStateData.Packed and agent.WorldStateData.CanUseAbilities) then
            if(action.Ability) then
                if(initialAgent:GetHealthPercent() >= 0.2) then
                    result = true
                end
				
				if agent.GOAP.NearbyEnemyHeroes and agent.GOAP.NearbyEnemyHeroes.ClosestDistance <= 15 then
					result = false
				end				
				
				local allies = aiBrain:GetUnitsAroundPoint(categories.HERO, initialAgent.Position, 30, 'Ally')
				for k, v in allies do
					if v:GetHealthPercent() < 0.6   then
						result = true
						break
					end
				end		
				
				
            end
        end

        if(result == true) then
            agent.WorldStateData.Packed = true
            agent.WorldStateConsistent = false
            return {Survival = -5, SupportAlly = -5}, PackedTime
        else
            return result
        end
    end,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

----------------------------------------------------------------------------
# -- # SHAMBLER
----------------------------------------------------------------------------
# -- local ShamblerAbilities = {
    # -- 'HQueenShambler01',
    # -- 'HQueenShambler02',
    # -- 'HQueenShambler03',
    # -- 'HQueenShambler04',
# -- }
# -- local ShamblerCastTime = 2
# -- local ShamblerDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Shambler',
    # -- }
# -- )

--------------------------
# -- # Shambler
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Shambler',
    # -- UnitId = 'hqueen',
    # -- Abilities = ShamblerAbilities,
    # -- DisableActions = ShamblerDisables,
    # -- GoalSets = {
        # -- Assassinate = true,
        # -- SquadKill = true,
        # -- Attack = true,
        # -- MakeItemPurchases = false,
        # -- CapturePoint = true,
        # -- Flee = false,
        # -- SquadMove = true,
        # -- DestroyStructures = true,
        # -- WaitMasterGoal = true,
    # -- },
    # -- UninterruptibleAction = true,
    # -- UnitCutoffThreshold = 1,
    # -- WeightTime = ShamblerCastTime,
    # -- ActionFunction = AIAbility.InstantActionFunction,
    # -- InstantTimeout = 5,
    # -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        # -- local killHero = -5
        # -- local killUnits = -3
        # -- local killStructures = -3
        # -- local result = false

        # -- if(agent.WorldStateData.CanUseAbilities and agent.WorldStateData.Packed and action.Ability) then
            # -- if(AIAbility.TestEnergy(agent, action.Ability)) then
                # -- result = true

                # -- # See if heroes are nearby
                # -- if(aiBrain:GetThreatAtPosition(agent.Position, 1, 'Hero') > 0) then
                    # -- killHero = -7
                # -- end

                # -- # See if grunts are nearby
                # -- if(aiBrain:GetThreatAtPosition(agent.Position, 1, 'LandNoHero') > 15) then
                    # -- killUnits = -5
                # -- end

                # -- # See if structures are nearby
                # -- if(aiBrain:GetThreatAtPosition(agent.Position, 1, 'Structures') > 0) then
                    # -- killStructures = -5
                # -- end
            # -- end
        # -- end

        # -- if(result == true) then
            # -- return {KillHero = killHero, KillStructures = killStructures, KillUnits = killUnits}, ShamblerCastTime
        # -- else
            # -- return result
        # -- end
    # -- end,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }

----------------------------------------------------------------------------
# -- # MULCH
----------------------------------------------------------------------------
# -- local MulchAbilities = {
    # -- 'HQueenConsumeShambler01',
    # -- 'HQueenConsumeShambler02',
    # -- 'HQueenConsumeShambler03',
# -- }
# -- local MulchDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Mulch Shambler',
    # -- }
# -- )
# -- local MulchTime = 2

--------------------------
# -- # Mulch Shambler
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Mulch Shambler',
    # -- UnitId = 'hqueen',
    # -- Abilities = MulchAbilities,
    # -- DisableActions = MulchDisables,
    # -- GoalSets = {
        # -- All = true,
    # -- },
    # -- UninterruptibleAction = true,
    # -- ActionFunction = function(unit, action)
        # -- local actionBp = HeroAIActionTemplates[action.ActionName]
        # -- local aiBrain = unit:GetAIBrain()

        # -- # Find the weakest Shambler to Mulch
        # -- local shamblers = aiBrain:GetUnitsAroundPoint(categories.ENT, unit:GetPosition(), 15, 'Ally')
        # -- local target = nil
        # -- local targetPercent = 1.1
        # -- if(table.getn(shamblers) > 0) then
            # -- for k, v in shamblers do
                # -- local healthPercent = v:GetHealthPercent()
                # -- if(healthPercent < targetPercent) then
                    # -- target = v
                    # -- targetPercent = healthPercent
                # -- end
            # -- end
        # -- end

        # -- if(target) then
            # -- return AIAbility.TargetedActionFunction(unit, action, target, actionBp.ActionTimeout)
        # -- end
    # -- end,
    # -- ActionTimeout = 5,
    # -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        # -- local result = false

        # -- if(agent.WorldStateData.CanUseAbilities and agent.WorldStateData.Packed) then
            # -- # If health is less than 40% or mana is less than 20%
            # -- if(initialAgent:GetHealthPercent() <= .4 or initialAgent:GetEnergyPercent() <= .2) then
                # -- result = true
            # -- end

            # -- if(result) then
                # -- # Make sure there are Shamblers to mulch
                # -- local shamblers = aiBrain:GetUnitsAroundPoint(categories.ENT, initialAgent:GetPosition(), 15, 'Ally')
                # -- if(table.getn(shamblers) > 0) then
                    # -- result = true
                # -- else
                    # -- result = false
                # -- end
            # -- else
                # -- # If health is less than 80% or mana is less than 80%
                # -- if(initialAgent:GetHealthPercent() <= .8 or initialAgent:GetEnergyPercent() <= .8) then
                    # -- # If there is a weak Shambler, sacrifice it
                    # -- local shamblers = aiBrain:GetUnitsAroundPoint(categories.ENT, initialAgent:GetPosition(), 15, 'Ally')
                    # -- if(table.getn(shamblers) > 0) then
                        # -- for k, v in shamblers do
                            # -- if(v:GetHealthPercent() <= .25) then
                                # -- result = true
                                # -- break
                            # -- end
                        # -- end
                    # -- end
                # -- end
            # -- end
        # -- end

        # -- if(result) then
            # -- return {Health = -5, Energy = -5, Survival = -5}, MulchTime
        # -- else
            # -- return result
        # -- end
    # -- end,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }

----------------------------------------------------------------------------
# -- # BRAMBLE SHIELD
----------------------------------------------------------------------------
# -- local ShieldAbilities = {
    # -- 'HQueenBrambleShield01',
    # -- 'HQueenBrambleShield02',
    # -- 'HQueenBrambleShield03',
    # -- 'HQueenBrambleShield04',
# -- }
# -- local ShieldCastTime = 1
# -- local ShieldDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Bramble Shield - Self',
        # -- 'Bramble Shield - Friendly Hero',
    # -- }
# -- )

--------------------------
# -- # Bramble Shield - Self
--------------------------
HeroAIActionTemplates['Bramble Shield - Self'] = {
    Name = 'Bramble Shield - Self',
    UnitId = 'hqueen',
    Abilities = ShieldAbilities,
    DisableActions = ShieldDisables,
    GoalSets = {
        All = true,
    },
    UninterruptibleAction = true,
    ActionFunction = AIAbility.TargetedSelfHeroFunction,
    ActionTimeout = 5,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        local result = false

        if(agent.WorldStateData.CanUseAbilities and agent.WorldStateData.Packed) then
            if(action.Ability) then
                if(AIAbility.TestEnergy(agent, action.Ability)) then
					local allies =  aiBrain:GetUnitsAroundPoint(categories.HERO, agent.Position, 20, 'Ally')
					local enemies = aiBrain:GetThreatAtPosition(agent.Position, 2, 'Hero', 'Enemy') 
					local towerThreat = aiBrain:GetThreatAtPosition(agent.Position, 2, 'Structures', 'Enemy' )

					if (enemies > 0 or towerThreat > 0) and (not initialAgent.Absorption or initialAgent.Absorption < 500) and table.getn(allies) == 0 then
						result = true
					end
				end
            end
        end

        if(result == true) then
			#WARN('Use Shield' .. tostring(initialAgent.Absorption) )
            return {Health = -10, Survival = -10, KillHero = -5}, ShieldCastTime
        else
            return result
        end
    end,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

--------------------------
# -- # Bramble Shield - Friendly Hero
--------------------------
HeroAIActionTemplates['Bramble Shield - Friendly Hero'] = {
    Name = 'Bramble Shield - Friendly Hero',
    UnitId = 'hqueen',
    Abilities = ShieldAbilities,
    DisableActions = ShieldDisables,
    GoalSets = {
        All = true,
    },
    UninterruptibleAction = true,
    ActionFunction = AIAbility.TargetedWeakFriendHeroFunction,
    ActionTimeout = 5,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        local result = false

        if(agent.WorldStateData.CanUseAbilities and agent.WorldStateData.Packed) then
            if(action.Ability) then
                if(AIAbility.TestEnergy(agent, action.Ability)) then
						result = true
                end
            end
        end

        if(result) then
            return {SupportAlly = -20, Health = -10, Survival = -10, KillHero = -5}, ShieldCastTime
        else
            return false
        end
    end,
    InstantStatusFunction = function(unit, action)
        local result = false

        if(AIAbility.DefaultStatusFunction(unit, action)) then
			local aiBrain =  unit:GetAIBrain()
            local allies =  aiBrain:GetUnitsAroundPoint(categories.HERO, unit.Position, 20, 'Ally')
			# -- local enemies = aiBrain:GetThreatAtPosition(unit.Position, 2, 'Hero', 'Enemy') 
			# -- local towerThreat = aiBrain:GetThreatAtPosition(unit.Position, 2, 'Structures', 'Enemy' )
			
			local statueDistance = unit.GOAP.BrainAsset:GetDistance( 'HEALTHSTATUE', 'Ally' )
			if statueDistance < 30 and table.getn(allies) > 0  then
				#WARN('Spam Shield at health stone')
				result = true
			else
				# -- if (enemies > 0 or towerThreat > 0) then
					for k, v in allies do
						if v != unit and (not v.Absorption or v.Absorption < 500) then # and v:GetHealthPercent() < 0.75 
							#WARN('Use Shield Ally - ' .. tostring(v.Absorption) )
							result = true
							break
						end
					end
				# -- end
			end
        end

        return result
    end,
}

----------------------------------------------------------------------------
# -- # UNPACKED
----------------------------------------------------------------------------
# -- local UnpackedDisables = table.append( DefaultDisables, PackedAbilities )
# -- local UnpackedTime = 1.9

HeroAIActionTemplates['Unpacked'] = {
    Name = 'Unpacked',
    UnitId = 'hqueen',
    Abilities = {'HQueenUnpack'},
    DisableActions = UnpackedDisables,
    GoalSets = {
        #All = true,
		
		Assassinate = true,
        Attack = true,
        Defend = true,
		CarefulAttack = true,
		MoveToFriendly = true,
        # -- DestroyStructures = true,
        SquadKill = true,
    },
    UninterruptibleAction = true,
    ActionFunction = function(unit,action)
        AIAbility.InstantActionFunction(unit,action)

        while not Buff.HasBuff(unit, 'HQueenPrimaryWeaponDisable') do
            WaitTicks(1)
        end

        return true
    end,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        local result = false

        if(agent.WorldStateData.CanUseAbilities and agent.WorldStateData.Packed) then
            if(action.Ability) then
                if(initialAgent:GetHealthPercent() >= 0.4) then
                    result = true
                end
            end
        end

        if(result == true) then
            agent.WorldStateData.Packed = false
            agent.WorldStateConsistent = false
            return {  AttackWithHelp = -5, KillUnits = -5 , KillHero = -5 }, PackedTime
        else
            return result
        end
    end,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

----------------------------------------------------------------------------
# -- # GROUND SPIKES
----------------------------------------------------------------------------
# -- GroundSpikesAbilities = {
    # -- 'HQueenGroundSpikes01',
    # -- 'HQueenGroundSpikes02',
    # -- 'HQueenGroundSpikes03',
    # -- 'HQueenGroundSpikes04',
# -- }
# -- GroundSpikesCastTime = 1.5
# -- GroundSpikesDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Ground Spikes - Hero',
        # -- 'Ground Spikes - Units',
        # -- 'Ground Spikes - Structures',
        # -- 'Ground Spikes - Squad Target',
    # -- }
# -- )

# -- function GroundSpikesWeights(action, aiBrain, agent, initialAgent)
    # -- local actionBp = HeroAIActionTemplates[action.ActionName]
    # -- local result = false

    # -- if(agent.WorldStateData.CanUseAbilities and not agent.WorldStateData.Packed) then
        # -- if(action.Ability) then
            # -- if(AIAbility.TestEnergy(agent, action.Ability)) then
                # -- if(actionBp.ThreatAmount and actionBp.ThreatType and (aiBrain:GetThreatAtPosition(agent.Position, 1, actionBp.ThreatType, 'Enemy') > actionBp.ThreatAmount)) then
                    # -- result = true
                # -- end
                # -- if(actionBp.SquadTarget and initialAgent.GOAP.AttackTarget) then
                    # -- result = true
                # -- end
            # -- end
        # -- end
    # -- end

    # -- if(result == true) then
        # -- return actionBp.GoalWeights, GroundSpikesCastTime
    # -- else
        # -- return false
    # -- end
# -- end

--------------------------
# -- # Ground Spikes - Hero
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Ground Spikes - Hero',
    # -- UnitId = 'hqueen',
    # -- Abilities = GroundSpikesAbilities,
    # -- DisableActions = GroundSpikesDisables,
    # -- GoalSets = {
        # -- Assassinate = true,
        # -- Attack = true,
    # -- },
    # -- GoalWeights = {
        # -- KillHero = -4,
    # -- },
    # -- ThreatAmount = 0,
    # -- ThreatType = 'Hero',
    # -- UninterruptibleAction = true,
    # -- UnitCutoffThreshold = 1,
    # -- WeightTime = GroundSpikesCastTime,
    # -- ActionCategory = 'HERO',
    # -- ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    # -- ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    # -- ActionTimeout = 5,
    # -- CalculateWeights = GroundSpikesWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }

--------------------------
# -- # Ground Spikes - Units
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Ground Spikes - Units',
    # -- UnitId = 'hqueen',
    # -- Abilities = GroundSpikesAbilities,
    # -- DisableActions = GroundSpikesDisables,
    # -- GoalSets = {
        # -- Attack = true,
        # -- Defend = true,
    # -- },
    # -- GoalWeights = {
        # -- KillUnits = -4,
    # -- },
    # -- ThreatAmount = 5,
    # -- ThreatType = 'LandNoHero',
    # -- UnitCutoffThreshold = 4,
    # -- UninterruptibleAction = true,
    # -- WeightTime = GroundSpikesCastTime,
    # -- ActionCategory = 'GRUNT',
    # -- ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    # -- ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    # -- ActionTimeout = 5,
    # -- CalculateWeights = GroundSpikesWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }

--------------------------
# -- # Ground Spikes - Structures
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Ground Spikes - Structures',
    # -- UnitId = 'hqueen',
    # -- Abilities = GroundSpikesAbilities,
    # -- DisableActions = GroundSpikesDisables,
    # -- GoalSets = {
        # -- DestroyStructures = true,
    # -- },
    # -- GoalWeights = {
        # -- KillStructures = -3,
    # -- },
    # -- ThreatAmount = 0,
    # -- ThreatType = 'Structures',
    # -- UnitCutoffThreshold = 1,
    # -- UninterruptibleAction = true,
    # -- WeightTime = GroundSpikesCastTime,
    # -- ActionCategory = 'STRUCTURE',
    # -- ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    # -- ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    # -- ActionTimeout = 5,
    # -- CalculateWeights = GroundSpikesWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }

--------------------------
# -- # Ground Spikes - Squad Target
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Ground Spikes - Squad Target',
    # -- UnitId = 'hqueen',
    # -- Abilities = GroundSpikesAbilities,
    # -- DisableActions = GroundSpikesDisables,
    # -- GoalSets = {
        # -- SquadKill = true,
    # -- },
    # -- GoalWeights = {
        # -- KillSquadTarget = -4,
    # -- },
    # -- SquadTarget = true,
    # -- TargetTypes = {'STRUCTURE', 'HERO', 'MOBILE'},
    # -- UninterruptibleAction = true,
    # -- WeightTime = GroundSpikesCastTime,
    # -- ActionCategory = 'STRUCTURE, HERO, GRUNT',
    # -- ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    # -- ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    # -- ActionTimeout = 5,
    # -- CalculateWeights = GroundSpikesWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }

----------------------------------------------------------------------------
# -- # SPIKE WAVE
----------------------------------------------------------------------------
# -- local SpikeWaveAbilities = {
    # -- 'HQueenSpikeWave01',
    # -- 'HQueenSpikeWave02',
    # -- 'HQueenSpikeWave03',
# -- }
# -- local SpikeWaveCastTime = 0.4
# -- local SpikeWaveDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Spike Wave - Hero',
        # -- 'Spike Wave - Units',
        # -- 'Spike Wave - Structures',
        # -- 'Spike Wave - Squad Target',
    # -- }
# -- )

# -- function SpikeWaveWeights(action, aiBrain, agent, initialAgent)
    # -- local actionBp = HeroAIActionTemplates[action.ActionName]
    # -- local result = false

    # -- if(agent.WorldStateData.CanUseAbilities and not agent.WorldStateData.Packed) then
        # -- if(action.Ability) then
            # -- if(AIAbility.TestEnergy(agent, action.Ability)) then
                # -- if(actionBp.ThreatAmount and actionBp.ThreatType and (aiBrain:GetThreatAtPosition(agent.Position, 1, actionBp.ThreatType, 'Enemy') > actionBp.ThreatAmount)) then
                    # -- result = true
                # -- end
                # -- if(actionBp.SquadTarget and initialAgent.GOAP.AttackTarget) then
                    # -- result = true
                # -- end
            # -- end
        # -- end
    # -- end

    # -- if(result == true) then
        # -- return actionBp.GoalWeights, SpikeWaveCastTime
    # -- else
        # -- return false
    # -- end
# -- end

--------------------------
# -- # Spike Wave - Hero
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Spike Wave - Hero',
    # -- UnitId = 'hqueen',
    # -- Abilities = SpikeWaveAbilities,
    # -- DisableActions = SpikeWaveDisables,
    # -- GoalSets = {
        # -- Assassinate = true,
        # -- Attack = true,
    # -- },
    # -- GoalWeights = {
        # -- KillHero = -4,
    # -- },
    # -- ThreatAmount = 0,
    # -- ThreatType = 'Hero',
    # -- UninterruptibleAction = true,
    # -- WeightTime = SpikeWaveCastTime,
    # -- ActionCategory = 'HERO',
    # -- ActionFunction = AIAbility.TargetedAreaAttackAbility,
    # -- ActionTimeout = 5,
    # -- CalculateWeights = SpikeWaveWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }

--------------------------
# -- # Spike Wave - Units
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Spike Wave - Units',
    # -- UnitId = 'hqueen',
    # -- Abilities = SpikeWaveAbilities,
    # -- DisableActions = SpikeWaveDisables,
    # -- GoalSets = {
        # -- Attack = true,
        # -- Defend = true,
    # -- },
    # -- GoalWeights = {
        # -- KillUnits = -4,
    # -- },
    # -- ThreatAmount = 10,
    # -- ThreatType = 'LandNoHero',
    # -- UninterruptibleAction = true,
    # -- WeightTime = SpikeWaveCastTime,
    # -- ActionCategory = 'GRUNT',
    # -- ActionFunction = AIAbility.TargetedAreaAttackAbility,
    # -- ActionTimeout = 5,
    # -- CalculateWeights = SpikeWaveWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }

--------------------------
# -- # Spike Wave - Structures
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Spike Wave - Structures',
    # -- UnitId = 'hqueen',
    # -- Abilities = SpikeWaveAbilities,
    # -- DisableActions = SpikeWaveDisables,
    # -- GoalSets = {
        # -- DestroyStructures = true,
    # -- },
    # -- GoalWeights = {
        # -- KillStructures = -3,
    # -- },
    # -- ThreatAmount = 0,
    # -- ThreatType = 'Structures',
    # -- UninterruptibleAction = true,
    # -- WeightTime = SpikeWaveCastTime,
    # -- ActionCategory = 'STRUCTURE',
    # -- ActionFunction = AIAbility.TargetedAreaAttackAbility,
    # -- ActionTimeout = 5,
    # -- CalculateWeights = SpikeWaveWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }

--------------------------
# -- # Spike Wave - Squad Target
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Spike Wave - Squad Target',
    # -- UnitId = 'hqueen',
    # -- Abilities = SpikeWaveAbilities,
    # -- DisableActions = SpikeWaveDisables,
    # -- GoalSets = {
        # -- SquadKill = true,
    # -- },
    # -- GoalWeights = {
        # -- KillSquadTarget = -4,
    # -- },
    # -- SquadTarget = true,
    # -- TargetTypes = {'STRUCTURE', 'HERO', 'MOBILE'},
    # -- UninterruptibleAction = true,
    # -- WeightTime = SpikeWaveCastTime,
    # -- ActionCategory = 'HERO, GRUNT, STRUCTURE',
    # -- ActionFunction = AIAbility.TargetedAreaAttackAbility,
    # -- ActionTimeout = 5,
    # -- CalculateWeights = SpikeWaveWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }

----------------------------------------------------------------------------
# -- # UPROOT
----------------------------------------------------------------------------
# -- local UprootAbilities = {
    # -- 'HQueenUproot01',
    # -- 'HQueenUproot02',
    # -- 'HQueenUproot03',
    # -- 'HQueenUproot04',
# -- }
# -- local UprootCastTime = 1.5
# -- local UprootDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Uproot - Structures',
        # -- 'Uproot - Squad Target',
    # -- }
# -- )
# -- function UprootWeights(action, aiBrain, agent, initialAgent)
    # -- local actionBp = HeroAIActionTemplates[action.ActionName]
    # -- local result = false

    # -- if(agent.WorldStateData.CanUseAbilities and not agent.WorldStateData.Packed) then
        # -- if(action.Ability) then
            # -- if(AIAbility.TestEnergy(agent, action.Ability)) then
                # -- if(aiBrain:GetThreatAtPosition(agent.Position, 1, 'Structures', 'Enemy') > 0) then
                    # -- result = true
                # -- end
                # -- if(actionBp.SquadTarget and initialAgent.GOAP.AttackTarget) then
                    # -- result = true
                # -- end
            # -- end
        # -- end
    # -- end

    # -- if(result == true) then
        # -- return actionBp.GoalWeights, UprootCastTime
    # -- else
        # -- return false
    # -- end
# -- end

--------------------------
# -- # Uproot - Structures
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Uproot - Structures',
    # -- UnitId = 'hqueen',
    # -- Abilities = UprootAbilities,
    # -- DisableActions = UprootDisables,
    # -- GoalSets = {
        # -- DestroyStructures = true,
    # -- },
    # -- GoalWeights = {
        # -- KillStructures = -10,
    # -- },
    # -- UninterruptibleAction = true,
    # -- WeightTime = UprootCastTime,
    # -- ActionFunction = AIAbility.TargetedAttackDefenseFunction,
    # -- ActionTimeout = 5,
    # -- CalculateWeights = UprootWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }

--------------------------
# -- # Uproot - Squad Target
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Uproot - Squad Target',
    # -- UnitId = 'hqueen',
    # -- Abilities = UprootAbilities,
    # -- DisableActions = UprootDisables,
    # -- GoalSets = {
        # -- SquadKill = true,
    # -- },
    # -- GoalWeights = {
        # -- KillSquadTarget = -10,
    # -- },
    # -- SquadTarget = true,
    # -- UninterruptibleAction = true,
    # -- WeightTime = UprootCastTime,
    # -- ActionFunction = AIAbility.TargetedAttackDefenseFunction,
    # -- ActionTimeout = 5,
    # -- CalculateWeights = UprootWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }
# 0.26.41 - Added code from miriyaka. This calls the new summon function in AIAbilityUtilities and keeps the DG
# from summoning additional shamblers/yeti/orbs if they are already maxed.
    HeroAIActionTemplates.Shambler.InstantStatusFunction = AIAbility.SummonStatusFunction
    HeroAIActionTemplates.Shambler.ActionFunction = AIAbility.SummonActionFunction