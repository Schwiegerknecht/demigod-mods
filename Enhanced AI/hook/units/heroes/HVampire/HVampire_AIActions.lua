# -- local ValidateAbility = import('/lua/common/ValidateAbility.lua')
# -- local AIUtils = import('/lua/sim/ai/aiutilities.lua')
# -- local AIAbility = import('/lua/sim/ai/AIAbilityUtilities.lua')
# -- local GetReadyAbility = AIAbility.GetReadyAbility
# -- local Buff = import('/lua/sim/Buff.lua')
# -- local AIGlobals = import('/lua/sim/ai/AIGlobals.lua')

# -- local DefaultDisables = import('/lua/sim/ai/AIGlobals.lua').DefaultDisables


# -- # ===================================================================
# -- # Mass Charm
# -- # ===================================================================
# -- # Charm Variables
# -- local CharmCastTime = 2.0

# -- local CharmAbilities = {
    # -- 'HVampireMassCharm01',
    # -- 'HVampireMassCharm02',
    # -- 'HVampireMassCharm03',
    # -- 'HVampireMassCharm04',
# -- }

# -- local CharmDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Charm - Hero',
        # -- 'Charm - Units',
        # -- 'Charm - Squad Target',
    # -- }
# -- )

# -- # Charm Functions
HeroAIActionTemplates['Charm - Hero'] = {
    Name = 'Charm - Hero',
    UnitId = 'hvampire',
    UninterruptibleAction = true,
    DisableActions = CharmDisables,
    GoalSets = {
        Assassinate = true,
        Attack = true,
		Defend = true,
    },
    Abilities = CharmAbilities,
    ReasonIgnore = {
        Disabled = true,
    },
    UnitCutoffThreshold = 1,
    ActionCategory = 'HERO',
    ActionTimeout = 7,
    ActionFunction = AIAbility.PointBlankAreaAttackFunction,

# 0.27.03 modified charm to stop the AI from intentionally trying to interrupt as its not possible
    InstantStatusFunction =  function(unit, action)
        local result = false
        if(AIAbility.DefaultStatusFunction(unit, action)) then
			local aiBrain = unit:GetAIBrain()	
			local enemyThreat = aiBrain:GetThreatAtPosition( unit.Position, 1, 'Hero', 'Enemy' )
			if enemyThreat >= 2 then
				 result = true
			end
        end
        return result
    end, 
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
        if not agent.WorldStateData.CanUseAbilities then
            return false
        end

        if not action.Ability then
            return false
        end

        if not AIAbility.TestEnergy( agent, action.Ability ) then
            return false
        end
        
        local enemyThreat = aiBrain:GetThreatAtPosition( agent.Position, 1, 'Hero', 'Enemy' )
                
        if enemyThreat > 0 then
            return {
                KillHero = -6,
            }, CharmCastTime
        end
        
        return false
    end,
    ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
}

HeroAIActionTemplates['Charm - Units'] = {
    Name = 'Charm - Units',
    UnitId = 'hvampire',
    UninterruptibleAction = true,
    GoalSets = {
        Attack = true,
        Defend = true,
    },
    DisableActions = CharmDisables,
    Abilities = CharmAbilities,
    ReasonIgnore = {
        Disabled = true,
    },
    ActionCategory = 'GRUNT',
    ActionTimeout = 7,
    ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,        
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
        if not agent.WorldStateData.CanUseAbilities then
            return false
        end

        if not action.Ability then
            return false
        end

        if not AIAbility.TestEnergy( agent, action.Ability ) then
            return false
        end
        
        local enemyThreat = aiBrain:GetThreatAtPosition( agent.Position, 1, 'LandNoHero', 'Enemy' )
                
        if enemyThreat >= 200 then
            return {
                KillUnits = -4,
            }, CharmCastTime
        end
        
        return false
    end,
    ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
}

HeroAIActionTemplates['Charm - Squad Target'] = {
    Name = 'Charm - Squad Target',
    UnitId = 'hvampire',
    UninterruptibleAction = true,
    GoalSets = {
        SquadKill = true,
    },
    DisableActions = CharmDisables,
    Abilities = CharmAbilities,
    ReasonIgnore = {
        Disabled = true,
    },
    ActionTimeout = 7,
    TargetTypes = { 'STRUCTURE', 'HERO', 'MOBILE' },

# 0.27.03 modified charm to stop the AI from intentionally trying to interrupt as its not possible
    InstantStatusFunction =  function(unit, action)
        local result = false
        if(AIAbility.DefaultStatusFunction(unit, action)) then
			local aiBrain = unit:GetAIBrain()	
			local enemyThreat = aiBrain:GetThreatAtPosition( unit.Position, 1, 'Hero', 'Enemy' )
			if enemyThreat >= 2 then
				 result = true
			end
        end
        return result
    end, 
	
    ActionFunction = AIAbility.PointBlankAreaTargetAttackFunction,
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
        if not agent.WorldStateData.CanUseAbilities then
            return false
        end
        
        local actionBp = HeroAIActionTemplates[action.ActionName]
        if not action.Ability then
            return false
        end
        
        if not AIAbility.TestEnergy( agent, action.Ability ) then
            return false
        end

        local target = initialAgent.GOAP.AttackTarget
        if not target or target:IsDead() or VDist3XZ( agent.Position, target.Position ) > 20 then
            return false
        end

        return {
            KillSquadTarget = -5,
        }, CharmCastTime
    end,
    ActionCleanupFunction = AIAbility.PointBlankAreaTargetAttackCleanup,
}



# -- # =====================================
# -- # VAMPIRE BITE
# -- # =====================================

# -- local BiteCastTime = 2.0

# -- local BiteAbilities = {
    # -- 'HVampireBite01',
    # -- 'HVampireBite02',
    # -- 'HVampireBite03',
    # -- 'HVampireBite04',
# -- }

# -- local BiteDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Bite - Hero',
        # -- 'Bite - Squad Target',
    # -- }
# -- )

# -- local function BiteDamage(ability)
    # -- if AIGlobals.AbilityDamage[ability] then
        # -- return AIGlobals.AbilityDamage[ability]
    # -- end

    # -- local abilityDef = Ability[ability]
    
    # -- local damage = abilityDef.Amount

    # -- AIGlobals.AbilityDamage[ability] = damage
    # -- return damage
# -- end

# -- local function BiteBonus(ability)
    # -- if 'HVampireBite01' then
        # -- return -1
    # -- elseif 'HVampireBite02' then
        # -- return -2
    # -- elseif 'HVampireBite03' then
        # -- return -3
    # -- end

    # -- WARN('*AI Warning: No ability found ' .. ability)
    # -- return 0
# -- end

# 0.27.03 increased ai's desire to bite
HeroAIActionTemplates['Bite - Hero'] = {
    Name = 'Bite - Hero',
    UnitId = 'hvampire',
    UninterruptibleAction = true,
    GoalSets = {
        Attack = true,
        Assassinate = true,
    },
    Abilities = BiteAbilities,
    UnitCutoffThreshold = 1,
    DisableActions = BiteDisables,
    GoalWeights = {
        KillHero = -50,
        Health = -5,
    },
    WeakHeroNearbyAdd = -50,
    DamageCalculationFunction = BiteDamage,
    BonusGoalFunction = BiteBonus,
    ActionTimeout = 5,
    ActionCategory = 'HERO',
    WeightTime = BiteCastTime,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
    ActionFunction = AIAbility.TargetedAttackHeroFunction,
    CalculateWeights = AIAbility.TargetedAttackWeightsHero,
}

# 0.27.03 increased ai's desire to bite
HeroAIActionTemplates['Bite - Squad Target'] = {
    Name = 'Bite - Squad Target',
    UnitId = 'hvampire',
    UninterruptibleAction = true,
    DisableActions = BiteDisables,
    GoalSets = {
        SquadKill = true,
    },
    Abilities = BiteAbilities,
    GoalWeights = {
        KillSquadTarget = -10,
        Health = -5,
    },
    SquadTargetNearbyAdd = -2,
    DamageCalculationFunction = BiteDamage,
    BonusGoalFunction = BiteBonus,
    UnitCutoffThreshold = 1,
    TargetTypes = { 'HERO', 'MOBILE' },
    ActionTimeout = 5,
    WeightTime = BiteCastTime,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
    ActionFunction = AIAbility.TargetedAbilitySquadTargetFunction,
    CalculateWeights = AIAbility.TargetedAbilitySquadTargetWeights,
}

# -- # ===================================================================
# -- # Bat Swarm
# -- # ===================================================================
# -- local BatSwarmCastTime = 2.0

# -- local BatSwarmAbilities = {
    # -- 'HVampireBatSwarm01',
    # -- 'HVampireBatSwarm02',
    # -- 'HVampireBatSwarm03',
# -- }

# -- local BatSwarmDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Bat Swarm - Hero',
        # -- 'Bat Swarm - Squad Target',
        # -- 'Bat Swarm to Safe Position',
    # -- }
# -- )

# -- # Bat Swarm Functionality
# -- function BatSwarmWeights(action, aiBrain, agent, initialAgent)
    # -- if not agent.WorldStateData.CanUseAbilities then
        # -- return false
    # -- end

    # -- local actionBp = HeroAIActionTemplates[action.ActionName]

    # -- if not action.Ability then
        # -- return false
    # -- end

    # -- if not AIAbility.TestEnergy( agent, action.Ability ) then
        # -- return false
    # -- end

    # -- if actionBp.SquadTarget and not initialAgent.GOAP.AttackTarget then
        # -- return false
    # -- end

    # -- local enemyThreat = aiBrain:GetThreatAtPosition( agent.Position, 1, actionBp.ThreatType, 'Enemy' )

    # -- if not actionBp.SquadTarget and enemyThreat < 5 then
        # -- return false
    # -- end

    # -- if actionBp.SquadTarget then
        # -- agent.WorldStateData.SquadTargetNearby = true
    # -- else
        # -- agent.WorldStateData.WeakHeroNearby = true
    # -- end
    # -- agent.WorldStateConsistent = false

    # -- return actionBp.GoalWeights, 1.5
# -- end

# -- HeroAIActionTemplate {
    # -- Name = 'Bat Swarm - Hero',
    # -- UnitId = 'hvampire',
    # -- UninterruptibleAction = true,
    # -- GoalSets = {
        # -- Attack = true,
        # -- Defend = true,
        # -- Assassinate = true,
    # -- },
    # -- Abilities = BatSwarmAbilities,
    # -- DisableActions = BatSwarmDisables,
    # -- GoalWeights = {
        # -- KillHero = -5,
    # -- },
    # -- ThreatType = 'Hero',
    # -- ActionTimeout = 5,
    # -- ActionCategory = 'HERO',
    # -- WeightTime = BatSwarmCastTime,
    # -- ActionFunction = AIAbility.TargetedAreaAttackAbility,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
    # -- CalculateWeights = BatSwarmWeights,
# -- }

# -- HeroAIActionTemplate {
    # -- Name = 'Bat Swarm - Squad Target',
    # -- UnitId = 'hvampire',
    # -- UninterruptibleAction = true,
    # -- GoalSets = {
        # -- SquadKill = true,
    # -- },
    # -- Abilities = BatSwarmAbilities,
    # -- DisableActions = BatSwarmDisables,
    # -- GoalWeights = {
        # -- KillSquadTarget = -5,
    # -- },
    # -- SquadTarget = true,
    # -- ThreatType = 'Hero',
    # -- ActionTimeout = 5,
    # -- ActionCategory = 'HERO',
    # -- TargetTypes = { 'STRUCTURE', 'HERO', 'MOBILE' },
    # -- WeightTime = BatSwarmCastTime,
    # -- ActionFunction = AIAbility.TargetedAreaAttackAbility,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
    # -- CalculateWeights = BatSwarmWeights,
# -- }

# -- HeroAIActionTemplate {
    # -- Name = 'Bat Swarm to Safe Position',
    # -- UnitId = 'hvampire',
    # -- Abilities = BatSwarmAbilities,
    # -- DisableActions = BatSwarmDisables,
    # -- GoalSets = {
        # -- Attack = true,
        # -- Defend = true,
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
            # -- return { Survival = -5, KillUnits = -1, KillHero = -1, }, 0.5
        # -- else
            # -- return result
        # -- end
    # -- end,
    # -- InstantStatusFunction = function(unit, action)
        # -- local aiBrain = unit:GetAIBrain()
        # -- if aiBrain:GetNumUnitsAroundPoint( categories.MOBILE + categories.DEFENSE, unit.Position, 10, 'Enemy' ) <= 0 then
            # -- return false
        # -- end

        # -- return AIAbility.DefaultStatusFunction(unit, action)
    # -- end,
# -- }

# -- # ===================================================================
# -- # Mist
# -- # ===================================================================
# -- local MistCastTime = 0.5

# -- local MistCheckAbilities = {
    # -- 'HVampireMist01',
    # -- 'HVampireMist02',
    # -- 'HVampireMist03',
    # -- 'HVampireMist04',
# -- }

# -- local MistOnAbilities = {
    # -- 'HVampireMistOn',
# -- }

# -- local MistOffAbilities = {
    # -- 'HVampireMistOff',
# -- }

# -- local MistOffDisables = {
    # -- 'Mist - Near Infantry',
    # -- 'Mist - Near Hero',
    # -- 'Mist - Near Squad Target',
    # -- 'Mist - Wait',
# -- }

# -- local MistLockoffActions = {
    # -- 'Two Second Wait',
# -- }

# -- local function GetMistRadius(ability)
    # -- local radius = Ability[ability].AffectRadius
    # -- if not radius then
        # -- radius = 10
        # -- WARN('*AI ERROR: Cannot find radius for Ability - ' .. ability)
    # -- end
    # -- return radius
# -- end

# -- local function MistLockActions(unit)
    # -- for k,v in MistLockoffActions do
        # -- unit.GOAP.LockedActions[v] = true
    # -- end
# -- end

# -- local function MistUnlockActions(unit)
    # -- for k,v in MistLockoffActions do
        # -- unit.GOAP.LockedActions[v] = false
    # -- end
# -- end

local function MistStatusFunction(unit, action)
    local actionBp = HeroAIActionTemplates[action.ActionName]
	    
		# -- local enemyHero = unit.GOAP.AttackTarget

		# -- if(enemyHero != unit and enemyHero.CastingAbilityTask ) then  #and enemyHero.CastingAbilityTask != "Item_Consumable_010"  and enemyHero.CastingAbilityTask != "Item_Health_Potion" and enemyHero.CastingAbilityTask != "Item_Large_Health_Potion"
			# -- local announcement = "Mist to avoid: "..enemyHero.CastingAbilityTask
			# -- AIUtils.AIChat(unit, announcement)
			# -- return AIAbility.DefaultStatusFunction(unit,action)
		# -- end

    if unit:GetHealthPercent() < 0.3 then
        return false
    end

    local currentMist = AIAbility.AbilityCheck(unit, actionBp.CheckAbilities)
    if not currentMist then
        return false
    end
    local affectRadius = GetMistRadius(currentMist)

    action.TestRadius = affectRadius

    # This action doesn't have at threat type; simpy make sure the ability is on
    if not actionBp.MistThreatType then
        return AIAbility.DefaultStatusFunction(unit,action)
    end
    
    local query = CreateThreatQuery(unit.Army)
    query:GetThreatsAroundPoint( unit.Position, 2, actionBp.MistThreatType, 'Enemy' )
    query:SortClosestToFurthest()
    query:FilterDistanceGreaterThan(30)
    query:FilterThreatLessThan(1)
    local threats = query:GetResults()
    
    # If we have some threats; use that location for our move position and return the current action
    if threats then
        action.MovePosition = {threats[1][1],0,threats[1][2]}
        action.Distance = threats[1][4]
        return AIAbility.DefaultStatusFunction(unit,action)
    end

    return false
end

# -- HeroAIActionTemplate {
    # -- Name = 'Mist - Near Infantry',
    # -- UnitId = 'hvampire',
    # -- FinalAction = true,
    # -- GoalSets = {
        # -- Attack = true,
        # -- Defend = true,
    # -- },
    # -- Abilities = MistOnAbilities,
    # -- ReasonIgnore = {
        # -- Disabled = true,
    # -- },
    # -- ActionCategory = 'GRUNT',
    # -- MistThreatType = 'LandNoHero',
    # -- ActionTimeout = 6,
    # -- CheckAbilities = MistCheckAbilities,
    # -- ActionFunction = function(unit,action)
        # -- if unit:GetHealthPercent() < 0.3 then
            # -- return false
        # -- end
        # -- if AIAbility.PointBlankAreaAttackFunction(unit,action) then
            # -- unit.GOAP:LockActions(MistLockoffActions)
        # -- end
    # -- end,
    # -- InstantStatusFunction = MistStatusFunction,
    # -- CalculateWeights = function( action, aiBrain, agent, initialAgent )
        # -- if agent.WorldStateData.MistMode or not agent.WorldStateData.CanMove or not agent.WorldStateData.CanUseAbilities then
            # -- return false
        # -- end

        # -- if not AIAbility.TestEnergy( agent, action.Ability ) then
            # -- return false
        # -- end

        # -- local goapAction = initialAgent.GOAP.Actions[action.ActionName]
        # -- agent:SetPosition( goapAction.MovePosition )
        # -- agent.WorldStateData.CanMove = false
        # -- agent.WorldStateData.CanUseAbilities = false
        # -- agent.WorldStateData.CanAttack = false
        # -- agent.WorldStateData.MistMode = true
        # -- agent.WorldStateConsistent = false
        
        # -- return { KillUnits = -10, Health = 2, }, 3
    # -- end,
# -- }

# -- HeroAIActionTemplates['Mist - Near Hero'] = {
    # -- Name = 'Mist - Near Hero',
    # -- UnitId = 'hvampire',
    # -- FinalAction = true,
    # -- GoalSets = {
        # -- Assassinate = true,
        # -- Attack = true,
    # -- },
    # -- Abilities = MistOnAbilities,
    # -- ReasonIgnore = {
        # -- Disabled = true,
    # -- },
    # -- MistThreatType = 'Hero',
    # -- ActionCategory = 'HERO',
    # -- ActionTimeout = 6,
    # -- CheckAbilities = MistCheckAbilities,
    # -- ActionFunction = function(unit,action)
        # -- if unit:GetHealthPercent() < 0.3 then
            # -- return false
        # -- end
        # -- if AIAbility.PointBlankAreaAttackFunction(unit,action) then
            # -- unit.GOAP:LockActions(MistLockoffActions)
        # -- end
    # -- end,
    # -- InstantStatusFunction = MistStatusFunction,    
    # -- CalculateWeights = function( action, aiBrain, agent, initialAgent )
        # -- if agent.WorldStateData.MistMode or not agent.WorldStateData.CanMove or not agent.WorldStateData.CanUseAbilities then
            # -- return false
        # -- end

        # -- if not AIAbility.TestEnergy( agent, action.Ability ) then
            # -- return false
        # -- end

        # -- local goapAction = initialAgent.GOAP.Actions[action.ActionName]
        # -- agent:SetPosition( goapAction.MovePosition )
        # -- agent.WorldStateData.CanMove = false
        # -- agent.WorldStateData.CanUseAbilities = false
        # -- agent.WorldStateData.CanAttack = false
        # -- agent.WorldStateData.MistMode = true
        # -- agent.WorldStateConsistent = false
        
        # -- return { KillHero = -5, Health = 2, }, 3
    # -- end,
# -- }

# -- HeroAIActionTemplate {
    # -- Name = 'Mist - Near Squad Target',
    # -- UnitId = 'hvampire',
    # -- FinalAction = true,
    # -- GoalSets = {
        # -- SquadKill = true,
    # -- },
    # -- Abilities = MistOnAbilities,
    # -- ReasonIgnore = {
        # -- Disabled = true,
    # -- },
    # -- TargetTypes = { 'HERO', },
    # -- ActionTimeout = 6,
    # -- CheckAbilities = MistCheckAbilities,
    # -- ActionFunction = function(unit,action)
        # -- if unit:GetHealthPercent() < 0.3 then
            # -- return false
        # -- end
        # -- if AIAbility.PointBlankAreaTargetAttackFunction(unit,action) then
            # -- unit.GOAP:LockActions(MistLockoffActions)
        # -- end
    # -- end,
    # -- InstantStatusFunction = MistStatusFunction,    
    # -- CalculateWeights = function( action, aiBrain, agent, initialAgent )
        # -- if agent.WorldStateData.MistMode or not agent.WorldStateData.CanMove or not agent.WorldStateData.CanUseAbilities then
            # -- return false
        # -- end

        # -- if not AIAbility.TestEnergy( agent, action.Ability ) then
            # -- return false
        # -- end

        # -- local goapAction = initialAgent.GOAP.Actions[action.ActionName]

        # -- local target = initialAgent.GOAP.AttackTarget
        # -- if(not target or target:IsDead() or VDist3XZSq(agent.Position, target.Position) > 400) then
            # -- return false
        # -- end

        # -- agent:SetPosition( target.Position )
        # -- agent.WorldStateData.CanMove = false
        # -- agent.WorldStateData.CanUseAbilities = false
        # -- agent.WorldStateData.CanAttack = false
        # -- agent.WorldStateData.MistMode = true
        # -- agent.WorldStateConsistent = false
        
        # -- return { KillSquadTarget = -5, Health = 2, }, 3
    # -- end,
# -- }

# -- HeroAIActionTemplate {
    # -- Name = 'Mist - Wait',
    # -- UnitId = 'hvampire',
    # -- GoalSets = {
        # -- Attack = true,
        # -- Defend = true,
        # -- Assassinate = true,
        # -- SquadKill = true,
    # -- },
    # -- ActionTimeout = 3,
    # -- CheckAbilities = MistCheckAbilities,
    # -- ActionFunction = function(unit,action)
        # -- local actionBp = HeroAIActionTemplates[action.ActionName]
        # -- WaitSeconds(actionBp.ActionTimeout)
    # -- end,
    # -- InstantStatusFunction = function(unit,action)
        # -- # Make sure we are in mist mode
        # -- if not unit.WorldStateData.MistMode then
            # -- return false
        # -- end

        # -- local actionBp = HeroAIActionTemplates[action.ActionName]
        # -- local aiBrain = unit:GetAIBrain()
        
        # -- local currentMist = AIAbility.AbilityCheck(unit, actionBp.CheckAbilities)
        # -- if not currentMist then
            # -- return false
        # -- end
        # -- local affectRadius = GetMistRadius(currentMist)

        # -- # Test Heroes
        # -- action.HeroWeight = 0
        # -- if aiBrain:GetNumUnitsAroundPoint( categories.HERO, unit.Position, affectRadius, 'Enemy' ) > 0 then
            # -- action.HeroWeight = -4
        # -- end

        # -- # Test Grunts
        # -- action.GruntWeight = 0
        # -- local numGrunts = aiBrain:GetNumUnitsAroundPoint( categories.MOBILE - categories.HERO, unit.Position, affectRadius, 'Enemy' )
        # -- if numGrunts > 0 then
            # -- action.KillUnits = math.ceil( numGrunts / 5 ) * -1
        # -- end

        # -- # Test Squad Target
        # -- action.SquadKillWeight = 0
        # -- if unit.GOAP.AttackTarget and not unit.GOAP.AttackTarget:IsDead() then
            # -- if VDist3XZSq( unit.Position, unit.GOAP.AttackTarget.Position ) < affectRadius * affectRadius then
                # -- action.SquadKillWeight = -4
            # -- end
        # -- end

        # -- return true
    # -- end,    
    # -- CalculateWeights = function( action, aiBrain, agent, initialAgent )
        # -- if not agent.WorldStateData.MistMode then
            # -- return false
        # -- end

        # -- local goapAction = initialAgent.GOAP.Actions[action.ActionName]

        # -- local returnTable = {
            # -- KillHero = goapAction.HeroWeight,
            # -- KillUnits = goapAction.GruntWeight,
            # -- KillSquadTarget = goapAction.SquadKillWeight,
            # -- Health = 1,
        # -- }

        # -- return returnTable, 3
    # -- end,
# -- }

# -- HeroAIActionTemplate {
    # -- Name = 'Mist - Off',
    # -- UnitId = 'hvampire',
    # -- GoalSets = {
        # -- All = true,
    # -- },
    # -- Abilities = MistOffAbilities,
    # -- ReasonIgnore = {
        # -- Disabled = true,
    # -- },
    # -- ActionTimeout = 1,
    # -- ActionFunction = function(unit,action)
        # -- if AIAbility.InstantActionFunction(unit,action) then
            # -- unit.GOAP:UnlockActions(MistLockoffActions)
        # -- end
    # -- end,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,    
    # -- CalculateWeights = function( action, aiBrain, agent, initialAgent )
        # -- if not agent.WorldStateData.MistMode then
            # -- return false
        # -- end

        # -- agent.WorldStateData.CanMove = true
        # -- agent.WorldStateData.CanUseAbilities = true
        # -- agent.WorldStateData.CanAttack = true
        # -- agent.WorldStateData.MistMode = false
        # -- agent.WorldStateConsistent = false
        
        # -- if initialAgent:GetHealthPercent() < 0.3 then
            # -- return { Health = -6, }, 1
        # -- end
        # -- return { Health = -2, }, 1
    # -- end,
# -- }

