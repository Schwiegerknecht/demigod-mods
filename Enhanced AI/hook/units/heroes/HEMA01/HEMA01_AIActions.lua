local Validate = import('/lua/common/ValidateAbility.lua')
local Utils = import('/lua/utilities.lua')
--[[

local AIAbility = import('/lua/sim/ai/AIAbilityUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

local DefaultDisables = import('/lua/sim/ai/AIGlobals.lua').DefaultDisables

local FrostAbilities = {
    'Frost Nova - Hero',
    'Frost Nova - Units',
    'Frost Nova - Squad Target',
    'Rain of Ice - Hero',
    'Rain of Ice - Units',
    'Rain of Ice - Structures',
    'Rain of Ice - Squad Target',
    'Deep Freeze - Hero',
    'Deep Freeze - Squad Target',
}

local FireAbilities = {
    'Fire Nova - Hero',
    'Fire Nova - Units',
    'Fire Nova - Structure',
    'Fire Nova - Squad Target',
    'Fireball - Hero',
    'Fireball - Structures',
    'Fireball - Squad Target',
    'Ring of Fire - Hero',
    'Ring of Fire - Units',
    'Ring of Fire - Structures',
    'Ring of Fire - Squad Target',
}

# ------------------------------------------------------------------------------
# FROST NOVA
# ------------------------------------------------------------------------------
local FrostNovaAbilities = {
    'HEMA01FrostNova01',
    'HEMA01FrostNova02',
    'HEMA01FrostNova03',
}
local FrostNovaDisables = table.append( DefaultDisables,
    {
        'Frost Nova - Hero',
        'Frost Nova - Units',
        'Frost Nova - Squad Target',
    }
)
local FrostNovaTime = 2.5
]]-- 
function FrostNovaWeights(action, aiBrain, agent, initialAgent)
    local result = false
    local actionBp = HeroAIActionTemplates[action.ActionName]

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
             return actionBp.GoalWeights, FrostNovaTime
        end
        
        return false
      

end

# ----------------------------
# Frost Nova - Hero
# ----------------------------
HeroAIActionTemplates['Frost Nova - Hero'] =  {
    Name = 'Frost Nova - Hero',
    UnitId = 'hema01',
    Abilities = FrostNovaAbilities,
    DisableActions = FrostNovaDisables,
    GoalSets = {
        Assassinate = true,
        Attack = true,
		Defend = true,
    },
    GoalWeights = {
        KillHero = -15,
    },
    IgnoreBuffs = FrostNovaAbilities,
    ReasonIgnore = {
        Disabled = true,
    },
    ThreatAmount = 0,
    ThreatType = 'Hero',
    UninterruptibleAction = true,
    UnitCutoffThreshold = 1,
    ActionCategory = 'HERO',
    ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    ActionTimeout = 7,
    CalculateWeights = FrostNovaWeights,
# 0.27.01
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
    
# 0.27.01 commented out original logic for frost nova
--[[
	InstantStatusFunction =  function(unit, action)
        local result = false

        if(AIAbility.DefaultStatusFunction(unit, action)) then
			local enemyHero = unit.GOAP.AttackTarget
			if(enemyHero != unit and enemyHero.CastingAbilityTask) then 
				result = true
			end
			
			if not result then
				local aiBrain = unit:GetAIBrain()	
				local enemyThreat = aiBrain:GetThreatAtPosition( unit.Position, 1, 'Hero', 'Enemy' )
					
				if enemyThreat >= 2 then
					 result = true
				end
			end
			
			#if result then WARN('Nova Triggered') end
        end

        return result
    end, 
--]]
}

# ----------------------------
# Frost Nova - Units
# ----------------------------
HeroAIActionTemplates['Frost Nova - Units'] = {
    Name = 'Frost Nova - Units',
    UnitId = 'hema01',
    Abilities = FrostNovaAbilities,
    DisableActions = FrostNovaDisables,
    GoalSets = {
        Attack = true,
        Defend = true,
    },
    GoalWeights = {
        KillUnits = 0,
    },
    IgnoreBuffs = FrostNovaAbilities,
    ReasonIgnore = {
        Disabled = true,
    },
    ThreatAmount = 10,
    ThreatType = 'LandNoHero',
    UninterruptibleAction = true,
    ActionCategory = 'GRUNT',
    ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    ActionTimeout = 7,
    CalculateWeights = FrostNovaWeights,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ----------------------------
# Frost Nova - Squad Target
# ----------------------------
HeroAIActionTemplates['Frost Nova - Squad Target'] = {
    Name = 'Frost Nova - Squad Target',
    UnitId = 'hema01',
    Abilities = FrostNovaAbilities,
    DisableActions = FrostNovaDisables,
    GoalSets = {
        SquadKill = true,
    },
    
# 0.27.01 increased weight from 0 to -15
	GoalWeights = {
        KillSquadTarget = -15,
    },
    IgnoreBuffs = FrostNovaAbilities,
    ReasonIgnore = {
        Disabled = true,
    },
    SquadTarget = true,
    TargetTypes = {'STRUCTURE', 'HERO', 'MOBILE'},
    UninterruptibleAction = true,
    ActionCleanupFunction = AIAbility.PointBlankAreaTargetAttackCleanup,
    ActionFunction = AIAbility.PointBlankAreaTargetAttackFunction,
    ActionTimeout = 7,
    CalculateWeights = FrostNovaWeights,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}
--[[
# ------------------------------------------------------------------------------
# RAIN OF ICE
# ------------------------------------------------------------------------------
local RainOfIceAbilities = {
    'HEMA01RainIce01',
    'HEMA01RainIce02',
    'HEMA01RainIce03',
    'HEMA01RainIce04',
}
local RainOfIceDisables = table.append( DefaultDisables,
    {
        'Rain of Ice - Hero',
        'Rain of Ice - Units',
        'Rain of Ice - Structures',
        'Rain of Ice - Squad Target',
    }
)
local RainOfIceTime = 1.5

function RainWeights(action, aiBrain, agent, initialAgent)
    if not agent.WorldStateData.CanUseAbilities then
        return false
    end

    local result = false
    local actionBp = HeroAIActionTemplates[action.ActionName]

    if((actionBp.FireMode and agent.WorldStateData.FireMode) or
       (not actionBp.FireMode and not agent.WorldStateData.FireMode)) then
        if(action.Ability and AIAbility.TestEnergy(agent, action.Ability)) then
            if(actionBp.ThreatAmount and actionBp.ThreatType) then
                if(aiBrain:GetThreatAtPosition(agent.Position, 1, actionBp.ThreatType, 'Enemy') > actionBp.ThreatAmount) then
                    result = true
                end
            elseif(actionBp.SquadTarget and initialAgent.GOAP.AttackTarget) then
                result = true
            end
        end
    end

    if(result) then
        return actionBp.GoalWeights, actionBp.Time
    else
        return result
    end
end

# ----------------------------
# Rain of Ice - Hero
# ----------------------------
HeroAIActionTemplate {
    Name = 'Rain of Ice - Hero',
    UnitId = 'hema01',
    Abilities = RainOfIceAbilities,
    DisableActions = RainOfIceDisables,
    GoalSets = {
        Assassinate = true,
    },
    GoalWeights = {
        KillHero = -5,
    },
    ReasonIgnore = {
        Disabled = true,
    },
    ThreatAmount = 0,
    ThreatType = 'Hero',
    Time = RainOfIceTime,
    UninterruptibleAction = true,
    ActionCategory = 'HERO',
    ActionFunction = AIAbility.TargetedAreaAttackAbility,
    ActionTimeout = 5,
    CalculateWeights = RainWeights,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ----------------------------
# Rain of Ice - Units
# ----------------------------
HeroAIActionTemplate {
    Name = 'Rain of Ice - Units',
    UnitId = 'hema01',
    Abilities = RainOfIceAbilities,
    DisableActions = RainOfIceDisables,
    GoalSets = {
        Attack = true,
        Defend = true,
    },
    GoalWeights = {
        KillUnits = -7,
    },
    ReasonIgnore = {
        Disabled = true,
    },
    ThreatAmount = 5,
    ThreatType = 'LandNoHero',
    Time = RainOfIceTime,
    UninterruptibleAction = true,
    ActionCategory = 'GRUNT',
    ActionFunction = AIAbility.TargetedAreaAttackAbility,
    ActionTimeout = 5,
    CalculateWeights = RainWeights,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ----------------------------
# Rain of Ice - Structures
# ----------------------------
HeroAIActionTemplate {
    Name = 'Rain of Ice - Structures',
    UnitId = 'hema01',
    Abilities = RainOfIceAbilities,
    DisableActions = RainOfIceDisables,
    GoalSets = {
        DestroyStructures = true,
    },
    GoalWeights = {
        KillStructures = -3,
    },
    ReasonIgnore = {
        Disabled = true,
    },
    ThreatAmount = 5,
    ThreatType = 'Structures',
    Time = RainOfIceTime,
    UninterruptibleAction = true,
    ActionCategory = 'STRUCTURE',
    ActionFunction = AIAbility.TargetedAreaAttackAbility,
    ActionTimeout = 5,
    CalculateWeights = RainWeights,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ----------------------------
# Rain of Ice - Squad Target
# ----------------------------
HeroAIActionTemplate {
    Name = 'Rain of Ice - Squad Target',
    UnitId = 'hema01',
    Abilities = RainOfIceAbilities,
    DisableActions = RainOfIceDisables,
    GoalSets = {
        SquadKill = true,
    },
    GoalWeights = {
        KillSquadTarget = -5,
    },
    ReasonIgnore = {
        Disabled = true,
    },
    SquadTarget = true,
    TargetTypes = {'STRUCTURE', 'HERO', 'MOBILE'},
    Time = RainOfIceTime,
    UninterruptibleAction = true,
    ActionFunction = AIAbility.TargetedAreaSquadTargetAbility,
    ActionTimeout = 5,
    CalculateWeights = RainWeights,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ------------------------------------------------------------------------------
# DEEP FREEZE
# ------------------------------------------------------------------------------
local DeepFreezeAbilities = {
    'HEMA01FreezeStructure01',
    'HEMA01FreezeStructure02',
    'HEMA01FreezeStructure03',
    'HEMA01FreezeStructure04',
}
local DeepFreezeDisables = table.append( DefaultDisables,
    {
        'Deep Freeze - Squad Target',
        'Deep Freeze - Hero',
    }
)
local FreezeTime = 1.0
]]--
# 0.26.54 added new goalsets (defend/carefulattack/flee) - added new goal (captureflag - increased priority -25)
# ----------------------------
# Deep Freeze - Hero
# ----------------------------
HeroAIActionTemplates['Deep Freeze - Hero'] = {
    Name = 'Deep Freeze - Hero',
    UnitId = 'hema01',
    Abilities = DeepFreezeAbilities,
    DisableActions = DeepFreezeDisables,
    GoalSets = {
        Assassinate = true,
        Attack = true,
        Defend = true,
		CarefulAttack = true,
		Flee = true,
    },
# 0.26.56 removed captureflag goal per miri
    GoalTable = {
        KillHero = -25,
		--CaptureFlag = -25,
    },
    ForceGoalWeights = true,
    IgnoreBuffs = DeepFreezeAbilities,
    ReasonIgnore = {
        Disabled = true,
    },
    UninterruptibleAction = true,
    WeightTime = FreezeTime,
    ActionFunction = AIAbility.TargetedDebuffHeroFunction,
    ActionTimeout = 5,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
		local result = false
		
        if(not agent.WorldStateData.FireMode) then
			local enemyHero = initialAgent.GOAP.AttackTarget

			if enemyHero and not enemyHero:IsDead() then
					result = true 
			end
        else
            result = false
        end
		
		if result then
			return AIAbility.TargetedDebuffWeightsHero(action, aiBrain, agent, initialAgent)
		else
			return result
		end
    end,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ----------------------------
# Deep Freeze - Squad Target
# ----------------------------
HeroAIActionTemplates['Deep Freeze - Squad Target'] = {
    Name = 'Deep Freeze - Squad Target',
    UnitId = 'hema01',
    Abilities = DeepFreezeAbilities,
    DisableActions = DeepFreezeDisables,
    GoalSets = {
        SquadKill = true,
    },
    GoalWeights = {
# 0.26.50 increased AI desire to killsquadtarget from 0 to -10	
        KillSquadTarget = -10,
    },
    ForceGoalWeights = true,
    IgnoreBuffs = DeepFreezeAbilities,
    ReasonIgnore = {
        Disabled = true,
    },
    TargetTypes = { 'HERO', },
    UninterruptibleAction = true,
    WeightTime = FreezeTime,
    ActionFunction = AIAbility.TargetedAbilitySquadTargetFunction,
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
        if(not agent.WorldStateData.FireMode) then
            return AIAbility.TargetedAbilitySquadTargetWeights(action, aiBrain, agent, initialAgent)
        else
            return false
        end
    end,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ------------------------------------------------------------------------------
# BURN ALIVE
# ------------------------------------------------------------------------------
# -- local BurnAliveTime = 1.5
# -- local FrostDisables = table.append( DefaultDisables, FrostAbilities )

# ----------------------------
# Burn Alive
# ----------------------------
HeroAIActionTemplates['Burn Alive'] = {
    Name = 'Burn Alive',
    UnitId = 'hema01',
    Abilities = {
        'HEMA01SwitchFire',
    },
    DisableActions = FrostDisables,
    GoalSets = {
        Attack = true,
        Defend = true,
        Assassinate = true,
        DestroyStructures = true,
        SquadKill = true,
    },
    UninterruptibleAction = true,
    ActionFunction = function(unit,action)
        if not AIAbility.InstantActionFunction(unit,action) then
            return false
        end

        WaitSeconds(BurnAliveTime)
        if unit:IsDead() then
            return false
        end

        return true
    end,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        local result = false

        if(not agent.WorldStateData.FireMode and agent.WorldStateData.CanUseAbilities) then
            if(action.Ability) then
			
				local fireCount = 0
				local fireSkills = Utils.TableCat(FireNovaAbilities, FireballAbilities, RingOfFireAbilities)
				for k,v in fireSkills do
					if Validate.HasAbility(initialAgent, v) then
						fireCount = fireCount + 1
					end
				end
				
				#WARN('Fire Count: ' .. fireCount)
				if fireCount > 0 then
					if(initialAgent:GetHealthPercent() > 0.5) then
						result = true
					end
				end
			
            end
        end

        if(result) then
            agent.WorldStateData.FireMode = true
            agent.WorldStateConsistent = false
            return {}, BurnAliveTime
        else
            return result
        end
    end,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}
--[[
# ------------------------------------------------------------------------------
# FIRE NOVA
# ------------------------------------------------------------------------------
local FireNovaAbilities = {
    'HEMA01FireNova01',
    'HEMA01FireNova02',
    'HEMA01FireNova03',
}
local FireNovaDisables = table.append( DefaultDisables,
    {
        'Fire Nova - Hero',
        'Fire Nova - Units',
        'Fire Nova - Structure',
        'Fire Nova - Squad Target',
    }
)

local FireNovaTime = 2.5

function FireNovaWeights(action, aiBrain, agent, initialAgent)
    local result = false
    local actionBp = HeroAIActionTemplates[action.ActionName]

    if(agent.WorldStateData.FireMode and agent.WorldStateData.CanUseAbilities) then
        if(action.Ability and AIAbility.TestEnergy(agent, action.Ability)) then
            if(actionBp.ThreatAmount and actionBp.ThreatType and (aiBrain:GetThreatAtPosition(agent.Position, 1, actionBp.ThreatType, 'Enemy') > actionBp.ThreatAmount)) then
                result = true
            elseif(actionBp.SquadTarget) then
                local target = initialAgent.GOAP.AttackTarget
                if(target and not target:IsDead() and VDist3XZSq(agent.Position, target.Position) < 400) then
                    result = true
                end
            end
        end
    end

    if(result) then
        return actionBp.GoalWeights, FireNovaTime
    else
        return result
    end
end

# ----------------------------
# Fire Nova - Hero
# ----------------------------
HeroAIActionTemplate {
    Name = 'Fire Nova - Hero',
    UnitId = 'hema01',
    Abilities = FireNovaAbilities,
    DisableActions = FireNovaDisables,
    GoalSets = {
        Assassinate = true,
    },
    GoalWeights = {
        KillHero = -8,
    },
    ReasonIgnore = {
        Disabled = true,
    },
    ThreatAmount = 0,
    ThreatType = 'Hero',
    UninterruptibleAction = true,
    UnitCutoffThreshold = 1,
    ActionCategory = 'HERO',
    ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    ActionTimeout = 7,
    CalculateWeights = FireNovaWeights,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ----------------------------
# Fire Nova - Units
# ----------------------------
HeroAIActionTemplate {
    Name = 'Fire Nova - Units',
    UnitId = 'hema01',

    Abilities = FireNovaAbilities,
    DisableActions = FireNovaDisables,
    GoalSets = {
        Attack = true,
        Defend = true,
    },
    ReasonIgnore = {
        Disabled = true,
    },
    UninterruptibleAction = true,
    ActionCategory = 'GRUNT',
    ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    ActionTimeout = 7,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        local result = false
        local goalWeights

        if(agent.WorldStateData.FireMode and agent.WorldStateData.CanUseAbilities) then
            if(action.Ability and AIAbility.TestEnergy(agent, action.Ability)) then
                local threat = aiBrain:GetThreatAtPosition(agent.Position, 1, 'LandNoHero', 'Enemy')
                if(threat >= 40) then
                    goalWeights = {KillUnits = -10}
                    result = true
                elseif(threat >= 10) then
                    goalWeights = {KillUnits = -7}
                    result = true
                end
            end
        end

        if(result) then
            return goalWeights, FireNovaTime
        else
            return result
        end
    end,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ----------------------------
# Fire Nova - Structure
# ----------------------------
HeroAIActionTemplate {
    Name = 'Fire Nova - Structure',
    UnitId = 'hema01',
    Abilities = FireNovaAbilities,
    DisableActions = FireNovaDisables,
    GoalSets = {
        DestroyStructures = true,
    },
    GoalWeights = {
        KillStructures = -2,
    },
    ReasonIgnore = {
        Disabled = true,
    },
    ThreatAmount = 0,
    ThreatType = 'Structures',
    UninterruptibleAction = true,
    UnitCutoffThreshold = 1,
    ActionCategory = 'STRUCTURE',
    ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    ActionTimeout = 7,
    CalculateWeights = FireNovaWeights,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ----------------------------
# Fire Nova - Squad Target
# ----------------------------
HeroAIActionTemplate {
    Name = 'Fire Nova - Squad Target',
    UnitId = 'hema01',
    Abilities = FireNovaAbilities,
    DisableActions = FireNovaDisables,
    GoalSets = {
        SquadKill = true,
    },
    GoalWeights = {
        KillSquadTarget = -8,
    },
    ReasonIgnore = {
        Disabled = true,
    },
    UninterruptibleAction = true,
    UnitCutoffThreshold = 1,
    SquadTarget = true,
    TargetTypes = {'STRUCTURE', 'HERO', 'MOBILE'},
    ActionCleanupFunction = AIAbility.PointBlankAreaTargetAttackCleanup,
    ActionFunction = AIAbility.PointBlankAreaTargetAttackFunction,
    ActionTimeout = 7,
    CalculateWeights = FireNovaWeights,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ------------------------------------------------------------------------------
# FIREBALL
# ------------------------------------------------------------------------------
local FireballAbilities = {
    'HEMA01Fireball01',
    'HEMA01Fireball02',
    'HEMA01Fireball03',
    'HEMA01Fireball04',
}
local FireballDisables = table.append( DefaultDisables,
    {
        'Fireball - Hero',
        'Fireball - Structures',
        'Fireball - Squad Target',
    }
)
local FireballTime = 1.0

# ----------------------------
# Fireball - Hero
# ----------------------------
HeroAIActionTemplate {
    Name = 'Fireball - Hero',
    UnitId = 'hema01',
    Abilities = FireballAbilities,
    DisableActions = FireballDisables,
    GoalSets = {
        Attack = true,
        Assassinate = true,
    },
    GoalWeights = {
        KillHero = -5,
    },
    ReasonIgnore = {
        Disabled = true,
    },
    UninterruptibleAction = true,
    WeightTime = FireballTime,
    ActionFunction = AIAbility.TargetedAttackHeroFunction,
    ActionTimeout = 5,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        if(agent.WorldStateData.FireMode and agent.WorldStateData.CanUseAbilities) then
            return AIAbility.TargetedAttackWeightsHero(action, aiBrain, agent, initialAgent)
        else
            return false
        end
    end,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ----------------------------
# Fireball - Structures
# ----------------------------
HeroAIActionTemplate {
    Name = 'Fireball - Structures',
    UnitId = 'hema01',
    Abilities = FireballAbilities,
    DisableActions = FireballDisables,
    GoalSets = {
        DestroyStructures = true,
    },
    GoalWeights = {
        KillStructures = -3,
    },
    ReasonIgnore = {
        Disabled = true,
    },
    UninterruptibleAction = true,
    WeightTime = FireballTime,
    ActionFunction = AIAbility.TargetedAttackDefenseFunction,
    ActionTimeout = 5,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        if(agent.WorldStateData.FireMode and agent.WorldStateData.CanUseAbilities) then
            return AIAbility.TargetedAttackWeightsDefense(action, aiBrain, agent, initialAgent)
        else
            return false
        end
    end,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ----------------------------
# Fireball - Squad Target
# ----------------------------
HeroAIActionTemplate {
    Name = 'Fireball - Squad Target',
    UnitId = 'hema01',
    Abilities = FireballAbilities,
    DisableActions = FireballDisables,
    KillShot = true,
    GoalSets = {
        SquadKill = true,
    },
    GoalWeights = {
        KillSquadTarget = -5,
    },
    ReasonIgnore = {
        Disabled = true,
    },
    TargetTypes = {'STRUCTURE', 'HERO', 'MOBILE'},
    UninterruptibleAction = true,
    WeightTime = FireballTime,
    ActionFunction = AIAbility.TargetedAbilitySquadTargetFunction,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        if(agent.WorldStateData.FireMode and agent.WorldStateData.CanUseAbilities) then
            return AIAbility.TargetedAbilitySquadTargetWeights(action, aiBrain, agent, initialAgent)
        else
            return false
        end
    end,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ------------------------------------------------------------------------------
# RING OF FIRE
# ------------------------------------------------------------------------------
local RingOfFireAbilities = {
    'HEMA01RingOfFire01',
    'HEMA01RingOfFire02',
    'HEMA01RingOfFire03',
    'HEMA01RingOfFire04',
}
local RingOfFireDisables = table.append( DefaultDisables,
    {
        'Ring of Fire - Hero',
        'Ring of Fire - Units',
        'Ring of Fire - Structures',
        'Ring of Fire - Squad Target',
    }
)
local RingCastTime = 4

function RingOfFireActionFunction(unit, action)
    if(not AIAbility.PointBlankAreaAttackFunction(unit, action)) then
        return false
    end

    WaitSeconds(1)

    if(unit and not unit:IsDead()) then
        return AIAbility.FinishCasting(unit)
    else
        return false
    end
end

function RingOfFireWeights(action, aiBrain, agent, initialAgent)
    local result = false
    local actionBp = HeroAIActionTemplates[action.ActionName]

    if(agent.WorldStateData.FireMode and agent.WorldStateData.CanUseAbilities) then
        if(action.Ability and AIAbility.TestEnergy(agent, action.Ability)) then
            if(actionBp.ThreatAmount and actionBp.ThreatType and aiBrain:GetThreatAtPosition(agent.Position, 1, actionBp.ThreatType, 'Enemy') > actionBp.ThreatAmount) then
                result = true
            elseif(actionBp.SquadTarget) then
                local target = initialAgent.GOAP.AttackTarget
                if(target and not target:IsDead() and VDist3XZSq(agent.Position, target.Position) < 400) then
                    result = true
                end
            end
        end
    end

    if(result) then
        return actionBp.GoalWeights, RingCastTime
    else
        return result
    end
end

# ----------------------------
# Ring of Fire - Hero
# ----------------------------
HeroAIActionTemplate {
    Name = 'Ring of Fire - Hero',
    UnitId = 'hema01',
    Abilities = RingOfFireAbilities,
    DisableActions = RingOfFireDisables,
    GoalSets = {
        Assassinate = true,
        Attack = true,
    },
    GoalWeights = {
        KillHero = -3,
    },
    ReasonIgnore = {
        Disabled = true,
    },
    ThreatAmount = 0,
    ThreatType = 'Hero',
    UninterruptibleAction = true,
    ActionCategory = 'HERO',
    ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    ActionFunction = RingOfFireActionFunction,
    ActionTimeout = 5,
    CalculateWeights = RingOfFireWeights,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ----------------------------
# Ring of Fire - Units
# ----------------------------
HeroAIActionTemplate {
    Name = 'Ring of Fire - Units',
    UnitId = 'hema01',
    Abilities = RingOfFireAbilities,
    DisableActions = RingOfFireDisables,
    GoalSets = {
        Attack = true,
        Defend = true,
    },
    GoalWeights = {
        KillUnits = -3,
    },
    ReasonIgnore = {
        Disabled = true,
    },
    ThreatAmount = 5,
    ThreatType = 'LandNoHero',
    UninterruptibleAction = true,
    ActionCategory = 'GRUNT',
    ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    ActionFunction = RingOfFireActionFunction,
    ActionTimeout = 5,
    CalculateWeights = RingOfFireWeights,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ----------------------------
# Ring of Fire - Structures
# ----------------------------
HeroAIActionTemplate {
    Name = 'Ring of Fire - Structures',
    UnitId = 'hema01',
    Abilities = RingOfFireAbilities,
    DisableActions = RingOfFireDisables,
    GoalSets = {
        Attack = true,
        DestroyStructures = true,
    },
    GoalWeights = {
        KillStructures = -15,
    },
    ReasonIgnore = {
        Disabled = true,
    },
    ThreatAmount = 0,
    ThreatType = 'Structures',
    UninterruptibleAction = true,
    ActionCategory = 'STRUCTURE',
    ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    ActionFunction = RingOfFireActionFunction,
    ActionTimeout = 5,
    CalculateWeights = RingOfFireWeights,
    InstantStatusFunction = function(unit,action)
        if(unit:GetAIBrain():GetNumUnitsAroundPoint(categories.STRUCTURE, unit.Position, 20, 'Enemy') > 0) then
            return AIAbility.DefaultStatusFunction(unit,action)
        else
            return false
        end
    end,
}

# ----------------------------
# Ring of Fire - Squad Target
# ----------------------------
HeroAIActionTemplate {
    Name = 'Ring of Fire - Squad Target',
    UnitId = 'hema01',
    Abilities = RingOfFireAbilities,
    DisableActions = RingOfFireDisables,
    GoalSets = {
        SquadKill = true,
    },
    GoalWeights = {
        KillSquadTarget = -10,
    },
    ReasonIgnore = {
        Disabled = true,
    },
    SquadTarget = true,
    TargetTypes = {'STRUCTURE', 'HERO', 'MOBILE'},
    UninterruptibleAction = true,
    ActionFunction = function(unit, action)
        if(not AIAbility.PointBlankAreaTargetAttackFunction(unit, action)) then
            return false
        end

        WaitSeconds(1)

        if(unit and not unit:IsDead()) then
            return AIAbility.FinishCasting(unit)
        else
            return false
        end
    end,
    ActionTimeout = 5,
    CalculateWeights = RingOfFireWeights,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ------------------------------------------------------------------------------
# FROZEN HEART
# ------------------------------------------------------------------------------
local IceModeTime = 1.5
local FireDisables = table.append( DefaultDisables, FireAbilities )
--]]
# ----------------------------
# Frozen Heart
# ----------------------------
HeroAIActionTemplates['Frozen Heart'] = {
    Name = 'Frozen Heart',
    UnitId = 'hema01',
    Abilities = {
        'HEMA01SwitchIce',
    },
    DisableActions = FireDisables,
    GoalSets = {
		All = true,
        # -- Attack = true,
        # -- Defend = true,
        # -- Assassinate = true,
        # -- DestroyStructures = true,
        # -- SquadKill = true,
    },
    UninterruptibleAction = true,
    ActionFunction = function(unit,action)
        if not AIAbility.InstantActionFunction(unit,action) then
            return false
        end

        WaitSeconds(IceModeTime)
        if unit:IsDead() then
            return false
        end

        return true
    end,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        local result = false

        if(agent.WorldStateData.FireMode and agent.WorldStateData.CanUseAbilities) then
            if(action.Ability) then
			
				local coldCount = 0
				local coldSkills = Utils.TableCat(FrostNovaAbilities, RainOfIceAbilities, DeepFreezeAbilities)
				for k,v in coldSkills do
					if Validate.HasAbility(initialAgent, v) then
						coldCount = coldCount + 1
					end
				end
				
				#WARN('Cold Count: ' .. coldCount)
				if coldCount > 0 then
					if(initialAgent:GetHealthPercent() > 0.3) then
						result = true
					end
				end
        
				# -- if not result then
					# -- local enemyThreat = aiBrain:GetThreatAtPosition( agent.Position, 1, 'Hero', 'Enemy' )					
					# -- if enemyThreat > 0 or initialAgent:GetHealthPercent() <= 0.5 then
						# -- result = true
					# -- end
				# -- end
				
            end
        end

        if(result) then
            agent.WorldStateData.FireMode = false
            agent.WorldStateConsistent = false
            return {}, IceModeTime
        else
            return result
        end
    end,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# 0.26.48 - added miri's check to force the tb to stay in whatever mode its build is designed for
# eg if its a fire tb, it will stay in fire - ice, in ice
--Get TB's skill build mode - hybrid, fire, or ice
function GetBuildAbilityMode(unit)
    if not unit.BuildAbilityMode then
        local build = string.lower(unit:GetAIBrain().SkillBuild or 'none')
        local fire = string.find(build, 'fire')
        local ice = string.find(build, 'ice')
        local hybrid = string.find(build, 'hybrid')
        if hybrid or (ice and fire) then
            unit.BuildAbilityMode = 'hybrid'
        elseif ice then
            unit.BuildAbilityMode = 'ice'
        elseif fire then
            unit.BuildAbilityMode = 'fire'
        end
        # LOG("GetBuildAbilityMode: Setting mode: "..repr(unit.BuildAbilityMode))
    end
    return unit.BuildAbilityMode or 'unknown'
end

--Add a skill-build mode check to the mode-switch InstantStatusFunctions and ActionFunctions
local prevFireAction = HeroAIActionTemplates['Burn Alive'].ActionFunction
HeroAIActionTemplates['Burn Alive'].ActionFunction = function(unit, action)
    if GetBuildAbilityMode(unit) ~= 'ice' then
        return prevFireAction(unit, action)
    else
        return false
    end
end

local prevFireStatus = HeroAIActionTemplates['Burn Alive'].InstantStatusFunction
HeroAIActionTemplates['Burn Alive'].InstantStatusFunction = function(unit, action)
    if GetBuildAbilityMode(unit) ~= 'ice' then
        return prevFireStatus(unit, action)
    else
        return false
    end
end

local prevIceAction = HeroAIActionTemplates['Frozen Heart'].ActionFunction
HeroAIActionTemplates['Frozen Heart'].ActionFunction = function(unit, action)
    if GetBuildAbilityMode(unit) ~= 'fire' then
        return prevIceAction(unit, action)
    else
        return false
    end
end

local prevIceStatus = HeroAIActionTemplates['Frozen Heart'].InstantStatusFunction
HeroAIActionTemplates['Frozen Heart'].InstantStatusFunction = function(unit, action)
    if GetBuildAbilityMode(unit) ~= 'fire' then
        return prevIceStatus(unit, action)
    else
        return false
    end
end