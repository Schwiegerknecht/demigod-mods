--Mithy: Fix for map domination notification only on flag loss and ROLLOVER DATA ERROR on FoW flag capture
local prevFlag = FlagUnit

FlagUnit = Class(prevFlag) {

    --Hook OnStopBeingBuilt to add domination notification on flag gain
    OnStopBeingBuilt = function(self, builder, layer)
        local FCFP = Game.GameData.FlagControlFlagPercent
        local brain = self:GetAIBrain()
        local prevPct = brain.FlagPercent or 0

        prevFlag.OnStopBeingBuilt(self, builder, layer)

        --Moved from ArmyLosingFlag
        if(brain.Name != 'NEUTRAL_CIVILIAN') then
            --Added condition for pre-capture flag percent so this only triggers when crossing the flag control threshold
            --Also changed comparison from .75 to the actual GameData.FlagControlFlagPercent value (default still .75)
            if (brain.FlagPercent >= FCFP) then --and (prevPct < FCFP) then
                if(brain.Name == 'TEAM_1') then
                    brain:Alert(brain:GetStronghold(), 'FlagDominatingLight')
                    print(LOCF('<LOC flag_0000>The Forces of Light control the map!'))
                elseif(brain.Name == 'TEAM_2') then
                    brain:Alert(brain:GetStronghold(), 'FlagDominatingDark')
                    print(LOCF('<LOC flag_0001>The Forces of Darkness control the map!'))
                end
            end
        end

        --ROLLOVER DATA ERROR fix
        --Spawns a 1-radius .1 second viz for the enemy team upon flag capture
        local enemyBrain = brain:GetEnemyTeamArmy()
        if enemyBrain then
        	local enemyArmy = enemyBrain:GetArmyIndex()
	        local pos = self:GetPosition()
	        local viz = import('/lua/sim/VizMarker.lua').VizMarker {
	            X = pos[1],
	            Z = pos[3],
	            LifeTime = .01,
	            Radius = 1,
	            Army = enemyArmy,
	            Omni = true,
	            Vision = true,
	        }
	        self.Trash:Add(viz)
	    end
    end,

    --Destructively override ArmyLosingFlag to remove domination notification on flag loss
    ArmyLosingFlag = function(self)
        local brain = self:GetAIBrain()
        if not brain.NumFlags then
            brain.NumFlags = 0
        end
        brain.NumFlags = brain.NumFlags - 1
        brain.FlagPercent = brain.NumFlags / ScenarioInfo.NumFlags

        --Removed: domination notification

        # find the brain flag bonus here
        if brain.FlagPercent >= Game.GameData.FlagControlFlagPercent then
            brain.WarScoreMultiplier = Game.GameData.FlagControlMultiplier
        elseif brain.FlagPercent >= Game.GameData.FlagControlMinorFlagPercent then
            brain.WarScoreMultiplier = Game.GameData.FlagControlMinorMultiplier
        else
            brain.WarScoreMultiplier = 1.0
        end
    end,
}