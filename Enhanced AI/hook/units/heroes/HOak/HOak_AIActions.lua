# -- local AIAbility = import('/lua/sim/ai/AIAbilityUtilities.lua')

# -- local DefaultDisables = import('/lua/sim/ai/AIGlobals.lua').DefaultDisables

# ------------------------------------------------------------------------------
# SHIELD
# ------------------------------------------------------------------------------
# -- local ShieldAbilities = {
    # -- 'HOAKShield01',
    # -- 'HOAKShield02',
    # -- 'HOAKShield03',
    # -- 'HOAKShield04',
# -- }
# -- local ShieldCastTime = 0.5
# -- local ShieldDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Shield - Self',
        # -- 'Shield - Friendly Hero',
    # -- }
# -- )

# ----------------------------
# Shield - Self
# ----------------------------
HeroAIActionTemplates['Shield - Self'] = {
    Name = 'Shield - Self',
    UnitId = 'hoak',
    Abilities = ShieldAbilities,
    DisableActions = ShieldDisables,
    GoalSets = {
        All = true,
    },
    UninterruptibleAction = true,
    ActionFunction = AIAbility.TargetedSelfHeroFunction,
    ActionTimeout = 5,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        if not agent.WorldStateData.CanUseAbilities then
            return false
        end

        local result = false

        if(action.Ability) then
            if(AIAbility.TestEnergy(agent, action.Ability)) then
                if (aiBrain:GetThreatAtPosition(agent.Position, 1, 'Hero', 'Enemy') >= 1) then
                    result = true
                end
            end
        end

        if(result == true) then
            return {Survival = -10}, ShieldCastTime
        else
            return result
        end
    end,
    InstantStatusFunction = function(unit, action)
        local result = false

        if(AIAbility.DefaultStatusFunction(unit, action)) then
			if  unit:GetHealthPercent() < 0.5 then
				result = true
            end
        end

        return result
    end,
}

# ----------------------------
# Shield - Friendly Hero
# ----------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Shield - Friendly Hero',
    # -- UnitId = 'hoak',
    # -- Abilities = ShieldAbilities,
    # -- DisableActions = ShieldDisables,
    # -- GoalSets = {
        # -- All = true,
    # -- },
    # -- UninterruptibleAction = true,
    # -- ActionFunction = AIAbility.TargetedWeakFriendHeroFunction,
    # -- ActionTimeout = 5,
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
            # -- return {SupportAlly = -5}, ShieldCastTime
        # -- else
            # -- return false
        # -- end
    # -- end,
    # -- InstantStatusFunction = function(unit, action)
        # -- local result = false

        # -- if(AIAbility.DefaultStatusFunction(unit, action)) then
            # -- local allies = unit:GetAIBrain():GetUnitsAroundPoint(categories.HERO, unit.Position, 25, 'Ally')
            # -- for k, v in allies do
                # -- if(v != unit and v:GetHealthPercent() < 0.5) then
                    # -- result = true
                    # -- break
                # -- end
            # -- end
        # -- end

        # -- return result
    # -- end,
# -- }

# ------------------------------------------------------------------------------
# PENITENCE
# ------------------------------------------------------------------------------
# -- local PenitenceAbilities = {
    # -- 'HOAKPenitence01',
    # -- 'HOAKPenitence02',
    # -- 'HOAKPenitence03',
    # -- 'HOAKPenitence04',
# -- }
# -- local PenitenceCastTime = 2
# -- local PenitenceDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Penitence - Hero',
        # -- 'Penitence - Squad Target',
    # -- }
# -- )

# ----------------------------
# Penitence - Hero
# ----------------------------

# 0.26.56 commented out custom customs completely - no necessary
-- # 0.26.52 commented out custom function and created a new one that does not care about interrupts - just spams
--[[
local AIUtils = import('/lua/sim/ai/aiutilities.lua')
function myPenitenceStatusFunction (unit, action)
  local result = false
        if(action.Ability and AIAbility.TestEnergy(agent, action.Ability)) then
			result = true
		end
--	if(AIAbility.DefaultStatusFunction(unit, action)) then
--		 if unit:GetEnergy() >= 300 then
			-- result = true
--		 else
--		end
--	end
  return result
end
--]]
--[[
# [MOD] Use penitence for interrupt. 
local AIUtils = import('/lua/sim/ai/aiutilities.lua')
function myPenitenceStatusFunction (unit, action)
  local result = false
	if(AIAbility.DefaultStatusFunction(unit, action)) then
		 if unit:GetEnergy() > 1500 then
			result = true
		 else
   
			local enemyHero = unit.GOAP.AttackTarget
				if(enemyHero != unit and enemyHero.CastingAbilityTask) then 
					# -- local announcement = "Interrupt: "..enemyHero.CastingAbilityTask
					# -- AIUtils.AIChat(unit, announcement)
                    result = true
                    
                end
	 
            # -- local enemyHero = unit:GetAIBrain():GetUnitsAroundPoint(categories.HERO, unit.Position, 25, 'Enemy')
            # -- for k, v in enemyHero do
                # -- if(v != unit and v.CastingAbilityTask) then 
					# -- local announcement = "Interrupt: "..v.CastingAbilityTask
					# -- AIUtils.AIChat(unit, announcement)
                    # -- result = true
                    # -- break
                # -- end
			# -- end
		end
	end
  return result
end
--]]
HeroAIActionTemplates['Penitence - Hero'] =  {
    Name = 'Penitence - Hero',
    UnitId = 'hoak',
    Abilities = PenitenceAbilities,
    DisableActions = PenitenceDisables,
    GoalSets = {
        Assassinate = true,
        Attack = true,
        Defend = true,
		CarefulAttack = true,
		Flee = true,
    },
# 0.26.56 Removed Catpureflag goal weight as it is not needed
    GoalWeights = {
        KillHero = -50,
    },
    UninterruptibleAction = true,
    WeightTime = PenitenceCastTime,
    ActionFunction = AIAbility.TargetedAttackHeroFunction,
    ActionTimeout = 5,
    CalculateWeights = AIAbility.TargetedAttackWeightsHero,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,	
}



# ----------------------------
# Penitence - Squad Target
# ----------------------------
HeroAIActionTemplates['Penitence - Squad Target'] = {
    Name = 'Penitence - Squad Target',
    UnitId = 'hoak',
    Abilities = PenitenceAbilities,
    DisableActions = PenitenceDisables,
    GoalSets = {
        SquadKill = true,
    },
    GoalWeights = {
        KillSquadTarget = -25,
    },
    TargetTypes = { 'HERO', },
    UninterruptibleAction = true,
    WeightTime = PenitenceCastTime,
    ActionFunction = AIAbility.TargetedAbilitySquadTargetFunction,
    CalculateWeights = AIAbility.TargetedAbilitySquadTargetWeights,
	InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ------------------------------------------------------------------------------
# SURGE
# ------------------------------------------------------------------------------
# -- local SurgeAbilities = {
    # -- 'HOAKSurgeofFaith01',
    # -- 'HOAKSurgeofFaith02',
    # -- 'HOAKSurgeofFaith03',
# -- }
# -- local SurgeCastTime = 2
# -- local SurgeDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Surge - Hero',
        # -- 'Surge - Units',
        # -- 'Surge - Squad Target',
    # -- }
# -- )

# ----------------------------
# Surge - Hero
# ----------------------------
HeroAIActionTemplates['Surge - Hero'] = {
    Name = 'Surge - Hero',
    UnitId = 'hoak',
    Abilities = SurgeAbilities,
    DisableActions = SurgeDisables,
    GoalSets = {
# 0.26.53 added attack/defend/carefulattack/flee
		Assassinate = true,
		Attack = true,
		Defend = true,
		CarefulAttack = true,
		Flee = true,
    },
    UninterruptibleAction = true,
    UnitCutoffThreshold = 1,
    ActionCategory = 'HERO',
    ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    ActionTimeout = 7,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        if not agent.WorldStateData.CanUseAbilities then
            return false
        end

        local result = false

        if(action.Ability) then
            if(AIAbility.TestEnergy(agent, action.Ability)) then
				if initialAgent:GetEnergyPercent() > .50 or initialAgent:GetEnergy() > 1550 then
					if(aiBrain:GetThreatAtPosition(agent.Position, .8, 'Hero', 'Enemy') > 0) then
						result = true
					end
				end
            end
        end

        if(result) then
            return {KillHero = -50}, SurgeCastTime
        else
            return result
        end
    end,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ----------------------------
# Surge - Units
# ----------------------------
HeroAIActionTemplates['Surge - Units'] = {
    Name = 'Surge - Units',
    UnitId = 'hoak',
    Abilities = SurgeAbilities,
    DisableActions = SurgeDisables,
    GoalSets = {
        Attack = true,
        Defend = true,
    },
    UninterruptibleAction = true,
    ActionCategory = 'GRUNT',
    ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    ActionTimeout = 5,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        if not agent.WorldStateData.CanUseAbilities then
            return false
        end

        local result = false
        local killUnits = 0

# 0.27.03 increased oak's desire to use surge to kill units
        if(action.Ability) then
            if(AIAbility.TestEnergy(agent, action.Ability)) then
				if initialAgent:GetEnergyPercent() > .50 or initialAgent:GetEnergy() > 1550 then
					local enemyThreat = aiBrain:GetThreatAtPosition(agent.Position, .8, 'LandNoHero', 'Enemy')
					if(enemyThreat >= 20) then # was 40
						killUnits = -15
					elseif(enemyThreat >= 10) then # was 20
						killUnits = -1
					end
				end
			end
        end

        if(result) then
            return {KillUnits = killUnits}, SurgeCastTime
        else
            return result
        end
    end,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ----------------------------
# Surge - Squad Target
# ----------------------------
HeroAIActionTemplates['Surge - Squad Target'] = {
    Name = 'Surge - Squad Target',
    UnitId = 'hoak',
    Abilities = SurgeAbilities,
    DisableActions = SurgeDisables,
    GoalSets = {
        SquadKill = true,
    },
    TargetTypes = { 'HERO', 'MOBILE' },
    UninterruptibleAction = true,
    UnitCutoffThreshold = 1,
    ActionCleanupFunction = AIAbility.PointBlankAreaTargetAttackCleanup,
    ActionFunction = AIAbility.PointBlankAreaTargetAttackFunction,
    ActionTimeout = 7,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        if not agent.WorldStateData.CanUseAbilities then
            return false
        end

        local result = false

        if(action.Ability) then
            if(AIAbility.TestEnergy(agent, action.Ability)) then
				if initialAgent:GetEnergyPercent() > .50 or initialAgent:GetEnergy() > 1550 then
					local target = initialAgent.GOAP.AttackTarget
					if(target and VDist3XZ(agent.Position, target.Position) <= 10) then
						result = true
					end
				end
			end
        end

        if(result) then
            return {KillSquadTarget = -4}, SurgeCastTime
        else
            return result
        end
    end,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ------------------------------------------------------------------------------
# RAISE DEAD WARD
# ------------------------------------------------------------------------------
# -- local RaiseDeadAbilities = {
    # -- 'HOAKRaiseDeadWard01',
    # -- 'HOAKRaiseDeadWard02',
    # -- 'HOAKRaiseDeadWard03',
    # -- 'HOAKRaiseDeadWard04',
# -- }
# -- local RaiseDeadCastTime = 3
# -- local RaiseDeadDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Place Raise Dead Ward',
    # -- }
# -- )

# ----------------------------
# Place Raise Dead Ward
# ----------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Place Raise Dead Ward',
    # -- UnitId = 'hoak',
    # -- Abilities = RaiseDeadAbilities,
    # -- DisableActions = RaiseDeadDisables,
    # -- GoalSets = {
        # -- Assassinate = true,
        # -- Attack = true,
        # -- AttackStructure = true,
        # -- Defend = true,
    # -- },
    # -- UninterruptibleAction = true,
    # -- ActionCategory = 'GRUNT',
    # -- ActionFunction = AIAbility.TargetedAreaAttackAbility,
    # -- ActionTimeout = 5,
    # -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        # -- if not agent.WorldStateData.CanUseAbilities then
            # -- return false
        # -- end

        # -- local result = false

        # -- if(action.Ability) then
            # -- if(AIAbility.TestEnergy(agent, action.Ability)) then
                # -- if(aiBrain:GetThreatAtPosition(agent.Position, 1, 'Land', 'Enemy') > 0) then
                    # -- result = true
                # -- end
            # -- end
        # -- end

        # -- if(result) then
            # -- return {KillUnits = -5}, RaiseDeadCastTime
        # -- else
            # -- return result
        # -- end
    # -- end,
    # -- InstantStatusFunction = function(unit, action)
        # -- local aiBrain = unit:GetAIBrain()
        # -- local checkCat = categories.hoakraisedeadward01 + categories.hoakraisedeadward02 + 
                            # -- categories.hoakraisedeadward03 + categories.hoakraisedeadward04

        # -- if AIAbility.DefaultStatusFunction(unit,action) then
            # -- local wards = aiBrain:GetUnitsAroundPoint(checkCat, unit.Position, 15, 'Ally')

            # -- for k,v in wards do
                # -- if v:GetArmy() == unit:GetArmy() then
                    # -- return false
                # -- end
            # -- end
            # -- return true
        # -- end

        # -- return false
    # -- end,
# -- }