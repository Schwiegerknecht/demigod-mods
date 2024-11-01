#  [MOD] Portal weights increased

# -- local StrategicAsset = import('/lua/sim/ai/StrategicAsset.lua').StrategicAsset

# -- local AIUtils = import('/lua/sim/ai/aiutilities.lua')

#[version .23] changed flag weights and customized flag weights for different maps

local prefs = import ('/lua/ui/prefs.lua')


FlagAsset = Class(StrategicAsset) {
    __init = function(self, planner, flag, flagData)
        StrategicAsset.__init(self, planner)
        self.IsFlagAsset = true

        #LOG('*AI LOG: New FlagAsset: ' .. flag.UnitName .. ' - Brain: ' .. self.Brain.Name)

        self.FlagUnit = flag

        self.Ally = IsAlly( self.Brain:GetArmyIndex(), flag:GetArmy() )

        self.AssetName = flag.UnitName
        self.FlagName = flag.UnitName

        self.FlagPosition = flag.Position

        self.RallyLocations = {}
        self.RallyMarkers = false
        self:FindRallyLocations()

        self.DemigodNeeds = {
            Assassin = { Value = 0, Weights = {} },
            StructureKill = { Value = 0, Weights = {} },
            Push = { Value = 0, Weights = {} },
        }

        self.CaptureReward = 0
        self:FindCaptureReward(flag)

        #self:ForkThread( self.DrawRallyPointThread )
    end,

    CheckAsset = function(self)
        self:FindRallyLocations()

        # Make sure there is a valid way to get to the flag
        local captureStatus = true
        local captureValue = 0
        if table.empty( self.RallyLocations ) then
            captureStatus = false
            captureValue = -25
        end
        self:SetActionStatus( 'Capture Point', captureStatus )
        self:UpdateGoals( 'Capture', captureValue )

        local defendStatus = false
        local defendValue = -25
        if self.Ally and self.Brain:GetThreatAtPosition( self.FlagPosition, 0, 'Hero', 'Enemy' ) > 1 then
            defendValue = 0
            defendStatus = true
        end
        self:UpdateGoals( 'DefendCapture', defendValue )
        self:SetActionStatus( 'DefendFlag', defendStatus )

        for needType,needData in self.DemigodNeeds do
            self.DemigodNeeds[needType].Value = 0
            for k,v in needData.Weights do
                self.DemigodNeeds[needType].Value = self.DemigodNeeds[needType].Value + v
            end
        end

        self:FindRallyStructure()
    end,

    GetBestRallyPoint = function(self, position)
        local distance, finalPos
        for k,v in self.RallyLocations do
            local tempDist = VDist3XZSq(position, v)
            if distance and tempDist >= distance then
                continue
            end

            distance = tempDist
            finalPos = table.copy(v)
        end

        return finalPos
    end,

    FindRallyLocations = function(self)
        if not self.RallyMarkers then
            self.RallyMarkers = AIUtils.GetMarkersAroundPoint( self.FlagPosition, 'Conquest Flag Rally Point', 30 )
            table.insert( self.RallyMarkers, { position = self.FlagPosition } )
        end

        local validPoints = {}

        for k,v in self.RallyMarkers do
            if self.Brain:GetThreatAtPosition( v.position, 3, 'Land', 'Ally' ) >= 0 then
                continue
            end

            if self.Brain:GetThreatAtPosition( v.position, 1, 'Land', 'Enemy' ) > 10 then
                continue
            end

            table.insert( validPoints, v.position )
        end

        self.RallyLocations = validPoints
    end,

    FindFlag = function(self)
        if self.FlagUnit and not self.FlagUnit:IsDead() then
            return self.FlagUnit
        end

        local units = self.Brain:GetUnitsAroundPoint( categories.FLAG, self.FlagPosition, 5 )
        if table.empty(units) then
            return false
        end
        return units[1]
    end,

    UpdateFlag = function(self, flag)
        #LOG('*AI LOG: Updating flag for FlagAsset: ' .. self.FlagName .. ' - Brain: ' .. self.Brain.Name)
        self.FlagUnit = flag
        self.Ally = IsAlly( self.Brain:GetArmyIndex(), flag:GetArmy() )
    end,

    IsFlagAlly = function(self)
        if not self:FindFlag() then
            return false
        end

        if IsAlly( self.Brain:GetArmyIndex(), self.FlagUnit:GetArmy() ) then
            return true
        end

        return false
    end,

    IsFlagEnemy = function(self)
        if not self:FindFlag() then
            return false
        end

        if IsEnemy( self.Brain:GetArmyIndex(), self.FlagUnit:GetArmy() ) then
            return true
        end

        return false
    end,

    FindRallyStructure = function(self)
        self.RallyStructure = false
        local structures = self.Brain:GetUnitsAroundPoint( categories.STRUCTURE, self.FlagPosition, 20, 'Ally' )
        if not structures or table.empty(structures) then
            return false
        end

        local sorted = SortEntitiesByDistanceXZ( self.FlagPosition, structures )
        self.RallyStructure = sorted[1]
        return sorted[1]
    end,

    SetDemigodNeed = function(self, needType, needName, needWeight)
        self.DemigodNeeds[needType].Weights[needName] = needWeight
    end,

    GetHeroStrength = function(self, brainAsset)
        # Starting strength for all demigods; basically it can capture without problem
        local startStrength = 0

        local noDefense = true

        # Reduce strength if there are structures nearby
        if self.DemigodNeeds.StructureKill.Value > 0 then
            noDefense = false
            local addValue = math.min( 2, brainAsset.HeroStrengths.StructureKillValue / self.DemigodNeeds.StructureKill.Value ) * 5
            if brainAsset.HeroStrengths.LevelValue < 5 then
                addValue = -10
            end
            startStrength = startStrength + addValue
        end

        # Reduce strength if there are enemy demigods nearby
        if self.DemigodNeeds.Assassin.Value > 0 then
            noDefense = false
            local addValue = math.min( 2, brainAsset.HeroStrengths.AssassinValue / self.DemigodNeeds.Assassin.Value ) * 5
            startStrength = startStrength + addValue
        elseif not noDefense then
            startStrength = startStrength + 5
        end

        if noDefense then
            startStrength = 20
        end

        return startStrength
    end,


    # Capture reward - this is how important the brain thinks it is to hold this point
    FindCaptureReward = function(self, flag)
        local brainName = self.Brain.Name

        local captureReward = 0

        local towerWeight = 0.5
        local fortWeight = 0.5
        local goldWeight = 0.5 # 0.27.04 changed value from 1.75 to 0.5
        local portalWeight = 0.5 # 0.27.04 changed value from 1.75 to 0.5
		        LOG('*AI LOG: flag weights loaded')
        if ScenarioInfo.Options.SpawnRate == 'Never' then
            portalWeight = 0.5
		end
	
		# 0.27.05 test
-- note, you CANNOT alter flag weights HERE based on warrank.  	Tried the 2 functions below, could not get it to update the xp weight
		--if self.Brain.Score.WarRank >= 2 then
		--if self.Score.WarRank  >= 2 then  
--			 local experienceWeight = 100
--			 		        LOG('*AI LOG: xp weights loaded')
--		end
		

        local warIdolWeight = 0.75 # 0.26.54 dropped to 0.75 from 1.5
        local artifactsWeight = 0.75 # 0.27.05 dropped to 0.75 from 1.25
        local cooldownWeight = 0.75 # 0.27.05 dropped to 0.75 from 1.5
        local damageAmpWeight = 0.75 # 0.27.05 dropped to 0.75 from 1.5
        local healthRegenWeight = 0.75
        local manaRegenWeight = 0.75
        local maxHealthWeight = 1.25 # 0.27.05 increased from 1.0 to 1.25
        local maxManaWeight = 1.0  # 0.27.05 increased from 1.0 to 1.25
        local waveSpeedWeight = 0.75  # 0.27.05 dropped to 0.75 from 1.25
        local waveSizesWeight = 0.75  # 0.27.05 dropped to 0.75 from 1.0
        local experienceWeight = 1.0 # 0.26.54 dropped to 1.0 from 1.75
        local healthStatueWeight = 1.5
        local trebuchetWeight = 0.75

		
# 0.27.05 removed per map logic as the code does not work - only the rules above are utilized

--[[
	#[version .24] customized flag weights for various maps below

	local AIGlobals = import ('/lua/sim/AI/AIGlobals.lua')

	#Prison
	if 'lastscenario' == '/maps/map13/map13_scenario.lua' then
		local experienceWeight = 120 #90
		local artifactsWeight = 110 #85
		local cooldownWeight = 110 #85
	end
	
	#The Brothers 
	if 'lastscenario' == '/maps/map11/map11_scenario.lua' then
		 local artifactsWeight = 30
		 local warIdolWeight = 15
		 local goldWeight = 15
		 local trebuchetWeight = 15
		 local portalWeight = 30
	end

	if 'lastscenario' == '/maps/map11/map11_scenario.lua' then 
		if unit:GetAIBrain().Score.WarRank >= 8 then
			local portalWeight = 80
		end
	end

	if 'lastscenario' == '/maps/map11/map11_scenario.lua' then
		if GetEnemyTeamBrain(unit).Score.WarRank >= 8 then
			local portalWeight = 80
	    	end
	end

	#Exile 
	if 'lastscenario' == '/maps/map12/map12_scenario.lua' then
		local maxHealthWeight = 75
		local cooldownWeight = 60
		local damageAmpWeight = 65
		local healthStatueWeight = 60
	end

	#Mandala
	if 'lastscenario' == '/maps/map04/map04_scenario.lua' then
		local maxHealthWeight = 40
		local manaRegenWeight = 30
		local cooldownWeight = 35
		local damageAmpWeight = 40
		local healthStatueWeight = 45
		local goldWeight = 45	
		local portalWeight = 40
	end

	if 'lastscenario' == '/maps/map04/map04_scenario.lua' then
		if unit:GetAIBrain().Score.WarRank >= 8 then
			local portalWeight = 80
		end
	end

	if 'lastscenario' == '/maps/map04/map04_scenario.lua' then
		if GetEnemyTeamBrain(unit).Score.WarRank >= 8 then
			local portalWeight = 80
		end
	end

# 0.26.41 adjusting flag weights to encourage the AI to stay away from the middle of the map and reducing the health value
	#Cataract
	if 'lastscenario' == '/maps/map05/map05_scenario.lua' then
		local maxHealthWeight = 30
		local maxManaWeight = 30
		local cooldownWeight = 10
		local experienceWeight = 30
		local goldWeight = 5
		local portalWeight = 5
	end



	if 'lastscenario' == '/maps/map05/map05_scenario.lua' then
		if unit:GetAIBrain().Score.WarRank >= 8 then
			local portalWeight = 60
			local warIdolWeight = 25 # 0.26.50 increased value of war idol after ws8	
		end
	end

	if 'lastscenario' == '/maps/map05/map05_scenario.lua' then
		if GetEnemyTeamBrain(unit).Score.WarRank >= 8 then
			local portalWeight = 60
			local warIdolWeight = 25 # 0.26.50 increased value of war idol after ws8	
		end
	end

	#Zikurat
	if 'lastscenario' == '/maps/map07/map07_scenario.lua' then
		local cooldownWeight = 10
		local experienceWeight = 15
		local goldWeight = 10
		local artifactsWeight = 15	
		local portalWeight = 15
	end

	if 'lastscenario' == '/maps/map07/map07_scenario.lua' then
		if unit:GetAIBrain().Score.WarRank >= 8 then
			local portalWeight = 95	
			local warIdolWeight = 20
		end
	end

	if 'lastscenario' == '/maps/map07/map07_scenario.lua' then
		if GetEnemyTeamBrain(unit).Score.WarRank >= 8 then
			local portalWeight = 95
			local warIdolWeight = 20
		end
	end
	
	#Leviathan
	if 'lastscenario' == '/maps/map09/map09_scenario.lua' then
		local damageAmpWeight = 100 
		local artifactsWeight = 100 
		local healthRegenWeight = 20
		local manaRegenWeight = 20
		local portalWeight = 120 
	end

	if 'lastscenario' == '/maps/map09/map09_scenario.lua' then
		if unit:GetAIBrain().Score.WarRank >= 8 then
			local healthRegenWeight = 40
			local manaRegenWeight = 40
		end
	end

	if 'lastscenario' == '/maps/map09/map09_scenario.lua' then
		if GetEnemyTeamBrain(unit).Score.WarRank >= 8 then
			local healthRegenWeight = 40
			local manaRegenWeight = 40
		end
	end
	
--]]
# 0.26.49 - Documentation of flag names for new locking parameters - REFERENCE
# Gold flag 'ugbresource01'
# HP flag 'unbflaghealthregen01'
# Mana flag 'unbflagmanaregen01'
# XP flag 'unbflagexperience01'
# Portal flag 'ugbportal01'
# Valor flag 'unbidol01'
	
	
	
        if flag then
            local captureUnits = flag:GetCaptureList()

            for k,v in captureUnits do
                # Towers of Light
                if (v == 'ugbdefense02') and captureReward < towerWeight then
                    captureReward = towerWeight

                # Forts
                elseif (v == 'ugbfort01') and captureReward < fortWeight then
                    captureReward = fortWeight

                # Gold Mine
                elseif (v == 'ugbresource01')and captureReward < goldWeight then
                    captureReward = goldWeight

                # War Idol
                elseif (v == 'unbidol01')and captureReward < warIdolWeight then
                    captureReward = warIdolWeight

                # Artifacts shop
                elseif (v == 'ugbshop05')and captureReward < artifactsWeight then
                    captureReward = artifactsWeight

                # Portal
                elseif (v == 'ugbportal01')and captureReward < portalWeight then
                    captureReward = portalWeight

                # Cooldown Flag
                elseif (v=='unbflagcooldown01')and captureReward < cooldownWeight then
                    captureReward = cooldownWeight

                # Damage Amp Flag
                elseif (v=='unbflagdamageamp01')and captureReward < damageAmpWeight then
                    captureReward = damageAmpWeight                

                # Health Regen Flag
                elseif (v=='unbflaghealthregen01')and captureReward < healthRegenWeight then
                    captureReward = healthRegenWeight                

                # Mana Regen Flag
                elseif (v=='unbflagmanaregen01')and captureReward < manaRegenWeight then
                    captureReward = manaRegenWeight                

                # Max Health Flag
                elseif (v=='unbflagmaxhealth01')and captureReward < maxHealthWeight then
                    captureReward = maxHealthWeight                

                # Max Mana Flag
                elseif (v=='unbflagmaxmana01')and captureReward < maxManaWeight then
                    captureReward = maxManaWeight                

                # Wave Speed Flag
                elseif (v=='unbflagwavespeed01')and captureReward < waveSpeedWeight then
                    captureReward = waveSpeedWeight

                # Wave Sizes Flag
                elseif (v=='unbflagwavesizes01')and captureReward < waveSizesWeight then
                    captureReward = waveSizesWeight

                # Experience Flag
                elseif (v=='unbflagexperience01')and captureReward < experienceWeight then
                    captureReward = experienceWeight

                # Health Statue
                elseif (v=='ugbhealthstatue01') and captureReward < healthStatueWeight then
                    captureReward = healthStatueWeight

                # Trebuchet
                elseif (v=='ugbartillery01') and captureReward < trebuchetWeight then
                    captureReward = trebuchetWeight

                end
            end

            if captureReward <= 0 then
                WARN( '*AI ERROR: No good reward found at flag - ' .. flag.UnitName )
                captureReward = 0.5
            end

            # LOG('*AI DEBUG: Capture Reward for - ' .. flag.UnitName .. ' = ' .. captureReward)
        end

        self.CaptureReward = captureReward
    end,

   CheckRallyDistances = function(self)
        # This is the position function for the asset; we pass this along to the friendly assets
        local posFunction = self.GetBestRallyPoint

        # This is the name of the indexed distance we are creating
        local name = self.FlagName .. '_RallyPoint'

        for brainName,brainAsset in self.Planner.Brains do
            if not brainAsset.IsFriendlyAsset then
                continue
            end

            brainAsset:FindNamedDistance(name, posFunction, self)
        end
   end,

   GetRallyDistance = function(self, brainName)
        local brainAsset = self.Planner.Brains[brainName]

        if not brainAsset then
            return false
        end

        local name = self.FlagName .. '_RallyPoint'
        return brainAsset:GetNamedDistance(name)
   end,
}
