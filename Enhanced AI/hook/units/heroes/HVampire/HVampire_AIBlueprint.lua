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

UnitAITemplates['hvampire'] = {
    UnitId = 'hvampire',

    ActionSets = {
        MeleeHero = true,
        General = true,
    },
    SensorSets = {
    },

    GoapCreation = function(hero, planner)
        local mistOnFunction = function(unit, buffName, instigator)
            if buffName != 'HVampireMistImmunity' then
                return
            end
            unit.WorldStateData.MistMode = true
            unit.WorldStateData.CanMove = false
            unit.WorldStateData.CanUseAbilities = false
            unit.WorldStateData.CanAttack = false
        end

        local mistOffFunction = function(unit, buffName, instigator)
            if buffName != 'HVampireMistImmunity' then
                return
            end
            unit.WorldStateData.MistMode = false
            unit.WorldStateData.CanMove = true
            unit.WorldStateData.CanUseAbilities = true
            unit.WorldStateData.CanAttack = true
        end

        hero.WorldStateData.MistMode = false

        hero.Callbacks.OnBuffActivate:Add(mistOnFunction, hero)
        hero.Callbacks.OnBuffDeactivate:Add(mistOffFunction, hero)
    end,
# Removed all builds for pacov test 0.2636 -  
# There will likely only be 1 build when I'm done
    SkillBuilds = {

# 0.26.40 - removing mist from the build and replacing with coven until we can get the logic updated for mist
# Use pacov_Standard_assassin1 when we want to add mist back to the build again and just disable build 2	

	Bite_Charm = {
			'HVampireBite01',          		# 1
			'HVampireCoven01', 			# 2
			'SAVE',					# 3
			'HVampireBite02',				# 4
			'HVampireBatSwarm01',  'HVampireMassCharm01', #5
			'HVampireMassCharm02', 		# 6
			'HVampireBite03',           		# 7
			'HVampireMassCharm03', 		# 8
			'SAVE',      					# 9
			'HVampireMassCharm04','HVampireBatSwarm02',	# 10
			'HVampireBite04', 			# 11
			'HVampirePoisonedBlood01',  		# 12
			'HVampirePoisonedBlood02',		# 13
			'SAVE',      					# 14
			'HVampireMuddle', 'HVampireVampiricAura01',   #15
			'HVampireBatSwarm03',  		# 16
			'HVampireCoven02',			# 17
			'HVampireCoven03',			# 18
			'HVampireConversion01',		# 19
			'GeneralStatsBuff01',			# 20
			FavorItems = {'AchievementHealth'}, #'AchievementMinionInvis',
			ItemWeights = {
			
				
			},			
			
        },
},

--[[
pacov_standard_Assassin1 = {
            'HVampireBite01',           # 1
            'HVampireMist01',			# 2
			'SAVE',						# 3
			'SAVE2',					# 4
			'HVampireBite02', 'HVampireBatSwarm01',  'HVampireMassCharm01', #5
			'HVampireMassCharm02', 		# 6
			'HVampireBite03',           # 7
			'HVampireMassCharm03', 		# 8
			'SAVE',      				# 9
			'HVampireBite04','HVampireBatSwarm02',	# 10
			'HVampireMassCharm04', 		# 11
			'HVampirePoisonedBlood01',  # 12
            'HVampirePoisonedBlood02',	# 13
			'SAVE',      				# 14
			'HVampireMuddle', 'HVampireVampiricAura01',   #15
			'HVampireCoven01', 			# 16
			'HVampireCoven02',  		# 17
			'HVampireCoven03',			# 18
			'HVampireConversion01',		# 19
			'HVampireConversion02',		# 20
			FavorItems = {'AchievementHealth'}, #'AchievementMinionInvis',
			ItemWeights = {
			
				
			},			
			
        },
},
--]]

# Removed my build 0.26.38 - going to try to modify it so erb does not have stun at an early level (and waste mana)

--[[
	pacov_standard_Assassin = {
            'HVampireBite01',           # 1
            'HVampireMist01',			# 2
			'HVampireMassCharm01', 		# 3
			'HVampireBite02',           # 4
			'HVampireBatSwarm01',       # 5
			'HVampireMassCharm02', 		# 6
			'HVampireBite03',           # 7
			'HVampireMassCharm03', 		# 8
			'SAVE',      				# 9
			'HVampireBite04','HVampireBatSwarm02',	# 10
			'HVampireMassCharm04', 		# 11
			'HVampirePoisonedBlood01',  # 12
            'HVampirePoisonedBlood02',	# 13
			'SAVE',      				# 14
			'HVampireMuddle', 'HVampireVampiricAura01',   #15
			'HVampireCoven01', 			# 16
			'HVampireCoven02',  		# 17
			'HVampireCoven03',			# 18
			'HVampireConversion01',		# 19
			'HVampireConversion02',		# 20
			FavorItems = {'AchievementHealth'}, #'AchievementMinionInvis',
			ItemWeights = {
			
				
			},			
			
        },
},


--]]
# removed by pacov	
--[[	
	        bite_swarm_army = {
            'HVampireBite01',           # 1
            'HVampireCoven01', 			# 2
            'HVampireConversion01',		# 3
            'HVampireBite02',           # 4
            'HVampireBatSwarm01',       # 5
            'HVampireCoven02',  		# 6
            'HVampireBite03',           # 7
            'HVampireCoven03',			# 8
            'SAVE',      				# 9
            'HVampireBite04','HVampireBatSwarm02',	# 10
            'HVampireConversion02',		# 11
            'HVampireConversion03',		# 12
            'HVampirePoisonedBlood01',  # 13
            'HVampirePoisonedBlood02',	# 14
            'HVampireArmyoftheNight', 	# 15
            'HVampireVampiricAura01',	# 16
            'GeneralStatsBuff01',     	# 17
            'GeneralStatsBuff02',       # 18
            'GeneralStatsBuff03',  		# 19
            'GeneralStatsBuff04',       # 20
			FavorItems = {'AchievementHealth'}, #'AchievementMinionInvis',
			ItemWeights = {
			
				
			},			
			
        },
	        bite_mist_charm = {
            'HVampireBite01',           # 1
            'HVampireMassCharm01', 		# 2
            'HVampireMist01',			# 3
            'HVampireBite02',           # 4
            'HVampireBatSwarm01',       # 5
            'HVampireMassCharm02',  	# 6
            'HVampireBite03',           # 7
            'HVampireMassCharm03',		# 8
            'SAVE',      				# 9
            'HVampireBite04','HVampireBatSwarm02',	# 10
            'HVampireCoven01',			# 11
            'HVampireConversion01',		# 12
            'HVampirePoisonedBlood01',  # 13
            'HVampirePoisonedBlood02',	# 14
            'HVampireVampiricAura01', 	# 15
            'HVampireCoven02',			# 16
            'HVampireCoven03',   		# 17
            'HVampireConversion02', 	# 18
            'HVampireConversion03',  	# 19
            'HVampireArmyoftheNight',  	# 20
			FavorItems = {'AchievementHealth'}, # 'AchievementMinionInvis',
			ItemWeights = {
			
	
			},			
			
        },	
	
	},
--]]	
    SkillWeights = {

        # =====================
        # Vampire Conversion
        # =====================
        HVampireConversion01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.4,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
                HVampireCoven01 = 1.0, HVampireCoven02 = 1.0, HVampireCoven03 = 1.0,
            },
            ShopDesires = {
                MinionDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HVampireConversion02 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.4,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
                HVampireCoven01 = 1.0, HVampireCoven02 = 1.0, HVampireCoven03 = 1.0,
            },
            ShopDesires = {
                MinionDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HVampireConversion03 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.4,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
                HVampireCoven01 = 1.0, HVampireCoven02 = 1.0, HVampireCoven03 = 1.0,
            },
            ShopDesires = {
                MinionDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },

        # =====================
        # Vampire Coven
        # =====================
        HVampireCoven01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.4,
                StructureKillValue = 0.4,
            },
            SkillBonuses = {
                HVampireConversion01 = 1.0, HVampireConversion02 = 1.0, HVampireConversion03 = 1.0,
            },
            ShopDesires = {
                MinionDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HVampireCoven02 = {
            BasePriority = 10,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.4,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
                HVampireConversion01 = 1.0, HVampireConversion02 = 1.0, HVampireConversion03 = 1.0,
            },
            ShopDesires = {
                MinionDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HVampireCoven03 = {
            BasePriority = 13,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.4,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
                HVampireConversion01 = 1.0, HVampireConversion02 = 1.0, HVampireConversion03 = 1.0,
            },
            ShopDesires = {
                MinionDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HVampireArmyoftheNight = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.4,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
                HVampireConversion01 = 1.0, HVampireConversion02 = 1.0, HVampireConversion03 = 1.0,
                HVampireCoven01 = 1.0, HVampireCoven02 = 1.0, HVampireCoven03 = 1.0,
            },
        },

        # =====================
        # Vampire Bite
        # =====================
        HVampireBite01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                SpeedDesire = -0.1,
                HealthDesire = -0.2,
            },
        },
        HVampireBite02 = {
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
                SpeedDesire = -0.1,
                HealthDesire = -0.2,
            },
        },
        HVampireBite03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                SpeedDesire = -0.1,
                HealthDesire = -0.2,
            },
        },
        HVampireBite04 = {
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
                SpeedDesire = -0.1,
                HealthDesire = -0.2,
            },
        },

        # =====================
        # Bat Swarm
        # =====================
        HVampireBatSwarm01 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.3,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                HealthDesire = -0.2,
            },
        },
        HVampireBatSwarm02 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.3,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                HealthDesire = -0.2,
            },
        },
        HVampireBatSwarm03 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.3,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                HealthDesire = -0.2,
            },
        },

        # =====================
        # Mass Charm
        # =====================
        HVampireMassCharm01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.4,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.15,
                SpeedDesire = -0.1,
                HealthDesire = -0.15,
            },
        },
        HVampireMassCharm02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.4,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.15,
                SpeedDesire = -0.1,
                HealthDesire = -0.15,
            },
        },
        HVampireMassCharm03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.4,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.15,
                SpeedDesire = -0.1,
                HealthDesire = -0.15,
            },
        },
        HVampireMassCharm04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.4,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.15,
                SpeedDesire = -0.1,
                HealthDesire = -0.15,
            },
        },
        HVampireMuddle = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.4,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
        },

        # =====================
        # Mist
        # =====================
        HVampireMist01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.6,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.3,
                HealthDesire = -0.1,
            },
        },
        HVampireMist02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.6,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.3,
                HealthDesire = -0.1,
            },
        },
        HVampireMist03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.6,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.3,
                HealthDesire = -0.1,
            },
        },
        HVampireMist04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.6,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.3,
                HealthDesire = -0.1,
            },
        },
        HVampireBloodyHaze = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.6,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
        },

        # =====================
        # Poisoned Blood
        # =====================
        HVampirePoisonedBlood01 = {
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
        HVampirePoisonedBlood02 = {
            BasePriority = 14,
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
        HVampireVampiricAura01 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.4,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
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
