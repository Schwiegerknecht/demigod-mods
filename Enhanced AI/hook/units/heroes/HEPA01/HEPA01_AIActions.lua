# -- local AIAbility = import('/lua/sim/ai/AIAbilityUtilities.lua')
# -- local AIGlobals = import('/lua/sim/ai/AIGlobals.lua')

# -- local Buff = import('/lua/sim/Buff.lua')

# -- local DefaultDisables = import('/lua/sim/ai/AIGlobals.lua').DefaultDisables

# ------------------------------------------------------------------------------
# VENOM SPIT
# ------------------------------------------------------------------------------
# -- local VenomSpitAbilities = {
    # -- 'HEPA01VenomSpit01',
    # -- 'HEPA01VenomSpit02',
    # -- 'HEPA01VenomSpit03',
    # -- 'HEPA01VenomSpit04',
# -- }
# -- local VenomSpitDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Venom Spit - Hero',
        # -- 'Venom Spit - Defense',
        # -- 'Venom Spit - Squad Target',
    # -- }
# -- )

# -- local function VenomSpitDamageCalc(ability)
    # -- if AIGlobals.AbilityDamage[ability] then
        # -- return AIGlobals.AbilityDamage[ability]
    # -- end

    # -- local damage = Ability[ability].DamageAmt
    
    # -- local buff = false
    # -- if ability == 'HEPA01VenomSpit01' then
        # -- buff = Buffs['HEPA01VenomSpitDoT01']
    # -- elseif ability == 'HEPA01VenomSpit02' then
        # -- buff = Buffs['HEPA01VenomSpitDoT02']
    # -- elseif ability == 'HEPA01VenomSpit03' then
        # -- buff = Buffs['HEPA01VenomSpitDoT03']
    # -- elseif ability == 'HEPA01VenomSpit04' then
        # -- buff = Buffs['HEPA01VenomSpitDoT04']
    # -- end

    # -- if buff then
        # -- for buffType,buffData in buff.Affects do
            # -- if buffType == 'Health' then
                # -- damage = damage + ( buff.Duration * math.abs(buffData.Add) )
            # -- end
        # -- end
    # -- else
        # -- WARN('*AI ERROR: Could not find buff for - ' .. ability )
    # -- end

    # -- AIGlobals.AbilityDamage[ability] = damage
    # -- return damage
# -- end

# ----------------------------
# Venom Spit - Hero
# ----------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Venom Spit - Hero',
    # -- UnitId = 'hepa01',
    # -- Abilities = VenomSpitAbilities,
    # -- DisableActions = VenomSpitDisables,
    # -- GoalSets = {
        # -- Attack = true,
        # -- Defend = true,
        # -- Assassinate = true,
    # -- },
    # -- GoalWeights = {
        # -- KillHero = -5,
    # -- },
    # -- UninterruptibleAction = true,
    # -- DamageCalculationFunction = VenomSpitDamageCalc,
    # -- ActionFunction = AIAbility.TargetedAttackHeroFunction,
    # -- CalculateWeights = AIAbility.TargetedAttackWeightsHero,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }

# ----------------------------
# Venom Spit - Defense
# ----------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Venom Spit - Defense',
    # -- UnitId = 'hepa01',
    # -- Abilities = VenomSpitAbilities,
    # -- DisableActions = VenomSpitDisables,
    # -- GoalSets = {
        # -- Attack = true,
        # -- DestroyStructures = true,
    # -- },
    # -- GoalWeights = {
        # -- KillStructures = -5,
    # -- },
    # -- UninterruptibleAction = true,
    # -- DamageCalculationFunction = VenomSpitDamageCalc,
    # -- ActionFunction = AIAbility.TargetedAttackDefenseFunction,
    # -- CalculateWeights = AIAbility.TargetedAttackWeightsDefense,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }

# ----------------------------
# Venom Spit - Squad Target
# ----------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Venom Spit - Squad Target',
    # -- UnitId = 'hepa01',
    # -- Abilities = VenomSpitAbilities,
    # -- DisableActions = VenomSpitDisables,
    # -- GoalSets = {
        # -- SquadKill = true,
    # -- },
    # -- GoalWeights = {
        # -- KillStructures = -5,
        # -- KillSquadTarget = -5,
    # -- },
    # -- TargetTypes = { 'STRUCTURE', 'HERO', 'MOBILE' },
    # -- UninterruptibleAction = true,
    # -- DamageCalculationFunction = VenomSpitDamageCalc,
    # -- ActionFunction = AIAbility.TargetedAbilitySquadTargetFunction,
    # -- CalculateWeights = AIAbility.TargetedAbilitySquadTargetWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }

# ------------------------------------------------------------------------------
# BESTIAL WRATH
# ------------------------------------------------------------------------------
# -- local BestialWrathAbilities = {
    # -- 'HEPA01BestialWrath01',
    # -- 'HEPA01BestialWrath02',
    # -- 'HEPA01BestialWrath03',
    # -- 'HEPA01BestialWrath04',
# -- }
# -- local BestialWrathDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Bestial Wrath',
    # -- }
# -- )
# -- local BestialWrathCastTime = 2

# -- local function BestialWrathMultiplier(ability)
    # -- if AIGlobals.AbilityDamage[ability] then
        # -- return AIGlobals.AbilityDamage[ability]
    # -- end

    # -- local damageMult = 1

    # -- local abilDef = Ability[ability]
    # -- local found = false
    # -- for _,buffName in abilDef.Buffs do
        # -- for buffType,buffData in Buffs[buffName].Affects do
            # -- if buffType != 'DamageRating' then
                # -- continue
            # -- end

            # -- damageMult = damageMult + buffData.Mult
            # -- found = true
        # -- end
        # -- if not found then
            # -- WARN('*AI WARNING: Could not find a new damage mult for ability - ' .. ability)
        # -- end
    # -- end

    # -- AIGlobals.AbilityDamage[ability] = damageMult
    # -- return damageMult
# -- end

# ----------------------------
# Bestial Wrath
# ----------------------------
HeroAIActionTemplates['Bestial Wrath'] = {
    Name = 'Bestial Wrath',
    UnitId = 'hepa01',
    UninterruptibleAction = true,
    DisableActions = BestialWrathDisables,
    GoalSets = {
        Attack = true,
        Defend = true,
        Assassinate = true,
        DestroyStructures = true,
        SquadKill = true,
    },
    Abilities = BestialWrathAbilities,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
    ActionFunction = AIAbility.InstantActionFunction,
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
        if not agent.WorldStateData.CanUseAbilities then
            return false
        end

        if not AIAbility.TestEnergy( agent, action.Ability ) then
            return false
        end

        agent.DamageRating = BestialWrathMultiplier(action.Ability) * agent.DamageRating

        local enemyThreat = aiBrain:GetThreatAtPosition( agent.Position, 1, 'Hero', 'Enemy' )

        if enemyThreat >= 0 then
            return {}, BestialWrathCastTime
        end

        return false
    end,
}

# ------------------------------------------------------------------------------
# OOZE
# ------------------------------------------------------------------------------
# -- local OozeDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Ooze On - Hero',
        # -- 'Ooze On - Units',
        # -- 'Ooze On - Squad Target',
        # -- 'Ooze Off',
    # -- }
# -- )
# -- local OozeOffAbilities = {
    # -- 'HEPA01OozeOff',
# -- }
# -- local OozeOnAbilities = {
    # -- 'HEPA01OozeOn',
# -- }
# 0.27.09 re-enabled ooze code
 local OozeTime = 1

function OozeOnWeights(action, aiBrain, agent, initialAgent)
    local result = false
    local actionBp = HeroAIActionTemplates[action.ActionName]

    if not agent.WorldStateData.CanUseAbilities then
        return false
    end

    if(not agent.WorldStateData.OozeMode) then
        if(action.Ability) then
            # 0.27.09 Changed ooze on value to >= 30% from >= 40%
			# Turn on Ooze if I have >= 30% health
            if(initialAgent:GetHealthPercent() >= .3) then
                if(actionBp.ThreatType and actionBp.ThreatNumber and aiBrain:GetThreatAtPosition(agent.Position, 1, actionBp.ThreatType, 'Enemy') >= actionBp.ThreatNumber) then
                    result = true
                end
                if(actionBp.SquadTarget and initialAgent.GOAP.AttackTarget) then
                    result = true
                end
            end
        end
    end

    if(result) then
        agent.WorldStateData.OozeMode = true
        agent.WorldStateData.HeroKillBonus = agent.WorldStateData.HeroKillBonus - 1
        agent.WorldStateData.GruntKillBonus = agent.WorldStateData.GruntKillBonus - 1
        agent.WorldStateConsistent = false
        return actionBp.GoalWeights, OozeTime
    else
        return result
    end
end

function OozeOffWeights(action, aiBrain, agent, initialAgent)
    local result = false
    local actionBp = HeroAIActionTemplates[action.ActionName]

    if(agent.WorldStateData.OozeMode) then
        if(action.Ability) then
		    # 0.27.09 Changed ooze on value to < 30% from < 40%
            # Turn off Ooze if my health is < 30%
            # Turn off Ooze if land threat is <= 5
            if(initialAgent:GetHealthPercent() < .3) then
                result = true
            elseif(aiBrain:GetThreatAtPosition(agent.Position, 1, 'Land', 'Enemy') <= 5) then
			# WARN( 'current threat value - ' .. aiBrain:GetThreatAtPosition(agent.Position, 1, 'Land', 'Enemy'))		
                result = true
            end
        end
    end

    if(result) then
        agent.WorldStateData.OozeMode = false
        agent.WorldStateData.HeroKillBonus = agent.WorldStateData.HeroKillBonus + 1
        agent.WorldStateData.GruntKillBonus = agent.WorldStateData.GruntKillBonus + 1
        agent.WorldStateConsistent = false
        return actionBp.GoalWeights, OozeTime
    else
        return result
    end
end

# ----------------------------
# Ooze On - Hero
# ----------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Ooze On - Hero',
    # -- UnitId = 'hepa01',
    # -- Abilities = OozeOnAbilities,
    # -- DisableActions = OozeDisables,
    # -- GoalSets = {
        # -- Assassinate = true,
        # -- Attack = true,
    # -- },
    # -- GoalWeights = {
        # -- KillHero = -5,
    # -- },
    # -- ThreatNumber = 0,
    # -- ThreatType = 'Hero',
    # -- UninterruptibleAction = true,
    # -- ActionFunction = AIAbility.InstantActionFunction,
    # -- CalculateWeights = OozeOnWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }

# ----------------------------
# Ooze On - Units
# ----------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Ooze On - Units',
    # -- UnitId = 'hepa01',
    # -- Abilities = OozeOnAbilities,
    # -- DisableActions = OozeDisables,
    # -- GoalSets = {
        # -- Attack = true,
        # -- Defend = true,
    # -- },
    # -- GoalWeights = {
        # -- KillUnits = -5,
    # -- },
    # -- ThreatNumber = 10,
    # -- ThreatType = 'LandNoHero',
    # -- UninterruptibleAction = true,
    # -- ActionFunction = AIAbility.InstantActionFunction,
    # -- CalculateWeights = OozeOnWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }

# ----------------------------
# Ooze On - Squad Target
# ----------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Ooze On - Squad Target',
    # -- UnitId = 'hepa01',
    # -- Abilities = OozeOnAbilities,
    # -- DisableActions = OozeDisables,
    # -- GoalSets = {
        # -- SquadKill = true,
    # -- },
    # -- GoalWeights = {
        # -- KillSquadTarget = -5,
    # -- },
    # -- SquadTarget = true,
    # -- TargetTypes = {'HERO', 'MOBILE'},
    # -- UninterruptibleAction = true,
    # -- ActionFunction = AIAbility.InstantActionFunction,
    # -- CalculateWeights = OozeOnWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }

# ----------------------------
# Ooze Off
# ----------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Ooze Off',
    # -- UnitId = 'hepa01',
    # -- Abilities = OozeOffAbilities,
    # -- DisableActions = OozeDisables,
    # -- GoalSets = {
        # -- All = true,
    # -- },
    # -- GoalWeights = {
        # -- Health = -5,
        # -- Survival = -5,
    # -- },
    # -- UninterruptibleAction = true,
    # -- ActionFunction = AIAbility.InstantActionFunction,
    # -- CalculateWeights = OozeOffWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }

# ------------------------------------------------------------------------------
# FOUL GRASP
# ------------------------------------------------------------------------------
# -- local FoulGraspAbilities = {
    # -- 'HEPA01FoulGrasp01',
    # -- 'HEPA01FoulGrasp02',
    # -- 'HEPA01FoulGrasp03',
# -- }
# -- local FoulGraspDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Foul Grasp - Hero',
        # -- 'Foul Grasp - Squad Target',
    # -- }
# -- )

local FoulGraspCastTime = 5

 local function FoulGraspDamage(ability)
    if AIGlobals.AbilityDamage[ability] then
        return AIGlobals.AbilityDamage[ability]
    end
    local def = Ability[ability]
     local damage = 0
     if def then
         damage = def.Amount * def.Pulses
     else
         WARN('*AI WARNING: Could not get damage for ability - ' .. ability)
     end

     AIGlobals.AbilityDamage[ability] = damage
     return damage
 end

# ----------------------------
# Foul Grasp - Hero
# ----------------------------

# 0.26.56 removed custom grasp function as it is not needed
--# 0.26.50 [MOD] Use new grasp function 

--[[
local AIUtils = import('/lua/sim/ai/aiutilities.lua')
function myGraspStatusFunction (unit, action)
  local result = false
	if(AIAbility.DefaultStatusFunction(unit, action)) then
		 if unit:GetEnergy() >= 800 then
			result = true
		 else
		end
	end
  return result
end
--]]

local AIUtils = import('/lua/sim/ai/aiutilities.lua')
HeroAIActionTemplates['Foul Grasp - Hero'] = {
    Name = 'Foul Grasp - Hero',
    UnitId = 'hepa01',
    Abilities = FoulGraspAbilities,
    DisableActions = FoulGraspDisables,
    GoalSets = {
        Attack = true,
        Defend = true,
        Assassinate = true,
		CarefulAttack = true,
    },

    GoalWeights = {

# 0.26.56 Removed CaptureFlag setting
--# 0.26.55 Fixed a typo with the capture flag functionality (must be CaptureFlag - not Captureflag)
--# 0.26.52 added capture flag -10
--# 0.26.50 increased kilhero and health from -5 and -2 to -10 and -5

        KillHero = -15,
		Health = -5,
    },
    UninterruptibleAction = true,
    WeightTime = FoulGraspCastTime,	
    ActionFunction = AIAbility.TargetedAttackHeroFunction,
    ActionTimeout = 5,
    DamageCalculationFunction = FoulGraspDamage,
    CalculateWeights = AIAbility.TargetedAttackWeightsHero,
	InstantStatusFunction = AIAbility.DefaultStatusFunction,	

}

# ----------------------------
# Foul Grasp - Squad Target
# ----------------------------
HeroAIActionTemplates['Foul Grasp - Squad Target'] = {
    Name = 'Foul Grasp - Squad Target',
    UnitId = 'hepa01',
    Abilities = FoulGraspAbilities,
    DisableActions = FoulGraspDisables,
    GoalSets = {
        SquadKill = true,
    },

    GoalWeights = {
        KillSquadTarget = -15,
        Health = -5,
    },
    TargetTypes = { 'HERO' },
    UninterruptibleAction = true,
	WeightTime = FoulGraspCastTime,	
    ActionTimeout = 5,
    DamageCalculationFunction = FoulGraspDamage,
    CalculateWeights = AIAbility.TargetedAbilitySquadTargetWeights,
	InstantStatusFunction = AIAbility.DefaultStatusFunction,	
}