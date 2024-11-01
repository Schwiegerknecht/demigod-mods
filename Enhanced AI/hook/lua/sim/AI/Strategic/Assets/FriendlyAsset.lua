#  [MOD] The Citadel upgrade section has been moded to accept a priority function

local HeroBrainAsset = import('/lua/sim/ai/Strategic/Assets/HeroBrainAsset.lua').HeroBrainAsset

local AIUtils = import('/lua/sim/ai/aiutilities.lua')
local AIAbility = import('/lua/sim/ai/AIAbilityUtilities.lua')
local AIShop = import('/lua/sim/ai/AIShopUtilities.lua')

local ValidateSkill = import('/lua/common/ValidateSkill.lua')

local HasAbility = import('/lua/common/ValidateAbility.lua').HasAbility

local AIGlobals = import('/lua/sim/ai/AIGlobals.lua')

FriendlyAsset = Class(HeroBrainAsset) {
    __init = function(self, planner, brainData)
        HeroBrainAsset.__init(self, planner, brainData)
        self.IsFriendlyAsset = true

        self.ShoppingDesires = {}
        self:SetDefaultShopDesires()

        self.CaptureWeights = {}
        self.StrongholdWeights = {}
        self.StructureDefenseFortWeights = {}

        self.PurchasedSkills = {}
        self.AddedSkills = {}

        self.UnitDistances = {}

        import('/lua/sim/skill.lua').OnSkillAdded:Add(self.DemigodSkillAdded, self)

        # Find out which lanes/points/etc are closest to this brain
        self:SortHeroLanes()
        for flagName,flagAsset in self.Planner.CapturePoints do
            self:SortHeroCapturePoint(flagName)
        end
    end,

    CheckAsset = function(self)
        # Check if this hero can teleport; this will alter the weights for various locations
        self:CheckTeleport()
        self:SortHeroLanes()
    end,

    UnitSpawned = function(self, brain, unit)
        HeroBrainAsset.UnitSpawned(self, brain, unit)
        self:FriendlyHeroSpawn(brain, unit)
    end,

    FriendlyHeroSpawn = function(self, brain, hero)
        # Make sure the passed in unit is a hero
        if not EntityCategoryContains( categories.HERO, hero ) then
            return
        end

        # Old distances are invalid; clear them
        self:ClearDistances()

        # Add callbacks to hero
        self:AddFriendlyHeroCallbacks(hero)
    end,

    AddFriendlyHeroCallbacks = function(self, hero)
        for k,v in self.FriendlyHeroCallbacks do
            hero.Callbacks[k]:Add( v, self )
        end
    end,

    GetFriendlyStronghold = function(self)
        if self.FriendlyStronghold and not self.FriendlyStronghold:IsDead() then
            return self.FriendlyStronghold
        end

        local stronghold = self.HeroBrain:GetTeamArmy():GetStronghold()
        if stronghold then
            self.FriendlyStronghold = stronghold
            return stronghold
        end

        return false
    end,

    GetFriendlyStrongholdPosition = function(self)
        if self.FriendlyStrongholdPosition then
            return self.FriendlyStrongholdPosition
        end

        self.FriendlyStrongholdPosition = false
        if self:GetFriendlyStronghold() then
            self.FriendlyStrongholdPosition = table.copy( self:GetFriendlyStronghold().Position )
            return self.FriendlyStrongholdPosition
        end

        if(not ScenarioInfo.MatchComplete) then
            WARN('*AI ERROR: No Hero Friendly Stronghold location for friendly Asset')
        end
        return {0,0,0}
    end,

    FriendlyHeroCallbacks = {
        OnKilled = function(self, unit)
            self:ClearDistances()
        end,
        OnInventoryAdded = function(self, unit, item)
            #LOG('*AI DEBUG: Item added to hero: ' .. unit:GetAIBrain().Name .. ' - ' .. item.Blueprint.Name )
            local desires = AIShop.GetItemDesires(item.Blueprint.Name)
            if desires then
                self:AddShoppingDesires(desires)
                #if unit:GetArmy() == 1 then
                #    LOG('*AI DEBUG: Item added to hero: ' .. unit:GetAIBrain().Name .. ' - ' .. item.Blueprint.Name )
                #    LOG('*AI DEBUG: Army 1 Shopping Desires = ' .. repr(self.ShoppingDesires) )
                #    LOG('*AI DEBUG: Adding desires = ' .. repr(desires))
                #end
            end
        end,
        OnInventoryRemoved = function(self, unit, item)
            #LOG('*AI DEBUG: Item removed from hero: ' .. unit:GetAIBrain().Name .. ' - ' .. item.Blueprint.Name )
            local desires = AIShop.GetItemDesires(item.Blueprint.Name)
            if desires then
                self:SubtractShoppingDesires(desires)
                #if unit:GetArmy() == 1 then
                #    LOG('*AI DEBUG: Item removed from hero: ' .. unit:GetAIBrain().Name .. ' - ' .. item.Blueprint.Name )
                #    LOG('*AI DEBUG: Army 1 Shopping Desires = ' .. repr(self.ShoppingDesires) )
                #    LOG('*AI DEBUG: Removing desires = ' .. repr(desires))
                #end
            end
        end,
    },

    # This function checks the teleport abilities in AIGlobals; if any of those abilities are usable on the hero
    # we flag the asset as able to teleport; the asset will then use this data when calculating strategic weights
    CheckTeleport = function(self)
        local hero = self.HeroBrain:GetHero()
        self.HeroTeleport = false
        if not hero then
            return
        end

        local ability = AIAbility.GetReadyAbility(hero, AIGlobals.TeleportAbilities)
        if ability then
            self.HeroTeleport = true
        end
    end,

    # ===== SHOPPING RELATED FUNCTIONS ===== #
    SetDefaultShopDesires = function(self)
        for desireName,desireVal in self.DefaultShopDesires do
            self.ShoppingDesires[desireName] = desireVal
        end
    end,

    SetShoppingDesires = function(self, desires)
        for desireName,desireVal in desires do
            self.ShoppingDesires[desireName] = desireVal
        end
    end,

    AddShoppingDesires = function(self, desires)
        for desireName,desireVal in desires do
            if self.ShoppingDesires[desireName] then
                self.ShoppingDesires[desireName] = self.ShoppingDesires[desireName] + desireVal
            else
                self.ShoppingDesires[desireName] = desireVal
            end
        end
    end,

    SubtractShoppingDesires = function(self, desires)
        for desireName,desireVal in desires do
            if self.ShoppingDesires[desireName] then
                self.ShoppingDesires[desireName] = self.ShoppingDesires[desireName] - desireVal
            else
                self.ShoppingDesires[desireName] = 0 - desireVal
            end
        end
    end,

    DefaultShopDesires = {
        HealthDesire = 0,
        ManaDesire = 0,
        PrimaryWeaponDesire = 0,
        MinionDesire = 0, # Minion Desire only applies to generals through idols
        SpeedDesire = 0,
    },

    GetShoppingDesires = function(self)
        return self.ShoppingDesires
    end,



    # ==== ITEM PICKING ==== #

    SortItemPriorities = function(self, unit)
        # Get Item list - this is the global data for items
        local itemList = AIShop.GetItemsList()

        # These are how desireable different item types are to the demigod
        local shoppingDesires = self:GetShoppingDesires()

        # Clear the list of priorities on the asset
        self.ItemPriorities = {}

        local isGeneral = EntityCategoryContains( categories.GENERAL, unit )
        local isAssassin = EntityCategoryContains( categories.ASSASSIN, unit )

        # Iterate through item database
        for k,v in itemList do
            # Check if this is a General or Assassin item that is not in the General/Assassin shop
            if(v.GeneralItem and not isGeneral) then
                continue
            elseif(v.AssassinItem and not isAssassin) then
                continue
            end

            # Check if has a category for use
            local itemBp = Items[v.ItemId]
            if itemBp.PurchaseCategory then
                if (itemBp.PurchaseCategory == 'GENERAL' and not isGeneral) then
                    continue
                elseif (itemBp.PurchaseCategory == 'ASSASSIN' and not isAssassin) then
                    continue
                end
            end

            local priority = v.ItemWeights.Priority

            if AIGlobals.ItemWeights[v.ItemId].PriorityFunction then
                local currentCount = AIShop.GetItemCount(unit, v.ItemId)
                priority = AIGlobals.ItemWeights[v.ItemId].PriorityFunction(unit,currentCount)
            end

			#  [MOD] Gets weighting by build
            # Get hero weighting defaulted for this item
			local unitId = unit:GetUnitId()#..'peppe'
			local brain = unit:GetAIBrain()

			local build = UnitAITemplates[unitId].SkillBuilds[brain.SkillBuild]
			local heroItemWeights = build.ItemWeights
			
			if heroItemWeights then
				if heroItemWeights[v.ItemId].Priority then
					priority = priority + heroItemWeights[v.ItemId].Priority
				end




			end







			# -- if priority > 0 then 
            # -- # Calculate weight based on shopping desires; We desire to have all the shopping desires
            # -- # be 0. So we subtract the difference between the hero desire and the item gain; this
            # -- # is intended to create balanced builds based on the abilities selected by the demigod
				# -- for desireName,desireWeight in shoppingDesires do
					# -- if desireWeight >= 0 or v.ItemWeights[desireName] <= 0 then
						# -- continue
					# -- end


					# -- local addVal = 0

					# -- # We cap the added bonus to be whatever the current desireWeight is
					# -- if desireWeight + v.ItemWeights[desireName] > 0 then
						# -- addVal =  (1 + desireWeight) * (1 + desireWeight) - 1
					# -- else

						# -- addVal = (1 + v.ItemWeights[desireName]) * (1 + v.ItemWeights[desireName]) - 1
					# -- end


					# -- if addVal <= 0 then
						# -- continue
					# -- end


					# -- #if unit:GetAIBrain():GetArmyIndex() == 1 then
					# -- #    LOG('*AI DEBUG: Item = ' .. v.ItemId .. ' - desireName = ' .. desireName .. ' - DesireWeight = ' .. addVal )
					# -- #end

					# -- priority = priority + addVal
				# -- end
			# -- end


		# Add the item to the Asset priorties list; the list is sorted at the end
		table.insert( self.ItemPriorities, { ItemTable = v, Priority = priority, } )
        end

        # Sort the priority table here
        table.sort(self.ItemPriorities, sort_down_by 'Priority')
    end,

    # ==== CITADEL UPGRADE PICKING ==== #
    SortCitadelUpgradePriorities = function(self, unit)
        # Clear the list of priorities on the asset
        self.CitadelUpgradePriorities = {}

        local upgradesList = AIShop.GetUpgradesList()
		
		
		
        for k, v in upgradesList do
		
			#  [MOD] priority declared and set to local variable to allow processing PriorityFunction		
			local priority =  v.ItemWeights.Priority
					
			
			#  [MOD] If a PriorityFunction function is declared process it 
			if AIGlobals.CitadelUpgradeWeights[v.ItemId].PriorityFunction then
				priority = AIGlobals.CitadelUpgradeWeights[v.ItemId].PriorityFunction(unit)
			end
		 
            # Add the upgrade to the Asset priorties list; the list is sorted at the end
            table.insert( self.CitadelUpgradePriorities, { ItemTable = v, Priority = priority, } )

            # Uncommment to see what the priorities are for the first brain (must be in /fullai)
            #if unit:GetAIBrain():GetArmyIndex() == 1 then
            #   LOG('*AI DEBUG: Item = ' .. v.ItemId .. ' - priority = ' .. priority )
            # end
        end

        # Sort the priority table here
        table.sort(self.CitadelUpgradePriorities, sort_down_by 'Priority')
    end,

    # ==== SKILL PICKING ==== #

    savedSkillcomplete = function(self, unit)
       local brain = unit:GetAIBrain()
			brain.SkillLevel = brain.SkillLevel + 1
	 
	end,
	
    PickSkillUpgrade = function(self, unit)
        local unitId = unit:GetUnitId()#..'peppe' 

        if not UnitAITemplates[unitId] then
            WARN('*AI ERROR: Invalid UnitAITemplate for unit - ' .. unitId)
            return false
        end

        local returnSkill = nil

        # Try to use skill builds if they exist
        if(UnitAITemplates[unitId].SkillBuilds) then
            local brain = unit:GetAIBrain()
            if(not brain.UseSkillWeights) then
                local build = nil
                if(brain.SkillBuild) then
                    build = UnitAITemplates[unitId].SkillBuilds[brain.SkillBuild]
                else
                    local buildNames = {}
                    for k, v in UnitAITemplates[unitId].SkillBuilds do
                        table.insert(buildNames, k)
                    end
                    local num = math.random(table.getn(buildNames))
                    build = UnitAITemplates[unitId].SkillBuilds[buildNames[num]]
                    brain.SkillBuild = buildNames[num]
                    brain.SkillLevel = 1
					
					
					#[MOD]  Announce Build:
					local announcement = buildNames[num]
					local myArmyIndex = unit:GetArmy()
					local waitTime 
					local allyHeroes = {}
					for k, brainA in ArmyBrains do
						if  brainA.Score.HeroId and brainA.BrainController != 'Human' and IsAlly(brain:GetArmyIndex(), brainA:GetArmyIndex()) then	
							table.insert(allyHeroes,  myArmyIndex)
						end
					end

					if myArmyIndex >  table.getn(allyHeroes) then
						waitTime = 8 + 3.5 * (myArmyIndex - table.getn(allyHeroes))
					else
						waitTime = 8 + 3.5 * myArmyIndex
					end 
					#WARN(brain.Nickname ..' - '.. waitTime .. ' - allies -' .. table.getn(allyHeroes) .. ' - army index - ' .. myArmyIndex )
					ForkThread(function() WaitSeconds(waitTime); AIUtils.AIChat(unit, announcement) end)
					#AIUtils.AIChat(unit, announcement)
                end

                # Pick the skill
                returnSkill = build[brain.SkillLevel]

                # Make sure the skill exists in the unit's skill tree
                local skillTree = GetBlueprint(unit).Abilities.Tree
                if not skillTree then
                    error("Skill tree undefined for unit: " .. GetBlueprint(unit).BlueprintId)
                end

				if returnSkill == 'SAVE' then
					#Do nothing (save skill point)
				elseif returnSkill == 'SAVE2' then
					#Do nothing (save 2 skill points)
				elseif returnSkill == 'SAVE3' then
					#Do nothing (save 3 skill points)
				else
					local skill = skillTree[returnSkill]
					if not skill then
						WARN('Invalid skill name in unit AIBlueprint - UnitId: ' .. unit:GetUnitId() .. ' - SkillName = ' .. returnSkill )
						returnSkill = nil
					end
				
				
					# Make sure we can actually pick this skill
					if returnSkill and not ValidateSkill.CanPickSkill( unit, returnSkill, false ) then
						WARN('Cannot Select Skill - UnitId: ' .. unit:GetUnitId() .. ' - SkillName = ' .. returnSkill )
						returnSkill = nil
					end

					if returnSkill then
						brain.SkillLevel = brain.SkillLevel + 1
					end
				end
            end
        end

        # Use skill weights
        if(returnSkill == nil) then
            if not UnitAITemplates[unitId].SkillWeights then
                WARN('*AI ERROR: ' .. unitId .. ' - Does not have UnitAITemplates[unitId].SkillWeights')
                return false
            end

            local bestVal, upgrade

            local heroBaseWeights = self.HeroStrengths

            local skillChoices = {}

            # Iterate through the skills; find the highest skill based on weights
            for skillName,skillData in UnitAITemplates[unitId].SkillWeights do
                # Make sure the skill exists in the unit's skill tree
                local skillTree = GetBlueprint(unit).Abilities.Tree
                if not skillTree then
                    error("Skill tree undefined for unit: " .. GetBlueprint(unit).BlueprintId)
                end

                local skill = skillTree[skillName]
                if not skill then
                    WARN('Invalid skill name in unit AIBlueprint - UnitId: ' .. unit:GetUnitId() .. ' - SkillName = ' .. skillName )
                    continue
                end

                # Make sure we can actually pick this skill
                if not ValidateSkill.CanPickSkill( unit, skillName, false ) then
                    continue
                end

                local skillPriority = UnitAITemplates[unitId].SkillWeights[skillName].BasePriority

                if UnitAITemplates[unitId].SkillWeights[skillName].SkillBonuses then
                    for abilityName, abilityBonus in UnitAITemplates[unitId].SkillWeights[skillName].SkillBonuses do
                        if HasAbility( unit, abilityName ) then
                            skillPriority = skillPriority + abilityBonus
                        end
                    end
                end

                # LOG('*AI DEBUG: SkillPriority = ' .. skillPriority .. ' - SkillName = ' .. skillName )

                # If the new value is further away than the old value; ignore this value
                if bestVal and skillPriority < bestVal then
                    continue
                end

                if bestVal and skillPriority == bestVal then
                    table.insert( skillChoices, skillName )
                    continue
                end

                bestVal = skillPriority
                skillChoices = { skillName }
            end

            # LOG( '*AI DEBUG: Skill choices = ' .. repr(skillChoices) )

            returnSkill = skillChoices[ Random(1,table.getn(skillChoices)) ]
        end

		if returnSkill != 'SAVE' then
			table.insert( self.PurchasedSkills, returnSkill )
			# LOG( '*AI DEBUG: Purchase order = ' .. repr(self.PurchasedSkills) )
		end
		
        if not returnSkill then
            WARN('*AI ERROR: Could not find a valid skill')
        end
        return returnSkill
    end,

    DemigodSkillAdded = function(self, unit, skillName)
        if self.HeroBrainIndex != unit:GetArmy() then
            return
        end

        if self.AddedSkills[skillName] then
            return
        end

        self.AddedSkills[skillName] = true
        local unitId = unit:GetUnitId()

        if UnitAITemplates[unitId].SkillWeights and UnitAITemplates[unitId].SkillWeights[skillName] then
            local skillData = UnitAITemplates[unitId].SkillWeights[skillName]

            self.HeroBaseStrengths.StructureKillValue = self.HeroBaseStrengths.StructureKillValue + skillData.StrategicWeights.StructureKillValue
            self.HeroBaseStrengths.PushValue = self.HeroBaseStrengths.PushValue + skillData.StrategicWeights.PushValue
            self.HeroBaseStrengths.AssassinValue = self.HeroBaseStrengths.AssassinValue + skillData.StrategicWeights.AssassinValue
            if UnitAITemplates[unitId].SkillWeights[skillName].ShopDesires then
                self:AddShoppingDesires(UnitAITemplates[unitId].SkillWeights[skillName].ShopDesires)
                #if unit:GetArmy() == 1 then
                #    LOG('*AI DEBUG: Skill added to hero: ' .. unit:GetAIBrain().Name .. ' - ' .. skillName )
                #    LOG('*AI DEBUG: Army 1 Shopping Desires = ' .. repr(self.ShoppingDesires) )
                #end
            end
        else
            self.HeroBaseStrengths.StructureKillValue = self.HeroBaseStrengths.StructureKillValue + 0.333
            self.HeroBaseStrengths.PushValue = self.HeroBaseStrengths.PushValue + 0.333
            self.HeroBaseStrengths.AssassinValue = self.HeroBaseStrengths.AssassinValue + 0.333
        end

        self:ApplyStrengthMultipliers()
        # LOG('*AI DEBUG: Hero Strengths = ' .. repr(self.HeroStrengths))
    end,





    # ===== DISTANCE TRACKING ===== #

    FindDistance = function(self, unitCategory, alliance)
        local brains = {}

        # Clear out the old value
        self.UnitDistances[alliance][unitCategory] = false

        # Figure out what type of brains to use for the comparison
        if alliance == 'Self' then
            table.insert( brains, self.HeroBrain )
        else
            # Based on the type of alliance; the function to test alliance is changed
            local testFunction
            if alliance == 'Enemy' then
                testFunction = IsEnemy
            elseif alliance == 'Ally' then
                testFunction = IsAlly
            elseif alliance == 'Neutral' then
                testFunction = IsNeutral
            else
                WARN('Invalid alliance type in FriendlyAsset FindDistance function - ' .. alliance)
            end

            # Test the alliance and insert the brain if the alliance type matches
            for _,brain in ArmyBrains do
                if not testFunction( self.HeroBrainIndex, brain:GetArmyIndex() ) then
                    continue
                end

                table.insert( brains, brain )
            end
        end

        # Grab the units from each brain of the desired type; grab all of them and then we filter based on blip
        local units = {}
        for _,brain in brains do
            units = table.append( units, brain:GetListOfUnits( ParseEntityCategory(unitCategory), false, false ) )
        end

        # No more units of this type found; return out
        if table.empty(units) then
            return
        end

        # Make sure we have a blip for the unit; if the unit is NOT a structure
        # If the unit is a structure; we assume we know about it
        if not EntityCategoryContains( categories.STRUCTURE, units[1] ) then
            for k,v in units do
                if v:IsDead() then
                    table.remove( units, k )
                    continue
                end

                local blip = v:GetBlip( self.HeroBrainIndex )
                if not blip then
                    table.remove( units, k )
                    continue
                end

                if not ( blip:IsSeenNow() or blip:IsOnOmni() ) then
                    table.remove( units, k )
                end
            end
        end

        # If the list is more than 5 units; sort the list as we only test a maximum of 5
        if table.getn( units ) > 5 then
            SortEntitiesByDistanceXZ(self.HeroBrain:GetHero().Position, units)
        end

        # Find the best value using the ai path find system
        local shortest = false
        for k,v in units do
            if k > 5 then
                break
            end

            local distance = AIUtils.GetPathDistanceBetweenPoints( self.HeroBrain, self.HeroBrain:GetHero().Position, v.Position )

            if shortest and distance > shortest then
                continue
            end

            shortest = distance
        end

        self.UnitDistances[alliance][unitCategory] = shortest
    end,

    GetDistance = function(self, unitCategory, alliance)
        if not self.UnitDistances[alliance] or not self.UnitDistances[alliance][unitCategory] then
            self:FindDistance( unitCategory, alliance )
        end

        return self.UnitDistances[alliance][unitCategory]
    end,

    # We have the concept of a "Named Distance"; These are distances we name and give a function.
    #   Ex: TEAM_1_CHAIN_1_RallyPoint
    FindNamedDistance = function(self, indexName, positionFunction, firstArgument)
        if not self.UnitDistances.Function[indexName] then
            self.UnitDistances.Function[indexName] = {
                PositionFunction = positionFunction,
                FirstArgument = firstArgument,
                Distance = false,
            }
        end

        self.UnitDistances.Function[indexName].Distance = false

        local heroPos = self.HeroBrain:GetHero().Position
        if not heroPos then
            heroPos = self:GetFriendlyStrongholdPosition()
        end

        if not heroPos then
            WARN('*AI ERROR: No Hero position for FindNamedDistance')
        end

        if not self.UnitDistances.Function[indexName].PositionFunction then
            WARN('*AI DEBUG: Error Storing NamedDistance - ' .. indexName .. ' - No function available')
        end

        local comparePosition
        if self.UnitDistances.Function[indexName].FirstArgument then
            comparePosition = self.UnitDistances.Function[indexName].PositionFunction(self.UnitDistances.Function[indexName].FirstArgument, heroPos)
        else
            comparePosition = self.UnitDistances.Function[indexName].PositionFunction(heroPos)
        end

        if not comparePosition then
            # WARN('*AI ERROR: Could not get a compare position for FindNamedDistance = ' .. indexName)
            return false
        end

        local distance = AIUtils.GetPathDistanceBetweenPoints( self.HeroBrain, heroPos, comparePosition )

        self.UnitDistances.Function[indexName].Distance = distance

        return true
    end,

    GetNamedDistance = function(self, indexName)
        if not self.UnitDistances.Function[indexName] then
            return false
        end

        if not self.UnitDistances.Function[indexName].Distance then
            self:FindNamedDistance(indexName)
        end

        return self.UnitDistances.Function[indexName].Distance
    end,

    ClearDistances = function(self)
        local allianceTypes = { 'Self', 'Enemy', 'Neutral', 'Ally', 'Function', 'Position', 'Unit', }
        for _,aType in allianceTypes do
            if not self.UnitDistances[aType] then
                self.UnitDistances[aType] = {}
            end
        end

        for aType,aData in self.UnitDistances do
            if aType == 'Position' or aType == 'Unit' then
                continue
            end

            if aType == 'Function' then
                for indexName,indexData in aData do
                    indexData.Distance = false
                end
            else
                for catType,distance in aData do
                    aData[catType] = false
                end
            end
        end
    end,








    # ===== WEIGHT SORTING FUNCTIONS ===== #
    SortHeroLanes = function(self)
        local aiBrain = self.HeroBrain

        local distances = {}
        for laneName,laneAsset in self.Planner.Lanes do
            local distance
            if self.HeroTeleport and laneAsset.RallyStructure then
                distance = 0
            else
                distance = self:GetNamedDistance(laneName .. '_RallyPoint')
            end

            table.insert( distances, { LaneName = laneName, Distance = distance, } )
        end

        self.LaneWeights = {}
        #LOG('*AI DEBUG: Lane Weights')
        local closest, dist
        for k,v in distances do
            if not v.Distance then
                self.LaneWeights[v.LaneName] = false
                LOG('*AI DEBUG: No distance for lane - ' .. v.LaneName .. ' - Brain = ' .. self.HeroBrain.Name )
                self:FindNamedDistance(v.LaneName .. '_RallyPoint')
                continue
            end

            #LOG('*AI DEBUG: DIstance = ' .. v.Distance )
            if v.Distance < 50 then
                self.LaneWeights[v.LaneName] = 2.0
            elseif v.Distance < 100 then
                self.LaneWeights[v.LaneName] = 1.8
            elseif v.Distance < 125 then
                self.LaneWeights[v.LaneName] = 1.6
            elseif v.Distance < 150 then
                self.LaneWeights[v.LaneName] = 1.4
            elseif v.Distance < 175 then
                self.LaneWeights[v.LaneName] = 1.2
            elseif v.Distance < 200 then
                self.LaneWeights[v.LaneName] = 1.0
            elseif v.Distance < 225 then
                self.LaneWeights[v.LaneName] = 0.8
            else
                self.LaneWeights[v.LaneName] = 0.5
            end
            # LOG('*AI DEBUG: Army ' .. aiBrain:GetArmyIndex() .. ': ' .. v.LaneName .. ': Distance = ' .. v.Distance .. ': Weight = ' .. self.LaneWeights[v.LaneName])

            if dist and v.Dist > dist then
                continue
            end

            dist = v.Distance
            closest = v.LaneName
        end

        if self.LaneWeights[closest] then
            self.LaneWeights[closest] = self.LaneWeights[closest] + 0.5
        end
    end,

    SortHeroCapturePoint = function(self, flagName)
        local aiBrain = self.HeroBrain
        local flagAsset = self.Planner:GetChildAsset(flagName)

        local distance

        if self.HeroTeleport and flagAsset.RallyStructure then
            distance = 0
        else
            distance = self:GetNamedDistance(flagName .. '_RallyPoint')
        end

        local captureReward = flagAsset.CaptureReward

        if not distance then
            self.CaptureWeights[flagName] = false
            # LOG('*AI DEBUG: No distance for point - ' .. flagName)
            return
        end

        if distance < 50 then
            self.CaptureWeights[flagName] = 1.0 * captureReward
        elseif distance < 125 then
            self.CaptureWeights[flagName] = 0.75 * captureReward
        elseif distance < 200 then
            self.CaptureWeights[flagName] = 0.5 * captureReward
        else
            self.CaptureWeights[flagName] = 0
        end
        # LOG('*AI DEBUG: Army ' .. aiBrain:GetArmyIndex() .. ': ' .. flagName .. ': Distance = ' .. distance .. ': Weight = ' .. self.CaptureWeights[flagName])

        return self.CaptureWeights[flagName]
    end,

    SortHeroStronghold = function(self, strongholdName)
        local aiBrain = self.HeroBrain
        local strongholdAsset = self.Planner:GetChildAsset(strongholdName)

        local distance

        if self.HeroTeleport and strongholdAsset.RallyStructure then
            distance = 0
        else
            distance = self:GetNamedDistance(strongholdName .. '_Location')
        end

        if not distance then
            # LOG('*AI DEBUG: No distance for point - ' .. strongholdName)
            self.StrongholdWeights[strongholdName] = false
            return
        end

        if distance < 10 then
            self.StrongholdWeights[strongholdName] = 2.0
        elseif distance < 50 then
            self.StrongholdWeights[strongholdName] = 1.5
        elseif distance < 100 then
            self.StrongholdWeights[strongholdName] = 1.25
        elseif distance < 150 then
            self.StrongholdWeights[strongholdName] = 1.0
        else
            self.StrongholdWeights[strongholdName] = 0.75
        end
        # LOG('*AI DEBUG: Army ' .. aiBrain:GetArmyIndex() .. ': ' .. strongholdName .. ': Distance = ' .. distance .. ': Weight = ' .. self.StrongholdWeights[strongholdName])

        return self.StrongholdWeights[strongholdName]
    end,

    SortHeroStructureDefenseFort = function(self, fortName)
        local aiBrain = self.HeroBrain
        local fortAsset = self.Planner:GetChildAsset(fortName)

        local distance

        if self.HeroTeleport and fortAsset.RallyStructure then
            distance = 0
        else
            distance = self:GetNamedDistance(fortName .. '_Location')
        end

        if not distance then
            # LOG('*AI DEBUG: No distance for point - ' .. fortName)
            self.StructureDefenseFortWeights[fortName] = false
            return
        end

        if distance < 10 then
            self.StructureDefenseFortWeights[fortName] = 2.0
        elseif distance < 50 then
            self.StructureDefenseFortWeights[fortName] = 1.5
        elseif distance < 100 then
            self.StructureDefenseFortWeights[fortName] = 1.25
        elseif distance < 150 then
            self.StructureDefenseFortWeights[fortName] = 1.0
        else
            self.StructureDefenseFortWeights[fortName] = 0.75
        end
        # LOG('*AI DEBUG: Army ' .. aiBrain:GetArmyIndex() .. ': ' .. fortName .. ': Distance = ' .. distance .. ': Weight = ' .. self.StructureDefenseFortWeights[fortName])

        return self.StructureDefenseFortWeights[fortName]
    end,
}
