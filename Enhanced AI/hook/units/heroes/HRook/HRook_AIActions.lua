# -- local ValidateAbility = import('/lua/common/ValidateAbility.lua')
# -- local AIUtils = import('/lua/sim/ai/aiutilities.lua')
# -- local AIAbility = import('/lua/sim/ai/AIAbilityUtilities.lua')
# -- local GetReadyAbility = AIAbility.GetReadyAbility
# -- local Buff = import('/lua/sim/Buff.lua')

# -- local AIGlobals = import('/lua/sim/AI/AIGlobals.lua')

# -- local DefaultDisables = import('/lua/sim/ai/AIGlobals.lua').DefaultDisables
local HasAbility = ValidateAbility.HasAbility

# ===============================================
# Structural Transfer
# ===============================================
# -- local StructureTransferDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Structural Transfer',
        # -- 'Structural Transfer - Squad Target',
    # -- }
# -- )

# -- local StructuralTransferAbilities = {
    # -- 'HRookStructuralTransfer01',
    # -- 'HRookStructuralTransfer02',
    # -- 'HRookStructuralTransfer03',
    # -- 'HRookStructuralTransfer04',
# -- }

# -- local function StructuralTransferDamage(ability)
    # -- if AIGlobals.AbilityDamage[ability] then
        # -- return AIGlobals.AbilityDamage[ability]
    # -- end

    # -- local def = Ability[ability]
    # -- local damage = 0
    # -- if def then
        # -- damage = def.Amount * def.Pulses
    # -- else
        # -- WARN('*AI WARNING: Could not get damage for ability - ' .. ability)
    # -- end

    # -- AIGlobals.AbilityDamage[ability] = damage
    # -- return damage
# -- end

HeroAIActionTemplates['Structural Transfer'] = {
    Name = 'Structural Transfer',
    UnitId = 'hrook',
    UninterruptibleAction = true,
    DisableActions = StructureTransferDisables,
    GoalSets = {
        Assassinate = true,
        Attack = true,
        Defend = true,
        DestroyStructures = true,
		#Flee = true,
    },
    Abilities = StructuralTransferAbilities,
	ActionTimeout = 15,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
    ActionFunction = function(unit, action )
        local aiBrain = unit:GetAIBrain()

        local actionBp = HeroAIActionTemplates[action.ActionName]
        if not action.Ability then
            return false
        end

        local range = Ability[action.Ability].RangeMax * 3
        local damage = StructuralTransferDamage(action.Ability)
        local targets = aiBrain:GetUnitsAroundPoint(categories.ROOKTOWER,
                        unit:GetPosition(), 25, 'Ally' )
		
		#WARN( LOC(aiBrain.Nickname) .. ' Ally towers - ' .. tostring(table.getn(targets) ) )
        targets = table.append( targets, aiBrain:GetBlipsAroundPoint( categories.STRUCTURE - categories.WALL - categories.UNTARGETABLE,
                        unit:GetPosition(), 14, 'Enemy' ) )

        local target
        local targetIsDefense
        for k,v in targets do
            if v:IsDead() then
                continue
            end

            # The current target is an enemy; the new target is a friend - we don't want the new target
            if target and IsEnemy( target:GetArmy(), unit:GetArmy() ) and IsAlly( v:GetArmy(), unit:GetArmy() ) then
                continue
            end

            # If our current target is an ally; override it if the new target is possibly an enemy
            if target and IsAlly( target:GetArmy(), unit:GetArmy() ) and IsEnemy( unit:GetArmy(), v:GetArmy() ) then
                target = v
                # Find out if the target is a defense in this case as we want to immediatlely loop out and skip some lower logic
                if EntityCategoryContains( categories.DEFENSE, v ) then
                    targetIsDefense = true
                end
                continue
            end

            # The current target is a defensive structure; new target is not a defense; skip it; defenses are first priority
            if target and targetIsDefense and not EntityCategoryContains( categories.DEFENSE, v ) then
                continue
            end

            # if we think we can kill someone with it, target them
            if v:GetHealth() < damage and IsEnemy( unit:GetArmy(), v:GetArmy() ) then
                target = v
                break
            end

            # The target is an ally; we only draw health from allied buildings if we really need the health
            # And we NEVER draw health from a stronghold
            if IsAlly( v:GetArmy(), unit:GetArmy() )
                and ( unit:GetHealthPercent() > 0.75 or EntityCategoryContains( categories.STRONGHOLD, v ) ) then
                continue
            end

            # Decent target, use for now
            if target and v:GetHealth() < target:GetHealth() then
                continue
            end

            # Remember if this target is a defensive structure or not; we prefer killing defenses as they hurt us
            if not targetIsDefense and EntityCategoryContains( categories.DEFENSE, v ) then
                targetIsDefense = true
            end

            # New loop unit is the new target; Hooray!
            target = v
        end

        if not target then
            return
        end

        if not AIAbility.UseTargetedAbility( unit, action.Ability, target, 15 ) then
            return false
        end
		
		WaitSeconds(5)
        while Buff.HasBuff( unit, 'Immobile' ) do
            WaitSeconds(.5)
            if unit:IsDead() then
                return false
            end
        end

    end,
    CalculateWeights = function( action, aiBrain, agent, initialAgent )
        if not agent.WorldStateData.CanUseAbilities then
            return false
        end

        if not agent.WorldStateData.EnemyStructureNearby and not agent.WorldStateData.EnemyDefenseNearby and initialAgent:GetHealthPercent() > 0.75 then  # 
            return false
        end

        if not action.Ability then
            return false
        end
        local actionBp = HeroAIActionTemplates[action.ActionName]

        local target = false
        local targetHps = false

        if agent.WorldStateData.DefenseNearby and initialAgent.GOAP.DefenseNearbyHps then
            target = agent.WorldStateData.DefenseNearby
            targetHps = initialAgent.GOAP.DefenseNearbyHps
        end

        if agent.WorldStateData.StructureNearby and initialAgent.GOAP.StructureNearbyHps and initialAgent.GOAP.StructureNearbyHps > targetHps then
            target = agent.WorldStateData.StructureNearby
            targetHps = initialAgent.GOAP.StructureNearbyHps
        end

        if not target then
            return false
        end

        local damage = StructuralTransferDamage(action.Ability)

        local damagePct = targetHps / damage
        local healPct = ( initialAgent:GetMaxHealth() - initialAgent:GetHealth() ) / damage

        local returnTable = {
            Health = -20 * healPct,
        }
        if agent.WorldStateData.EnemyStructureNearby or agent.WorldStateData.EnemyDefenseNearby then
            returnTable.KillStructures = -30 * damagePct
        end

		#returnTable.Survival = -5
		
        return returnTable, 15
    end,
}

HeroAIActionTemplates['Structural Transfer - Squad Target'] = {
    Name = 'Structural Transfer - Squad Target',
    UnitId = 'hrook',
    UninterruptibleAction = true,
    DisableActions = StructureTransferDisables,
    GoalSets = {
        SquadKill = true,
    },
    Abilities = StructuralTransferAbilities,
    GoalWeights = {
        KillSquadTarget = 0,
        Health = 0,
    },
    TargetTypes = { 'STRUCTURE', },
    DamageCalculationFunction = StructuralTransferDamage,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
    ActionFunction = AIAbility.TargetedAbilitySquadTargetFunction,
    CalculateWeights = AIAbility.TargetedAbilitySquadTargetWeights,
}




# ===============================================================
# Towers
# ===============================================================

# -- local CreateTowerAbilities = {
    # -- 'HRookTower01',
    # -- 'HRookTower02',
    # -- 'HRookTower03',
    # -- 'HRookTower04',
# -- }

# -- local CreateTowerDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Create Tower of Light',
        # -- 'Create Tower of Light - Squad Target',
    # -- }
# -- )

HeroAIActionTemplates['Create Tower of Light'] = {
    Name = 'Create Tower of Light',
    UnitId = 'hrook',
    UninterruptibleAction = true,
    DisableActions = CreateTowerDisables,
    GoalSets = {
        Assassinate = true,
        Attack = true,
        Defend = true,
        DestroyStructures = true,
		SquadMove = true,
		WaitMasterGoal = true,
		CarefulAttack = true,		
    },
    Abilities = CreateTowerAbilities,
    ActionTimeout = 7,
    AffectRadius = 15,
    ActionFunction = function(unit, action)
        local aiBrain = unit:GetAIBrain()
        local actionBp = HeroAIActionTemplates[action.ActionName]

        local threat = aiBrain:GetThreatAtPosition( unit:GetPosition(), 1, 'Land', 'Enemy' )
        local strucThreat = aiBrain:GetThreatAtPosition( unit:GetPosition(), 1, 'Structures', 'Enemy' )
		local rookTowers = aiBrain:GetUnitsAroundPoint( categories.ROOKTOWER, unit:GetPosition(), 15)		
		#	WARN('Rook tower count' ..   table.getn(rookTowers) )
		local flags = aiBrain:GetUnitsAroundPoint( categories.FLAG, unit:GetPosition(), 15)	
		local eflags = aiBrain:GetUnitsAroundPoint( categories.FLAG, unit:GetPosition(), 20, 'Enemy' )	
        if threat <= 0 and strucThreat <= 0 and table.getn(eflags) == 0 and  table.getn(rookTowers)  == 0  then  #and table.getn(flags) <= 0
            return
        end

        #local pos = table.copy( unit:GetPosition() )
        local unitId = 'UGBDefense02'

        #pos[1] = pos[1] + 3
        #pos[3] = pos[3] + 3
		local position
		if  table.getn(flags) > 0 then
			position = flags[1].Position
		else
			position = aiBrain:FindUnitConcentration( categories.MOBILE + categories.DEFENSE, unit:GetPosition(), 10, 15, 'Enemy' ) 
		end


        local location = aiBrain:FindNearestSpotToBuildOn(unit, unitId, position)
        if not location then
            return
        end
		return AIAbility.TargetedActionFunction( unit, action, location, actionBp.ActionTimeout )
        

    end,
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

        local returnTable = {
            KillUnits = -5,
            KillHero = -5,
            KillStructures = -25,
		CaptureFlag = -25,
        }



        if not agent.WorldStateData.DefenseNearby then
            agent.WorldStateData.DefenseNearby = true
            initialAgent.GOAP.DefenseNearbyHps = 2000
            agent.WorldStateConsistent = false
        end

        return returnTable, Ability[action.Ability].CastingTime
    end,
}

# -- HeroAIActionTemplate {
    # -- Name = 'Create Tower of Light - Squad Target',
    # -- UnitId = 'hrook',
    # -- UninterruptibleAction = true,
    # -- DisableActions = CreateTowerDisables,
    # -- GoalSets = {
        # -- SquadKill = true,
    # -- },
    # -- Abilities = CreateTowerAbilities,
    # -- ActionTimeout = 7,
    # -- TargetTypes = { 'STRUCTURE', 'HERO', 'MOBILE', },
    # -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
    # -- ActionFunction = function(unit, action)
        # -- local aiBrain = unit:GetAIBrain()
        # -- local actionBp = HeroAIActionTemplates[action.ActionName]

        # -- local target = unit.GOAP.AttackTarget
        # -- if not target or target:IsDead() or VDist3XZ(unit.Position, target.Position) > 15 then
            # -- return false
        # -- end

        # -- local unitId = 'UGBDefense02'

        # -- local location = aiBrain:FindNearestSpotToBuildOn(unit, unitId, unit.Position)

        # -- return AIAbility.TargetedActionFunction( unit, action, location, actionBp.ActionTimeout )
    # -- end,
    # -- CalculateWeights = function( action, aiBrain, agent, initialAgent )
        # -- if not agent.WorldStateData.CanUseAbilities then
            # -- return false
        # -- end

        # -- if not action.Ability then
            # -- return false
        # -- end

        # -- if not AIAbility.TestEnergy( agent, action.Ability ) then
            # -- return false
        # -- end

        # -- local target = initialAgent.GOAP.AttackTarget
        # -- if not target or target:IsDead() or VDist3XZ( agent.Position, target.Position) > 15 then
            # -- return false
        # -- end

        # -- if not agent.WorldStateData.DefenseNearby then
            # -- agent.WorldStateData.DefenseNearby = true
            # -- initialAgent.GOAP.DefenseNearbyHps = 2000
            # -- agent.WorldStateConsistent = false
        # -- end

        # -- return { KillSquadTarget = -3 }, Ability[action.Ability].CastingTime
    # -- end,
# -- }



# ===============================================================
# HAMMER SLAM
# ===============================================================

# -- local HammerSlamAbilities = {
    # -- 'HRookHammerSlam01',
    # -- 'HRookHammerSlam02',
    # -- 'HRookHammerSlam03',
    # -- 'HRookHammerSlam04',
# -- }

# -- local HammerSlamDisables = table.append(DefaultDisables, {
        # -- 'Rook Hammer Slam',
        # -- 'Rook Hammer Slam - Squad Target',
    # -- }
# -- )

# 0.26.55 uncommented hammer slam
local HammerSlamTime = 2

HeroAIActionTemplates['Rook Hammer Slam'] = {
    Name = 'Rook Hammer Slam',
    UnitId = 'hrook',
    UninterruptibleAction = true,
    GoalSets = {
        Assassinate = true,
        Attack = true,
        Defend = true,
		CarefulAttack = true,
    },
    Abilities = HammerSlamAbilities,
    #UnitCutoffThreshold = 1,
    DisableActions = HammerSlamDisables,
    GoalWeights = {
            KillUnits = -5,
            KillHero = -50,
            KillStructures = -5,
    },
    ActionTimeout = 5,
    ActionCategory = 'HERO',
    WeightTime = HammerSlamTime,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
    ActionFunction = AIAbility.TargetedAttackHeroFunction,
--    CalculateWeights = AIAbility.TargetedAttackWeightsHero,
# 0.27.07 added new hammer slam calculation from miri - should increase the odds that hammerslam will be used if the enemy is stunned	
	CalculateWeights = function(action, aiBrain, agent, initialAgent)
        local weights, time = AIAbility.TargetedAttackWeightsHero(action, aiBrain, agent, initialAgent)
        if weights then
            local category = HeroAIActionTemplates[action.ActionName].TargetCategory or categories.HERO
            local range = Ability[action.Ability].RangeMax * 1.5
            local units = aiBrain:GetBlipsAroundPoint(category, initialAgent:GetPosition(), range, 'Enemy')
            local target = AIUtils.GetWeakestUnit(units)
            if target and target:IsStunned() then
                LOG("Rook Hammer Slam: Stunned Target")
                for k, v in weights do
                    weights[k] = v * 2
                end
            end
            return weights, time
        end
        return false
    end,
}

HeroAIActionTemplates['Rook Hammer Slam - Squad Target'] = {
    Name = 'Rook Hammer Slam - Squad Target',
    UnitId = 'hrook',
    UninterruptibleAction = true,
    DisableActions = HammerSlamDisables,
    GoalSets = {
        SquadKill = true,
		Attack = true,
    },
    Abilities = HammerSlamAbilities,
    GoalWeights = {
		KillSquadTarget = -5,
		KillUnits = -5,
		KillHero = -5,
		KillStructures = -5,
    },
    #UnitCutoffThreshold = 1,
    TargetTypes = { 'STRUCTURE', 'HERO', 'MOBILE' },
    ActionTimeout = 5,
    InstantStatusFunction = AIAbility.DefaultStatusFunction,
    ActionFunction = AIAbility.TargetedAbilitySquadTargetFunction,
--    CalculateWeights = AIAbility.TargetedAbilitySquadTargetWeights,
# 0.27.07 added new hammer slam calculation from miri - should increase the odds that hammerslam will be used if the enemy is stunned (Squad target code)
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        local weights, time = AIAbility.TargetedAbilitySquadTargetWeights(action, aiBrain, agent, initialAgent)
        if weights then
            local range = Ability[action.Ability].RangeMax * 1.5
            local target = initialAgent.GOAP.AttackTarget
            if target and VDist3XZSq( agent.Position, target.Position ) < range * range and target:IsStunned() then
                LOG("Rook Hammer Slam - Squad Target: Stunned Target")
                for k, v in weights do
                    weights[k] = v * 2
                end
            end
            return weights, time
        end
        return false
    end,
}



# ===============================================================
# BOULDER ROLL
# ===============================================================

# -- local RookRollAbilities = {
    # -- 'HRookBoulderRoll01',
    # -- 'HRookBoulderRoll02',
    # -- 'HRookBoulderRoll03',
# -- }

# -- local RookRollDisables = table.append( DefaultDisables,
    # -- {
        # -- 'Rook Roll - Hero',
        # -- 'Rook Roll - Squad Target',
    # -- }
# -- )

# -- local RookRollTime = 2

# -- function RookRollWeights(action, aiBrain, agent, initialAgent)
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

    # -- if actionBp.SquadTarget or enemyThreat >= 5 then
        # -- return actionBp.GoalWeights, 1.5
    # -- end

    # -- return false
# -- end

HeroAIActionTemplates['Rook Roll - Hero'] = {
    Name = 'Rook Roll - Hero',
    UnitId = 'hrook',
    UninterruptibleAction = true,
    GoalSets = {
        Attack = true,
        Defend = true,
        Assassinate = true,
    },
    Abilities = RookRollAbilities,
    DisableActions = RookRollDisables,
    GoalWeights = {
            KillUnits = -10,
            KillHero = -25,
            KillStructures = -10,
			CaptureFlag = -10,
    },
    ThreatType = 'Hero',
    ActionTimeout = 5,
    ActionCategory = 'HERO',
    WeightTime = RookRollTime,
    ActionFunction = AIAbility.TargetedAreaAttackAbility,
	InstantStatusFunction = AIAbility.DefaultStatusFunction,	
    # -- InstantStatusFunction =  function(unit, action)
        # -- local result = false

        # -- if(AIAbility.DefaultStatusFunction(unit, action)) then
		
				# -- local enemyHero = unit.GOAP.AttackTarget
				# -- if(enemyHero != unit and enemyHero.CastingAbilityTask) then 
					#local announcement = "Interrupt: "..enemyHero.CastingAbilityTask
					#AIUtils.AIChat(unit, announcement)
                    # -- result = true
                    
                # -- end
				

				# -- if(enemyHero and enemyHero != unit and not enemyHero:IsDead()) then	
					# -- if (enemyHero:GetHealthPercent() < .6) then
						#local announcement = "Boulder low health"
						#AIUtils.AIChat(unit, announcement)
						# -- result = true  
					# -- end
                # -- end
        # -- end

        # -- return result
    # -- end,
    CalculateWeights = RookRollWeights,
}

HeroAIActionTemplates['Rook Roll - Squad Target'] = {
    Name = 'Rook Roll - Squad Target',
    UnitId = 'hrook',
    UninterruptibleAction = true,
    GoalSets = {
        SquadKill = true,
    },
    Abilities = RookRollAbilities,
    DisableActions = RookRollDisables,
    GoalWeights = {
            KillUnits = -10,
            KillHero = -10,
            KillStructures = -10,
			CaptureFlag = -10,
			KillSquadTarget = -10,
    },
    SquadTarget = true,
    ThreatType = 'Hero',
    ActionTimeout = 5,
    ActionCategory = 'HERO',
    TargetTypes = { 'STRUCTURE', 'HERO', 'MOBILE' },
    WeightTime = RookRollTime,
    ActionFunction = AIAbility.TargetedAreaAttackAbility,
	InstantStatusFunction = AIAbility.DefaultStatusFunction,	
    # -- InstantStatusFunction =  function(unit, action)
        # -- local result = false

        # -- if(AIAbility.DefaultStatusFunction(unit, action)) then
			# -- local enemyHero = unit.GOAP.AttackTarget
				# -- if(enemyHero != unit and enemyHero.CastingAbilityTask) then 
					#local announcement = "Interrupt: "..enemyHero.CastingAbilityTask
					#AIUtils.AIChat(unit, announcement)
                    # -- result = true
                    
                # -- end
				# -- if(enemyHero and enemyHero != unit and not enemyHero:IsDead()) then	
					# -- if (enemyHero:GetHealthPercent() < .6) then
						#local announcement = "Boulder low health"
						#AIUtils.AIChat(unit, announcement)
						# -- result = true  
					# -- end
                # -- end
        # -- end

        # -- return result
    # -- end,
    CalculateWeights = RookRollWeights,
}

