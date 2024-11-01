# -- local AIAbility = import('/lua/sim/ai/AIAbilityUtilities.lua')
local ValidateAbility = import('/lua/common/ValidateAbility.lua')
# -- local DefaultDisables = import('/lua/sim/ai/AIGlobals.lua').DefaultDisables

----------------------------------------------------------------------------
# -- # POUNCE
----------------------------------------------------------------------------
local PounceAbilities = {
    'HSednaPounce01',    
    'HSednaPounce02',
    'HSednaPounce03',
    'HSednaPounce04',
}
local PounceCastTime = .3
--[[
local PounceDisables = table.append( DefaultDisables,
     {
         'Pounce - Hero',
         'Pounce - Squad Target',
     }
 )
--]]
--------------------------
# -- # Pounce - Hero
--------------------------
# 0.26.56 commented out my custom function - it is not needed
--# 0.26.55 commented out custom function and created a new one that does not care about interrupts - just spams

local AIUtils = import('/lua/sim/ai/aiutilities.lua')
--[[
function myPounceStatusFunction (unit, action)
  local result = false
	if(AIAbility.DefaultStatusFunction(unit, action)) then
		 if unit:GetEnergy() >= 300 then
			result = true
		 else
		end
	end
  return result
end
--]]

HeroAIActionTemplates['Pounce - Hero'] = {
    Name = 'Pounce - Hero',
    UnitId = 'hsedna',
    Abilities = PounceAbilities,
    DisableActions = PounceDisables,
    GoalSets = {
        Assassinate = true,
        Attack = true,
        Defend = true,
		CarefulAttack = true,
    },
# 0.26.56 removed captureflag goal per miri's advice
    GoalWeights = {
        KillHero = -50,
		--CaptureFlag = -50,
    },
    UninterruptibleAction = true,
    # UnitCutoffThreshold = 1,
    WeightTime = PounceCastTime,
    ActionFunction = AIAbility.TargetedAttackHeroFunction,
    ActionTimeout = 5,
    CalculateWeights = AIAbility.TargetedAttackWeightsHero,
	InstantStatusFunction = AIAbility.DefaultStatusFunction,	
	--InstantStatusFunction = myPounceStatusFunction,
}

# 0.26.55 this is a bunch of crap - had to overwrite the pounceone nonsense with more nonsense - looking forward to miri seeing this rot :P
HeroAIActionTemplates['PounceOne - Hero'] = {
    Name = 'PounceOne - Hero',
    UnitId = 'hsedna',
    Abilities = YetiAbilities,
    UnitCutoffThreshold = 1,
     DisableActions = YetiDisables,
     ActionTimeout = 5,
    ActionCategory = 'HERO',
    WeightTime = YetiCastTime,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
    ActionFunction = AIAbility.InstantActionFunction,
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
        if not agent.WorldStateData.CanUseAbilities then
            return false
        end

        if not AIAbility.TestEnergy( agent, action.Ability ) then
            return false
        end

        local returnTable = {
            KillHero = -10,
            KillUnits = 0,
            KillStructures = 0,
            KillSquadTarget = 0,
         }

        local bShouldCast = false
        # See if heroes are nearby
        if aiBrain:GetThreatAtPosition( agent.Position, 1, 'Hero' ) > 0 then
            returnTable.KillHero = -5
            bShouldCast = true
        end
        return returnTable, YetiCastTime
    end,
}


--------------------------
# -- # Pounce - Squad Target
--------------------------
HeroAIActionTemplates['Pounce - Squad Target'] = {
    Name = 'Pounce - Squad Target',
    UnitId = 'hsedna',
    Abilities = PounceAbilities,
    DisableActions = PounceDisables,
    GoalSets = {
        SquadKill = true,
    },
    GoalWeights = {
        KillSquadTarget = -10,
    },
    TargetTypes = { 'HERO', 'MOBILE' },
    UninterruptibleAction = true,
    # UnitCutoffThreshold = 1,
    WeightTime = PounceCastTime,
    ActionFunction = AIAbility.TargetedAttackHeroFunction,
    ActionTimeout = 5,
    CalculateWeights = AIAbility.TargetedAttackWeightsHero,
	InstantStatusFunction = AIAbility.DefaultStatusFunction,	
	--InstantStatusFunction = myPounceStatusFunction,
}

----------------------------------------------------------------------------
# -- # SUMMON YETI
----------------------------------------------------------------------------
# -- local YetiAbilities = {
    # -- 'HSednaYeti01',
    # -- 'HSednaYeti02',
    # -- 'HSednaYeti03',
    # -- 'HSednaYeti04',
# -- }
# -- local YetiCastTime = 3.0
# -- local YetiDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Summon Yeti',
    # -- }
# -- )

--------------------------
# -- # Summon Yeti
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'Summon Yeti',
    # -- UnitId = 'hsedna',
    # -- UninterruptibleAction = true,
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

    # -- Abilities = YetiAbilities,
    # -- UnitCutoffThreshold = 1,
    # -- DisableActions = YetiDisables,
    # -- ActionTimeout = 5,
    # -- ActionCategory = 'HERO',
    # -- WeightTime = YetiCastTime,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
    # -- ActionFunction = AIAbility.InstantActionFunction,
    # -- CalculateWeights = function( action, aiBrain, agent, initialAgent )
        # -- if not agent.WorldStateData.CanUseAbilities then
            # -- return false
        # -- end

        # -- if not AIAbility.TestEnergy( agent, action.Ability ) then
            # -- return false
        # -- end

        # -- local returnTable = {
            # -- KillHero = 0,
            # -- KillUnits = 0,
            # -- KillStructures = 0,
            # -- KillSquadTarget = 0,
        # -- }

        # -- local bShouldCast = false

        # -- # See if heroes are nearby
        # -- if aiBrain:GetThreatAtPosition( agent.Position, 1, 'Hero' ) > 0 then
            # -- returnTable.KillHero = -5
            # -- bShouldCast = true
        # -- end

        # -- # See if structures are nearby
        # -- if aiBrain:GetThreatAtPosition( agent.Position, 1, 'Structures' ) > 0 then
            # -- returnTable.KillStructures = -5
            # -- bShouldCast = true
        # -- end

        # -- # See if grunts are nearby
        # -- if aiBrain:GetThreatAtPosition( agent.Position, 1, 'LandNoHero') > 15 then
            # -- returnTable.KillUnits = -5
            # -- bShouldCast = true
        # -- end

        # -- if not bShouldCast then
            # -- return false
        # -- end

        # -- return returnTable, YetiCastTime
    # -- end,
# -- }

----------------------------------------------------------------------------
# -- # HEAL
----------------------------------------------------------------------------
# -- local HealAbilities = {
    # -- 'HSednaHeal01',
    # -- 'HSednaHeal02',
    # -- 'HSednaHeal03',
    # -- 'HSednaHeal04',
# -- }
local HealCastTime = .5
# -- local HealDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Heal - Self',
        # -- 'Heal - Friendly Hero',
    # -- }
# -- )

--------------------------
# -- # Heal - Self
--------------------------
HeroAIActionTemplates[ 'Heal - Self'] = {
    Name = 'Heal - Self',
    UnitId = 'hsedna',
    Abilities = HealAbilities,
    DisableActions = HealDisables,
    GoalSets = {
        All = true,
    },
    UninterruptibleAction = true,
    ActionFunction = AIAbility.TargetedSelfHeroFunction,
    ActionTimeout = 5,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        local result = false

        if(agent.WorldStateData.CanUseAbilities and action.Ability) then
			local allies = aiBrain:GetUnitsAroundPoint(categories.HERO, initialAgent.Position, 10, 'Ally')
			local healPercent = .85
			if table.getn(allies) > 0 then 
				healPercent = .7
			end
			
			if(initialAgent:GetHealthPercent() < healPercent)  then
				if(AIAbility.TestEnergy(agent, action.Ability)) then
					result = true
				end
			end
        end

        if(result == true) then
            return {Survival = -10, Health = -10}, HealCastTime
        else
            return result
        end
    end,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}

--------------------------
# -- # Heal - Friendly Hero
--------------------------
HeroAIActionTemplates['Heal - Friendly Hero'] = {
    Name = 'Heal - Friendly Hero',
    UnitId = 'hsedna',
    Abilities = HealAbilities,
    DisableActions = HealDisables,
    GoalSets = {
        All = true,
    },
    UninterruptibleAction = true,
    ActionFunction = AIAbility.TargetedWeakFriendHeroFunction,
    ActionTimeout = 5,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        local result = false

        if(agent.WorldStateData.CanUseAbilities and action.Ability) then
            if(AIAbility.TestEnergy(agent, action.Ability)) then			
                result = true
            end
        end

        if(result) then
            return {Survival = -10, SupportAlly = -20}, HealCastTime
        else
            return false
        end
    end,
    InstantStatusFunction = function(unit, action)
        local result = false

        if(AIAbility.DefaultStatusFunction(unit, action)) then	
            local allies = unit:GetAIBrain():GetUnitsAroundPoint(categories.HERO, unit.Position, 30, 'Ally')
            for k, v in allies do
                if(v != unit and v:GetHealthPercent() < 0.85) then
                    result = true
                    break
                end
            end
        end

        return result
    end,
}

----------------------------------------------------------------------------
# -- # SILENCE
----------------------------------------------------------------------------
# -- local SilenceAbilities = {
    # -- 'HSednaSilence01',
    # -- 'HSednaSilence02',
    # -- 'HSednaSilence03',
# -- }
# -- local SilenceCastTime = 0.5
# -- local SilenceDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Silence - Hero',
        # -- 'Silence - Squad Target',
    # -- }
# -- )

--------------------------
# -- # Silence - Hero
--------------------------
HeroAIActionTemplates['Silence - Hero'] = {
    Name = 'Silence - Hero',
    UnitId = 'hsedna',
    Abilities = SilenceAbilities,
    DisableActions = SilenceDisables,
    GoalSets = {
        Assassinate = true,
        Attack = true,
		Flee = true,
    },
    IgnoreBuffs = SilenceAbilities,
    UninterruptibleAction = true,
    UnitCutoffThreshold = 1,
    WeightTime = SilenceCastTime,
    ActionCategory = 'HERO',
    ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
    ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    ActionTimeout = 5,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        local enemyThreat = 0

        if(agent.WorldStateData.CanUseAbilities and action.Ability) then
            if(AIAbility.TestEnergy(agent, action.Ability)) then
                enemyThreat = aiBrain:GetNumUnitsAroundPoint( categories.HERO, agent.Position, 15, 'Enemy' )
            end
        end


        if(enemyThreat > 0) then
            return {KillHero = -6, Survival = -6}, SilenceCastTime
        else
            return false
        end
    end,
	InstantStatusFunction =  function(unit, action)
        local result = false

        if(AIAbility.DefaultStatusFunction(unit, action)) then
			local enemyHero = unit.GOAP.AttackTarget
# 0.27.03 removed interrupt code from silence			
--[[
			if(enemyHero != unit and enemyHero.CastingAbilityTask) then 
				# -- local announcement = "Interrupt: "..enemyHero.CastingAbilityTask
				# -- AIUtils.AIChat(unit, announcement)
				result = true
			end
--]]
			if enemyHero and enemyHero != unit and not enemyHero:IsDead() and enemyHero:GetHealthPercent() < .35 then
				result = true
			end


				
			if not result then
				local aiBrain = unit:GetAIBrain()	
				local enemyThreat = aiBrain:GetNumUnitsAroundPoint( categories.HERO, unit:GetPosition(), 15, 'Enemy' )
				
				
				#WARN('Sedna silence - ' .. enemyThreat )
				if enemyThreat >= 3 then
					 result = true
				end
				if enemyThreat > 0 and unit:GetHealthPercent() < .35 then
					result = true
				end

				
			end
        end

        return result
    end, 
}

--------------------------
# -- # Silence - Squad Target
--------------------------
HeroAIActionTemplates['Silence - Squad Target'] = {
    Name = 'Silence - Squad Target',
    UnitId = 'hsedna',
    Abilities = SilenceAbilities,
    DisableActions = SilenceDisables,
    GoalSets = {
        SquadKill = true,
    },
    IgnoreBuffs = SilenceAbilities,
    TargetTypes = {'HERO'},
    UninterruptibleAction = true,
    UnitCutoffThreshold = 1,
    WeightTime = SilenceCastTime,
    ActionCleanupFunction = AIAbility.PointBlankAreaTargetAttackCleanup,
    ActionFunction = AIAbility.PointBlankAreaTargetAttackFunction,
    ActionTimeout = 5,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        local result = false
		
		if 1 == 1 then
			return false
		end

        if(agent.WorldStateData.CanUseAbilities and action.Ability) then
            if(AIAbility.TestEnergy(agent, action.Ability)) then
                local target = initialAgent.GOAP.AttackTarget
                if(target and not target:IsDead() and VDist3XZ(agent.Position, target.Position) <= 20) then
                    result = true
                end
            end
        end

        if(result == true) then
            return {KillSquadTarget = -5}, SilenceCastTime
        else
            return result
        end
    end,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
}