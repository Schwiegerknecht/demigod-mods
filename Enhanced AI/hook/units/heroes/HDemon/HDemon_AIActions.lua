# -- local AIAbility = import('/lua/sim/ai/AIAbilityUtilities.lua')
# -- local GetReadyAbility = AIAbility.GetReadyAbility
# -- local ValidateAbility = import('/lua/common/ValidateAbility.lua')
# -- local AIGlobals = import('/lua/sim/ai/AIGlobals.lua')

# -- local DefaultDisables = import('/lua/sim/ai/AIGlobals.lua').DefaultDisables

----------------------------------------------------------------------------
# -- # Warp Strike
----------------------------------------------------------------------------
# -- local WarpStrikeAbilities = {
    # -- 'HDemonWarpStrike01',
    # -- 'HDemonWarpStrike02',
    # -- 'HDemonWarpStrike03',
    # -- 'HDemonWarpStrike04',
# -- }
# -- local WarpStrikeDisables = table.append( DefaultDisables,
    # -- {
        # -- 'WarpStrike - Hero',
        # -- 'WarpStrike - Squad Target',
    # -- }
# -- )
--------------------------
# -- # WarpStrike - Squad Target
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'WarpStrike - Squad Target',
    # -- UnitId = 'hdemon',
    # -- AnnounceAction = false,
    # -- Abilities = WarpStrikeAbilities,
    # -- DisableActions = WarpStrikeDisables,
    # -- GoalSets = {
        # -- SquadKill = true,
    # -- },
    # -- GoalWeights = {
        # -- KillSquadTarget = -7.5,
    # -- },
    # -- TargetTypes = { 'HERO', },
    # -- UninterruptibleAction = true,
    # -- ActionFunction = AIAbility.TargetedAbilitySquadTargetFunction,
    # -- ActionTimeout = 4,
    # -- CalculateWeights = AIAbility.TargetedAbilitySquadTargetWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }

----------------------------------------------------------------------------
# -- # Spine Attack
----------------------------------------------------------------------------
# -- local SpineAttackAbilities = {
    # -- 'HDemonSpineAttack01',
    # -- 'HDemonSpineAttack02',
    # -- 'HDemonSpineAttack03',
    # -- 'HDemonSpineAttack04',
# -- }
# -- local SpineAttackDisables = table.append( DefaultDisables,
    # -- {
        # -- 'SpineAttack - Hero',
        # -- 'SpineAttack - Structure',
        # -- 'SpineAttack - Squad Target',
    # -- }
# -- )

--------------------------
# -- # SpineAttack - Squad Target
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'SpineAttack - Squad Target',
    # -- UnitId = 'hdemon',
    # -- AnnounceAction = false,
    # -- Abilities = SpineAttackAbilities,
    # -- DisableActions = SpineAttackDisables,
    # -- GoalSets = {
        # -- SquadKill = true,
    # -- },
    # -- GoalWeights = {
        # -- KillSquadTarget = -3,
    # -- },
    # -- TargetTypes = { 'HERO', 'MOBILE' },
    # -- UninterruptibleAction = true,
    # -- ActionFunction = AIAbility.TargetedAbilitySquadTargetFunction,
    # -- ActionTimeout = 4,
    # -- CalculateWeights = AIAbility.TargetedAbilitySquadTargetWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
# -- }
----------------------------------------------------------------------------
# -- # ShadowSwap
----------------------------------------------------------------------------
# -- local ShadowSwapAbilities = {
    # -- 'HDemonShadowSwap01',
    # -- 'HDemonShadowSwap02',
    # -- 'HDemonShadowSwap03',
# -- }
# -- local ShadowSwapDisables = table.append( DefaultDisables, {
        # -- 'ShadowSwap - Hero',
        # -- 'ShadowSwap - Squad Target',
    # -- }
# -- )

# 0.27.04 refined the swap code further
--------------------------
# -- # ShadowSwap - Hero
--------------------------
    HeroAIActionTemplates['ShadowSwap - Hero'] = {
        Name = 'ShadowSwap - Hero',
        UnitId = 'hdemon',
        AnnounceAction = false,
        Abilities = ShadowSwapAbilities,
        DisableActions = ShadowSwapDisables,
        GoalSets = {
            Assassinate = true,
            Attack = true,
            Defend = true,
        },
        GoalWeights = {
            KillHero = -7.5,
        },
        ForceGoalWeights = true,
        UninterruptibleAction = true,
        ActionFunction = AIAbility.TargetedAttackHeroFunction,
        ActionTimeout = 4,
        CalculateWeights = AIAbility.TargetedAttackWeightsHero,
        InstantStatusFunction =  function(unit, action)
            local result = false
       
            if(AIAbility.DefaultStatusFunction(unit, action)) then
                local allies = unit:GetAIBrain():GetUnitsAroundPoint(categories.HERO, unit.Position, 15, 'Ally')
                local enemies = unit:GetAIBrain():GetUnitsAroundPoint(categories.HERO, unit.Position, 15, 'Enemy')
                local allyCT = 0
                local enemyCT = 0
                local differenceCT = 0
                if not table.empty(enemies) then
                    enemyCT = table.getn(enemies)   
                        if not table.empty(allies) then
                        allyCT = table.getn(allies)   
                        differenceCT = allyCT - enemyCT
                            if differenceCT >= 1 then
                                result = true
                            end
                        end
                end
			end
            return result
        end,       
    }   	
	

--------------------------
# -- # ShadowSwap - Squad Target
--------------------------
HeroAIActionTemplates['ShadowSwap - Squad Target'] = {
    Name = 'ShadowSwap - Squad Target',
    UnitId = 'hdemon',
    AnnounceAction = false,
    Abilities = ShadowSwapAbilities,
    DisableActions = ShadowSwapDisables,
    GoalSets = {
        SquadKill = true,
    },
    GoalWeights = {
        KillSquadTarget = 0,
    },
    ForceGoalWeights = true,
    TargetTypes = { 'STRUCTURE', 'HERO', 'MOBILE' },
    UninterruptibleAction = true,
    ActionFunction = AIAbility.TargetedAbilitySquadTargetFunction,
    ActionTimeout = 4,
    CalculateWeights = AIAbility.TargetedAbilitySquadTargetWeights,
        InstantStatusFunction =  function(unit, action)
            local result = false
       
            if(AIAbility.DefaultStatusFunction(unit, action)) then
                local allies = unit:GetAIBrain():GetUnitsAroundPoint(categories.HERO, unit.Position, 15, 'Ally')
                local enemies = unit:GetAIBrain():GetUnitsAroundPoint(categories.HERO, unit.Position, 15, 'Enemy')
                local allyCT = 0
                local enemyCT = 0
                local differenceCT = 0
                if not table.empty(enemies) then
                    enemyCT = table.getn(enemies)   
                        if not table.empty(allies) then
                        allyCT = table.getn(allies)   
                        differenceCT = allyCT - enemyCT
                            if differenceCT >= 1 then
                                result = true
                            end
                        end
                end
			end
            return result
        end,       
    }   	

----------------------------------------------------------------------------
# -- # WarpArea
----------------------------------------------------------------------------
# -- local WarpAreaAbilities = {
    # -- 'HDemonWarpArea01',
    # -- 'HDemonWarpArea02',
# -- }
# -- local WarpAreaDisables = table.append( DefaultDisables,
    # -- {
        # -- 'WarpArea - Hero',
        # -- 'WarpArea - Grunts',
        # -- 'WarpArea - Squad Target',
    # -- }
# -- )

# -- function WarpAreaWeights(action, aiBrain, agent, initialAgent)
    # -- local result = false
    # -- local actionBp = HeroAIActionTemplates[action.ActionName]

    # -- if not agent.WorldStateData.CanUseAbilities then
        # -- return false
    # -- end

    # -- if(action.Ability) then
        # -- if(AIAbility.TestEnergy(agent, action.Ability)) then
            # -- if(aiBrain:GetThreatAtPosition(agent.Position, 1, 'Land', 'Enemy') > 0) then
                # -- result = true
            # -- end
        # -- end
    # -- end

    # -- if(result == true) then
        # -- return actionBp.GoalWeights, Ability[action.Ability].CastingTime
    # -- else
        # -- return result
    # -- end
# -- end

--------------------------
# -- # WarpArea - Hero
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'WarpArea - Hero',
    # -- UnitId = 'hdemon',
    # -- AnnounceAction = false,
    # -- Abilities = WarpAreaAbilities,
    # -- DisableActions = WarpAreaDisables,
    # -- GoalSets = {
        # -- Assassinate = true,
        # -- Attack = true,
        # -- Defend = true,
    # -- },
    # -- GoalWeights = {
        # -- KillHero = -5,
    # -- },
    # -- TestRadius = 10,
    # -- UninterruptibleAction = true,
    # -- ActionCategory = 'HERO',
    # -- UnitCutoffThreshold = 1,
    # -- ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    # -- ActionTimeout = 5,
    # -- CalculateWeights = WarpAreaWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
    # -- ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
# -- }

--------------------------
# -- # WarpArea - Grunts
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'WarpArea - Grunts',
    # -- UnitId = 'hdemon',
    # -- AnnounceAction = false,
    # -- Abilities = WarpAreaAbilities,
    # -- DisableActions = WarpAreaDisables,
    # -- GoalSets = {
        # -- Attack = true,
    # -- },
    # -- GoalWeights = {
        # -- KillUnits = -5,
    # -- },
    # -- TestRadius = 10,
    # -- UnitCutoffThreshold = 4,
    # -- UninterruptibleAction = true,
    # -- ActionCategory = 'GRUNT',
    # -- ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    # -- ActionTimeout = 5,
    # -- CalculateWeights = WarpAreaWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
    # -- ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
# -- }

--------------------------
# -- # WarpArea - Squad Target
--------------------------
# -- HeroAIActionTemplate {
    # -- Name = 'WarpArea - Squad Target',
    # -- UnitId = 'hdemon',
    # -- AnnounceAction = false,
    # -- Abilities = WarpAreaAbilities,
    # -- DisableActions = WarpAreaDisables,
    # -- GoalSets = {
        # -- SquadKill = true,
    # -- },
    # -- GoalWeights = {
        # -- KillSquadTarget = -5,
    # -- },
    # -- TestRadius = 10,
    # -- UnitCutoffThreshold = 4,
    # -- TargetTypes = { 'HERO', 'MOBILE' },
    # -- UninterruptibleAction = true,
    # -- ActionCategory = 'HERO, GRUNT',
    # -- ActionFunction = AIAbility.PointBlankAreaAttackFunction,
    # -- ActionTimeout = 5,
    # -- CalculateWeights = WarpAreaWeights,
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
    # -- ActionCleanupFunction = AIAbility.PointBlankAreaAttackCleanup,
# -- }


