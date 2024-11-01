#  [MOD] Blade of serpent mana % trigger

# -- local AIAbility = import('/lua/sim/ai/AIAbilityUtilities.lua')
# -- local AIGlobals = import('/lua/sim/ai/AIGlobals.lua')
# -- local AIUtils = import('/lua/sim/ai/aiutilities.lua')
# -- local Common = import('/lua/common/CommonUtils.lua')
# -- local GetReadyAbility = AIAbility.GetReadyAbility

# -- local DefaultDisables = AIGlobals.DefaultDisables

# ------------------------------------------------------------------------------
# HOLY SYMBOL OF PURITY
# Use: Purge all negative effects.
# ------------------------------------------------------------------------------
-- HeroAIActionTemplates['Use Holy Symbol of Purity'] = {
    -- Name = 'Use Holy Symbol of Purity',
    -- Abilities = {'AchievementPure'},
    -- DisableActions = table.append(DefaultDisables, {'Use Holy Symbol of Purity'}),
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

        -- for buffType, buffTbl in unit.Buffs.BuffTable do
            -- for buffName, buffDef in buffTbl do
                -- if(Buffs[buffName].Debuff == true) then
                    -- if(Buffs[buffName].CanBeDispelled == true) then
                        -- result = true
                        -- break
                    -- end
                -- end
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
# AMULET OF TELEPORTATION
# Use: Teleport to targeted friendly structure.
# ------------------------------------------------------------------------------

# Action in UseItemsActions.lua, Teleport to Health Statue

# ------------------------------------------------------------------------------
# DARK CRIMSON VIAL
# Use: Heal 1000 Health.
# ------------------------------------------------------------------------------

# Action in UseItemsActions.lua, Use Health Potion

# ------------------------------------------------------------------------------
# CAPE OF PLENTIFUL MANA
# Use: +500% Mana Regeneration for 10 seconds.
# ------------------------------------------------------------------------------
-- HeroAIActionTemplates['Use Cape of Plentiful Mana'] = {
    -- Name = 'Use Cape of Plentiful Mana',
    -- Abilities = {'AchievementAEMana'},
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

        -- return {Energy = -5}, Ability[action.Ability].CastingTime
    -- end,
    -- InstantStatusFunction = function(unit, action)
        -- local result = false

        -- # If my energy percentage is below 60% and not near a health statue
        -- if(unit:GetEnergyPercent() < 0.6) then
            -- local brain = unit:GetAIBrain()
            -- local healthStatues = brain:GetUnitsAroundPoint(categories.HEALTHSTATUE, unit.Position, 20, 'Ally')
            -- if(table.empty(healthStatues)) then
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
# REGENERATION OF THE SERAPHIM
# Use: +200 Health Regeneration for 10 seconds.
# ------------------------------------------------------------------------------
-- HeroAIActionTemplates['Use Regeneration of the Seraphim'] = {
    -- Name = 'Use Regeneration of the Seraphim',
    -- Abilities = {'AchievementAERegen'},
    -- DisableActions = table.append(DefaultDisables, AIGlobals.HealthDisables),
    -- GoalSets = {
        -- All = true,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = AIAbility.InstantActionFunction,
    -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        -- if not agent.WorldStateData.CanUseAbilities then
            -- return false
        -- end

        -- return {Health = -5, Survival = -5}, Ability[action.Ability].CastingTime or 1
    -- end,
    -- InstantStatusFunction = function(unit, action)
        -- local result = false

        -- # If my health percentage is below 40% and not near a health statue
        -- if(unit:GetHealthPercent() < 0.4) then
            -- local brain = unit:GetAIBrain()
            -- local healthStatues = brain:GetUnitsAroundPoint(categories.HEALTHSTATUE, unit.Position, 20, 'Ally')
            -- if(table.empty(healthStatues)) then
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
# STAFF OF RENEWAL
# Use: All abilities are instantly refreshed.
# ------------------------------------------------------------------------------
-- HeroAIActionTemplates['Use Staff of Renewal'] = {
    -- Name = 'Use Staff of Renewal',
    -- Abilities = {'AchievementRefreshCooldowns'},
    -- DisableActions = table.append(DefaultDisables, {'Use Staff of Renewal'}),
    -- GoalSets = {
        -- All = true,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = AIAbility.InstantActionFunction,
    -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        -- if not agent.WorldStateData.CanUseAbilities then
            -- return false
        -- end

        -- return {KillUnits = -5, KillHero = -5, KillStructures = -5, KillSquadTarget = -5}, Ability[action.Ability].CastingTime or 1
    -- end,
    -- InstantStatusFunction = function(unit, action)
        -- local result = false

        -- if(unit:GetHealthPercent() > .75) then
            -- local syncData = Common.GetSyncData(unit)
            -- local currentCooldown = 0
            -- local maxCooldown = 0
            -- for k, v in unit.Abilities do
                -- local def = Ability[k]
                -- if(def.Cooldown > 0) then
                    -- maxCooldown = maxCooldown + def.Cooldown
                    -- if(not def.SharedCooldown) then
                        -- # syncData stores the cooldown in ticks, convert to seconds before adding
                        -- currentCooldown = currentCooldown + (syncData.Abilities[k].Cooldown/10)
                    -- else
                        -- currentCooldown = currentCooldown + (syncData.SharedCooldowns[def.SharedCooldown]/10)
                    -- end
                -- end
            -- end

            -- if(currentCooldown > 20 and currentCooldown/maxCooldown > .4) then
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
# BLADE OF THE SERPENT
# Use: 100% chance on hit to gain 35% of your damage in Mana for 10 seconds.
# ------------------------------------------------------------------------------
HeroAIActionTemplates['Use Blade of the Serpent'] = {
    Name = 'Use Blade of the Serpent',
    Abilities = {'AchievementManaLeech'},
    DisableActions = table.append(DefaultDisables, AIGlobals.EnergyDisables),
    GoalSets = {
        Assassinate = true,
        Attack = true,
        DestroyStructures = true,
        SquadKill = true,
    },
    UninterruptibleAction = true,
    ActionFunction = AIAbility.InstantActionFunction,
    CalculateWeights = function(action, aiBrain, agent, initialAgent)
        if not agent.WorldStateData.CanUseAbilities then
            return false
        end

        return {Energy = -5}, Ability[action.Ability].CastingTime or 1
    end,
    InstantStatusFunction = function(unit, action)
        local result = false

        # If my energy percentage is below 70% and not near a health statue
        if(unit:GetEnergyPercent() < .7) then
            local brain = unit:GetAIBrain()
            local healthStatues = brain:GetUnitsAroundPoint(categories.HEALTHSTATUE, unit.Position, 20, 'Ally')
            if(table.empty(healthStatues)) then
                # Make sure there is a threat nearby
                if(brain:GetThreatAtPosition(unit.Position, 1, nil, 'Enemy') > 4) then
                    result = true
                end
            end
        end

        if(result) then
            return AIAbility.DefaultStatusFunction(unit, action)
        else
            return result
        end
    end,
}

# ------------------------------------------------------------------------------
# PURIFIED ESSENCE OF MAGIC
# Use: The cost of all abilities reduced to 0 for 10 seconds.
# ------------------------------------------------------------------------------
-- HeroAIActionTemplates['Use Purified Essence of Magic'] = {
    -- Name = 'Use Purified Essence of Magic',
    -- Abilities = {'AchievementFreeSpells'},
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
				-- if(brain:GetThreatAtPosition(unit.Position, 1, 'Hero', 'Enemy') > 0) then
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
# HEAVENS WRATH
# Use: Fire a beam of searing light at the targeted location.
# ------------------------------------------------------------------------------
-- HeroAIActionTemplates['Use Heavens Wrath'] = {
    -- Name = 'Use Heavens Wrath',
    -- Abilities = {'AchievementFinger'},
    -- DisableActions = table.append(DefaultDisables, {'Use Heavens Wrath'}),
    -- GoalSets = {
        -- All = true,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = function(unit, action)
        -- local result = false
        -- local target = nil
        -- local actionBp = HeroAIActionTemplates[action.ActionName]

        -- local ready = GetReadyAbility(unit, actionBp.Abilities)
        -- if(ready) then
            -- local aiBrain = unit:GetAIBrain()
            -- local radius = Ability[ready].AffectRadius
            -- local position = aiBrain:FindUnitConcentration(categories.GRUNT + categories.HERO, unit:GetPosition(), 50, radius, 'Enemy')
            -- if(position and (position[1] != 0 and position[3] != 0)) then
                -- position[2] = 100
                -- return AIAbility.UseTargetedAbility(unit, ready, position, actionBp.ActionTimeout)
            -- else
                -- return false
            -- end
        -- else
            -- return false
        -- end
    -- end,
    -- ActionTimeout = 5,
    -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        -- if not agent.WorldStateData.CanUseAbilities then
            -- return false
        -- end

        -- return {KillHero = -5, KillUnits = -5,}, Ability[action.Ability].CastingTime or 1
    -- end,
    -- InstantStatusFunction = AIAbility.DefaultStatusFunction,
-- }

# ------------------------------------------------------------------------------
# RING OF DIVINE MIGHT
# Use: Minions are infused with divine power, allowing them to knock away smaller units for 10 seconds.
# ------------------------------------------------------------------------------
-- HeroAIActionTemplates['Use Ring of Divine Might'] = {
    -- Name = 'Use Ring of Divine Might',
    -- Abilities = {'AchievementMinionMeta'},
    -- DisableActions = table.append(DefaultDisables, {'Use Ring of Divine Might'}),
    -- GoalSets = {
        -- Assassinate = true,
        -- Attack = true,
        -- DestroyStructures = true,
        -- SquadKill = true,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = AIAbility.InstantActionFunction,
    -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        -- if not agent.WorldStateData.CanUseAbilities then
            -- return false
        -- end

        -- return {KillUnits = -5}, Ability[action.Ability].CastingTime or 1
    -- end,
    -- InstantStatusFunction = function(unit, action)
        -- local result = false

        -- # If my minions are near infantry
        -- local brain = unit:GetAIBrain()
        -- local units = brain:GetListOfUnits(categories.MINION, false)
        -- if(units) then
            -- if(brain:GetThreatAtPosition(unit.Position, 1, 'LandNoHero', 'Enemy') >= 5) then
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
# HORN OF BATTLE
# Use: Minions gain +100 Health Regeneration for 5 seconds.
# ------------------------------------------------------------------------------
-- HeroAIActionTemplates['Use Horn of Battle'] = {
    -- Name = 'Use Horn of Battle',
    -- Abilities = {'AchievementMinionBuff'},
    -- DisableActions = table.append(DefaultDisables, {'Use Horn of Battle'}),
    -- GoalSets = {
        -- All = true,
    -- },
    -- UninterruptibleAction = true,
    -- ActionFunction = AIAbility.InstantActionFunction,
    -- CalculateWeights = function(action, aiBrain, agent, initialAgent)
        -- if not agent.WorldStateData.CanUseAbilities then
            -- return false
        -- end

        -- return {Survival = -5}, Ability[action.Ability].CastingTime or 1
    -- end,
    -- InstantStatusFunction = function(unit, action)
        -- local result = false

        -- # If my minions health percentage is below 60% and not near a health statue
        -- local brain = unit:GetAIBrain()
        -- local units = brain:GetListOfUnits(categories.MINION, false)
        -- if(units) then
            -- local healthStatues = brain:GetUnitsAroundPoint(categories.HEALTHSTATUE, unit.Position, 20, 'Ally')
            -- if(table.empty(healthStatues)) then
                -- local health = 0
                -- local maxHealth = 0
                -- for k, v in units do
                    -- health = health + v:GetHealth()
                    -- maxHealth = maxHealth + v:GetMaxHealth()
                -- end
                -- if(health/maxHealth <= 0.6) then
                    -- result = true
                -- end
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
# BLOOD SOAKED WAND
# Use: Heal self and all nearby allies for 1500.
# ------------------------------------------------------------------------------

# Action in UseItemsActions.lua, Use Health Potion

# ------------------------------------------------------------------------------
# CLOAK OF NIGHT
# Use: Warp to a targeted location, dealing 300 damage upon entry.
# ------------------------------------------------------------------------------

# Action in UseItemsActions.lua, Warp to Weak Hero, Warp to Squad Target