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

UnitAITemplates['hsedna'] = {
    UnitId = 'hsedna',

    ActionSets = {
        MeleeHero = true,
        General = true,
    },
    SensorSets = {
        MeleeHero = true,
    },

# 0.26.36 Removed all builds and created 2 new ones
# There will only be 2 builds when I'm done
	
    SkillBuilds = {
	
	Heal_Late_Pounce = {
		'HSednaHeal01',               	# 1
		'HSednaHealingWind01',       	# 2
		'HSednaPounce01',          	# 3
		'HSednaHeal02',               	# 4
		'HSednaHealingWind02',       	# 5
		'HSednaSilence01',          	# 6
		'HSednaHeal03',               	# 7
		'HSednaCounterHealing01',      # 8
		'HSednaInnerGrace01',          # 9
		'HSednaHeal04',               	# 10
		'HSednaMagnificentPresence01',	# 11
		'HSednaSilence02',             	# 12
		'HSednaMagnificentPresence02',	# 13
		'HSednaInnerGrace02',       	# 14
		'HSednaMagnificentPresence03',	# 15				
		'HSednaInnerGrace03',      	# 16
		'HSednaPounce02',              	# 17
		'HSednaPounce03',  		# 18
		'HSednaPounce04',  		# 19
		'HSednaSilence03',             	# 20
			FavorItems = {'AchievementHealth'}, #'AchievementMinionInvis',
			ItemWeights = {
# 0.26.51 Updated equipment build based on the new priorities set in version 0.26.51		
					# Nature's Reckoning
					# 15% chance on hit to strike nearby enemies with lightning for 250 damage
					Item_Ring_030 = {
						Priority = 45,
					},	
			--Plenor Battlecrown
			--+1000 Mana
			---25% to ability cooldowns
				Item_Helm_030 = {
				Priority = 50,
				},
				--Hauberk of Life
				--+750 Hit Points
				--+20 Hit Points per second
				Item_Chest_040 = {
				Priority = 45,
				},					
			},
        },
# 0.27.02 disabled build again - pounce is still not good enough to be utilized as a primary ability in game
-- 0.26.56 re-enabled sedna's build - pounce issues seem resolved
-- 0.26.45 removed again by pacov until we get better balance
-- 0.26.42 added back in now that I have the pounce logic sorted
-- 0.26.39 Removed by pacov.  Sedna needs to have her code adjusted to use pounce more.  Disabling this build until I have time to sort that
	Pounce_Late_Heal = {
		'HSednaHeal01',               		# 1
		'HSednaHealingWind01',       		# 2
		'HSednaPounce01',          		# 3
		'HSednaPounce02',              		# 4
		'HSednaInnerGrace01',          	# 5
		'HSednaSilence01',          		# 6
		'HSednaPounce03',  			# 7
		'HSednaHealingWind02',			# 8			
		'HSednaCounterHealing01',      	# 9
	        'HSednaPounce04',  			# 10		
		'HSednaInnerGrace02',          	# 11		
		'HSednaSilence02',          		# 12			
		'HSednaMagnificentPresence01',    	# 13
		'HSednaMagnificentPresence02',	# 14
	        'HSednaMagnificentPresence03',	# 15			
		'HSednaInnerGrace03',      		# 16			
	        'HSednaHeal02',               		# 17
		'HSednaHeal03',               		# 18			 
		'HSednaHeal04',               		# 19
		'HSednaSilence03',             		# 20
			FavorItems = {'AchievementHealth'}, #'AchievementMinionInvis',
			ItemWeights = {
		
					# Nature's Reckoning
					# 15% chance on hit to strike nearby enemies with lightning for 250 damage
					Item_Ring_030 = {
						Priority = 45,
					},		
				
			},
        },
	},		
# removed by pacov 0.26.36 - old build that needed tweaked
--[[
		 heal_silence = {
            'HSednaHeal01',               		# 1
            'HSednaHealingWind01',           	# 2
            'HSednaPounce01',          			# 3
            'HSednaHeal02',               		# 4
            'HSednaHealingWind02',         		# 5
            'HSednaSilence01',          		# 6
            'HSednaHeal03',               		# 7
            'HSednaCounterHealing01',         	# 8
            'SAVE',       						# 9
            'HSednaHeal04', 'HSednaSilence02',	# 10
            'HSednaMagnificentPresence01',    	# 11
            'HSednaMagnificentPresence02',  	# 12
            'HSednaInnerGrace01',  				# 13
            'SAVE',   							# 14
            'HSednaMagnificentPresence03', 'HSednaSilence03', # 15
            'HSednaPounce02',             		# 16
            'HSednaPounce03',  					# 17
            'HSednaPounce04',					# 18
            'HSednaInnerGrace02',				# 19
            'HSednaInnerGrace03', 				# 20
			FavorItems = {'AchievementHealth'}, #'AchievementMinionInvis',
			ItemWeights = {
		
					# Nature's Reckoning
					# 15% chance on hit to strike nearby enemies with lightning for 250 damage
					Item_Ring_030 = {
						Priority = 35,
					},		
				
			},
        },
	
	 heal_tank = {
            'HSednaHeal01',               	# 1
            'HSednaHealingWind01',       	# 2
            'HSednaPounce01',          		# 3
            'HSednaHeal02',               	# 4
            'HSednaHealingWind02',       	# 5
            'HSednaInnerGrace01',          	# 6
            'HSednaHeal03',               	# 7
            'HSednaCounterHealing01',      	# 8
            'HSednaInnerGrace02',       	# 9
            'HSednaHeal04',               	# 10
            'HSednaPounce02',              	# 11
            'HSednaPounce03',  				# 12
            'HSednaPounce04',  				# 13
            'HSednaInnerGrace03',      		# 14
            'HSednaSilence01',          	# 15
            'HSednaSilence02',             	# 16
            'HSednaSilence03',  			# 17
            'HSednaMagnificentPresence01',	# 18
            'HSednaMagnificentPresence02',	# 19
            'HSednaMagnificentPresence03',	# 20
			FavorItems = {'AchievementHealth'}, #'AchievementMinionInvis',
			ItemWeights = {
		
					# Nature's Reckoning
					# 15% chance on hit to strike nearby enemies with lightning for 250 damage
					Item_Ring_030 = {
						Priority = 35,
					},		
				
			},
        },

	 pounce_heal = {
            'HSednaHeal01',               	# 1
            'HSednaPounce01',       		# 2
            'HSednaInnerGrace01',        	# 3
            'HSednaPounce02',             	# 4
            'HSednaSilence01',       		# 5
            'HSednaHeal02',          		# 6
            'HSednaPounce03',            	# 7
            'HSednaHealingWind01',      	# 8
            'HSednaHealingWind02',       	# 9
            'HSednaPounce04',            	# 10
            'HSednaMagnificentPresence01',	# 11
            'HSednaMagnificentPresence02',	# 12
            'HSednaHeal03',  				# 13
            'HSednaInnerGrace02',      		# 14
            'HSednaMagnificentPresence03', 	# 15
            'HSednaHeal04',             	# 16
            'HSednaCounterHealing01',  		# 17
            'HSednaInnerGrace03',			# 18
            'HSednaSilence02',				# 19
            'HSednaSilence03',				# 20
			FavorItems = {'AchievementHealth'}, #'AchievementMinionInvis',
			ItemWeights = {
		
					# Nature's Reckoning
					# 15% chance on hit to strike nearby enemies with lightning for 250 damage
					Item_Ring_030 = {
						Priority = 35,
					},		
				
			},
        },

		
    },
--]]
    SkillWeights = {
        # =====================
        # Silence
        # =====================
        HSednaSilence01 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.15,
                HealthDesire = -0.15,
            },
        },
        HSednaSilence02 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.15,
                HealthDesire = -0.15,
            },
        },
        HSednaSilence03 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.15,
                HealthDesire = -0.15,
            },
        },


        # =====================
        # Healing Wind
        # =====================
        HSednaHealingWind01 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.1,
            },
        },
        HSednaHealingWind02 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.1,
            },
        },
        HSednaCounterHealing01 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.1,
            },
        },

        # =====================
        # Magnificent Presence
        # =====================
        HSednaMagnificentPresence01 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.3,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                SpeedDesire = -0.1,
            },
        },
        HSednaMagnificentPresence02 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.3,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                SpeedDesire = -0.1,
            },
        },
        HSednaMagnificentPresence03 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.3,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                SpeedDesire = -0.1,
            },
        },

        # =====================
        # Inner Grace
        # =====================
        HSednaInnerGrace01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.2,
            },
        },
        HSednaInnerGrace02 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.2,
            },
        },
        HSednaInnerGrace03 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.2,
            },
        },

        # =====================
        # Heal
        # =====================
        HSednaHeal01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.2,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.2,
            },
        },
        HSednaHeal02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.2,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.2,
            },
        },
        HSednaHeal03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.2,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.2,
            },
        },
        HSednaHeal04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.2,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.2,
            },
        },
        HSednaLifesChild = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.2,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
        },

        # =====================
        # Yetis
        # =====================
        HSednaYeti01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.3,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                MinionDesire = -0.2,
            },
        },
        HSednaYeti02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.3,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                MinionDesire = -0.2,
            },
        },
        HSednaYeti03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.3,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                MinionDesire = -0.2,
            },
        },
        HSednaYeti04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.3,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                MinionDesire = -0.2,
            },
        },
        HSednaWildSwings = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.3,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
            },
        },

        # =====================
        # Pounce
        # =====================
        HSednaPounce01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.2,
            },
        },
        HSednaPounce02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.2,
            },
        },
        HSednaPounce03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.2,
            },
        },
        HSednaPounce04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.2,
            },
        },
        HSednaInspiringRoar = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
        },

        # =====================
        # Stat Buffs
        # =====================
        GeneralStatsBuff01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            ShopDesires = {
                MinionDesire = -0.1,
            },
        },
        GeneralStatsBuff02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            ShopDesires = {
                MinionDesire = -0.1,
            },
        },
        GeneralStatsBuff03 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            ShopDesires = {
                MinionDesire = -0.1,
            },
        },
        GeneralStatsBuff04 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            ShopDesires = {
                MinionDesire = -0.1,
            },
        },
        GeneralStatsBuff05 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            ShopDesires = {
                MinionDesire = -0.1,
            },
        },
        GeneralStatsBuff06 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            ShopDesires = {
                MinionDesire = -0.1,
            },
        },
    },
}