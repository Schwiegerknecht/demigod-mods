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

UnitAITemplates['hqueen'] = {
    UnitId = 'hqueen',

    ActionSets = {
        RangeHero = true,
        General = true,
    },
    SensorSets = {
        RangeHero = true,
    },

    GoapCreation = function(hero, planner)
        local packupFunction = function(unit, buffName, instigator)
            if(buffName == 'HQueenPackedBuffs') then
                unit.WorldStateData.Packed = true
            end
        end

        local unpackFunction = function(unit, buffName, instigator)
            if(buffName == 'HQueenPackedBuffs') then
                unit.WorldStateData.Packed = false
            end
        end

        hero.WorldStateData.Packed = false

        hero.Callbacks.OnBuffActivate:Add(packupFunction, hero)
        hero.Callbacks.OnBuffDeactivate:Add(unpackFunction, hero)
    end,

	
# Removed all builds for pacov test 0.2636 -  will likely add back shield_spike build
# There will likely only be 2 builds when I'm done - shield_spike and pacov_dmg_build
    SkillBuilds = {

	Spike_Shambler = {
	'HQueenShambler01',			# 1
	'HQueenGroundSpikes01',		# 2
	'GeneralStatsBuff01',			# 3
	'HQueenGroundSpikes02',		# 4
	'HQueenSpikeWave01',   		# 5
	'HQueenShambler02',			# 6
	'HQueenGroundSpikes03',		# 7
	'HQueenShambler03',  			# 8
	'HQueenCompost01',  			# 9
	'HQueenGroundSpikes04',		# 10
	'HQueenSpikeWave02',			# 11
	'HQueenEntourage01',			# 12
	'HQueenEntourage02',			# 13
	'HQueenEntourage03',			# 14
	'HQueenTribute',  			# 15
	'HQueenSpikeWave03',			# 16
	'GeneralStatsBuff02', 			# 17
	'GeneralStatsBuff03',  			# 18
	'GeneralStatsBuff04',  			# 19
	'GeneralStatsBuff05',			# 20
	FavorItems = {'AchievementHealth'}, #'AchievementMinionInvis',
			ItemWeights = {
# 0.26.51 Updated equipmenet build based on the new priorities set in version 0.26.51
			--Hungarling's Crown
			--Reduces the cost of abilities for you and all nearby Demigods by 35%.
				Item_Helm_060 = {
				Priority = 100,
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
	Spike_Shield = {
	'HQueenBrambleShield01',		# 1
	'HQueenGroundSpikes01',		# 2
	'SAVE',					# 3
	'HQueenGroundSpikes02','HQueenBrambleShield02',	# 4
	'HQueenSpikeWave01',   		# 5
	'SAVE',					# 6
	'HQueenGroundSpikes03','HQueenBrambleShield03',	# 7
	'SAVE',  					# 8
	'SAVE2',  					# 9
	'HQueenGroundSpikes04','HQueenBrambleShield04','HQueenSpikeWave02',   	# 10
	'GeneralStatsBuff01',			# 11
	'GeneralStatsBuff02',			# 12
	'GeneralStatsBuff03',			# 13
	'SAVE',					# 14
	'HQueenSpikeWave03','HQueenGoddessofThorns',	# 15
	'GeneralStatsBuff04',			# 16
	'GeneralStatsBuff05', 			# 17
	'GeneralStatsBuff06',  			# 18
	'HQueenShambler01',  			# 19
	'HQueenShambler02',			# 20
	FavorItems = {'AchievementHealth'}, #'AchievementMinionInvis',
			ItemWeights = {
# 0.26.51 Updated equipmenet build based on the new priorities set in version 0.26.51
			--Hungarling's Crown
			--Reduces the cost of abilities for you and all nearby Demigods by 35%.
				Item_Helm_060 = {
				Priority = 100,
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
},
	
# removed by pacov
--[[
	shield_spike = {
            'HQueenBrambleShield01',	# 1
            'HQueenGroundSpikes01',		# 2
            'SAVE',          			# 3
            'HQueenBrambleShield02','HQueenGroundSpikes02',	# 4
            'HQueenSpikeWave01',   		# 5
            'SAVE',  					# 6
            'HQueenBrambleShield03','HQueenGroundSpikes03',	# 7
            'SAVE',        				# 8
            'SAVE2',          			# 9
            'HQueenBrambleShield04','HQueenGroundSpikes04','HQueenSpikeWave02',	# 10
            'HQueenShambler01',  		# 11
            'HQueenShambler02',  		# 12
            'HQueenConsumeShambler01',	# 13
            'SAVE',       				# 14
            'HQueenGoddessofThorns','HQueenSpikeWave03',  # 15
            'HQueenConsumeShambler02',	# 16
            'HQueenShambler03',  		# 17
            'HQueenConsumeShambler03',	# 18
            'HQueenCompost01',			# 19
            'HQueenCompost02',      	# 20
			FavorItems = {'AchievementHealth'}, #'AchievementMinionInvis',
			ItemWeights = {
	
					# Orb of Defiance
					# Use: Become invulnerable for 5 seconds. Cannot move, attack or use abilities.
					# +500 Health
					# +500 Armor
					Item_Consumable_150 = {
						Priority = 30,
					},
			},
        },
	
	
		shield_spike = {
            'HQueenBrambleShield01',	# 1
            'HQueenGroundSpikes01',		# 2
            'SAVE',          			# 3
            'HQueenBrambleShield02','HQueenGroundSpikes02',	# 4
            'HQueenSpikeWave01',   		# 5
            'SAVE',  					# 6
            'HQueenBrambleShield03','HQueenGroundSpikes03',	# 7
            'SAVE',        				# 8
            'SAVE2',          			# 9
            'HQueenBrambleShield04','HQueenGroundSpikes04','HQueenSpikeWave02',	# 10
            'HQueenShambler01',  		# 11
            'HQueenShambler02',  		# 12
            'HQueenConsumeShambler01',	# 13
            'SAVE',       				# 14
            'HQueenGoddessofThorns','HQueenSpikeWave03',  # 15
            'HQueenConsumeShambler02',	# 16
            'HQueenShambler03',  		# 17
            'HQueenConsumeShambler03',	# 18
            'HQueenCompost01',			# 19
            'HQueenCompost02',      	# 20
			FavorItems = {'AchievementHealth'}, #'AchievementMinionInvis',
			ItemWeights = {
	
					# Orb of Defiance
					# Use: Become invulnerable for 5 seconds. Cannot move, attack or use abilities.
					# +500 Health
					# +500 Armor
					Item_Consumable_150 = {
						Priority = 30,
					},
			},
        },

		# -- queen_minion = {
            # -- 'HQueenBrambleShield01',# 1
            # -- 'HQueenShambler01',		# 2
            # -- 'HQueenEntourage01',	# 3
            # -- 'HQueenBrambleShield02',# 4
            # -- 'HQueenEntourage02',   	# 5
            # -- 'HQueenShambler02',  	# 6
            # -- 'HQueenConsumeShambler01',		# 7
            # -- 'HQueenEntourage03',    # 8
            # -- 'HQueenBrambleShield03',# 9
            # -- 'HQueenBrambleShield04', # 10
            # -- 'HQueenShambler03',  	# 11
            # -- 'HQueenConsumeShambler02',  	# 12
            # -- 'HQueenConsumeShambler03', 	# 13
            # -- 'HQueenCompost01', 	# 14
            # -- 'HQueenTribute', 		# 15
            # -- 'HQueenCompost02',  	# 16
            # -- 'HQueenCompost03',  	# 17
            # -- 'GeneralStatsBuff01',		# 18
            # -- 'GeneralStatsBuff02',		# 19
            # -- 'GeneralStatsBuff03',      # 20
			# -- FavorItems = {'AchievementHealth'}, #'AchievementMinionInvis',
			# -- ItemWeights = {
				
					# -- # Orb of Defiance
					# -- # Use: Become invulnerable for 5 seconds. Cannot move, attack or use abilities.
					# -- # +500 Health
					# -- # +500 Armor
					# -- Item_Consumable_150 = {
						# -- Priority = 30,
					# -- },
			# -- },
        # -- },

    },
--]]

    SkillWeights = {
        # ----------------------------------------------------------------------
        # UNPACKED
        # ----------------------------------------------------------------------

        # --------------------
        # Ground Spikes
        # --------------------
        HQueenGroundSpikes01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.6,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.15,
                HealthDesire = -0.1,
                SpeedDesire = -0.15,
            },
        },
        HQueenGroundSpikes02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.6,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.15,
                HealthDesire = -0.1,
                SpeedDesire = -0.15,
            },
        },
        HQueenGroundSpikes03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.6,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.15,
                HealthDesire = -0.1,
                SpeedDesire = -0.15,
            },
        },
        HQueenGroundSpikes04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.6,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.15,
                HealthDesire = -0.1,
                SpeedDesire = -0.15,
            },
        },
        HQueenGoddessofThorns = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.6,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
        },

        # --------------------
        # Spike Wave
        # --------------------
        HQueenSpikeWave01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
            },
        },
        HQueenSpikeWave02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
            },
        },
        HQueenSpikeWave03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
            },
        },

        # --------------------
        # Uproot
        # --------------------
        HQueenUproot01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.1,
                PushValue = 0.1,
                StructureKillValue = 0.8,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.1,
                SpeedDesire = -0.1,
            },
        },
        HQueenUproot02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.1,
                PushValue = 0.1,
                StructureKillValue = 0.8,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.1,
                SpeedDesire = -0.1,
            },
        },
        HQueenUproot03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.1,
                PushValue = 0.1,
                StructureKillValue = 0.8,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.1,
                SpeedDesire = -0.1,
            },
        },
        HQueenUproot04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.1,
                PushValue = 0.1,
                StructureKillValue = 0.8,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.1,
                SpeedDesire = -0.1,
            },
        },
        HQueenViolentSiege = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.1,
                PushValue = 0.1,
                StructureKillValue = 0.8,
            },
            SkillBonuses = {
            },
        },

        # ----------------------------------------------------------------------
        # PACKED
        # ----------------------------------------------------------------------

        # --------------------
        # Summon Shambler
        # --------------------
        HQueenShambler01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.3,
                StructureKillValue = 0.3
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                MinionDesire = -0.2,
            },
        },
        HQueenShambler02 = {
            BasePriority = 8,
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
        HQueenShambler03 = {
            BasePriority = 11,
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
        HQueenShambler04 = {
            BasePriority = 14,
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

        # --------------------
        # Mulch Shambler
        # --------------------
        HQueenConsumeShambler01 = {
            BasePriority = 4,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.2,
                StructureKillValue = 0.4,
            },
            SkillBonuses = {
                HQueenShambler01 = 1.0, HQueenShambler02 = 1.0, HQueenShambler03 = 1.0, HQueenShambler04 = 1.0,
            },
            ShopDesires = {
                ManaDesire = -0.2,
                MinionDesire = -0.1,
            },
        },
        HQueenConsumeShambler02 = {
            BasePriority = 7,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.2,
                StructureKillValue = 0.4,
            },
            SkillBonuses = {
                HQueenShambler02 = 1.0, HQueenShambler03 = 1.0, HQueenShambler04 = 1.0,
            },
            ShopDesires = {
                ManaDesire = -0.2,
                MinionDesire = -0.1,
            },
        },
        HQueenConsumeShambler03 = {
            BasePriority = 10,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.2,
                StructureKillValue = 0.4,
            },
            SkillBonuses = {
                HQueenShambler03 = 1.0, HQueenShambler04 = 1.0,
            },
            ShopDesires = {
                ManaDesire = -0.2,
                MinionDesire = -0.1,
            },
        },

        # --------------------
        # Bramble Shield
        # --------------------
        HQueenBrambleShield01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.3,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.1,
            },
        },
        HQueenBrambleShield02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.3,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.1,
            },
        },
        HQueenBrambleShield03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.3,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.1,
            },
        },
        HQueenBrambleShield04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.3,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.1,
            },
        },

        # ----------------------------------------------------------------------
        # PASSIVE
        # ----------------------------------------------------------------------

        # --------------------
        # Entourage
        # --------------------
        HQueenEntourage01 = {
            BasePriority = 4,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.2,
                StructureKillValue = 0.4,
            },
            SkillBonuses = {
                HQueenShambler01 = 1.0, HQueenShambler02 = 1.0, HQueenShambler03 = 1.0,
            },
            ShopDesires = {
                MinionDesire = -0.1,
            },
        },
        HQueenEntourage02 = {
            BasePriority = 7,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.2,
                StructureKillValue = 0.4,
            },
            SkillBonuses = {
                HQueenShambler02 = 1.0, HQueenShambler03 = 4.0,
            },
            ShopDesires = {
                MinionDesire = -0.1,
            },
        },
        HQueenEntourage03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.2,
                StructureKillValue = 0.4,
            },
            SkillBonuses = {
                HQueenShambler03 = 3.0,
            },
            ShopDesires = {
                MinionDesire = -0.1,
            },
        },
        HQueenTribute = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.2,
                StructureKillValue = 0.4,
            },
            ShopDesires = {
                MinionDesire = -0.1,
            },
        },

        # --------------------
        # Compost
        # --------------------
        HQueenCompost01 = {
            BasePriority = 4,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.2,
                StructureKillValue = 0.5,
            },
            SkillBonuses = {
                HQueenUproot01 = 1.0, HQueenUproot02 = 1.0, HQueenUproot03 = 1.0, HQueenUproot04 = 1.0, HQueenViolentSiege = 1.0,
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                SpeedDesire = -0.1,
            },
        },
        HQueenCompost02 = {
            BasePriority = 7,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.2,
                StructureKillValue = 0.5,
            },
            SkillBonuses = {
                HQueenUproot02 = 1.0, HQueenUproot03 = 1.0, HQueenUproot04 = 1.0, HQueenViolentSiege = 1.0,
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                SpeedDesire = -0.1,
            },
        },
        HQueenCompost03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.2,
                StructureKillValue = 0.5,
            },
            SkillBonuses = {
                HQueenUproot03 = 1.0, HQueenUproot04 = 1.0, HQueenViolentSiege = 1.0,
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                SpeedDesire = -0.1,
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
                MinionDesire = -0.05,
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
                MinionDesire = -0.05,
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
                MinionDesire = -0.05,
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
                MinionDesire = -0.05,
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
                MinionDesire = -0.05,
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
                MinionDesire = -0.05,
            },
        },
    },

}