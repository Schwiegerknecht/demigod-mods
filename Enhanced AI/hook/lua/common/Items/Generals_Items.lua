local CanUseAbility = import('/lua/common/ValidateAbility.lua').CanUseAbility
local AIShop = import('/lua/sim/ai/AIShopUtilities.lua') 
#################################################################################################################
# General Demigod items
#################################################################################################################
function SummonMinions(self, unit, params, minions)
	local myBrain = unit:GetAIBrain()
    local numMinions = 0
    if(minions) then
        for k, v in minions do
            if(v and not v:IsDead()) then
                numMinions = numMinions + 1
            end
        end
    end
    local count = self.SummonCount
    if numMinions + self.SummonCount > self.MaxUnits then
        count = self.MaxUnits - numMinions
    end

    local unitID = self.SummonType
    local spawnedMinions = {}
    unit:OccupyGround(true)
    local nearbyUnits = myBrain:GetUnitsAroundPoint( categories.MOBILE, unit.Position, 10 )
    for k,v in nearbyUnits do
        v:OccupyGround(true)
    end
    local orient = unit:GetOrientation()

    for i = 1, count do
        if(unit and not unit:IsDead()) then
            local pos = unit:FindEmptySpotNear(unit.Position)
            if not pos then
                pos = table.copy(unit.Position)
            end
            local minion = CreateUnitHPR(unitID, unit:GetArmy(), pos[1], pos[2], pos[3], orient[1], orient[2], orient[3])
            if not minion then
                break
            end
            minion:OccupyGround(true)
            table.insert(spawnedMinions, minion)
			
			if myBrain.BrainController != 'Human' and unit:GetHealthPercent() > .7 and i == 2 and (self.SummonType == 'highpriest01' or self.SummonType == 'highpriest02' or self.SummonType == 'highpriest03' or self.SummonType == 'highpriest04') then	
				
				local myItem 
				
				if self.SummonType == 'highpriest01' then
				myItem = 'Item_High_Priest_010'
				elseif self.SummonType == 'highpriest02' then
				myItem = 'Item_High_Priest_020'
				elseif self.SummonType == 'highpriest03' then
				myItem = 'Item_High_Priest_030'
				elseif self.SummonType == 'highpriest04' then
				myItem = 'Item_High_Priest_040'
				end
				
				
				local allyHeroes = {}

				for k, brain in ArmyBrains do
					if brain.Score.HeroId and myBrain:GetArmyIndex() !=  brain:GetArmyIndex() and IsAlly(myBrain:GetArmyIndex(), brain:GetArmyIndex()) then	
						local heroUnit = brain:GetListOfUnits(categories.HERO, false)
						local hero = brain:GetHero()
						#WARN('Ally healer status = ' .. tostring(heroUnit.Healer)) and not heroUnit.Healer
						if(hero and not hero:IsDead())  then
							if not AIShop.UnitHasItem(hero, myItem, 'ugbshop09') then
								table.insert(allyHeroes,  heroUnit[1])
							end 
						end
					end
				end
						
				if table.getn(allyHeroes) > 0 then
					#WARN( LOC(myBrain.Nickname) .. ' Sent Healer to Ally')		
					local heroUnit = allyHeroes[ math.random(1, table.getn(allyHeroes) ) ]
					IssueGuard({minion},  heroUnit)
					#heroUnit.Healer = true
					
				else
					IssueGuard({minion}, unit)
				end
		
				
			else
				IssueGuard({minion}, unit)
			end
        end
    end
    for k,v in nearbyUnits do
        v:OccupyGround(false)
    end
    for k, v in spawnedMinions do
        if(v and not v:IsDead()) then
            v:OccupyGround(false)
			v:AdjustHealth( v:GetMaxHealth() )
        end
    end
    unit:OccupyGround(false)
end

# -- function CheckUnitCap(self, unit, minions)
    # -- if(minions) then
        # -- local numMinions = 0
        # -- for k, v in minions do
            # -- if(v and not v:IsDead()) then
                # -- numMinions = numMinions + 1
            # -- end
        # -- end
        # -- if(numMinions >= self.MaxUnits) then
            # -- return false
        # -- end
    # -- end

    # -- return true
# -- end

--[[
#################################################################################################################
# Minotaur Captain Idol I
#################################################################################################################
ItemBlueprint {
    DisplayName = '<LOC ITEM_Idol_0000>Minotaur Berserker Idol',
    Description = '<LOC ITEM_Idol_0024>Use: Summons [GetSummonCount] Minotaur Berserkers. Can have a maximum of [GetSummonMax] Minotaur Berserkers.',
    GetSummonCount = function(self) return Ability['Item_Minotaur_Captain_010'].SummonCount end,
    GetSummonMax = function(self) return Ability['Item_Minotaur_Captain_010'].MaxUnits end,
    GetEnergyCost = function(self) return Ability['Item_Minotaur_Captain_010'].EnergyCost end,
    GetCastTime = function(self) return Ability['Item_Minotaur_Captain_010'].CastingTime end,
    GetCooldown = function(self) return Ability['Item_Minotaur_Captain_010'].Cooldown end,
	Icon = 'NewIcons/Boots/Boot1',
    InventoryType = 'Generals',
    SubInventoryType = 'Soldiers',
    Mesh = '/meshes/items/chest/chest_mesh',
    Animation = '/meshes/items/chest/Animations/chest_Idle_anim.gr2',
    MeshScale = 0.10,
    Name = 'Item_Minotaur_Captain_010',

    Useable = true,
    PurchaseCategory = 'GENERAL',
    Abilities = {
        AbilityBlueprint {
            AbilityType = 'Instant',
            AbilityCategory = 'USABLEITEM',
            CastingTime = 0.5,
            CastAction = 'CastItem1sec',
            Cooldown = 30,
            EnergyCost = 200,
            InventoryType = 'Generals',
            FromItem = 'Item_Minotaur_Captain_010',
            Icon = 'NewIcons/SuperGruntIcons/MinotaurCaptain_01',
            Name = 'Item_Minotaur_Captain_010',
            NoAbortText = true,
            SummonCount = 2,
            SummonType = 'minotaurcaptain01',
            SharedCooldown = 'MCaptainItems',
			ReengageTargetAfterUse = true,
            MaxUnits = 2,
            Audio = {
                 OnStartCasting = {Sound = 'Forge/ITEMS/snd_item_conjure',},
                 OnFinishCasting = {Sound = 'Forge/ITEMS/General/snd_item_general_Item_Minotaur_Captain_010',},
                 OnAbortCasting = {Sound = 'Forge/ITEMS/snd_item_abort',},
             },
            PreCastCheck = function(self, unit)
                return CheckUnitCap(self, unit, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.minotaurcaptain01, false))
            end,
            OnStartAbility = function(self, unit, params)
                SummonMinions(self, unit, params, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.minotaurcaptain01, false))
            end,
            OnRemoveAbility = function(self, unit)
                unit:DestroyMinions(categories.minotaurcaptain01)
            end,
        }
    },
}

#################################################################################################################
# Minotaur Captain Idol II
#################################################################################################################
ItemBlueprint {
    DisplayName = '<LOC ITEM_Idol_0002>Minotaur Captain Idol',
    Description = '<LOC ITEM_Idol_0003>Use: Summons [GetSummonCount] Minotaur Captains. Can have a maximum of [GetSummonMax] Minotaur Captains. Minotaur Captains are more powerful than Minotaur Berserkers.',
    GetSummonCount = function(self) return Ability['Item_Minotaur_Captain_020'].SummonCount end,
    GetSummonMax = function(self) return Ability['Item_Minotaur_Captain_020'].MaxUnits end,
    GetEnergyCost = function(self) return Ability['Item_Minotaur_Captain_020'].EnergyCost end,
    GetCastTime = function(self) return Ability['Item_Minotaur_Captain_020'].CastingTime end,
    GetCooldown = function(self) return Ability['Item_Minotaur_Captain_020'].Cooldown end,
    Icon = 'NewIcons/Boots/Boot1',
    InventoryType = 'Generals',
    SubInventoryType = 'Soldiers',
    Mesh = '/meshes/items/chest/chest_mesh',
    Animation = '/meshes/items/chest/Animations/chest_Idle_anim.gr2',
    MeshScale = 0.10,
    Name = 'Item_Minotaur_Captain_020',
    Useable = true,
    PurchaseCategory = 'GENERAL',
    Abilities = {
        AbilityBlueprint {
            AbilityType = 'Instant',
            AbilityCategory = 'USABLEITEM',
            CastingTime = 0.5,
            CastAction = 'CastItem1sec',
            Cooldown = 30,
            EnergyCost = 250,
            InventoryType = 'Generals',
            FromItem = 'Item_Minotaur_Captain_020',
            Icon = 'NewIcons/SuperGruntIcons/MinotaurCaptain_02',
            Name = 'Item_Minotaur_Captain_020',
            NoAbortText = true,
            SummonCount = 2,
            SummonType = 'minotaurcaptain02',
            SharedCooldown = 'MCaptainItems',
			ReengageTargetAfterUse = true,
            MaxUnits = 2,
            Audio = {
                 OnStartCasting = {Sound = 'Forge/ITEMS/snd_item_conjure',},
                 OnFinishCasting = {Sound = 'Forge/ITEMS/General/snd_item_general_Item_Minotaur_Captain_020',},
                 OnAbortCasting = {Sound = 'Forge/ITEMS/snd_item_abort',},
             },
            PreCastCheck = function(self, unit)
                return CheckUnitCap(self, unit, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.minotaurcaptain02, false))
            end,
            OnStartAbility = function(self, unit, params)
                SummonMinions(self, unit, params, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.minotaurcaptain02, false))
            end,
            OnRemoveAbility = function(self, unit)
                unit:DestroyMinions(categories.minotaurcaptain02)
            end,
        }
    },
}

#################################################################################################################
# Minotaur Captain Idol III
#################################################################################################################
ItemBlueprint {
    DisplayName = '<LOC ITEM_Idol_0004>Minotaur Royal Guard Idol',
    Description = '<LOC ITEM_Idol_0005>Use: Summons [GetSummonCount] Minotaur Royal Guards. Can have a maximum of [GetSummonMax] Minotaur Royal Guards. Minotaur Royal Guards are more powerful than Minotaur Captains.',
    GetSummonCount = function(self) return Ability['Item_Minotaur_Captain_030'].SummonCount end,
    GetSummonMax = function(self) return Ability['Item_Minotaur_Captain_030'].MaxUnits end,
    GetEnergyCost = function(self) return Ability['Item_Minotaur_Captain_030'].EnergyCost end,
    GetCastTime = function(self) return Ability['Item_Minotaur_Captain_030'].CastingTime end,
    GetCooldown = function(self) return Ability['Item_Minotaur_Captain_030'].Cooldown end,
    Icon = 'NewIcons/Boots/Boot1',
    InventoryType = 'Generals',
    SubInventoryType = 'Soldiers',
    Mesh = '/meshes/items/chest/chest_mesh',
    Animation = '/meshes/items/chest/Animations/chest_Idle_anim.gr2',
    MeshScale = 0.10,
    Name = 'Item_Minotaur_Captain_030',
    Useable = true,
    PurchaseCategory = 'GENERAL',
    Abilities = {
        AbilityBlueprint {
            AbilityType = 'Instant',
            AbilityCategory = 'USABLEITEM',
            CastingTime = 0.5,
            CastAction = 'CastItem1sec',
            Cooldown = 30,
            EnergyCost = 300,
            InventoryType = 'Generals',
            FromItem = 'Item_Minotaur_Captain_030',
            Icon = 'NewIcons/SuperGruntIcons/MinotaurCaptain_03',
            Name = 'Item_Minotaur_Captain_030',
            NoAbortText = true,
            SummonCount = 2,
            SummonType = 'minotaurcaptain03',
            SharedCooldown = 'MCaptainItems',
			ReengageTargetAfterUse = true,
            MaxUnits = 2,
            Audio = {
                 OnStartCasting = {Sound = 'Forge/ITEMS/snd_item_conjure',},
                 OnFinishCasting = {Sound = 'Forge/ITEMS/General/snd_item_general_Item_Minotaur_Captain_030',},
                 OnAbortCasting = {Sound = 'Forge/ITEMS/snd_item_abort',},
             },
            PreCastCheck = function(self, unit)
                return CheckUnitCap(self, unit, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.minotaurcaptain03, false))
            end,
            OnStartAbility = function(self, unit, params)
                SummonMinions(self, unit, params, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.minotaurcaptain03, false))
            end,
            OnRemoveAbility = function(self, unit)
                unit:DestroyMinions(categories.minotaurcaptain03)
            end,
        }
    },
}

#################################################################################################################
# Minotaur Captain Idol IV
#################################################################################################################
ItemBlueprint {
    DisplayName = '<LOC ITEM_Idol_0006>Minotaur High King Idol',
    Description = '<LOC ITEM_Idol_0007>Use: Summons [GetSummonCount] Minotaur High Kings. Can have a maximum of [GetSummonMax] Minotaur High Kings. Minotaur High Kings are more powerful than Minotaur Royal Guard.',
    GetSummonCount = function(self) return Ability['Item_Minotaur_Captain_040'].SummonCount end,
    GetSummonMax = function(self) return Ability['Item_Minotaur_Captain_040'].MaxUnits end,
    GetEnergyCost = function(self) return Ability['Item_Minotaur_Captain_040'].EnergyCost end,
    GetCastTime = function(self) return Ability['Item_Minotaur_Captain_040'].CastingTime end,
    GetCooldown = function(self) return Ability['Item_Minotaur_Captain_040'].Cooldown end,
    Mesh = '/meshes/items/chest/chest_mesh',
    Icon = 'NewIcons/Boots/Boot1',
    InventoryType = 'Generals',
    SubInventoryType = 'Soldiers',
    Animation = '/meshes/items/chest/Animations/chest_Idle_anim.gr2',
    MeshScale = 0.10,
    Name = 'Item_Minotaur_Captain_040',
    Useable = true,
    PurchaseCategory = 'GENERAL',
    Abilities = {
        AbilityBlueprint {
            AbilityType = 'Instant',
            AbilityCategory = 'USABLEITEM',
            CastingTime = 0.5,
            CastAction = 'CastItem1sec',
            Cooldown = 30,
            EnergyCost = 350,
            FromItem = 'Item_Minotaur_Captain_040',
            Icon = 'NewIcons/SuperGruntIcons/MinotaurCaptain_04',
            Name = 'Item_Minotaur_Captain_040',
            NoAbortText = true,
            SummonCount = 2,
            SummonType = 'minotaurcaptain04',
            SharedCooldown = 'MCaptainItems',
			ReengageTargetAfterUse = true,
            MaxUnits = 2,
            Audio = {
                 OnStartCasting = {Sound = 'Forge/ITEMS/snd_item_conjure',},
                 OnFinishCasting = {Sound = 'Forge/ITEMS/General/snd_item_general_Item_Minotaur_Captain_040',},
                 OnAbortCasting = {Sound = 'Forge/ITEMS/snd_item_abort',},
             },
            PreCastCheck = function(self, unit)
                return CheckUnitCap(self, unit, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.minotaurcaptain04, false))
            end,
            OnStartAbility = function(self, unit, params)
                SummonMinions(self, unit, params, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.minotaurcaptain04, false))
            end,
            OnRemoveAbility = function(self, unit)
                unit:DestroyMinions(categories.minotaurcaptain04)
            end,
        }
    },
}

#################################################################################################################
# Siege Archer Idol I
#################################################################################################################
ItemBlueprint {
    DisplayName = '<LOC ITEM_Idol_0008>Siege Archer Idol',
    Description = '<LOC ITEM_Idol_0009>Use: Summons [GetSummonCount] Siege Archers. Can have a maximum of [GetSummonMax] Siege Archers.',
    GetSummonCount = function(self) return Ability['Item_Siege_Archer_010'].SummonCount end,
    GetSummonMax = function(self) return Ability['Item_Siege_Archer_010'].MaxUnits end,
    GetEnergyCost = function(self) return Ability['Item_Siege_Archer_010'].EnergyCost end,
    GetCastTime = function(self) return Ability['Item_Siege_Archer_010'].CastingTime end,
    GetCooldown = function(self) return Ability['Item_Siege_Archer_010'].Cooldown end,
    Icon = 'NewIcons/Boots/Boot3',
    InventoryType = 'Generals',
    SubInventoryType = 'Archers',
    Mesh = '/meshes/items/chest/chest_mesh',
    Animation = '/meshes/items/chest/Animations/chest_Idle_anim.gr2',
    MeshScale = 0.10,
    Name = 'Item_Siege_Archer_010',
    Useable = true,
    PurchaseCategory = 'GENERAL',
    Abilities = {
        AbilityBlueprint {
            AbilityType = 'Instant',
            AbilityCategory = 'USABLEITEM',
            CastingTime = 0.5,
            CastAction = 'CastItem1sec',
            Cooldown = 30,
            EnergyCost = 200,
            InventoryType = 'Generals',
            FromItem = 'Item_Siege_Archer_010',
            Icon = 'NewIcons/SuperGruntIcons/SiegeArcher_01',
            Name = 'Item_Siege_Archer_010',
            NoAbortText = true,
            SummonCount = 2,
            SummonType = 'siegearcher01',
            SharedCooldown = 'SArcherItems',
			ReengageTargetAfterUse = true,
            MaxUnits = 2,
            Audio = {
                 OnStartCasting = {Sound = 'Forge/ITEMS/snd_item_conjure',},
                 OnFinishCasting = {Sound = 'Forge/ITEMS/General/snd_item_general_Item_Siege_Archer_010',},
                 OnAbortCasting = {Sound = 'Forge/ITEMS/snd_item_abort',},
             },
            PreCastCheck = function(self, unit)
                return CheckUnitCap(self, unit, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.siegearcher01, false))
            end,
            OnStartAbility = function(self, unit, params)
                SummonMinions(self, unit, params, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.siegearcher01, false))
            end,
            OnRemoveAbility = function(self, unit)
                unit:DestroyMinions(categories.siegearcher01)
            end,
        }
    },
}

#################################################################################################################
# Siege Archer Idol II
#################################################################################################################
ItemBlueprint {
    DisplayName = '<LOC ITEM_Idol_0010>Siege Gunner Idol',
    Description = '<LOC ITEM_Idol_0011>Use: Summons [GetSummonCount] Siege Gunners. Can have a maximum of [GetSummonMax] Siege Gunners. Siege Gunners are more powerful than Siege Archer.',
    GetSummonCount = function(self) return Ability['Item_Siege_Archer_020'].SummonCount end,
    GetSummonMax = function(self) return Ability['Item_Siege_Archer_020'].MaxUnits end,
    GetEnergyCost = function(self) return Ability['Item_Siege_Archer_020'].EnergyCost end,
    GetCastTime = function(self) return Ability['Item_Siege_Archer_020'].CastingTime end,
    GetCooldown = function(self) return Ability['Item_Siege_Archer_020'].Cooldown end,
    Icon = 'NewIcons/Boots/Boot3',
    InventoryType = 'Generals',
    SubInventoryType = 'Archers',
    Mesh = '/meshes/items/chest/chest_mesh',
    Animation = '/meshes/items/chest/Animations/chest_Idle_anim.gr2',
    MeshScale = 0.10,
    Name = 'Item_Siege_Archer_020',
    Useable = true,
    PurchaseCategory = 'GENERAL',
    Abilities = {
        AbilityBlueprint {
            AbilityType = 'Instant',
            AbilityCategory = 'USABLEITEM',
            CastingTime = 0.5,
            CastAction = 'CastItem1sec',
            Cooldown = 30,
            EnergyCost = 250,
            InventoryType = 'Generals',
            FromItem = 'Item_Siege_Archer_020',
            Icon = 'NewIcons/SuperGruntIcons/SiegeArcher_02',
            Name = 'Item_Siege_Archer_020',
            NoAbortText = true,
            SummonCount = 2,
            SummonType = 'siegearcher02',
            SharedCooldown = 'SArcherItems',
			ReengageTargetAfterUse = true,
            MaxUnits = 2,
            Audio = {
                 OnStartCasting = {Sound = 'Forge/ITEMS/snd_item_conjure',},
                 OnFinishCasting = {Sound = 'Forge/ITEMS/General/snd_item_general_Item_Siege_Archer_020'},
                 OnAbortCasting = {Sound = 'Forge/ITEMS/snd_item_abort',},
             },
            PreCastCheck = function(self, unit)
                return CheckUnitCap(self, unit, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.siegearcher02, false))
            end,
            OnStartAbility = function(self, unit, params)
                SummonMinions(self, unit, params, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.siegearcher02, false))
            end,
            OnRemoveAbility = function(self, unit)
                unit:DestroyMinions(categories.siegearcher02)
            end,
        }
    },
}

#################################################################################################################
# Siege Archer Idol III
#################################################################################################################
ItemBlueprint {
    DisplayName = '<LOC ITEM_Idol_0012>Siege Cannoneer Idol',
    Description = '<LOC ITEM_Idol_0013>Use: Summons [GetSummonCount] Siege Cannoneers. Can have a maximum of [GetSummonMax] Siege Cannoneers. Siege Cannoneers are more powerful than Siege Gunners.',
    GetSummonCount = function(self) return Ability['Item_Siege_Archer_030'].SummonCount end,
    GetSummonMax = function(self) return Ability['Item_Siege_Archer_030'].MaxUnits end,
    GetEnergyCost = function(self) return Ability['Item_Siege_Archer_030'].EnergyCost end,
    GetCastTime = function(self) return Ability['Item_Siege_Archer_030'].CastingTime end,
    GetCooldown = function(self) return Ability['Item_Siege_Archer_030'].Cooldown end,
    Icon = 'NewIcons/Boots/Boot3',
    InventoryType = 'Generals',
    SubInventoryType = 'Archers',
    Mesh = '/meshes/items/chest/chest_mesh',
    Animation = '/meshes/items/chest/Animations/chest_Idle_anim.gr2',
    MeshScale = 0.10,
    Name = 'Item_Siege_Archer_030',
    Useable = true,
    PurchaseCategory = 'GENERAL',
    Abilities = {
        AbilityBlueprint {
            AbilityType = 'Instant',
            AbilityCategory = 'USABLEITEM',
            CastingTime = 0.5,
            CastAction = 'CastItem1sec',
            Cooldown = 30,
            EnergyCost = 300,
            InventoryType = 'Generals',
            FromItem = 'Item_Siege_Archer_030',
            Icon = 'NewIcons/SuperGruntIcons/SiegeArcher_03',
            Name = 'Item_Siege_Archer_030',
            NoAbortText = true,
            SummonCount = 2,
            SummonType = 'siegearcher03',
            SharedCooldown = 'SArcherItems',
			ReengageTargetAfterUse = true,
            MaxUnits = 2,
            Audio = {
                 OnStartCasting = {Sound = 'Forge/ITEMS/snd_item_conjure',},
                 OnFinishCasting = {Sound = 'Forge/ITEMS/General/snd_item_general_Item_Siege_Archer_030'},
                 OnAbortCasting = {Sound = 'Forge/ITEMS/snd_item_abort',},
             },
            PreCastCheck = function(self, unit)
                return CheckUnitCap(self, unit, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.siegearcher03, false))
            end,
            OnStartAbility = function(self, unit, params)
                SummonMinions(self, unit, params, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.siegearcher03, false))
            end,
            OnRemoveAbility = function(self, unit)
                unit:DestroyMinions(categories.siegearcher03)
            end,
        }
    },
}

#################################################################################################################
# Siege Archer Idol IV
#################################################################################################################
ItemBlueprint {
    DisplayName = '<LOC ITEM_Idol_0014>Siege Demolisher Idol',
    Description = '<LOC ITEM_Idol_0015>Use: Summons [GetSummonCount] Siege Demolishers. Can have a maximum of [GetSummonMax] Siege Demolishers. Siege Demolishers are more powerful than Siege Cannoneers.',
    GetSummonCount = function(self) return Ability['Item_Siege_Archer_040'].SummonCount end,
    GetSummonMax = function(self) return Ability['Item_Siege_Archer_040'].MaxUnits end,
    GetEnergyCost = function(self) return Ability['Item_Siege_Archer_040'].EnergyCost end,
    GetCastTime = function(self) return Ability['Item_Siege_Archer_040'].CastingTime end,
    GetCooldown = function(self) return Ability['Item_Siege_Archer_040'].Cooldown end,
    Icon = 'NewIcons/Boots/Boot3',
    InventoryType = 'Generals',
    SubInventoryType = 'Archers',
    Mesh = '/meshes/items/chest/chest_mesh',
    Animation = '/meshes/items/chest/Animations/chest_Idle_anim.gr2',
    MeshScale = 0.10,
    Name = 'Item_Siege_Archer_040',
    Useable = true,
    PurchaseCategory = 'GENERAL',
    Abilities = {
        AbilityBlueprint {
            AbilityType = 'Instant',
            AbilityCategory = 'USABLEITEM',
            CastingTime = 0.5,
            CastAction = 'CastItem1sec',
            Cooldown = 30,
            EnergyCost = 350,
            InventoryType = 'Generals',
            FromItem = 'Item_Siege_Archer_040',
            Icon = 'NewIcons/SuperGruntIcons/SiegeArcher_04',
            Name = 'Item_Siege_Archer_040',
            NoAbortText = true,
            SummonCount = 2,
            SummonType = 'siegearcher04',
            SharedCooldown = 'SArcherItems',
			ReengageTargetAfterUse = true,
            MaxUnits = 2,
            Audio = {
                 OnStartCasting = {Sound = 'Forge/ITEMS/snd_item_conjure',},
                 OnFinishCasting = {Sound = 'Forge/ITEMS/General/snd_item_general_Item_Siege_Archer_040'},
                 OnAbortCasting = {Sound = 'Forge/ITEMS/snd_item_abort',},
             },
            PreCastCheck = function(self, unit)
                return CheckUnitCap(self, unit, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.siegearcher04, false))
            end,
            OnStartAbility = function(self, unit, params)
                SummonMinions(self, unit, params, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.siegearcher04, false))
            end,
            OnRemoveAbility = function(self, unit)
                unit:DestroyMinions(categories.siegearcher04)
            end,
        }
    },
}

#################################################################################################################
# High Priest Idol I
#################################################################################################################
ItemBlueprint {
    DisplayName = '<LOC ITEM_Idol_0016>Monk Idol',
    Description = '<LOC ITEM_Idol_0017>Use: Summons [GetSummonCount] Monks. Can have a maximum of [GetSummonMax] Monks.',
    GetSummonCount = function(self) return Ability['Item_High_Priest_010'].SummonCount end,
    GetSummonMax = function(self) return Ability['Item_High_Priest_010'].MaxUnits end,
    GetEnergyCost = function(self) return Ability['Item_High_Priest_010'].EnergyCost end,
    GetCastTime = function(self) return Ability['Item_High_Priest_010'].CastingTime end,
    GetCooldown = function(self) return Ability['Item_High_Priest_010'].Cooldown end,
    Icon = 'NewIcons/Boots/Boot7',
    InventoryType = 'Generals',
    SubInventoryType = 'Priests',
    Mesh = '/meshes/items/chest/chest_mesh',
    Animation = '/meshes/items/chest/Animations/chest_Idle_anim.gr2',
    MeshScale = 0.10,
    Name = 'Item_High_Priest_010',
    Useable = true,
    PurchaseCategory = 'GENERAL',
    Abilities = {
        AbilityBlueprint {
            AbilityType = 'Instant',
            AbilityCategory = 'USABLEITEM',
            CastingTime = 0.5,
            CastAction = 'CastItem1sec',
            Cooldown = 30,
            EnergyCost = 200,
            InventoryType = 'Generals',
            FromItem = 'Item_High_Priest_010',
            Icon = 'NewIcons/SuperGruntIcons/HighPriest_01',
            Name = 'Item_High_Priest_010',
            NoAbortText = true,
            SummonCount = 2,
            SummonType = 'highpriest01',
            SharedCooldown = 'PriestItems',
			ReengageTargetAfterUse = true,
            MaxUnits = 2,
            Audio = {
                 OnStartCasting = {Sound = 'Forge/ITEMS/snd_item_conjure',},
                 OnFinishCasting = {Sound = 'Forge/ITEMS/General/snd_item_general_Item_High_Priest_010'},
                 OnAbortCasting = {Sound = 'Forge/ITEMS/snd_item_abort',},
             },
            PreCastCheck = function(self, unit)
                return CheckUnitCap(self, unit, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.highpriest01, false))
            end,
            OnStartAbility = function(self, unit, params)
                SummonMinions(self, unit, params, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.highpriest01, false))
            end,
            OnRemoveAbility = function(self, unit)
                unit:DestroyMinions(categories.highpriest01)
            end,
        }
    },
}

#################################################################################################################
# High Priest Idol II
#################################################################################################################
ItemBlueprint {
    DisplayName = '<LOC ITEM_Idol_0018>Cleric Idol',
    Description = '<LOC ITEM_Idol_0019>Use: Summons [GetSummonCount] Clerics. Can have a maximum of [GetSummonMax] Clerics. Clerics are more powerful than Monks.',
    GetSummonCount = function(self) return Ability['Item_High_Priest_020'].SummonCount end,
    GetSummonMax = function(self) return Ability['Item_High_Priest_020'].MaxUnits end,
    GetEnergyCost = function(self) return Ability['Item_High_Priest_020'].EnergyCost end,
    GetCastTime = function(self) return Ability['Item_High_Priest_020'].CastingTime end,
    GetCooldown = function(self) return Ability['Item_High_Priest_020'].Cooldown end,
    Icon = 'NewIcons/Boots/Boot7',
    InventoryType = 'Generals',
    SubInventoryType = 'Priests',
    Mesh = '/meshes/items/chest/chest_mesh',
    Animation = '/meshes/items/chest/Animations/chest_Idle_anim.gr2',
    MeshScale = 0.10,
    Name = 'Item_High_Priest_020',
    Useable = true,
    PurchaseCategory = 'GENERAL',
    Abilities = {
        AbilityBlueprint {
            AbilityType = 'Instant',
            AbilityCategory = 'USABLEITEM',
            CastingTime = 0.5,
            CastAction = 'CastItem1sec',
            Cooldown = 30,
            EnergyCost = 250,
            FromItem = 'Item_High_Priest_020',
            Icon = 'NewIcons/SuperGruntIcons/HighPriest_02',
            Name = 'Item_High_Priest_020',
            NoAbortText = true,
            SummonCount = 2,
            SummonType = 'highpriest02',
            SharedCooldown = 'PriestItems',
			ReengageTargetAfterUse = true,
            MaxUnits = 2,
            Audio = {
                 OnStartCasting = {Sound = 'Forge/ITEMS/snd_item_conjure',},
                 OnFinishCasting = {Sound = 'Forge/ITEMS/General/snd_item_general_Item_High_Priest_020'},
                 OnAbortCasting = {Sound = 'Forge/ITEMS/snd_item_abort',},
             },
            PreCastCheck = function(self, unit)
                return CheckUnitCap(self, unit, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.highpriest02, false))
            end,
            OnStartAbility = function(self, unit, params)
                SummonMinions(self, unit, params, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.highpriest02, false))
            end,
            OnRemoveAbility = function(self, unit)
                unit:DestroyMinions(categories.highpriest02)
            end,
        }
    },
}

#################################################################################################################
# High Priest Idol III
#################################################################################################################
ItemBlueprint {
    DisplayName = '<LOC ITEM_Idol_0020>High Priest Idol',
    Description = '<LOC ITEM_Idol_0021>Use: Summons [GetSummonCount] High Priests. Can have a maximum of [GetSummonMax] High Priests. High Priests are more powerful than Clerics.',
    GetSummonCount = function(self) return Ability['Item_High_Priest_030'].SummonCount end,
    GetSummonMax = function(self) return Ability['Item_High_Priest_030'].MaxUnits end,
    GetEnergyCost = function(self) return Ability['Item_High_Priest_030'].EnergyCost end,
    GetCastTime = function(self) return Ability['Item_High_Priest_030'].CastingTime end,
    GetCooldown = function(self) return Ability['Item_High_Priest_030'].Cooldown end,
    Icon = 'NewIcons/Boots/Boot7',
    InventoryType = 'Generals',
    SubInventoryType = 'Priests',
    Mesh = '/meshes/items/chest/chest_mesh',
    Animation = '/meshes/items/chest/Animations/chest_Idle_anim.gr2',
    MeshScale = 0.10,
    Name = 'Item_High_Priest_030',
    Useable = true,
    PurchaseCategory = 'GENERAL',
    Abilities = {
        AbilityBlueprint {
            AbilityType = 'Instant',
            AbilityCategory = 'USABLEITEM',
            CastingTime = 0.5,
            CastAction = 'CastItem1sec',
            Cooldown = 30,
            EnergyCost = 300,
            InventoryType = 'Generals',
            FromItem = 'Item_High_Priest_030',
            Icon = 'NewIcons/SuperGruntIcons/HighPriest_03',
            Name = 'Item_High_Priest_030',
            NoAbortText = true,
            SummonCount = 2,
            SummonType = 'highpriest03',
            SharedCooldown = 'PriestItems',
			ReengageTargetAfterUse = true,
            MaxUnits = 2,
            Audio = {
                 OnStartCasting = {Sound = 'Forge/ITEMS/snd_item_conjure',},
                 OnFinishCasting = {Sound = 'Forge/ITEMS/General/snd_item_general_Item_High_Priest_030'},
                 OnAbortCasting = {Sound = 'Forge/ITEMS/snd_item_abort',},
             },
            PreCastCheck = function(self, unit)
                return CheckUnitCap(self, unit, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.highpriest03, false))
            end,
            OnStartAbility = function(self, unit, params)
                SummonMinions(self, unit, params, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.highpriest03, false))
            end,
            OnRemoveAbility = function(self, unit)
                unit:DestroyMinions(categories.highpriest03)
            end,
        }
    },
}

#################################################################################################################
# High Priest Idol IV
#################################################################################################################
ItemBlueprint {
    DisplayName = '<LOC ITEM_Idol_0022>Bishop Idol',
    Description = '<LOC ITEM_Idol_0023>Use: Summons [GetSummonCount] Bishops. Can have a maximum of [GetSummonMax] Bishops. Bishops are more powerful than High Priests.',
    GetSummonCount = function(self) return Ability['Item_High_Priest_040'].SummonCount end,
    GetSummonMax = function(self) return Ability['Item_High_Priest_040'].MaxUnits end,
    GetEnergyCost = function(self) return Ability['Item_High_Priest_040'].EnergyCost end,
    GetCastTime = function(self) return Ability['Item_High_Priest_040'].CastingTime end,
    GetCooldown = function(self) return Ability['Item_High_Priest_040'].Cooldown end,
    Icon = 'NewIcons/Boots/Boot7',
    InventoryType = 'Generals',
    SubInventoryType = 'Priests',
    Mesh = '/meshes/items/chest/chest_mesh',
    Animation = '/meshes/items/chest/Animations/chest_Idle_anim.gr2',
    MeshScale = 0.10,
    Name = 'Item_High_Priest_040',
    Useable = true,
    PurchaseCategory = 'GENERAL',
    Abilities = {
        AbilityBlueprint {
            AbilityType = 'Instant',
            AbilityCategory = 'USABLEITEM',
            CastingTime = 0.5,
            CastAction = 'CastItem1sec',
            Cooldown = 30,
            EnergyCost = 350,
            InventoryType = 'Generals',
            FromItem = 'Item_High_Priest_040',
            Icon = 'NewIcons/SuperGruntIcons/HighPriest_04',
            Name = 'Item_High_Priest_040',
            NoAbortText = true,
            SummonCount = 2,
            SummonType = 'highpriest04',
            SharedCooldown = 'PriestItems',
			ReengageTargetAfterUse = true,
            MaxUnits = 2,
            Audio = {
                 OnStartCasting = {Sound = 'Forge/ITEMS/snd_item_conjure',},
                 OnFinishCasting = {Sound = 'Forge/ITEMS/General/snd_item_general_Item_High_Priest_040'},
                 OnAbortCasting = {Sound = 'Forge/ITEMS/snd_item_abort',},
             },
            PreCastCheck = function(self, unit)
                return CheckUnitCap(self, unit, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.highpriest04, false))
            end,
            OnStartAbility = function(self, unit, params)
                SummonMinions(self, unit, params, ArmyBrains[unit:GetArmy()]:GetListOfUnits(categories.highpriest04, false))
            end,
            OnRemoveAbility = function(self, unit)
                unit:DestroyMinions(categories.highpriest04)
            end,
        }
    },
}

__moduleinfo.auto_reload = true ]]--