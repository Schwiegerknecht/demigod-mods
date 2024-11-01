local GetWeakestUnit = import('/lua/sim/ai/aiutilities.lua').GetWeakestUnit


--[[
local AIAbility = import('/lua/sim/ai/AIAbilityUtilities.lua')
local GetReadyAbility = AIAbility.GetReadyAbility
local ValidateAbility = import('/lua/common/ValidateAbility.lua')
local AIGlobals = import('/lua/sim/ai/AIGlobals.lua')

local DefaultDisables = import('/lua/sim/ai/AIGlobals.lua').DefaultDisables

# ------------------------------------------------------------------------------
# SNIPE
# ------------------------------------------------------------------------------
local SnipeAbilities = {
    'HGSA01Snipe01',
    'HGSA01Snipe02',
    'HGSA01Snipe03',
    'HGSA01Snipe04',
}
local SnipeDisables = table.append( DefaultDisables,
    {
        'Snipe - Hero',
        'Snipe - Structure',
        'Snipe - Squad Target',
    }
)

local function SnipeDamage(ability)
    if AIGlobals.AbilityDamage[ability] then
        return AIGlobals.AbilityDamage[ability]
    end

    local damage = Ability[ability].DamageAmt + 100 # 100 is for the travelling distance damage

    AIGlobals.AbilityDamage[ability] = damage
    return damage
end

]]-- 
# ----------------------------
# Snipe - Hero
# ----------------------------
HeroAIActionTemplates['Snipe - Hero'] = {
    Name = 'Snipe - Hero',
    UnitId = 'hgsa01',
    Abilities = SnipeAbilities,
    DisableActions = SnipeDisables,
    #KillShot = true,
    GoalSets = {
        # -- Assassinate = true,
        # -- Attack = true,
        # -- Defend = true,
		All = true,

    },
    GoalWeights = {
        KillHero = -500,
    },
    DamageCalculationFunction = SnipeDamage,
    UninterruptibleAction = true,
    ActionFunction = AIAbility.TargetedAttackHeroFunction,
    ActionTimeout = 2,
    CalculateWeights =  function( action, aiBrain, agent, initialAgent )
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
	
	# -- if initialAgent:GetHealth() < 900 then
        # -- return false	
	# -- end
	
	local range = 90
	local returnValue = table.copy(actionBp.GoalWeights)
	# [MOD] TE Minimum Distance for snipe


	

	local units = aiBrain:GetBlipsAroundPoint( categories.HERO, initialAgent:GetPosition(), range, 'Enemy' )

	local target = GetWeakestUnit( units,  actionBp.TargetIgnoreBuffs )
	
	if target and target:GetHealth() < actionBp.DamageCalculationFunction(action.Ability) then
		returnValue.KillHero = -500
		returnValue.KillSquadTarget = -500				
		returnValue.KillUnits = -500
		returnValue.CaptureFlag = -100		
		returnValue.AttackWithHelp = -100
		returnValue.KillStructures  = -100
		returnValue.PurchaseItems  = -50
		returnValue.Health  = -50		
		returnValue.Survival  = -50		
		returnValue.Energy = -50			
		#WARN('Snipe Target health' .. target:GetHealth() .. ' - vs -' .. actionBp.DamageCalculationFunction(action.Ability) )
		 return returnValue, 2
	end
		

    if initialAgent.GOAP.NearbyEnemyHeroes.ClosestDistance and initialAgent.GOAP.NearbyEnemyHeroes.ClosestDistance < 20 then
        return false
    end

	
	# -- range = 90	
	# -- local units = aiBrain:GetBlipsAroundPoint( categories.HERO, initialAgent:GetPosition(), range, 'Enemy' )

	# -- local target = GetWeakestUnit( units,  actionBp.TargetIgnoreBuffs )	

	
    if target then	
		returnValue.KillHero = -500
		returnValue.KillSquadTarget = -500				
		returnValue.KillUnits = -500
		returnValue.CaptureFlag = -100		
		returnValue.AttackWithHelp = -100
		returnValue.KillStructures  = -100
		returnValue.PurchaseItems  = -50
		returnValue.Health  = -5		
		returnValue.Survival  = -5	
		returnValue.Energy = -5					
    end


    if target then
        return returnValue, 2  #actionBp.WeightTime or Ability[action.Ability].CastingTime or 0
	else
		return false
    end
 
    end,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ----------------------------
# Snipe - Structure
# ----------------------------
HeroAIActionTemplates['Snipe - Structure'] =  {
    Name = 'Snipe - Structure',
    UnitId = 'hgsa01',
    Abilities = SnipeAbilities,
    DisableActions = SnipeDisables,
    KillShot = true,
    GoalSets = {
        DestroyStructures = true,
    },
    GoalWeights = {
        KillStructures = 0,
    },
    UninterruptibleAction = true,
    DamageCalculationFunction = SnipeDamage,
    ActionFunction = AIAbility.TargetedAttackDefenseFunction,
    ActionTimeout = 4,
    CalculateWeights = AIAbility.TargetedAttackWeightsDefense,
    InstantStatusFunction = false, #AIAbility.DefaultStatusFunction
}

# ----------------------------
# Snipe - Squad Target
# ----------------------------
HeroAIActionTemplates['Snipe - Squad Target'] = {
    Name = 'Snipe - Squad Target',
    UnitId = 'hgsa01',
    Abilities = SnipeAbilities,
    DisableActions = SnipeDisables,
    KillShot = true,
    GoalSets = {
        SquadKill = true,
    },
    GoalWeights = {
        KillSquadTarget = 0,
    },
    TargetTypes = { 'HERO', 'MOBILE' },
    DamageCalculationFunction = SnipeDamage,
    UninterruptibleAction = true,
    ActionFunction = AIAbility.TargetedAbilitySquadTargetFunction,
    ActionTimeout = 4,
    CalculateWeights = AIAbility.TargetedAbilitySquadTargetWeights,
    InstantStatusFunction = false, #AIAbility.DefaultStatusFunction,
}
--[[
# ------------------------------------------------------------------------------
# ANGELIC FURY
# ------------------------------------------------------------------------------
local AngelicFuryDisables = table.append( DefaultDisables,
    {
        'Angelic Fury - On - Hero',
        'Angelic Fury - On - Units',
        'Angelic Fury - On - Squad Target',
        'Vengeace - On - Hero',
        'Vengeace - On - Units',
        'Vengeace - On - Squad Target',
        'Angelic Fury - Off',
    }
)
local AngelicFuryOffAbilities = {
    'HGSA01AngelicFuryOff',
}
local AngelicFuryOnAbilities = {
    'HGSA01AngelicFuryOn',
}
local AngelicFuryTime = 1

function AngelicFuryStatusFunction(unit, action)
    local ready = false

    if(not ValidateAbility.HasAbility(unit, 'HGSA01Vengeance01')) then
        local actionBp = HeroAIActionTemplates[action.ActionName]
        local abilities = actionBp.Abilities

        local ignore = { Energy = true }
        ready = GetReadyAbility(unit, abilities, ignore)

        # If the action requires a target type, check what the unit's target is
        if(actionBp.TargetTypes and not AIAbility.CheckTargetTypes(unit,action)) then
            ready = false
        end
    end

    if(ready) then
        action.Ability = ready
        return true
    else
        action.Ability = false
        return false
    end
end

function VengeanceStatusFunction(unit, action)
    local ready = false

    if(ValidateAbility.HasAbility(unit, 'HGSA01Vengeance01')) then
        local actionBp = HeroAIActionTemplates[action.ActionName]
        local abilities = actionBp.Abilities

        local ignore = { Energy = true }
        ready = GetReadyAbility(unit, abilities, ignore)

        # If the action requires a target type, check what the unit's target is
        if(actionBp.TargetTypes and not AIAbility.CheckTargetTypes(unit,action)) then
            ready = false
        end
    end

    if(ready) then
        action.Ability = ready
        return true
    else
        action.Ability = false
        return false
    end
end

function AngelicFuryOnWeights(action, aiBrain, agent, initialAgent)
    local result = false
    local actionBp = HeroAIActionTemplates[action.ActionName]

    if(not agent.WorldStateData.AngelicFuryMode and agent.WorldStateData.CanUseAbilities) then
        if(action.Ability) then
            local energyPercent = initialAgent:GetEnergyPercent()
            # Turn on Angelic Fury if I have > 40% mana
            if(initialAgent:GetEnergyPercent() > .4) then
                if(actionBp.ThreatType and actionBp.ThreatNumber and aiBrain:GetThreatAtPosition(agent.Position, 1, actionBp.ThreatType, 'Enemy') >= actionBp.ThreatNumber) then
                    result = true
                end
                if(actionBp.SquadTarget and initialAgent.GOAP.AttackTarget) then
                    result = true
                end
            end
        end
    end

    if(result == true) then
        agent.WorldStateData.AngelicFuryMode = true
        agent.WorldStateData.HeroKillBonus = agent.WorldStateData.HeroKillBonus - 1
        agent.WorldStateData.GruntKillBonus = agent.WorldStateData.GruntKillBonus - 1
        agent.WorldStateConsistent = false
        return actionBp.GoalWeights, AngelicFuryTime
    else
        return result
    end
end

function AngelicFuryOffWeights(action, aiBrain, agent, initialAgent)
    local result = false

    if(agent.WorldStateData.AngelicFuryMode) then
        if(action.Ability) then
            # Turn off Angelic Fury if my mana is < 40%
            if(initialAgent:GetEnergyPercent() < .4) then
                result = true
            end
        end
    end

    if(result == true) then
        agent.WorldStateData.AngelicFuryMode = false
        agent.WorldStateData.HeroKillBonus = agent.WorldStateData.HeroKillBonus + 1
        agent.WorldStateData.GruntKillBonus = agent.WorldStateData.GruntKillBonus + 1
        agent.WorldStateConsistent = false
        return {Energy = -4}, AngelicFuryTime
    else
        return result
    end
end

# ----------------------------
# Angelic Fury - On - Hero
# ----------------------------
HeroAIActionTemplate {
    Name = 'Angelic Fury - On - Hero',
    UnitId = 'hgsa01',
    Abilities = AngelicFuryOnAbilities,
    DisableActions = AngelicFuryDisables,
    GoalSets = {
        Assassinate = true,
        Attack = true,
    },
    GoalWeights = {
        KillHero = -2,
    },
    ThreatNumber = 40,
    ThreatType = 'Hero',
    UninterruptibleAction = true,
    ActionFunction = AIAbility.InstantActionFunction,
    CalculateWeights = AngelicFuryOnWeights,
    InstantStatusFunction = AngelicFuryStatusFunction,
}

# ----------------------------
# Angelic Fury - On - Units
# ----------------------------
HeroAIActionTemplate {
    Name = 'Angelic Fury - On - Units',
    UnitId = 'hgsa01',
    Abilities = AngelicFuryOnAbilities,
    DisableActions = AngelicFuryDisables,
    GoalSets = {
        Attack = true,
        Defend = true,
    },
    GoalWeights = {
        KillUnits = -4,
    },
    ThreatNumber = 10,
    ThreatType = 'LandNoHero',
    UninterruptibleAction = true,
    ActionFunction = AIAbility.InstantActionFunction,
    CalculateWeights = AngelicFuryOnWeights,
    InstantStatusFunction = AngelicFuryStatusFunction,
}

# ----------------------------
# Angelic Fury - On - Squad Target
# ----------------------------
HeroAIActionTemplate {
    Name = 'Angelic Fury - On - Squad Target',
    UnitId = 'hgsa01',
    Abilities = AngelicFuryOnAbilities,
    DisableActions = AngelicFuryDisables,
    GoalSets = {
        SquadKill = true
    },
    GoalWeights = {
        KillSquadTarget = -4,
    },
    SquadTarget = true,
    TargetTypes = {'HERO', 'MOBILE'},
    UninterruptibleAction = true,
    ActionFunction = AIAbility.InstantActionFunction,
    CalculateWeights = AngelicFuryOnWeights,
    InstantStatusFunction = AngelicFuryStatusFunction,
}

# ----------------------------
# Vengeance - On - Hero
# ----------------------------
HeroAIActionTemplate {
    Name = 'Vengeance - On - Hero',
    UnitId = 'hgsa01',
    Abilities = AngelicFuryOnAbilities,
    DisableAction = AngelicFuryDisables,
    GoalSets = {
        Assassinate = true,
        Attack = true,
    },
    GoalWeights = {
        KillHero = -4,
    },
    TestRadius = Ability['HGSA01AngelicFuryOn'].VengAffectRadius,
    ThreatNumber = 40,
    ThreatType = 'Hero',
    UninterruptibleAction = true,
    UnitThreshold = 1,
    ActionCategory = 'HERO',
    ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    ActionTimeout = 7,
    CalculateWeights = AngelicFuryOnWeights,
    InstantStatusFunction = VengeanceStatusFunction,
}

# ----------------------------
# Vengeance - On - Units
# ----------------------------
HeroAIActionTemplate {
    Name = 'Vengeance - On - Units',
    UnitId = 'hgsa01',
    Abilities = AngelicFuryOnAbilities,
    DisableAction = AngelicFuryDisables,
    GoalSets = {
        Attack = true,
        Defend = true
    },
    GoalWeights = {
        KillUnits = -6,
    },
    TestRadius = Ability['HGSA01AngelicFuryOn'].VengAffectRadius,
    ThreatNumber = 15,
    ThreatType = 'LandNoHero',
    UninterruptibleAction = true,
    UnitThreshold = 4,
    ActionCategory = 'GRUNT',
    ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    ActionTimeout = 7,
    CalculateWeights = AngelicFuryOnWeights,
    InstantStatusFunction = VengeanceStatusFunction,
}

# ----------------------------
# Vengeance - On - Squad Target
# ----------------------------
HeroAIActionTemplate {
    Name = 'Vengeance - On - Squad Target',
    UnitId = 'hgsa01',
    Abilities = AngelicFuryOnAbilities,
    DisableAction = AngelicFuryDisables,
    GoalSets = {
        SquadKill = true,
    },
    GoalWeights = {
        KillSquadTarget = -6,
    },
    SquadTarget = true,
    TargetTypes = {'HERO', 'MOBILE'},
    TestRadius = Ability['HGSA01AngelicFuryOn'].VengAffectRadius,
    UninterruptibleAction = true,
    ActionCleanupFunction = AIAbility.PointBlankAreaTargetAttackCleanup,
    ActionFunction = AIAbility.PointBlankAreaTargetAttackFunction,
    ActionTimeout = 7,
    CalculateWeights = AngelicFuryOnWeights,
    InstantStatusFunction = VengeanceStatusFunction,
}

# ----------------------------
# Angelic Fury - Off
# ----------------------------
HeroAIActionTemplate {
    Name = 'Angelic Fury - Off',
    UnitId = 'hgsa01',
    Abilities = AngelicFuryOffAbilities,
    DisableActions = AngelicFuryDisables,
    GoalSets = {
        All = true,
    },
    UninterruptibleAction = true,
    ActionFunction = AIAbility.InstantActionFunction,
    CalculateWeights = AngelicFuryOffWeights,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ------------------------------------------------------------------------------
# BETRAYER
# ------------------------------------------------------------------------------
local BetrayerAbilities = {
    'HGSA01Betrayer01',
    'HGSA01Betrayer02',
    'HGSA01Betrayer03',
}
local BetrayerDisables = table.append( DefaultDisables, {
        'Betrayer - Hero',
        'Betrayer - Squad Target',
    }
)

local function BetrayerDamage(ability)
    if AIGlobals.AbilityDamage[ability] then
        return AIGlobals.AbilityDamage[ability]
    end

    local damage = 0

    local buff = Buffs[ability]

    if buff then
        damage = buff.DamageAmt
    else
        WARN('*AI Warning: Could not get a damage data for - ' .. ability)
    end

    AIGlobals.AbilityDamage[ability] = damage
    return damage
end
]]--
# ----------------------------
# Betrayer - Hero
# ----------------------------
HeroAIActionTemplates['Betrayer - Hero'] = {
    Name = 'Betrayer - Hero',
    UnitId = 'hgsa01',
    Abilities = BetrayerAbilities,
    DisableActions = BetrayerDisables,
    GoalSets = {
        Assassinate = true,
        Attack = true,
        Defend = true,
		CarefulAttack = true,
    },
    GoalWeights = {
        KillHero = -50,
    },
    UninterruptibleAction = true,
    DamageCalculationFunction = BetrayerDamage,
    ActionFunction = AIAbility.TargetedAttackHeroFunction,
    ActionTimeout = 4,
    CalculateWeights = AIAbility.TargetedAttackWeightsHero,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}


# 0.27.00 removed strucutre from target types as that's not possible
# 0.26.50 Re-enabled this code and increased the value of killsquadtarget to -50
# ----------------------------
# Betrayer - Squad Target
# ----------------------------
HeroAIActionTemplates['Betrayer - Squad Target'] = {
    Name = 'Betrayer - Squad Target',
    UnitId = 'hgsa01',
    Abilities = BetrayerAbilities,
    DisableActions = BetrayerDisables,
    GoalSets = {
        SquadKill = true,
    },
    GoalWeights = {
        KillSquadTarget = -50,
    },
    TargetTypes = { 'HERO', 'MOBILE' },
    UninterruptibleAction = true,
    DamageCalculationFunction = BetrayerDamage,
    ActionFunction = AIAbility.TargetedAbilitySquadTargetFunction,
    ActionTimeout = 4,
    CalculateWeights = AIAbility.TargetedAbilitySquadTargetWeights,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

--[[
# ------------------------------------------------------------------------------
# SHOOT MINE
# ------------------------------------------------------------------------------
local MineAbilities = {
    'HGSA01ExplosiveMine01',
    'HGSA01ExplosiveMine02',
    'HGSA01ExplosiveMine03',
    'HGSA01ShrapnelMine01',
}
local MineDisables = table.append( DefaultDisables,
    {
        'Shoot Mine - Hero',
        'Shoot Mine - Grunts',
        'Shoot Mine - Nearby Flag',
        'Shoot Mine - Squad Target',
    }
)

function ShootMineWeights(action, aiBrain, agent, initialAgent)
    local result = false
    local actionBp = HeroAIActionTemplates[action.ActionName]

    if not agent.WorldStateData.CanUseAbilities then
        return false
    end

    if(action.Ability) then
        if(AIAbility.TestEnergy(agent, action.Ability)) then
            if(aiBrain:GetThreatAtPosition(agent.Position, 1, 'Land', 'Enemy') > 0) then
                result = true
            end
        end
    end

    if(result == true) then
        return actionBp.GoalWeights, Ability[action.Ability].CastingTime
    else
        return result
    end
end

# ----------------------------
# Shoot Mine - Hero
# ----------------------------
HeroAIActionTemplate {
    Name = 'Shoot Mine - Hero',
    UnitId = 'hgsa01',
    Abilities = MineAbilities,
    DisableActions = MineDisables,
    GoalSets = {
        Assassinate = true,
        Attack = true,
        Defend = true,
    },
    GoalWeights = {
        KillHero = -5,
    },
    UninterruptibleAction = true,
    ActionCategory = 'HERO',
    ActionFunction = AIAbility.TargetedAreaAttackAbility,
    ActionTimeout = 5,
    CalculateWeights = ShootMineWeights,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ----------------------------
# Shoot Mine - Grunts
# ----------------------------
HeroAIActionTemplate {
    Name = 'Shoot Mine - Grunts',
    UnitId = 'hgsa01',
    Abilities = MineAbilities,
    DisableActions = MineDisables,
    GoalSets = {
        Attack = true,
    },
    GoalWeights = {
        KillUnits = -5,
    },
    UninterruptibleAction = true,
    ActionCategory = 'GRUNT',
    ActionFunction = AIAbility.TargetedAreaAttackAbility,
    ActionTimeout = 5,
    CalculateWeights = ShootMineWeights,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

# ----------------------------
# Shoot Mine - Nearby Flag
# ----------------------------
HeroAIActionTemplate {
    Name = 'Shoot Mine - Nearby Flag',
    UnitId = 'hgsa01',
    Abilities = MineAbilities,
    DisableActions = MineDisables,
    GoalSets = {
        Attack = true,
        CaptureFlag = true,
    },
    UninterruptibleAction = true,
    ActionCategory = 'FLAG',
    ActionFunction = AIAbility.TargetedAreaAttackAbility,
    ActionTimeout = 5,
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

        local goapAction = initialAgent.GOAP.Actions[action.ActionName]
        if not goapAction.FlagPosition then
            return false
        end

        agent:SetPosition( goapAction.FlagPosition )

        return {
            CaptureFlag = -5,
            KillUnits = -3,
            KillHero = -3,
        }, Ability[action.Ability].CastingTime

    end,
    InstantStatusFunction = function(unit,action)
        local aiBrain = unit:GetAIBrain()
        local nearFlag = nil
        action.FlagPosition = false

        local flags = aiBrain:GetUnitsAroundPoint( categories.FLAG, unit.Position, 32 )
        if table.empty(flags) then
            return false
        end

        action.FlagPosition = nearFlag.Position

        return AIAbility.DefaultStatusFunction(unit,action)
    end,
}

# ----------------------------
# Shoot Mine - Squad Target
# ----------------------------
HeroAIActionTemplate {
    Name = 'Shoot Mine - Squad Target',
    UnitId = 'hgsa01',
    Abilities = MineAbilities,
    DisableActions = MineDisables,
    GoalSets = {
        SquadKill = true,
    },
    GoalWeights = {
        KillSquadTarget = -5,
    },
    TargetTypes = { 'HERO', 'MOBILE' },
    UninterruptibleAction = true,
    ActionCategory = 'HERO, GRUNT',
    ActionFunction = AIAbility.TargetedAreaAttackAbility,
    ActionTimeout = 5,
    CalculateWeights = ShootMineWeights,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}
--]]