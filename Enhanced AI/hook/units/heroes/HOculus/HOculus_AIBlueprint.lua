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

UnitAITemplates['hoculus'] = {
    UnitId = 'hoculus',

    ActionSets = {
        MeleeHero = true,
        General = true,
    },
    SensorSets = {
    },

    GoapCreation = function(hero, planner)
    end,

SkillBuilds = {
        Chain_Blast = {
            'HOculusChainLightning01',	# 1
            'HOculusBlastOff01', 		# 2
            'HOculusKing01',     		# 3
            'HOculusChainLightning02', 	# 4
            'HOculusBlastOff02',        # 5
            'HOculusKing02',            # 6
            'HOculusChainLightning03', 	# 7
            'HOculusBlastOff03',        # 8
            'HOculusKing03',            # 9
            'HOculusChainLightning04',	# 10
            'HOculusBlastOff04',  		# 11
            'HOculusLightningBlast01',  # 12
            'HOculusLightningBlast02', 	# 13
            'HOculusLightningBlast03',	# 14
            'HOculusElectrocution',     # 15
            'GeneralStatsBuff01',   	# 16
            'GeneralStatsBuff02',       # 17
            'GeneralStatsBuff03',     	# 18
            'GeneralStatsBuff04',       # 19
            'GeneralStatsBuff05',		# 20
			FavorItems = {'AchievementHealth'},  #'AchievementMinionInvis',
			ItemWeights = {
# 0.26.51 Updated equipmenet build based on the new priorities set in version 0.26.51

					# Orb of Defiance
					# Use: Become invulnerable for 5 seconds. Cannot move, attack or use abilities.
					# +500 Health
					# +500 Armor
					Item_Consumable_150 = {
						Priority = 30,
					},
				--Hauberk of Life
				--+750 Hit Points
				--+20 Hit Points per second
				Item_Chest_040 = {
				Priority = 45,
				},			
			
			},
        },
    },
   


    SkillWeights = {

        # =====================
        # Chain Lightning
        # =====================
        HOculusChainLightning01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.5,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                MinionDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HOculusChainLightning02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.5,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                MinionDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HOculusChainLightning03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.5,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                MinionDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HOculusChainLightning04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.5,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                MinionDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HOculusElectrocution = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.5,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                MinionDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },

        # =====================
        # Lightning Blast
        # =====================
        HOculusLightningBlast01 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.5,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                MinionDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HOculusLightningBlast02 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.5,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                MinionDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HOculusLightningBlast03 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.5,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                MinionDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },

        # =====================
        # Blast off
        # =====================
        HOculusBlastOff01 = {
            BasePriority = 5,
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
        HOculusBlastOff02 = {
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
        HOculusBlastOff03 = {
            BasePriority = 11,
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
        HOculusBlastOff04 = {
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
        HOculusExplosiveEnd= {
            BasePriority = 19,
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
        # Ball Lightning
        # =====================
        HOculusBallLightning01 = {
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
                HealthDesire = -0.15,
            },
        },
        HOculusBallLightning02 = {
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
                HealthDesire = -0.15,
            },
        },
        HOculusBallLightning03 = {
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
                HealthDesire = -0.15,
            },
        },
        HOculusBallLightning04 = {
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
                HealthDesire = -0.15,
            },
        },
        HOculusExplosiveEnd = {
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
        # Brain Storm
        # =====================
        HOculusBrainStorm01 = {
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
            },
        },
        HOculusBrainStorm02 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.6,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.1,
            },
        },
        HOculusMentalAgility = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.6,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.1,
            },
        },

        # =====================
        # King!
        # =====================
        HOculusKing01 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.3,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                MinionDesire = -0.4,
                HealthDesire = -0.2,
            },
        },
        HOculusKing02 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.3,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                MinionDesire = -0.4,
                HealthDesire = -0.2,
            },
        },
        HOculusKing03 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.3,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                MinionDesire = -0.4,
                HealthDesire = -0.2,
            },
        },

        # =====================
        # Sacrifice
        # =====================
        HOculusSacrifice01 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.4,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                MinionDesire = -0.1,
                HealthDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HOculusSacrifice02 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.4,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                MinionDesire = -0.1,
                HealthDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HOculusSacrifice03 = {
            BasePriority = 18,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.4,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                MinionDesire = -0.1,
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
