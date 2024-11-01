#  [MOD] This is an AI template for how to build out a demigod of this type
#  SkillBuilds contains the custom build we have selected for the AI
#    If there are multiple builds in SkillBuilds the AI will select from one randomly on game start
#  Builds start with a comma seperated list of skills.  These are trained in the order they are listed.  
#    The skill plan doesn't have to be ahead of favor items or itemweights, but its easier to read if they are.
#    A build can use 'SAVE' and 'SAVE2' as skill names when it needs to save 1 or 2 skill points (Queen and Rook have examples of SAVE2)
#  Favor items can be added to each build through declaring FavorItems = {'favoritem1', 'favoritem2', '...'},   
#    The build will randomly select one favor item on start from the list
#    Reference dgdata\lua\common\Items\Achievement_Items.lua for the internal name of a favor item.
#  Items to use can be set for use by declaring ItemWeights = {item1 = {Priority=xx},item2= {Priority=xx},item3 = {Priority=xx}},
#    Priorities are added to global values in Skirmish_AI\hook\lua\sim\AIAIGlobals.lua
#    The format for item weights here is the exact same as the AIGlobals ItemWeights section so copy and paste from there as needed
#      Priority Functions are not currently usable on ItemWeights in the build section.  Set a hard value for Priority.
#    Most consumables and artifacts have a global value defined.  
#    Most wearable items have 0 Priority.
#    The AI buys the highest Priority item it can afford whenever it is shopping. 
#    It sells the lowest Priority item when it is out of slots and can afford something of higher priority 
#    Priorities can overlap, but we spread them out to make it clear to the AI what it should sell later

UnitAITemplates['hdemon'] = {
    UnitId = 'hdemon',

    SensorSets = {
        MeleeHero = true,
    },
    ActionSets = {
        MeleeHero = true,
    },

    GoapCreation = function(hero, planner)
        local furyOnFunction = function(unit, buffName, instigator)
            if(buffName == 'HGSA01AngelicFuryOnDisable') then
                unit.WorldStateData.AngelicFuryMode = true
                unit.WorldStateData.HeroKillBonus = unit.WorldStateData.HeroKillBonus - 1
                unit.WorldStateData.GruntKillBonus = unit.WorldStateData.GruntKillBonus - 1
            end
        end

        local furyOffFunction = function(unit, buffName, instigator)
            if(buffName == 'HGSA01AngelicFuryOnDisable') then
                unit.WorldStateData.AngelicFuryMode = false
                unit.WorldStateData.HeroKillBonus = unit.WorldStateData.HeroKillBonus + 1
                unit.WorldStateData.GruntKillBonus = unit.WorldStateData.GruntKillBonus + 1
            end
        end

        local maimAddFunction = function(unit, abilityName)
            if(abilityName == 'HGSA01Maim01') then
                unit.WorldStateData.HeroKillBonus = unit.WorldStateData.HeroKillBonus - .2
            elseif(abilityName == 'HGSA01Maim02') then
                unit.WorldStateData.HeroKillBonus = unit.WorldStateData.HeroKillBonus - .4
            elseif(abilityName == 'HGSA01Maim03') then
                unit.WorldStateData.HeroKillBonus = unit.WorldStateData.HeroKillBonus - .6
            end
        end

        hero.WorldStateData.AngelicFuryMode = false

        hero.Callbacks.OnBuffActivate:Add(furyOnFunction, hero)
        hero.Callbacks.OnBuffDeactivate:Add(furyOffFunction, hero)

        hero.Callbacks.OnAbilityAdded:Add(maimAddFunction, hero)
    end,


SkillBuilds = {

--# 0.26.52 disabled build - not liking it
--[[


   Speed_Spine = 
	   {
		    'HDemonSpineAttack01',      # 1
            'HDemonWarpStrike01',       # 2
            'HDemonDemonsSpeed01',		# 3
            'HDemonWarpStrike02',		# 4
            'HDemonShadowSwap01',	 	# 5
            'HDemonSpineAttack02', 		# 6
            'HDemonSpineAttack03', 		# 7
            'HDemonDemonsSpeed02',		# 8
            'SAVE',             		# 9
            'HDemonSpineAttack04','HDemonShadowSwap02',  # 10
            'HDemonWarpStrike03',		# 11
            'HDemonWarpStrike04',   	# 12
            'HDemonDemonsSpeed03',    	# 13
            'SAVE',      				# 14
            'HDemonDeadlyWarp','HDemonShadowSwap03',	 # 15
            'HDemonPrecision01',  		# 16
            'HDemonPrecision02',    	# 17
            'HDemonPrecision03',		# 18
            'HDemonPrecision04',		# 19
            'HDemonWarpArea01',			# 20
			FavorItems = {'AchievementRefreshCooldowns','AchievementHealth'},# 'AchievementFreeSpells'		
			ItemWeights = {

			# 0.26.51 Updated equipmenet build based on the new priorities set in version 0.26.51
					# Nature's Reckoning
					# 15% chance on hit to strike nearby enemies with lightning for 250 damage
					Item_Ring_030 = {
						Priority = 35,
					},

					# Wand of Speed
					# Use: Increase Base Run Speed by 30%.
					Item_Consumable_050 = {
						Priority = 20,
					},	
					
					# Boots of Speed
					# +15% Base Run Speed
					Item_Boot_020 = {
						Priority = 25,
					},	
					# Mage Slayer
					# +20% Life Steal
					# 40% chance on hit to stun target for 0.4 seconds.
					Item_Artifact_020 = {
					Priority = 20,
					},		
			},
		},
--]]
# 0.27.02 disabled build - going to use standard DA build now that swap is working as expected
--[[
--# 0.26.55 updated the build as there was an error
--# 0.26.54 added new build per request that does not use swap

		Warp_Spine =
				{
				'HDemonWarpStrike01',      # 1
				'HDemonSpineAttack01',     # 2
                'SAVE',                    # 3
                'HDemonWarpStrike02','HDemonSpineAttack02',  # 4
                'HDemonWarpArea01',  	   # 5
                'SAVE',     		       # 6
                'HDemonWarpStrike03','HDemonSpineAttack03',  # 7
                'HDemonDemonsSpeed01',     # 8
                'SAVE',                    # 9
                'HDemonWarpStrike04','HDemonSpineAttack04',  # 10
                'HDemonWarpArea02',        # 11
                'HDemonDemonsSpeed02',     # 12
				'HDemonDemonsSpeed03',     # 13
                'HDemonElusiveness01',     # 14
                'HDemonDeadlyWarp',        # 15
				'HDemonElusiveness02',     # 16           
                'HDemonElusiveness03',     # 17
                'HDemonAssassinsSpeed',    # 18           
                'HDemonForcefulBlows',     # 19
                'HDemonPrecision01',       # 20     
                
# 0.26.52 changed to only get Blood of the fallen
				FavorItems = {'AchievementHealth'},
			ItemWeights = {
# 0.26.51 Updated equipmenet build based on the new priorities set in version 0.26.51
					# Nature's Reckoning
					# 15% chance on hit to strike nearby enemies with lightning for 250 damage
					Item_Ring_030 = {
						Priority = 35,
					},

					# Wand of Speed
					# Use: Increase Base Run Speed by 30%.
					Item_Consumable_050 = {
						Priority = 20,
					},	
					
					# Boots of Speed
					# +15% Base Run Speed
					Item_Boot_020 = {
						Priority = 25,
					},	
					
					# Mage Slayer
					# +20% Life Steal
					# 40% chance on hit to stun target for 0.4 seconds.
					Item_Artifact_020 = {
					Priority = 20,
					},		
			
						
			},
		},
--]]

# 0.27.02 re-enabled build now that swap is working as expected
--# 0.26.54 removed build
	
		Warp_Spine =
				{
		'HDemonSpineAttack01',      	# 1
		'HDemonWarpStrike01',     	# 2
		'HDemonDemonsSpeed01',     	# 3
                'HDemonSpineAttack02',  	# 4
                'HDemonShadowSwap01',     	# 5
                'HDemonWarpStrike02',        	# 6
		'HDemonSpineAttack03',  	# 7
		'HDemonWarpStrike03',         	# 8
                'SAVE',                   		# 9
                'HDemonWarpStrike04','HDemonSpineAttack04',	# 10
		'HDemonShadowSwap02',     	# 11
                'HDemonDemonsSpeed02',    	# 12
                'HDemonDemonsSpeed03',     	# 13
                'SAVE',     				# 14           
                'HDemonDeadlyWarp','HDemonShadowSwap03', 	# 15
                'HDemonWarpArea01',     	# 16
                'HDemonWarpArea02',     	# 17           
                'HDemonPrecision01',     	# 18
                'HDemonPrecision02',     	# 19     
                'HDemonPrecision03',    	# 20   
# 0.26.52 changed to only get Blood of the fallen
				FavorItems = {'AchievementHealth'},
			ItemWeights = {
# 0.26.51 Updated equipmenet build based on the new priorities set in version 0.26.51
					# Nature's Reckoning
					# 15% chance on hit to strike nearby enemies with lightning for 250 damage
					Item_Ring_030 = {
						Priority = 35,
					},

					# Wand of Speed
					# Use: Increase Base Run Speed by 30%.
					Item_Consumable_050 = {
						Priority = 20,
					},	
					
					# Boots of Speed
					# +15% Base Run Speed
					Item_Boot_020 = {
						Priority = 25,
					},	
					
					# Mage Slayer
					# +20% Life Steal
					# 40% chance on hit to stun target for 0.4 seconds.
					Item_Artifact_020 = {
					Priority = 20,
					},		
			
						
			},
		},
		
		
		

	},

    SkillWeights = {
        # =====================
        # Demon Precision
        # =====================
        HDemonPrecision01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HDemonPrecision02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HDemonPrecision03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },
        
        # =====================
        # Warp Strike
        # =====================
        HDemonWarpStrike01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.7,
                PushValue = 0.1,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.2,
                ManaDesire = -0.2,
            },
        },
        HDemonWarpStrike02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.7,
                PushValue = 0.1,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.2,
                ManaDesire = -0.2,
            },
        },
        HDemonWarpStrike03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.7,
                PushValue = 0.1,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.2,
                ManaDesire = -0.2,
            },
        },
        HDemonWarpStrike04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.7,
                PushValue = 0.1,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.2,
                ManaDesire = -0.2,
            },
        },
        HDemonDeadlyWarp = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.2,
                ManaDesire = -0.2,
            },
        },

        # =====================
        # Spine Attack
        # =====================
        HDemonSpineAttack01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.7,
                PushValue = 0.1,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
            },
        },
        HDemonSpineAttack02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.7,
                PushValue = 0.1,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
            },
        },
        HDemonSpineAttack03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.7,
                PushValue = 0.1,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
            },
        },
        HDemonSpineAttack04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.7,
                PushValue = 0.1,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
            },
        },

        # =====================
        # Elusiveness
        # =====================
        HDemonElusiveness01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.3,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
            },
        },
        HDemonElusiveness02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.3,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
            },
        },
        HDemonElusiveness03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.3,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
            },
        },

        # =====================
        # Area Warp
        # =====================
        HDemonWarpArea01 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.1,
                ManaDesire = -0.1,
            },
        },
        HDemonWarpArea02 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.1,
                ManaDesire = -0.1,
            },
        },
        HDemonForcefulBlows = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.5,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.1,
                ManaDesire = -0.1,
            },
        },

        # =====================
        # Shadow Swap
        # =====================
        HDemonShadowSwap01 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
            },
        },
        HDemonShadowSwap02 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
            },
        },
        HDemonShadowSwap03 = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
            },
        },

        # =====================
        # Demons Speed
        # =====================
        HDemonDemonsSpeed01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.6,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.1,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HDemonDemonsSpeed02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.6,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.1,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HDemonDemonsSpeed03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.6,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.1,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HDemonAssassinsSpeed = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.1,
                PushValue = 0.8,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
        },

        # =====================
        # Stat Buffs
        # =====================
        StatsBuff01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.1,
            },
        },
        StatsBuff02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.1,
            },
        },
        StatsBuff03 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.1,
            },
        },
        StatsBuff04 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.1,
            },
        },
        StatsBuff05 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.1,
            },
        },
        StatsBuff06 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.1,
            },
        },
    },

}