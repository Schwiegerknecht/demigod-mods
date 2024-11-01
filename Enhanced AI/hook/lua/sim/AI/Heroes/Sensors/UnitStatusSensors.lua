# -- local Common = import('/lua/common/CommonUtils.lua')
# -- local ValidateAbility = import('/lua/common/ValidateAbility.lua')
# -- local AIShop = import('/lua/sim/ai/AIShopUtilities.lua')
local AIUtils = import('/lua/sim/AI/AIUtilities.lua')
#  [MOD] Increase status level to force retreat quicker
HeroAISensorTemplates.HealthSensor = {
    Name = 'HealthSensor',
    StatusPriority = 3,
    InstantGoalRepick = true,
    StatusFunction = function(unit, sensor)
        local curHealth = unit:GetHealth()
        local healthPercent = unit:GetHealthPercent()

        local statusLevel = 0

        if curHealth < 2000 and healthPercent < 0.8 then
            if  healthPercent < 0.10 then
                statusLevel = 100
            elseif healthPercent < 0.15 then
                statusLevel = 75
            elseif healthPercent < 0.25 then
                statusLevel = 50
			elseif healthPercent < 0.30 then
				statusLevel = 30
			elseif healthPercent < 0.40 then
                statusLevel = 20
            elseif healthPercent < 0.50 then
                statusLevel = 15
			elseif healthPercent < 0.60 then
                statusLevel = 10
            else
                statusLevel = 4
            end
        end

        sensor:SensorUpdate(statusLevel)
    end,
    GoalUpdates = {
        Health = 1,
        Survival = 0.75,
    },
}

# -- HeroAISensorTemplate {
    # -- Name = 'HealthSensor - Full Health Check',
    # -- StatusPriority = 3,
    # -- StatusFunction = function(unit, sensor)
        # -- local statusLevel = 0

        # -- if unit:GetHealthPercent() < 1.0 then
            # -- statusLevel = 1
        # -- end

        # -- sensor:SensorUpdate(statusLevel)
    # -- end,
    # -- GoalUpdates = {
        # -- Health = 2,
        # -- Survival = 1,
    # -- },
# -- }

# -- HeroAISensorTemplate {
    # -- Name = 'EnergySensor',
    # -- StatusPriority = 3,
    # -- StatusFunction = function(unit, sensor)
        # -- local energyPercent = unit:GetEnergyPercent()
        # -- local statusLevel = (1 - energyPercent) * 5

        # -- sensor:SensorUpdate(statusLevel)
    # -- end,
    # -- GoalUpdates = {
        # -- Energy = 4,
        # -- Survival = 0.5
    # -- },
# -- }

# -- HeroAISensorTemplate {
    # -- Name = 'EnergySensor - No Energy Check',
    # -- StatusPriority = 3,
    # -- StatusFunction = function(unit, sensor)
        # -- local statusLevel = 0
        # -- local energyPercent = unit:GetEnergyPercent()

        # -- if(energyPercent < .2) then
            # -- statusLevel = (1 - energyPercent) * 10
        # -- end

        # -- sensor:SensorUpdate(statusLevel)
    # -- end,
    # -- GoalUpdates = {
        # -- Energy = 1,
        # -- Survival = 0.5,
    # -- },
# -- }

# [MOD] TE  Check if AI is stuck repick goal and issue move command.  Removed, AI does not get stuck if shopping is slowed down (1 second per action)
# -- HeroAISensorTemplate {
    # -- Name = 'Stuck Check',
    # -- StatusPriority = 1,
    # -- StatusFunction = function(unit, sensor)
		# -- local oldPos = table.copy( unit:GetPosition() )
		# -- local myTimer = 0


		
		# -- while myTimer <= 20 do
			# -- WaitSeconds(1)
			# -- local newPos = unit:GetPosition()
			# -- if newPos[1] == oldPos[1] and newPos[2] == oldPos[2] and newPos[3] == oldPos[3] then
				# -- myTimer = myTimer + 1
			# -- else
				# -- myTimer = 0
			# -- end
		# -- end
	
		# -- if myTimer >= 20 then
		
			# -- WARN('Peppe -- AI may be stuck, Unit = '.. unit:GetAIBrain().Nickname)
			 # -- unit.GOAP:SelectGoal(true)
			# -- local aiBrain = unit:GetAIBrain()
			# -- local myStronghold = aiBrain:GetStronghold():GetPosition()

		
			# -- local position = unit:FindEmptySpotNear(myStronghold)

			# -- local path = AIUtils.GetSafePathBetweenPoints(aiBrain, unit.Position, position, 10)

			# -- if not path then
				# -- path = { position }
			# -- end

			# -- # Move along the path
			# -- local cmd = false
			# -- for k,v in path do
				# -- cmd = IssueAggressiveMove( {unit}, v )
			# -- end
			# -- WaitSeconds(1)
		# -- end
		# -- return
    # -- end,
    # -- GoalUpdates = {},
# -- }


#  [MOD] Damage fixed value
local function TakeDamageCallback(sensor, unit, damageData, category)
    local instigator = damageData.Instigator
    if instigator and not instigator:IsDead() and EntityCategoryContains( category, instigator ) then
        local entityId = instigator:GetEntityId()
        local functionName = 'DamageTaken_' .. entityId
        
		# -- #  [MOD] Percent to fixed value (ignore damage below 50)
        local healthPct = damageData.Amount # / unit:GetMaxHealth()
        if healthPct < 50 then
            return
        end
        
        # Get our current sensor level; we only add to the sensor level if there is not already a thread
        # for the attacking entity
        local sensorLevel = sensor.SensorStatus
        if sensor[functionName] then
            KillThread( sensor[functionName] )
        else
            sensor['DamageBool_'..entityId] = true
            sensorLevel = sensorLevel + 1
        end

        sensor[functionName] = sensor:ForkThread(
            function(sensor, entityId)
                WaitSeconds(2)
                if sensor['DamageBool_'..entityId] then
                    sensor['DamageBool_'..entityId] = false
                    local sensorLevel = sensor.SensorStatus - 1
                    sensor:SensorUpdate(sensorLevel)
                end
            end, entityId
        )

        sensor:SensorUpdate(sensorLevel)
    end
end

#  [MOD] Increase Survival and Health when Tower is doing the damage
HeroAISensorTemplates['Demigod injured - Defense Attacker'] = {
    Name = 'Demigod injured - Defense Attacker',
	
    InstantGoalRepick = true,
    #TournamentMinimumDifficulty = 2,
    SensorTriggerSetup = {
        TriggerType = 'OnTakeDamage',
        SensorCallback = function(sensor, unit, damageData)
            TakeDamageCallback(sensor,unit,damageData,categories.DEFENSE)
        end,
    },
    GoalUpdates = {
        Survival = 500,
        Health = 500,		
    },
}

#  [MOD] Increase Survival and Health when a hero is doing the damage
HeroAISensorTemplates['Demigod injured - Hero Attacker'] = {
    Name = 'Demigod injured - Hero Attacker',
    InstantGoalRepick = true,
    #TournamentMinimumDifficulty = 2,
    SensorTriggerSetup = {
        TriggerType = 'OnTakeDamage',
        SensorCallback = function(sensor, unit, damageData)
            TakeDamageCallback(sensor,unit,damageData,categories.HERO)
        end,
    },
    GoalUpdates = {
        Survival = 25,
        Health = 25,
    },
}

# ==== GENERIC PURCHASE SENSORS ==== #
# -- HeroAISensorTemplate {
    # -- Name = 'Demigod Item Priorities',
    # -- StatusPriority = 1,
    # -- StatusInstant = true,
    # -- StatusFunction = function(unit, sensor)
        # -- local aiBrain = unit:GetAIBrain()

        # -- # Get the brain asset for the hero we are monitoring
        # -- local asset = sensor.StrategicAsset
        # -- if not asset then
            # -- return
        # -- end

        # -- asset:SortItemPriorities(unit)
    # -- end,
    # -- GoalUpdates = {},
# -- }

# -- HeroAISensorTemplate {
    # -- Name = 'Demigod Citadel Upgrade Priorities',
    # -- StatusPriority = 1,
    # -- StatusInstant = true,
    # -- StatusFunction = function(unit, sensor)
        # -- local aiBrain = unit:GetAIBrain()

        # -- # Get the brain asset for the hero we are monitoring
        # -- local asset = sensor.StrategicAsset
        # -- if not asset then
            # -- return
        # -- end

        # -- asset:SortCitadelUpgradePriorities(unit)
    # -- end,
    # -- GoalUpdates = {},
# -- }