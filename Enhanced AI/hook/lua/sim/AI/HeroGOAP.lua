#  [MOD] Support saving skill for later levels

# This is the Goal Oriented Action Planner for an agent
#     This selects goals, chooses actions, and repeats the process for an agent until the agent dies/game ends.

local Skill = import('/lua/sim/Skill.lua')
local Common = import('/lua/common/CommonUtils.lua')
local AIShop = import('/lua/sim/ai/AIShopUtilities.lua')
local AIUtils = import('/lua/sim/AI/AIUtilities.lua')
local ValidateInventory = import('/lua/common/ValidateInventory.lua')
local ValidateUpgrade = import('/lua/common/ValidateUpgrade.lua')
local Upgrades = import('/lua/common/CitadelUpgrades.lua').Upgrades


local HeroAIAction = import('/lua/sim/ai/HeroAIAction.lua').HeroAIAction
local HeroAIGoal = import('/lua/sim/ai/HeroAIGoal.lua').HeroAIGoal
local HeroAISensor = import('/lua/sim/ai/HeroAISensor.lua').HeroAISensor

local AIWorldState = import('/lua/sim/ai/HeroAIWorldState.lua').WorldState

local MaximumActions = import('/lua/sim/ai/AIGlobals.lua').MaximumActions
local highGold = import('/lua/sim/ai/AIGlobals.lua').highGold

--# 0.26.44 added import of miri's new fucntion 
--local SaveForUpgrade = import('/lua/sim/ai/AIGlobals.lua').SaveForUpgrade

local FirstDepthDisables = import('/lua/sim/ai/aiglobals.lua').FirstDepthDisables
local EnemyHasUpgrade = import('/lua/sim/ai/aiglobals.lua').EnemyHasUpgrade

# simlua PrintGoalData( 1, 'Survival' )
_G.PrintGoalData = function( armyNumber, goalName )
    for k,v in ArmyBrains do
        if v:GetArmyIndex() != armyNumber then
            continue
        end

        local hero = v:GetHero()
        if not hero then
            continue
        end

        if not hero.GOAP then
            continue
        end

        for gName,gData in hero.GOAP.Goals do
            if goalName == gName then
                gData:PrintData()
                #LOG('*GOAL DATA: GoalName = ' .. gName .. ' - Data = ' .. repr(gData) )
                return
            end
        end
    end

    LOG('*AI DEBUG: Could not find army number or goal name')
end

_G.DumpGoalData = function( armyNumber )
    local found = false
    for k,v in ArmyBrains do
        if v:GetArmyIndex() != armyNumber then
            continue
        end

        local hero = v:GetHero()
        if not hero then
            continue
        end

        if not hero.GOAP then
            continue
        end

        local found = true

        for gName,gData in hero.GOAP.Goals do
            gData:PrintData()
        end
    end

    if found then
        return
    end

    LOG('*AI DEBUG: Could not find army number or goal name')
end

_G.PrintLastPlanGoalData = function( armyNumber, goalName )
    for k,v in ArmyBrains do
        if v:GetArmyIndex() != armyNumber then
            continue
        end

        local hero = v:GetHero()
        if not hero then
            continue
        end

        if not hero.GOAP then
            continue
        end

        for gName,gData in hero.GOAP.PreviousGoals do
            if goalName == gName then
                LOG('*AI DEBUG: Goal Name = ' .. gData.GoalName)
                LOG('*AI DEBUG: Insistence = ' .. gData.Insistence )
                LOG('*AI DEBUG: Modifiers = ' .. repr(gData.Modifiers) )
                return
            end
        end
    end

    LOG('*AI DEBUG: Could not find army number or goal name')
end

_G.PrintLastMasterGoals = function( armyNumber )
    for k,v in ArmyBrains do
        if v:GetArmyIndex() != armyNumber then
            continue
        end

        local hero = v:GetHero()
        if not hero then
            continue
        end

        if not hero.GOAP then
            continue
        end

        LOG('*AI DEBUG: ===== MASTER GOALS =====')
        for gName,gData in hero.GOAP.MasterGoals do
            LOG('*AI DEBUG: Goal Name = ' .. gData.GoalName)
            LOG('*AI DEBUG: Insistence = ' .. repr(gData.Status) )
        end

        LOG('*AI DEBUG: ===== SET TABLE =====')
        for k,v in hero.GOAP.LastSetTable do
            LOG('*AI DEBUG: Goal Name = ' .. v )
        end
    end

    LOG('*AI DEBUG: Could not find army number')
end

_G.PrintLastPlanModel = function( armyNumber )
    for k,v in ArmyBrains do
        if v:GetArmyIndex() != armyNumber then
            continue
        end

        local hero = v:GetHero()
        if not hero then
            continue
        end

        if not hero.GOAP then
            continue
        end

        if not hero.GOAP.LastBestModel then
            break
        end

        LOG('*AI DEBUG: ===== GOAL INSISTENCES =====')
        for gName,gValue in hero.GOAP.LastBestModel do
            LOG('*AI DEBUG: Goal Name = ' .. gName .. ' - Insistence = ' .. gValue)
        end

        return
    end

    LOG('*AI DEBUG: Could not find army number or storing models is disabled')
end

_G.PrintLastPlanActions = function( armyNumber )
    for k,v in ArmyBrains do
        if v:GetArmyIndex() != armyNumber then
            continue
        end

        local hero = v:GetHero()
        if not hero then
            continue
        end

        if not hero.GOAP then
            continue
        end

        if not hero.GOAP.LastBestModel then
            break
        end

        LOG('*AI DEBUG: ===== AVAILABLE ACTIONS =====')
        for actionName,_ in hero.GOAP.PreviousActions do
            LOG('*AI DEBUG: Action Name = ' .. actionName )
        end

        return
    end

    LOG('*AI DEBUG: Could not find army number or storing actions is disabled')
end

HeroGOAP = Class() {
    TimeStats = false,
    LoopTimeStats = false,
    StatLogging = false,
    WeightsTimeThreshold = 1,
    ChildTimeThreshold = 1,
    SensorTimeThreshold = 1,
    TotalLoopThreshold = 2,
    WindowEnabled = false,
    WarnEmptyPlans = false,
    StoreBestModel = false,

    __init = function(self, agent)
        self.Trash = TrashBag()

        if ScenarioInfo.Options.AIWindow then
            self.WindowEnabled = true
        end

        if not agent then
            WARN('*AI DEBUG: Invalid agent passed into GOAP for creation' )
            return false
        end
        self.Agent = agent
        self.PlatoonLocked = 0
        self.Agent.LockedSquads = {}

        # Check if achievement slot is open
        if (ScenarioInfo.Options.achievements != 'false' and ValidateInventory.NumFreeSlots(agent.Inventory.Achievement) <= 0) then
            self.Agent.AchievementPurchased = true
        end

        self.Brain = agent:GetAIBrain()

        self.CurrentGoal = false
        self.CurrentMasterGoal = false

        self.Name = self.Brain.Name

        self.BrainAsset = self.Brain:GetTeamArmy().GOAP.Brains[self.Brain.Name]

        Sync.AIData.HeroData[self.Name] = {
            HeroName = self.Name .. ' - ' .. self.Agent:GetUnitId(),
        }

        self.Goals = {}
        self.Actions = {}
        self.Sensors = {}

        # This is a table of actions we are locking out; this is so we can have certain actions
        # disabled by other actions for longer than a single plan;
        # Ex: Mist locks out 'Two Second Wait' while Erebus is in Mist form
        self.LockedActions = {}

        # This table used for debugging the goals at last plan; contains each goal and the insistence modifiers
        self.PreviousGoals = {}
        self.PreviousActions = {}
        # Used for debugging: indexes of table or goal name - values are goal insistences
        self.LastBestModel = {}

        self:AddMasterGoals()
        self.OverrideMasterGoals = {}

        self.WorldStates = {}

        self.BuffModifiers = {}

        self.ActionPlan = {}

        self:AddUnitFunctions()

        self.PlanDepth = 4
        self.TournamentDifficulty = false
        if ScenarioInfo.Options.TournamentMode then
            # LOG('*AI DEBUG: Setting plan depth for tournament')
            if self.Brain.Difficulty == 1 then
                self.TournamentDifficulty = 1
                self.PlanDepth = 2
            elseif self.Brain.Difficulty == 2 then
                self.TournamentDifficulty = 2
                self.PlanDepth = 3
            end
        end

        self.WorldModels = {}
        self.MaximumWorldTime = 8
        self.GOAPTick = GetGameTick()

        self.Active = false
        self.SensorsActive = true

        local weapon = agent:GetWeapon(1)
        local weaponRad = 0
        if weapon then
            weaponRad = weapon:GetMaxRadius()
        end
        self.Agent.PrimaryWeaponRadius = weaponRad
		
		# -- if self.Brain.Score.HeroId == 'hgsa01' then
			# -- #WARN('Move cut off HGSA')
			# -- self.Agent.MoveCutoffRange = math.max( weaponRad, 30 ) #[MOD] TE
		# -- else
			self.Agent.MoveCutoffRange = math.max( weaponRad, 15 ) #[MOD] TE
		# -- end	


        self.Agent.WorldStateData = {
            HeroKillBonus = 0,
            GruntKillBonus = 0,
            CanMove = true,
            CanAttack = true,
            CanUseAbilities = true,
        }
        self.Agent.Callbacks.OnKilled:Add( self.AgentKilled, self )

        self.StatusFunctions = {
            LowPriority = {},
            MediumPriority = {},
            HighPriority = {},
        }

        # Sensors must be added later, they rely on the GOAP being finished with it's creation
        # Goals must be added instantly so the higher level AI can modify them earlier.
        # Actions don't hurt to have early.
        self:AddActions()
        self:AddGoals()

        self:ForkThread(self.SecondTickCreate)

        #if self.Agent:GetArmy() == 1 then
        #    self:ForkThread(self.DebugThread)
        #end
    end,

    ForkThread = function(self, fn, ...)
        if fn then
            local thread = ForkThread(fn, self, unpack(arg))
            self.Trash:Add(thread)
            return thread
        else
            return nil
        end
    end,

    IsActive = function(self)
        return self.Active
    end,

    AgentKilled = function(self)
        self.Active = false
        self.SensorsActive = false
    end,

    Destroy = function(self)
        if self.PlannerLocked then
            ScenarioInfo.AISystems.ActiveGOAPs = ScenarioInfo.AISystems.ActiveGOAPs - 1
        end

        for k,v in self.Actions do
            v:Destroy()
        end

        for k,v in self.Sensors do
            v:Destroy()
        end

        self.Trash:Destroy()
    end,



    # ==== SETUP FUNCTIONS ==== #

    SecondTickCreate = function(self)
        WaitTicks(1)
        if self.Agent:IsDead() then
            return
        end

        self:AddSensors()

        self:AddCallbacks()

        if UnitAITemplates[self.Agent:GetUnitId()].GoapCreation then
            UnitAITemplates[self.Agent:GetUnitId()].GoapCreation(self.Agent, self)
        end

        WaitTicks(3)
        if self.Agent:IsDead() then
            return
        end

        for i=0,self.PlanDepth do
            self.WorldModels[i] = AIWorldState( self.Brain, self.Agent, self.Goals, self.Actions )
        end

        WaitTicks(2)
        if self.Agent:IsDead() then
            return
        end

        self.Active = true
        self:SelectGoal()
    end,

    DebugThread = function(self)
        local upVec = Vector(0,1,0)
        while not self.Agent:IsDead() do
            local position =  AIUtils.FindSafePosition(self.Agent, self.Brain)
            if not position then
                continue
            end

            local name = self.Brain.Name
            local armyColor = import('/lua/GameColors.lua').GameColors.PlayerColors[self.Brain:GetArmyIndex()]
            DrawCircle( {position[1], 100, position[3]}, upVec, 2.5, armyColor, 10 )
            WaitTicks(1)
        end
    end,

    AddFriendlyAsset = function(self, asset)
        self.BrainAsset = asset
        for k,v in self.Sensors do
            v:AddStrategicAsset(asset)
        end
        for k,v in self.Actions do
            v:AddStrategicAsset(asset)
        end
    end,

    AddUnitFunctions = function(self)
        self.Agent.ShopInformation = {
            CanBuyItem = {},

            SellItem = {},
            BuyItem = {},
        }
        self.Agent.AIInformation = {}

        # the unit can call it's action complete which references this GOAP
        self.Agent.ActionComplete = function(agent)
            self:ActionComplete()
        end
    end,

    AddActions = function(self)
        local agentId = self.Agent:GetUnitId()
        local agentTemplate = UnitAITemplates[agentId]

        local strategicAsset = false
        if self.BrainAsset then
            strategicAsset = self.BrainAsset
        end

        for k,v in HeroAIActionTemplates do
            if v.UnitId and self.Agent:GetUnitId() != v.UnitId then
                continue
            end

            # This action can only be done in a certain victory condition
            if v.Victory and ScenarioInfo.Options.Victory != v.Victory then
                continue
            end

            # This action can only be applied to certain types of heroes
            if v.ActionSets then
                # Make sure we have teh template for the hero
                if not agentTemplate or not agentTemplate.ActionSets then
                    continue
                end

                # Check if we find the action in the blueprint
                local found = false
                for setName,bSet in v.ActionSets do
                    if not bSet then
                        continue
                    end

                    # If the agent's template has the action, we want to add this
                    if agentTemplate.ActionSets[setName] then
                        found = true
                        break
                    end
                end

                # Continue if we did not find the action set
                if not found then
                    continue
                end
            end

            # This action may have a function testing it if it can be added to heroes
            if v.RequirementFunction then
                if not v.RequirementFunction( self.Agent ) then
                    continue
                end
            end

            self.Actions[v.Name] = HeroAIAction( self.Agent, v.Name, self, strategicAsset )
        end
    end,

    AddGoals = function(self)
        for k,v in HeroAIGoalTemplates do
            if v.MasterGoal then
                continue
            end

            if v.Victory and ScenarioInfo.Options.Victory != v.Victory then
                continue
            end

            self.Goals[v.Name] = HeroAIGoal( self.Agent, v.Name, self )
        end
    end,

    AddMasterGoals = function(self)
        self.MasterGoals = {}

        for k,v in HeroAIGoalTemplates do
            if not v.MasterGoal then
                continue
            end

            if v.Victory and ScenarioInfo.Options.Victory != v.Victory then
                continue
            end

            local masterTable = {
                GoalName = v.Name,
                GoalWeights = v.MasterGoalWeights,
                Status = true,
            }

            self.MasterGoals[v.Name] = masterTable
        end
    end,

    AddSensors = function(self)
        local agentId = self.Agent:GetUnitId()
        local agentTemplate = UnitAITemplates[agentId]

        local strategicAsset = false
        if self.BrainAsset then
            strategicAsset = self.BrainAsset
        end

        for k,v in HeroAISensorTemplates do
            if v.UnitId and self.Agent:GetUnitId() != v.UnitId then
                continue
            end

            if v.Victory and ScenarioInfo.Options.Victory != v.Victory then
                continue
            end

            # This sensor may require a certain difficulty level for tournament mode
            if v.TournamentMinimumDifficulty and self.TournamentDifficulty and self.TournamentDifficulty < v.TournamentMinimumDifficulty then
                # LOG('*AI DEBUG: Skipping sensor - ' .. k )
                continue
            end

            if v.SensorSet and ( not agentTemplate or not agentTemplate.SensorSets or not agentTemplate.SensorSets[v.SensorSet] ) then
                continue
            end

            table.insert( self.Sensors, HeroAISensor( self.Agent, k, self, strategicAsset ) )
        end
    end,

    SensorTypeRefresh = function(self,sensorType)
        for sensorName,sensorData in self.Sensors do
            if sensorData.SensorType == sensorType then
                sensorData:ExecuteStatusFunction()
            end
        end
    end,

    AddStatusFunction = function( self, statusFunc, parent, priority, ... )
        if not priority or priority == 2 then
            table.insert( self.StatusFunctions.MediumPriority, { Function = statusFunc, Arguments = arg, Parent = parent, } )
        elseif priority == 1 then
            table.insert( self.StatusFunctions.LowPriority, { Function = statusFunc, Arguments = arg, Parent = parent } )
        elseif priority == 3 then
            table.insert( self.StatusFunctions.HighPriority, { Function = statusFunc, Arguments = arg, Parent = parent } )
        end
        if not self.HighPriorityStatusFunctionThread then
            self.HighPriorityStatusFunctionThread = self:ForkThread( self.StatusThreadBody, 'HighPriority', 0.5 )
            self.MediumPriorityStatusFunctionThread = self:ForkThread( self.StatusThreadBody, 'MediumPriority', 2.5 )
            self.LowPriorityStatusFunctionThread = self:ForkThread( self.StatusThreadBody, 'LowPriority', 7.5 )
        end
    end,

    StatusThreadBody = function(self, tableName, loopTime)
        local numPer
        local thisTick
        local statusTime
        local timer
        # Total number of this so far this loop; used to determine how many more ticks to wait after all status is run
        local totalTicks
        while self.SensorsActive and not self.Agent:IsDead() do
            # Find out how many to do per tick
            numPer = math.ceil( table.getn( self.StatusFunctions[tableName] ) / ( loopTime * TicksPerSecond ) )

            # Clear number of ticks for this run
            totalTicks = 1

            # This is the number we've tested this tick
            thisTick = 0
            for k,v in self.StatusFunctions[tableName] do
                if self.TimeStats then
                    timer = CreateProfileTimer()
                end
                local result = v.Function( self.Agent, v.Parent, unpack( v.Arguments ) )
                if self.TimeStats then
                    statusTime = ElapsedMilliseconds(timer)
                    self.Brain.GoalPlanner:UpdateSensorTime(statusTime)
                    if statusTime > self.SensorTimeThreshold then
                        local name = false
                        if v.Parent.IsAction then
                            name = 'Action Sensor - ' .. v.Parent.ActionName
                        elseif v.Parent.IsSensor then
                            name = 'Sensor - ' .. v.Parent.SensorName
                        end
                        LOG( '*AI DEBUG: ',GetGameTick(),' Long ' .. name .. ' - time = ' .. statusTime )
                    end
                end
                if v.Parent.IsAction then
                    v.Parent.Status = result
                end
                thisTick = thisTick + 1

                # If we've made the number of checks for this tick; wait a tick and start counting again
                if thisTick >= numPer then
                    WaitTicks(1)
                    thisTick = 0
                    totalTicks = totalTicks + 1
                    if not self.SensorsActive or self.Agent:IsDead() then
                        return
                    end
                end
            end # end for

            # Wait any extra time here; we don't want to have too many functions called.  Waiting on these is better than not
            if (totalTicks / TicksPerSecond) < loopTime then
                WaitSeconds( loopTime - (totalTicks / TicksPerSecond) )
            end

            WaitTicks(1)

        end
    end,

    AddCallbacks = function(self)

        local buffActivated = function(unit, buffName, instigator)
            self:HandleBuff( buffName, instigator, true )
        end
        self.Agent.Callbacks.OnBuffActivate:Add(buffActivated, self.Agent)

        local buffDeactivated = function(unit, buffName, instigator)
            self:HandleBuff( buffName, instigator, false )
        end
        self.Agent.Callbacks.OnBuffDeactivate:Add(buffDeactivated, self.Agent)

        if not self.Brain.HeroGOAPCallbacksAdded then
            self.Brain.HeroGOAPCallbacksAdded = true

        end
    end,

    HandleBuff = function(self, buffName, instigator, activate)
        if not self.BuffModifiers[buffName] then
            return
        end

        local buffData = self.BuffModifiers[buffName]
        local sensorData = HeroAISensorTemplates[buffData.SensorName]
        for k,v in sensorData.GoalUpdates do
            if activate then
                self:UpdateGoal( k, buffName, v * buffData.GoalModifier )
            else
                self:UpdateGoal( k, buffName, 0 )
            end
        end
    end,




    # ==== CHAT SYSTEM ==== #
    AnnounceGoalTest = {
        Attack = function(self)
            return 'Moving to attack.'
        end,
        Assassinate = function(self)
            return 'Striking an enemy Demigod.'
        end,
        Flee = function(self)
            return 'Fleeing the enemy.'
        end,
        SquadKill = function(self)
            return 'Attacking an enemy.'
        end,
        Defend = function(self)
            return 'Defending the area.'
        end,
        DestroyStructures = function(self)
            return 'Destroying nearby structures.'
        end,
        CapturePoint = function(self)
            return 'Capturing Flag.'
        end,

        SquadMove = function(self)
            return 'Squad Move.'
        end,
        MakeItemPurchases = function(self)
            return 'Making Item Purchase.'
        end,
        MoveToFriendly = function(self)
            return 'Moving to friendly.'
        end,
        WaitMasterGoal = function(self)
			return 'Waiting for master goal.'
        end,
    },

    AnnounceNewMasterGoal = function(self, newMaster)
        if  GetFocusArmy() > 0 and not IsAlly( self.Agent:GetArmy(), GetFocusArmy() ) then
            return
        end

        if self.LastAnnounce and self.LastAnnounce == newMaster then
            return
        end

        if not self.AnnounceGoalTest[newMaster] then
            WARN('*AI WARNING: No AnnounceGoalTest for master goal - ' .. newMaster)
            return
        end

        local announceString = self.AnnounceGoalTest[newMaster](self)
        if not announceString then
            return
        end

        self.LastAnnounce = newMaster

        if not Sync.AIChat then
            Sync.AIChat = {}
        end

        table.insert(Sync.AIChat,
            {
                Message = { to = 'To Allies:', text = announceString, },
                Name = self.Agent:GetAIBrain().Nickname,
            }
        )
    end,




    # ==== SHOPPING ==== #
    UpdatePurchaseActions = {
        'Sell Item - Clickables',
        'Sell Item - Equipment',
        'Purchase Base Item',
        'Purchase Base Item - Use Sell Refund',
    },
    
    PreUpdateSensors = {
        'Demigod Item Priorities',
    },

    UpdatePurchaseSensors = {
        'Shop Distance Sensor',
    },

    ForcePurchaseUpdate = function(self)
        for actionName,data in self.Agent.ShopInformation.BuyItem do
            self.Agent.ShopInformation.BuyItem[actionName] = false
        end
        for actionName,data in self.Agent.ShopInformation.CanBuyItem do
            self.Agent.ShopInformation.CanBuyItem[actionName] = false
        end
        for actionName,data in self.Agent.ShopInformation.SellItem do
            self.Agent.ShopInformation.SellItem[actionName] = false
        end

        for k,sensorName in self.PreUpdateSensors do
            local sensorBp = HeroAISensorTemplates[sensorName]
            for _,sensor in self.Sensors do
                if sensor.SensorName == sensorName then
                    sensorBp.StatusFunction(self.Agent, sensor)
                    WaitTicks(1)
                    break
                end
            end
        end
        
        for k,actionName in self.UpdatePurchaseActions do
            local actionBp = HeroAIActionTemplates[actionName]
            local action = self.Actions[actionName]

            actionBp.StatusTrigger( self.Agent, action )

            if k != table.getn(self.UpdatePurchaseActions) then
                WaitTicks(1)
            end
        end

        for k,sensorName in self.UpdatePurchaseSensors do
            local sensorBp = HeroAISensorTemplates[sensorName]
            for _,sensor in self.Sensors do
                if sensor.SensorName == sensorName then
                    sensorBp.StatusFunction(self.Agent, sensor)
                    break
                end
            end
        end
    end,




    # ==== DISTANCE MONITORS ==== #
    SetupDistanceMonitor = function(self)
        self.Agent.UnitDistances = {}

        for k,v in self.MonitorCategories do
        end

        self:ForkThread( self.DistanceMonitorFunction )
    end,

    DistanceMonitorFunction = function(self)
    end,

    UpdateDistance = function(self, updateType)
        local cat = self.MonitorCategories[updateType]

        local distance = GetPathDistanceBetweenPoints( self.Brain, self.Agent:GetPosition(), point2 )

        self.Agent.UnitDistances[updateType] = distance
		
    end,

    MonitorCategories = {
        Stronghold= categories.STRONGHOLD,
        Shop = categories.SHOP - categories.ARTIFACTSHOP,
        ArtifactShop = categories.ARTIFACTSHOP,
        HealthStatue = categories.HEALTHSTATUE,
    },




    # ==== GOAL FUNCTIONS ==== #

    AddOverrideMasterSet = function(self, setTable)
        for k,v in setTable do
            if not self.OverrideMasterGoals[v] then
                self.OverrideMasterGoals[v] = true
            end
        end
    end,

    RemoveOverrideMasterSet = function(self,setTable)
        for k,v in setTable do
            self.OverrideMasterGoals[v] = false
        end
    end,
    
    AllMasters = {
        'Flee',
        'Attack',
        'CarefulAttack',
        'MoveToFriendly',
        'Assassinate',
        'DestroyStructures',
        'SquadMove',
        'WaitMasterGoal',
        'SquadKill',
        'CapturePoint',
        'MakeItemPurchases',
    },

    EnableMasterSets = function(self, setTable)
        # Nothing passed in; enable all and return
        if not setTable then
            for k,v in self.MasterGoals do
                v.Status = true
            end
            self.LastSetTable = {}

            return
        end

        # Save out the last setTable for debug
        self.LastSetTable = table.copy(setTable)

        # We have a table; enable only those in the table
        # Disable all master goals
        for k,v in self.MasterGoals do
            v.Status = false
        end

        # Find and enable only those in the table
        for _,goalData in self.MasterGoals do

            # Some master goals have conditions which must be met in order to be valid; SquadKill must ahve a valid target, etc
            # The master goal functions are important; call them even if we aren't going to enable this master goal
            if HeroAIGoalTemplates[goalData.GoalName].GoalStatusFunction then
                if not HeroAIGoalTemplates[goalData.GoalName].GoalStatusFunction( goalData, self.Agent ) then
                    continue
                end
            end

            # if this goal is not in the override set, set if it's in the passed in setTable
            if not self.OverrideMasterGoals[goalData.GoalName] then
                local found = false
                for k,v in setTable do
                    if v == goalData.GoalName then
                        found = true
                        break
                    end
                end

                if not found then
                    continue
                end
            end

            goalData.Status = true
        end
    end,

    # Find the master goal which has the highest insistence;  This is the master goal with the actions we want
    SelectGoal = function(self, forceAction)
			local currentMaster, currentHigh
		
			#[MOD] TE Overide goals at start and other critical situations
			local eflags
			local aflags
			local nflags
			local enemyTeamBrain
			local neutCivBrain
			local allyTeamBrain
			local useLocalFunction = false
			local strongholdThreat = false

			# Find Team Brains
			for k, brain in ArmyBrains do
				if brain.TeamBrain and IsEnemy(self.Brain:GetArmyIndex(), brain:GetArmyIndex()) then
					enemyTeamBrain = brain
				elseif brain.TeamBrain and IsAlly(self.Brain:GetArmyIndex(), brain:GetArmyIndex()) then
					allyTeamBrain = brain
				elseif brain.Name == 'NEUTRAL_CIVILIAN' then
					neutCivBrain = brain
				end
			end
			
			# Find flags and count portals.
			nflags = neutCivBrain:GetListOfUnits(categories.FLAG, false)
			eflags = enemyTeamBrain:GetListOfUnits(categories.FLAG, false)
			aflags = allyTeamBrain:GetListOfUnits(categories.FLAG, false)
			local ePortals = enemyTeamBrain:GetListOfUnits(categories.PORTAL, false)
			local aPortals = allyTeamBrain:GetListOfUnits(categories.PORTAL, false)	
			local countAP = table.getn(aPortals) 
			local countEP = table.getn(ePortals)		

			# Get distances on important items
			local myStronghold = allyTeamBrain:GetStronghold()
			local strongholdDistance = false
			if myStronghold then
				strongholdThreat = allyTeamBrain:GetThreatAtPosition(myStronghold:GetPosition(), 1, nil, 'Enemy')
				strongholdDistance = self.BrainAsset:GetDistance('STRONGHOLD', 'Ally' )
			end
			
			local statueDistance = self.BrainAsset:GetDistance( 'HEALTHSTATUE', 'Ally' )
			local shopDistance = self.BrainAsset:GetDistance('ugbshop01', 'Ally' )
			local artShopDistance = self.BrainAsset:GetDistance('ugbshop05', 'Ally' )
					
			local canBuyItem = false
			for k,v in self.Agent.ShopInformation.CanBuyItem do
				if v then
					canBuyItem = true						
					break
				end
			end			
			
			# Get health and find enemies around us status
			local myHealthPercent = self.Agent:GetHealthPercent()
			local enemyGrunts =  self.Brain:GetThreatAtPosition( self.Agent.Position, 1, 'LandNoHero', 'Enemy' )
			
# 0.27.03 Added logic to count the number of enemy grunts near a hero
			# count the number of enemy grunts near the hero	
			local numEnemyGrunts = self.Brain:GetBlipsAroundPoint( categories.GRUNT, self.Agent.Position, 15, 'Enemy' )
			local numEnemyGruntsCT = 0					
					if not table.empty(numEnemyGrunts) then
					numEnemyGruntsCT = table.getn(numEnemyGrunts)	
					# WARN( 'total enemy grunts - ' .. numEnemyGruntsCT)					
					end
			local enemyTowersCount = self.Brain:GetBlipsAroundPoint( categories.DEFENSE  - categories.ROOKTOWER, self.Agent.Position, 20, 'Enemy' )
			local allyTowersCount =  self.Brain:GetUnitsAroundPoint( categories.DEFENSE  - categories.ROOKTOWER, self.Agent.Position, 15, 'Ally' )
			#WARN( 'Ally towers ' .. table.getn(allyTowersCount) )
			local enemyHeroes = false
			local enemyTowers = false
			local allyTowers = false
			
			if table.getn(enemyTowersCount) > 0 then
				enemyTowers = true
			end
			
			if table.getn(allyTowersCount) > 0 then
				allyTowers = true
			end

			# Adjust health for number of enemie heroes around
			local enemyHero = self.Brain:GetBlipsAroundPoint( categories.HERO, self.Agent.Position, 15, 'Enemy' )
			#WARN( 'Enemy count ' .. table.getn(enemyHero))
			local enemyHeroCT = 0
			if not table.empty(enemyHero) then
				enemyHeroCT = table.getn(enemyHero)
				
				if enemyHeroCT > 1 then
					local allyHero = self.Brain:GetUnitsAroundPoint( categories.HERO, self.Agent.Position, 15, 'Ally' )
								# WARN( 'Ally count ' .. table.getn(allyHero))
					local allyHeroCT = 0
					if not table.empty(allyHero) then
						allyHeroCT = table.getn(allyHero)
					end		
					
					myHealthPercent = myHealthPercent - (enemyHeroCT * .08) + (allyHeroCT * .03)
					# -- WARN( LOC(self.Brain.Nickname) .. ' Health : ' .. self.Agent:GetHealthPercent() .. ' modified ' .. myHealthPercent)
				end
			end					
			
			# Let regulus Snipe at full range
			if self.Brain.Score.HeroId == 'hgsa01' and self.Brain.SkillBuild == 'sniper_mines' and self.Agent:GetEnergy() >= 650 then			
				local units = self.Brain:GetBlipsAroundPoint( categories.HERO, self.Agent.Position, 90, 'Enemy' )
				if not table.empty(units) and table.getn(units) > 0 then
					enemyHeroes = true
				end
			else
				local units = self.Brain:GetBlipsAroundPoint( categories.HERO, self.Agent.Position, 30, 'Enemy' )
				if not table.empty(units) and table.getn(units) > 0 then
					enemyHeroes = true
				end
			end

			#self.Brain.mGold
		    #WARN ( self.Brain.Nickname .. ' tower check ' .. table.getn(enemyTowersCount) )

# 0.27.04 Get a count of allies and enemies in the area
local NearbyAllies = self.Brain:GetUnitsAroundPoint( categories.HERO, self.Agent.Position, 15, 'Ally' )
local NearbyEnemies = self.Brain:GetBlipsAroundPoint( categories.HERO, self.Agent.Position, 15, 'Enemy' )
local NearbyAllyCT = 0
local NearbyEnemyCT = 0
local DifferenceAmt = 0
			if not table.empty(NearbyAllies) then
				NearbyAllyCT = table.getn(NearbyAllies)
			end
			if not table.empty(NearbyEnemies) then
				NearbyEnemyCT = table.getn(NearbyEnemies)
			end
			DifferenceAmt = NearbyAllyCT - NearbyEnemyCT
			# WARN(LOC(self.Brain.Nickname) .. ' total difference between allies and enemiess ' .. DifferenceAmt)
			# WARN(LOC(self.Brain.Nickname) .. ' Ally count ' .. NearbyAllyCT)
			# WARN(LOC(self.Brain.Nickname) .. ' Enemy count ' .. NearbyEnemyCT)
			
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# 0.27.04 The following section is where we override existing mastergoals to force specific actions at specific times.  This is a hack that overrides the existing weight system.  Its current implementation can lead to the STUCK AI issue where the AI has a conflict of goals.
# the checks take place in the order they are listed (eg if the criteria for the first check is met, then no other checks occur - if the criteria for the first check is not met, then the second check is evaulated - and so on)

-----------------------------------------------------------------------------------------------
# NOTE - all of the code in this section is related to overrides for shopping and flag control
-----------------------------------------------------------------------------------------------

# If there are less than 20 seconds of game time, the AI should be making item purchases
# This override works perfectly and causes no conflicts
			if GetGameTimeSeconds() < 20 then
				currentMaster = 'MakeItemPurchases'
				# WARN(LOC(self.Brain.Nickname) .. ' GetGameTimeSeconds() < 20 ' .. currentMaster)

# 0.27.06 reduced gametime override from 60 seconds to 45 seconds
# If the game time is between 21 seconds and 60 seconds and there aren't any enemy heroes around, then the AI should try to capture a flag
# This override works perfectly and causes no conflicts	
			elseif GetGameTimeSeconds() < 45 and not enemyHeroes then   
				currentMaster = 'CapturePoint'
				# WARN(LOC(self.Brain.Nickname) .. ' GetGameTimeSeconds() < 60 and not enemyHeroes then ' .. currentMaster)

# If the current warscore is >= 300, the AI with the highest gold will attempt to to purchase FS1 if it has not already been purchased AND the AI has 600 gold.  This code works in conjuction with AIglobals.  
# The priority for FS1 must be low in AIglobals at the start of the game; otherwise, the AI would immediately attempt to buy FS1.  So, AIglobals increases the priority of FS1 to 500 as warscore 200.  
			elseif self.Brain.Score.WarScore >= 300 and highGold(self.Agent) and ValidateUpgrade.CanPickUpgrade(Upgrades.Tree, self.Agent, self.Brain.Score.WarRank, 'CBuildingHealth01') == true and self.Brain.mGold > 600 then
				currentMaster = 'MakeItemPurchases'
				# WARN(LOC(self.Brain.Nickname) .. ' self.Brain.Score.WarScore >= 300 and highGold(self.Agent) and ValidateUpgrade.Canbuy fs1 and self.Brain.mGold > 600 ' .. currentMaster)
				
# If the current war rank is >= 3 the AI with the highest gold will attempt to purchase currency 1 if it has not already been purchased and the AI has 1800 gold.  
			elseif self.Brain.Score.WarRank >= 3 and highGold(self.Agent) and ValidateUpgrade.CanPickUpgrade(Upgrades.Tree, self.Agent, self.Brain.Score.WarRank, 'CGoldIncome01') == true and self.Brain.mGold > 1800 then
				currentMaster = 'MakeItemPurchases'
				# WARN(LOC(self.Brain.Nickname) .. ' self.Brain.Score.WarRank >= 3 and highGold(self.Agent) and cur1 is a valid selection and I can afford it - ' .. currentMaster)

# 0.27.00 Reworked shop periods
# SHOP PERIODS
# Warscore >= 300, AI with most money, possible to buy fs1, at least 600 gold
# Warrank >= 3, AI with most money, possible to buy cur1, at least 1800 gold
# Warscore between 2450-2575, NOT AI with most money, at least 1500 gold
# Warscore between 3100-3225, AI with most money, at least 1500 gold
# Warscore between 3800-3925, AI with most money, at least 1500 gold
# Warscore between 4150-4275, NOT AI with most money, at least 1500 gold
# Warrank 8 OR AI already bought the upgrade, priest/angel/cats available, AI can afford the upgrade
# Warrank 10, possible to buy giants, AI can afford the upgrade
				
# If the current warscore is between 2450 and 2575, any AI with < the highest gold that has more than 1500 gold will shop
			elseif self.Brain.Score.WarScore > 2450 and self.Brain.Score.WarScore < 2575 and highGold(self.Agent) == false and self.Brain.mGold > 1500 then
				currentMaster = 'MakeItemPurchases'

# If the current warscore is between 3100 and 3225, the AI with the highest gold that has more than 1500 gold will shop
			elseif self.Brain.Score.WarScore > 3100 and self.Brain.Score.WarScore < 3225 and highGold(self.Agent) == true and self.Brain.mGold > 1500 then
				currentMaster = 'MakeItemPurchases'

# If the current warscore is between 3800 and 3925, the AI with the highest gold that has more than 1500 gold will shop
			elseif self.Brain.Score.WarScore > 3800 and self.Brain.Score.WarScore < 3925 and highGold(self.Agent) == true and self.Brain.mGold > 1500 then
				currentMaster = 'MakeItemPurchases'
				
# If the current warscore is between 4150 and 4275, any AI with < the highest gold that has more than 1500 gold will shop
			elseif self.Brain.Score.WarScore > 4150 and self.Brain.Score.WarScore < 4275 and highGold(self.Agent) == false and self.Brain.mGold > 1500 then
				currentMaster = 'MakeItemPurchases'

-------------------------------------------------------------------------------------------------------------------
# PURCHASING TROOPS
-------------------------------------------------------------------------------------------------------------------

# If either team has picked up priests or angels any time after they become available, the other team will immediately purchase priests or angels to even the playing field
			elseif EnemyHasUpgrade(self.Agent, 'CTroopNumber03') and ValidateUpgrade.CanPickUpgrade(Upgrades.Tree, self.Agent, self.Brain.Score.WarRank, 'CTroopNumber03') == true then
				currentMaster = 'MakeItemPurchases'	
			elseif EnemyHasUpgrade(self.Agent, 'CTroopNumber05') and ValidateUpgrade.CanPickUpgrade(Upgrades.Tree, self.Agent, self.Brain.Score.WarRank, 'CTroopNumber05') == true then
				currentMaster = 'MakeItemPurchases'		

# Once war rank 8 has been reached, each team will attempt to purchase priests (if not already owned), angels, and catapults
			elseif self.Brain.Score.WarRank >= 8 and ValidateUpgrade.CanPickUpgrade(Upgrades.Tree, self.Agent, self.Brain.Score.WarRank, 'CTroopNumber03') == true  then
				currentMaster = 'MakeItemPurchases'
			elseif self.Brain.Score.WarRank >= 8 and ValidateUpgrade.CanPickUpgrade(Upgrades.Tree, self.Agent, self.Brain.Score.WarRank, 'CTroopNumber05') == true  then  
				currentMaster = 'MakeItemPurchases'
			elseif self.Brain.Score.WarRank >= 8  and highGold(self.Agent) and ValidateUpgrade.CanPickUpgrade(Upgrades.Tree, self.Agent, self.Brain.Score.WarRank, 'CTroopNumber04') == true  then 
				currentMaster = 'MakeItemPurchases'

# Once warrank 10 is reached, each team will attempt to purchase giants as soon as possible
			elseif self.Brain.Score.WarRank == 10 and highGold(self.Agent) and ValidateUpgrade.CanPickUpgrade(Upgrades.Tree, self.Agent, self.Brain.Score.WarRank, 'CTroopNumber06') == true then  
				currentMaster = 'MakeItemPurchases'

-------------------------------------------------------------------------------------------------------------------
# SHOPPING OVERRIDES
-------------------------------------------------------------------------------------------------------------------
				
# The following overrides exist to ensure that the AI will attmept to shop if its close enough and can afford something, etc
			elseif canBuyItem and self.CurrentMasterGoal == 'MakeItemPurchases' and self.Brain.mGold > 250 then
				#currentMaster = 'MakeItemPurchases'
				useLocalFunction = true	
			elseif canBuyItem and strongholdDistance and   strongholdDistance < 15 and self.Brain.mGold > 250 then
				currentMaster = 'MakeItemPurchases'	
			elseif canBuyItem and shopDistance and    shopDistance < 15 and self.Brain.mGold > 250 then
				currentMaster = 'MakeItemPurchases'				
			elseif canBuyItem and artShopDistance and self.Brain.mGold >= 8000 and  artShopDistance < 15 then
				useLocalFunction = true	
				#currentMaster = 'MakeItemPurchases'						
			elseif canBuyItem and statueDistance and statueDistance < 15 and self.Brain.mGold > 250 then
				currentMaster = 'MakeItemPurchases'				

-------------------------------------------------------------------------------------------------------------------
# Late game rush for portals, etc
-------------------------------------------------------------------------------------------------------------------

# If the rank is >= 8 and the enemies control more than 1 flag and the number of enemy flags is >= the number of allied flags, AND the AI's hp is > 50%, AND no heroes are nearby, capture a flag				
			elseif eflags and table.getn(eflags) > 0 and self.Brain.Score.WarRank >= 8 and countEP >= countAP and myHealthPercent > .5 and not enemyHeroes then
				currentMaster = 'CapturePoint'	

-------------------------------------------------------------------------------------------------------------------
# AI Retreating Logic
-------------------------------------------------------------------------------------------------------------------

# 0.27.06 Reduced the reteat values if there are nearby enemy heroes and towers from 85% to 75%
			elseif myHealthPercent <  .75 and enemyHeroes and enemyTowers  then
				currentMaster = 'Flee'	
				# WARN(LOC(self.Brain.Nickname) .. ' myHealthPercent <  .85 and enemyHeroes and enemyTowers ' .. currentMaster)
			elseif myHealthPercent <  .60 and not enemyHeroes and enemyTowers  then
				currentMaster = 'Flee'			
				# WARN(LOC(self.Brain.Nickname) .. ' myHealthPercent <  .60 and not enemyHeroes and enemyTowers  ' .. currentMaster)				
			elseif myHealthPercent <  .60 and enemyHeroes and not allyTowers  and not enemyTowers  then 
				currentMaster = 'Flee'
				# WARN(LOC(self.Brain.Nickname) .. ' myHealthPercent <  .60 and enemyHeroes and not allyTowers  and not enemyTowers ' .. currentMaster)				
			elseif myHealthPercent <  .50 and enemyHeroes and allyTowers  then 
				currentMaster = 'Flee'
				# WARN(LOC(self.Brain.Nickname) .. ' myHealthPercent <  .50 and enemyHeroes and allyTowers ' .. currentMaster)								
			elseif self.Agent:GetHealth() <  1500 then
				currentMaster = 'Flee'
				# WARN(LOC(self.Brain.Nickname) .. ' self.Agent:GetHealth() <  1500 ' .. currentMaster)	

-------------------------------------------------------------------------------------------------------------------
# DG vs DG logic
-------------------------------------------------------------------------------------------------------------------

				
# 0.27.06 modified rules for dg vs dg fights.  AI will run if there are more enemies than allies present
--# 0.27.04 Rules of engagment for dg vs dg fights
-- these next 2 checks force an ai to fight unless the difference is 3 to 1.  If its 3ai v 1, the ai will flee

			elseif enemyHeroes and NearbyAllyCT >= NearbyEnemyCT then
				currentMaster = 'Assassinate'		
				# WARN(LOC(self.Brain.Nickname) .. ' there are more of us than them.  I must kill them ' .. currentMaster)	
			elseif enemyHeroes then
				currentMaster = 'Flee'		
				# WARN(LOC(self.Brain.Nickname) .. ' more enemies present than I like - i am running - ' .. currentMaster)	

# 0.27.03 reduced the warscore comparison from 250 to 100
			elseif myHealthPercent > .60 and  self.Brain.Score.WarRank < 10 and eflags and table.getn(eflags) > 0 and (enemyTeamBrain.Score.WarScore - allyTeamBrain.Score.WarScore) > 100 then
				# WARN('Score Difference:  ' .. 'Ally= ' .. allyTeamBrain.Score.WarScore .. ' Enemy= ' ..enemyTeamBrain.Score.WarScore.. ' Diff= ' .. (enemyTeamBrain.Score.WarScore - allyTeamBrain.Score.WarScore) )
				currentMaster = 'CapturePoint'	
				# WARN(LOC(self.Brain.Nickname) .. ' capture point goal - we are down in ws by at least 50' .. currentMaster)	
				
# 0.27.09 reenabled the code for now
--# 0.27.06 disabled the attack override code to allow the AI to make it's own decision based on weight
--# 0.27.03 changed this formula to evaluate whether or not to attack based on the number of grunts in the area			
			elseif myHealthPercent > .60  and self.Brain.Score.WarRank < 8  and numEnemyGruntsCT > 0 and not enemyTowers then 
				currentMaster = 'Attack'	
				# WARN(LOC(self.Brain.Nickname) .. ' myHealthPercent > .60  and self.Brain.Score.WarRank < 8  and enemyGrunts > 0' .. currentMaster)	
				# WARN(LOC(self.Brain.Nickname) .. 'LLLLLLLLLLLLLLLLLLLLLLOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOKKKKKKKKKKKKKKKKK PACOV total enemies ' .. numEnemyGruntsCT )	

# 0.27.03 Disabled the attack structure logic.  The AI readily receives the command but refuses to attack the structure (eg stays just out of range).  Additional changes would be necessary to force this goal and could cause a negative impact
--# 0.26.54 Re-enabled the attack structure code - added requirement that enemy heroes MUST NOT be present
--# 0.26.41 Re-enabled the attack structures code
--# 0.26.48 disabled the structures code for sledge (must re-enable)
--[[
			elseif myHealthPercent > .60  and self.Brain.Score.WarRank < 8  and enemyTowers and not enemyHeroes then 
				currentMaster = 'DestroyStructures'		
			WARN(LOC(self.Brain.Nickname) .. ' myHealthPercent > .60  and self.Brain.Score.WarRank < 8  and enemyTowers and not enemyHeroes then' .. currentMaster)	
--]]
				
				
			elseif eflags and aflags and table.getn(eflags) > table.getn(aflags) and  myHealthPercent > .6   then # and (table.getn(aflags) <= table.getn(eflags) or self.Brain.Score.WarRank >= 8)
				currentMaster = 'CapturePoint'	
				# WARN(LOC(self.Brain.Nickname) .. ' eflags and aflags and table.getn(eflags) > table.getn(aflags) and  myHealthPercent > .6 ' .. currentMaster)	
				
#  [MOD] TE, If no clear master goal based on current situation let default function make the choice.
			else
				
				useLocalFunction = true		
				# WARN(LOC(self.Brain.Nickname) .. '*No clear goal - let the AI pick')	
			end
			
			#WARN(LOC(self.Brain.Nickname) .. ' - ' .. currentMaster)
			
			if useLocalFunction or not currentMaster then
				#[MOD] TE  Original function
				for k,v in self.MasterGoals do
					if v.Status == false then
						continue
					end

					local tempValue = 0
					for goalName,goalWeight in v.GoalWeights do
						local goal = self:FindGoal(goalName)
						if not goal then
							WARN('*AI ERROR: No Goal found named - ' .. goalName )
							continue
						end
						tempValue = tempValue + ( goal.Insistence * goalWeight )
					end

					if tempValue <= 0 or tempValue < currentHigh then
						continue
					end
					currentMaster = v.GoalName
						# WARN('*Goal assigned by default function - ' .. currentMaster )		
					currentHigh = tempValue		
				end
			end
			
        if not currentMaster then
            #WARN('*AI ERROR: No master goal selected - ' .. self.Brain.Name)
            if not self.Brain.CurrentSquad then
                #WARN('*AI ERROR: No Squad')
                self:EnableMasterSets(self.AllMasters)
            else
                #WARN('*AI ERROR: Running squad type - ' .. repr(self.Brain.CurrentSquad.SquadType) )
                #if self.SquadState then
                #    WARN('*AI ERROR: Current Squad State - ' .. self.SquadState)
                #end
                self.Brain.CurrentSquad:UpdateSquadHero(self.Agent)
            end
            self:DelaySelect(true, .5)
            return
        end

        if self.CurrentMasterGoal != currentMaster or forceAction then

            #if not forceAction and self.Agent:GetArmy() == 1 and self.LastSensorUpdate then
            #    LOG( '*AI DEBUG: Army 1 goal repick forced new action - Sensor = ' .. self.LastSensorUpdate )
            #end

            if self.WindowEnabled then
                if not Sync.AIData.HeroData[self.Name] then
                    Sync.AIData.HeroData[self.Name] = {}
                end
                Sync.AIData.HeroData[self.Name].Goals = {}
                for k,v in self.Goals do
                    str = v.GoalName .. ' - ' .. v.Insistence
                    table.insert( Sync.AIData.HeroData[self.Name].Goals, str )
                end
                Sync.AIData.HeroData[self.Name].MasterGoal = currentMaster
            end

# 0.26.43 - disabled AI goal announcements
--[[
			#[MOD] AI Chat to let you know thier goal
            self:AnnounceNewMasterGoal(currentMaster)
			
			
            if self.Agent:GetArmy() == 1 then
               LOG('*AI DEBUG: Master Goal = ' .. currentMaster)
            end
--]]

            self.CurrentMasterGoal = currentMaster

            self:SelectPlan()
        end
    end,

    SelectPlan = function(self)
        if self.Active and not self.PlannerLocked then
            ScenarioInfo.AISystems.ActiveGOAPs = ScenarioInfo.AISystems.ActiveGOAPs + 1
            self.PlannerLocked = true
            KillThread( self.PlanningThread )
            self.PlanningThread = self:ForkThread( self.SelectIterativeDeepenedActionPlan, self.PlanDepth )
        end
    end,

    GetAction = function(self, actionName)
        return self.Actions[actionName]
    end,

    FindGoal = function(self, goalName)
        return self.Goals[goalName]
    end,

    UpdateGoal = function(self, goalName , modifier, value)
        local goal = self:FindGoal( goalName )

        if goal then
            goal:UpdateModifier( modifier, value )
            return
        end

        WARN('*AI ERROR: Invalid Goal update named - ' .. goalName )
    end,

    StorePreviousGoals = function(self)
        self.PreviousGoals = {}

        for goalName,goalData in self.Goals do
            self.PreviousGoals[goalName] = {
                GoalName = goalName,
                Insistence = goalData.Insistence,
                Modifiers = table.copy(goalData.Modifiers),
            }
        end
    end,

    StorePreviousActions = function(self, actionSet)
        self.PreviousActions = {}

        for actionName,actionData in actionSet do
            self.PreviousActions[actionName] = true
        end
    end,


    # ==== ACTION FUNCTIONS ==== #

    # This is to create a sub-set of actions for action planning; we don't want all actions
    # This pulls out any Status == false and of wrong master goal set currently
    CreateActionSet = function(self, goalSet)
        local actions = {}
        for k,v in self.Actions do
            # Check if the action has passed the status check
            if not v.Status then
                continue
            end

            # Check if the action is locked out by something
            if self.LockedActions[v.ActionName] then
                continue
            end

            # Check if the action is in the current master goal
            if self.CurrentMasterGoal and not v:CheckGoalSet(self.CurrentMasterGoal) then
                continue
            end

            # Check if the actions instant status if it has one
            if HeroAIActionTemplates[v.ActionName].InstantStatusFunction then
                if not HeroAIActionTemplates[v.ActionName].InstantStatusFunction(self.Agent, v) then
                    continue
                end
            end

            # Check if the current SquadType is in the SquadSet for this action
            if HeroAIActionTemplates[v.ActionName].SquadSets then
                if self.Brain.CurrentSquad then
                    if not HeroAIActionTemplates[v.ActionName].SquadSets[self.Brain.CurrentSquad.SquadType] then
                        #LOG('SquadType: ' .. self.Brain.CurrentSquad.SquadType)
                        continue
                    end
                end
            end

            # Add action to available list; the actions list is hashed by action name for
            # speed when disabling actions in the planning
            actions[v.ActionName] = v
        end
        return actions
    end,

    LockActions = function(self, actions)
        for k,v in actions do
            self.LockedActions[v] = true
        end
    end,

    UnlockActions = function(self, actions)
        for k,v in actions do
            self.LockedActions[v] = false
        end
    end,





    # ==== PLANNER FUNCTIONS ==== #

    ResetAgent = function(self)
        self.Agent.SafePosition = nil
    end,

    SelectIterativeDeepenedActionPlan = function(self, depth)
        # Check if we need to spend any skill points here
        while self.Agent.Sync.SkillPoints > 0 do
            local upgrade = self.BrainAsset:PickSkillUpgrade(self.Agent)

            if not upgrade then
                break
            end
			
			# [MOD] If the skill returned is 'SAVE' check if we have another skill point, otherwise abort
			if upgrade == 'SAVE' then
				if self.Agent.Sync.SkillPoints >= 2 then
					self.BrainAsset:savedSkillcomplete(self.Agent)
				else
					break
				end

				upgrade = self.BrainAsset:PickSkillUpgrade(self.Agent)
				
				if not upgrade then
					break
				end
            end
			
			if upgrade == 'SAVE2' then
				if self.Agent.Sync.SkillPoints >= 3 then
					self.BrainAsset:savedSkillcomplete(self.Agent)
				else
					break
				end

				upgrade = self.BrainAsset:PickSkillUpgrade(self.Agent)
				
				if not upgrade then
					break
				end
            end
			
			if upgrade == 'SAVE3' then
				if self.Agent.Sync.SkillPoints >= 4 then
					self.BrainAsset:savedSkillcomplete(self.Agent)
				else
					break
				end

				upgrade = self.BrainAsset:PickSkillUpgrade(self.Agent)
				
				if not upgrade then
					break
				end
            end
			

            PurchaseSkill(self.Agent, upgrade)
            WaitTicks(1)
        end
		

        while not ScenarioInfo.CameraWaitFinished do
            WaitTicks(1)
        end

        # Check if we can buy an achievement item
        if(not self.Agent.AchievementPurchased) then
            local result = false
            result = AIShop.PurchaseAchievementItem(self.Agent)
            if(result) then
                self.Agent.AchievementPurchased = true
            end
        end

        self:ResetAgent()

        # Do all pre-building of the GOAP here
        self.GOAPTick = GetGameTick()
        local actionSet = self:CreateActionSet()
        local masterGoal = self.CurrentMasterGoal

        if self.TimeStats then
            self.Brain.GoalPlanner:UpdateHeroGOAPCount()
        end
        local models = self.WorldModels

        local actions = {}
        local numTests = 0
        local numTicks = 1
        local numSwitches = 0
        local currentCount = 0

        local totalChildTime = 0
        local totalWeightTime = 0
        local totalCompareTime = 0
        local totalCopyTime = 0
        local totalLoopTime = 0

        local compareTimer, loopTimer, childTime, weightTime, stateTimer

        # Disable all actions in all models; only those created in the action set are enabled
        for k,v in models do
            for _,action in v.Actions do
                action.Status = false
            end
        end

        models[0]:UpdateWorldState( self.Agent, self.Goals, actionSet )
        for i=0,self.PlanDepth do
            models[i].Agent.WorldStateData = table.copy( self.Agent.WorldStateData )
        end

        local currentDepth = 0

        local bestModel = {}

        # Store out the current goals in the PreviousGoals table; for debugging
        self:StorePreviousGoals()
        self:StorePreviousActions(actionSet)


        # Begin GOAP processing here

        WaitTicks(1)
        if not self.Active then
            return
        end

        local bestAction, bestValue, bestDepth
        local actionMaximum = math.floor( MaximumActions / ScenarioInfo.AISystems.ActiveGOAPs )

        if self.TimeStats or self.LoopTimeStats then
            loopTimer = CreateProfileTimer()
        end

        while currentDepth >= 0 do

            numTests = numTests + 1
            currentCount = currentCount + 1

            # ==== COMPARISON SECTION ==== #

            if self.TimeStats then
                compareTimer = CreateProfileTimer()
            end

            local currentValue = models[currentDepth].WorldInsistence
            local currentTime = models[currentDepth].ActionTime

            if currentDepth > 0 and currentTime > 0 and
                        ( not bestValue or currentValue < bestValue or
                        (currentValue == bestValue and currentDepth < bestDepth) ) then
                bestValue = currentValue
                bestDepth = currentDepth
                bestAction = {}
                for i,act in actions do
                    if i > currentDepth then
                        continue
                    end

                    bestAction[i] = act
                end
                if self.StoreBestModel then
                    for k,v in models[currentDepth].Goals do
                        bestModel[k] = v.Insistence
                    end
                end
            end

            if self.TimeStats then
                local compareElapsed = ElapsedMilliseconds(compareTimer)
                totalCompareTime = totalCompareTime + compareElapsed
            end
            # ==== END COMPARISON SECTION ==== #

            # If at maximum depth
            if currentDepth >= depth then
                currentDepth = currentDepth - 1
                continue
            end

            # This model has reached the maximum time duration
            if models[currentDepth].ActionTime >= self.MaximumWorldTime then
                currentDepth = currentDepth - 1
                continue
            end

            local nextAction = models[currentDepth]:GetNextAction()
            if nextAction then

                # ==== RESET WORLD STATE SECTION ==== #
                # Reset world state on children if the model agent's world state was altered by a direct child
                if models[currentDepth].ResetWorldState then
                    if self.TimeStats then
                        stateTimer = CreateProfileTimer()
                    end

                    if currentDepth <= depth then
                        for i=currentDepth+1,depth do
                            models[i].Agent.WorldStateData = table.copy(models[currentDepth].Agent.WorldStateData)
                        end
                    end
                    models[currentDepth].ResetWorldState = false

                    if self.TimeStats then
                        local copyElapsed = ElapsedMilliseconds(stateTimer)
                        totalCopyTime = totalCopyTime + copyElapsed
                        #LOG('*AI DEBUG: World State Copy = ' .. copyElapsed .. ' - Action = ' .. nextAction .. ' - CurrentDepth = ' .. currentDepth)
                    end
                end
                # ==== END RESET WORLD STATE SECTION ==== #


                # ==== CHILD WORLD SECTION ==== #
                # Create a new child state
                # Track time it takes to create new child
                if self.TimeStats then
                    childTime = CreateProfileTimer()
                end
                models[currentDepth+1]:CopyWorldState( models[currentDepth], nextAction )
                if HeroAIActionTemplates[nextAction].FinalAction then
                    models[currentDepth+1]:DisableAllActions()
                elseif currentDepth == 0 then
                    models[currentDepth+1]:DisableActions( FirstDepthDisables )
                end
                if self.TimeStats then
                    local elapsed = ElapsedMilliseconds(childTime)
                    totalChildTime = totalChildTime + elapsed
                    if elapsed > self.ChildTimeThreshold then
                        LOG('*AI DEBUG: ',GetGameTick(),' Long Child - ' .. nextAction .. ' time = ' .. elapsed .. ' depth = ' .. currentDepth )
                    end
                end
                # ==== END CHILD WORLD SECTION ==== #


                # Apply new action to teh model
                actions[currentDepth+1] = nextAction


                # ==== WEIGHTS SECTION ==== #
                # Find out if we can go deeper in the models;
                # Track time it takes to calculate the weights and get status
                if self.TimeStats then
                    weightTime = CreateProfileTimer()
                end
                local status, consistent = models[currentDepth+1]:ApplyAction( nextAction )
                if self.TimeStats then
                    local elapsed = ElapsedMilliseconds(weightTime)
                    totalWeightTime = totalWeightTime + elapsed
                    if elapsed > self.WeightsTimeThreshold then
                        LOG('*AI DEBUG: ',GetGameTick(), ' Long Weights - ' .. nextAction .. ' time = ' .. elapsed .. ' depth = ' .. currentDepth )
                    end
                end
                # ==== END WEIGHTS SECTION ==== #

                if status then

                    # ==== PROPOGATE STATE SECTION ==== #
                    # Propogate the world state change to children
                    if not models[currentDepth+1].Agent.WorldStateConsistent then
                        if self.TimeStats then
                            stateTimer = CreateProfileTimer()
                        end

                        if currentDepth+2 <= depth then
                            for i=currentDepth+2,depth do
                                models[i].Agent.WorldStateData = table.copy(models[currentDepth+1].Agent.WorldStateData)
                            end
                        end

                        models[currentDepth].ResetWorldState = true
                        if self.TimeStats then
                            local elapsed = ElapsedMilliseconds(stateTimer)
                            totalCopyTime = totalCopyTime + elapsed
                            #LOG('*AI DEBUG: World State Copy = ' .. elapsed .. ' - Action = ' .. nextAction .. ' - CurrentDepth = ' .. currentDepth)
                        end
                    end
                    # ==== END PROPOGATE STATE SECTION ==== #


                    # Deepen by one
                    currentDepth = currentDepth + 1
                end
            else
                currentDepth = currentDepth - 1
            end




            if currentCount >= actionMaximum then
                currentCount = 0
                if self.TimeStats or self.LoopTimeStats then
                    self.Brain.GoalPlanner:IncreaseGOAPTickCount()
                    local loopElapsed = ElapsedMilliseconds(loopTimer)
                    totalLoopTime = loopElapsed + totalLoopTime
                end
                WaitTicks(1)
                if not self.Active or self.Agent:IsDead() then
                    return
                end
                numTicks = numTicks + 1
                loopTimer = CreateProfileTimer()
                actionMaximum = math.floor( MaximumActions / ScenarioInfo.AISystems.ActiveGOAPs )
            end
        end

        if self.TimeStats or self.LoopTimeStats then
            totalLoopTime = totalLoopTime + ElapsedMilliseconds(loopTimer)

            if totalLoopTime / numTicks > self.TotalLoopThreshold then
                LOG('*AI DEBUG: AI Brain Number = ' .. self.Agent:GetArmy() )
                LOG('*AI DEBGU: Master goal = ' .. masterGoal )
                LOG('*AI DEBUG: Current Tick = ' .. GetGameTick() )
                LOG('*AI DEBUG: numTests = ' .. numTests)
                LOG('*AI DEBUG: numTicks = ' .. numTicks)
                if totalCompareTime > 0 then
                    LOG('*AI DEBUG: Average CompareTime = ' .. totalCompareTime / numTests )
                end
                if totalCopyTime > 0 then
                    LOG('*AI DEBUG: Average CopyTime = ' .. totalCopyTime / numTests )
                end
                if totalChildTime > 0 then
                    LOG('*AI DEBUG: Average totalChildTime = ' .. totalChildTime / numTests )
                end
                if totalWeightTime > 0 then
                    LOG('*AI DEBUG: Average totalWeightTime = ' .. totalWeightTime / numTests )
                end
                LOG('*AI DEBUG: Average LoopTime = ' .. totalLoopTime / numTests )
		        LOG('*AI DEBUG: ==================')
                if totalCompareTime > 0 then
                    LOG('*AI DEBUG: CompareTime = ' .. totalCompareTime)
                end
                if totalCopyTime > 0 then
                    LOG('*AI DEBUG: CopyTime = ' .. totalCopyTime)
                end
                if totalChildTime > 0 then
                    LOG('*AI DEBUG: totalChildTime = ' .. totalChildTime)
                end
                if totalWeightTime > 0 then
                    LOG('*AI DEBUG: totalWeightTime = ' .. totalWeightTime)
                end
                WARN('*AI DEBUG: LoopTime = ' .. totalLoopTime)
                WARN('*AI DEBUG: Avg Loop Time = ' .. totalLoopTime / numTicks )
                local tempActions = {}
                for k,v in actionSet do
                    table.insert( tempActions, v.ActionName )
                end
                LOG('*AI ERROR: Num Actions = ' .. table.getn(tempActions) )
                LOG('*AI ERROR: Available Actions = ' .. repr(tempActions) )
                LOG('*AI DEBUG: ==================')
            end

            self.Brain.GoalPlanner:UpdateGOAPTimes(totalChildTime, totalWeightTime, numTests)
            self.Brain.GoalPlanner:UpdatePlanDepth( numTests, masterGoal )
        end

        if (self.TimeStats or self.LoopTimeStats) and numTests > 2000 then
            LOG('*AI DEBUG: UnitId = ' .. self.Agent:GetUnitId() .. ' NumTests = ' .. numTests )
            LOG('*AI DEBUG: Master goal = ' .. masterGoal )
            local tempActions = {}
            for k,v in actionSet do
                table.insert( tempActions, v.ActionName )
            end
            LOG('*AI DEBUG: Num Actions = ' .. table.getn(tempActions) )
            LOG('*AI DEBUG: Available Actions = ' .. repr(tempActions) )
        end

        # Unlock the planner
        self.PlannerLocked = false

        ScenarioInfo.AISystems.ActiveGOAPs = ScenarioInfo.AISystems.ActiveGOAPs - 1

        local actionTimer = nil
        if self.TimeStats then
            actionTimer = CreateProfileTimer()
        end

        # if we have a best action set, perform it
        if bestAction and table.getn(bestAction) > 0 then
            if self.WindowEnabled then
                if not Sync.AIData.HeroData[self.Name] then
                    Sync.AIData.HeroData[self.Name] = {}
                end
                Sync.AIData.HeroData[self.Name].ActionPlan = table.copy( bestAction )
                table.insert( Sync.AIData.HeroData[self.Name].ActionPlan, 'END' )
            end

            # Stat logging of action sets
            if self.StatLogging then
                import('/lua/sim/ai/AIStatTracking.lua').LogMasterGoalDepth( self.Brain, self.Agent, numTests, masterGoal )
                import('/lua/sim/ai/AIStatTracking.lua').LogHeroActionPlan( self.Brain, self.Agent, bestAction, masterGoal )
            end

            if self.StoreBestModel then
                self.LastBestModel = table.copy(bestModel)
            end
            # Set the action plan and start working on it
            self.ActionPlan = bestAction
            self:PerformNextAction()
        else
            if self.WarnEmptyPlans and self.Brain:GetArmyIndex() == 1 then
                # ERROR - No plan generated ....
                WARN('*AI ERROR: ==============================================')
                WARN('*AI ERROR: No plan generated - MasterGoal = ' .. masterGoal)
                WARN('*AI ERROR: UnitId = ' .. self.Agent:GetUnitId() .. ' - Army = ' .. self.Brain:GetArmyIndex() )
                if self.SquadState then
                    WARN('*AI ERROR: Squad State - ' .. self.SquadState)
                end
                local tempActions = {}
                for k,v in actionSet do
                    table.insert( tempActions, v.ActionName )
                end
                WARN('*AI ERROR: Num Actions = ' .. table.getn(tempActions) )
                WARN('*AI ERROR: Available Actions = ' .. repr(tempActions) )

                for k,v in self.Goals do
                    WARN('*AI ERROR: Goal - ' .. k .. ' - Insistence: ' .. v.Insistence)
                end
            end

            # No action set found; wait a few ticks
            self:DelaySelect(true, 0.5)
        end

        if self.TimeStats then
            local actionElapsed = ElapsedMilliseconds(actionTimer)
            if actionElapsed > 1 then
                LOG('*AI DEBUG: ActionElapsed = ' .. actionElapsed)
            end
        end
    end,

    UpdateSquadState = function(self, state)
        self.SquadState = state
        if self.WindowEnabled then
            if not Sync.AIData.HeroData[self.Name] then
                Sync.AIData.HeroData[self.Name] = {}
            end
            Sync.AIData.HeroData[self.Name].SquadState = state
        end
    end,

    ActionComplete = function(self)
        self.Agent.CurrentAction = false
        if table.getn(self.ActionPlan) > 0 then
            self:PerformNextAction()
        else
            self:ForkThread( self.DelaySelect, true )
        end
    end,

    DelaySelect = function(self, bForceAction, time)
        if not self.DelayLocked then
            self.DelayLocked = true
            self:ForkThread( self.DelaySelectFunction, bForceAction, time)
        end
    end,

    DelaySelectFunction = function(self, bForceAction, time)
        WaitSeconds(time or 0.1)
        if not self.Active or self.Agent:IsDead() then
            return
        end
        self.DelayLocked = false
        self:SelectGoal(bForceAction)
    end,

    PerformNextAction = function(self)
        # Some actions will want to finish before being interrupted.  While in a casting animation and finishing the casting
        if self.Agent.CurrentAction then
            if not self.Agent.CurrentAction:CheckInterruptableAction() then
                return false
            end
        end

        # Some actions must clean themselves up when they are interrupted (shopping)
        if self.Agent.CurrentAction then
            if not self.Agent.CurrentAction:ActionCleanup() then
                return false
            end
        end

        if table.getn(self.ActionPlan) <= 0 then
            return
        end
        local action = self.Actions[ table.remove( self.ActionPlan, 1 ) ]

        # Do action here
        if HeroAIActionTemplates[action.ActionName].LockPlatoon then
            self:LockPlatoon( HeroAIActionTemplates[action.ActionName].LockPlatoon )
        end

        if HeroAIActionTemplates[action.ActionName].LockSquads then
            for _,squadName in HeroAIActionTemplates[action.ActionName].LockSquads do
                self.Agent.LockedSquads[squadName] = true
            end
        end

        if self.WindowEnabled then
            if not Sync.AIData.HeroData[self.Name] then
                Sync.AIData.HeroData[self.Name] = {}
            end
            Sync.AIData.HeroData[self.Name].CurrentAction = action.ActionName
            Sync.AIData.HeroData[self.Name].CurrentActionTick = GetGameTick()
        end

        action:PerformAction( self.Agent )
    end,

}

