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

UnitAITemplates['hrook'] = {
    UnitId = 'hrook',

    SensorSets = {
    },
    ActionSets = {
        MeleeHero = true,
    },

    GoapCreation = function(hero, planner)
        local godStrengthAddFunction = function(unit, abilityName)
            if(abilityName == 'HRookGodStrength01') then
                unit.WorldStateData.GruntKillBonus = unit.WorldStateData.GruntKillBonus - .2
            elseif(abilityName == 'HRookGodStrength02') then
                unit.WorldStateData.GruntKillBonus = unit.WorldStateData.GruntKillBonus - .4
            elseif(abilityName == 'HRookGodStrength03') then
                unit.WorldStateData.GruntKillBonus = unit.WorldStateData.GruntKillBonus - .6
            end
        end

        hero.Callbacks.OnAbilityAdded:Add(godStrengthAddFunction, hero)
    end,

    SkillBuilds = {
	
		#version .24 - added this Rook build, Revised .26
		# -- Hammer_Tower1 = {
			# -- 'HRookTower01',			# 1
            # -- 'HRookArchers01',		# 2
            # -- 'SAVE',    				# 3
            # -- 'HRookTower02',	'SAVE',	# 4
            # -- 'HRookBoulderRoll01','HRookTowerOfLight01',	# 5
            # -- 'HRookHammerSlam01',	# 6
            # -- 'HRookTower03',			# 7
            # -- 'HRookTrebuchet01',		# 8
            # -- 'HRookHammerSlam02', 	# 9
            # -- 'HRookTower04',			# 10
			# -- 'HRookBoulderRoll02',	# 11
            # -- 'HRookHammerSlam03',  	# 12
            # -- 'HRookHammerSlam04', 	# 13
			# -- 'HRookGodStrength01',	# 14
			# -- 'HRookBoulderRoll03', 	# 15
            # -- 'HRookGodStrength02', 	# 16
            # -- 'HRookGodStrength03', 	# 17
            # -- 'HRookDizzyingForce', 	# 18
            # -- 'StatsBuff01', 			# 19
            # -- 'StatsBuff02',         	# 20
			
			# -- FavorItems = {'AchievementRefreshCooldowns'}, #'AchievementRunSpeed', 'AchievementHealth'
			# -- ItemWeights = {	
					# -- # Wand of Speed
					# -- # Use: Increase Base Run Speed by 30%.
					# -- Item_Consumable_050 = {
						# -- Priority = 20,
					# -- },	
					
					# -- # Narmoth's Ring
					# -- # +15% Life Steal
					# -- # When struck by melee attacks, the wearer reflects 90 damage back to the attacker.
					# -- Item_Ring_050 = {
						# -- Priority = 40,
					# -- },
	
					
					# -- # Orb of Defiance
					# -- # Use: Become invulnerable for 5 seconds. Cannot move, attack or use abilities.
					# -- # +500 Health
					# -- # +500 Armor
					# -- Item_Consumable_150 = {
						# -- Priority = 30,
					# -- },
					
					# -- # Bulwark of the Ages
					# -- # +2500 Armor
					# -- # All damage reduced by 25%.
					# -- Item_Artifact_120 = {	
						# -- Priority = 5,
					# -- },	
			# -- },
		# -- },				


# 0.27.05 modified the hammer tower build so that hammer is delayed a little to save mana
		Hammer_Tower = {
		'HRookTower01',								# 1
		'HRookArchers01', 							# 2			 
		'SAVE',    									# 3
		'HRookHammerSlam01', 'HRookTower02',				# 4
		'HRookTowerOfLight01',							# 5
		'HRookBoulderRoll01',							# 6
		'HRookHammerSlam02',							# 7			 
		'HRookHammerSlam03',							# 8
		'HRookTrebuchet01',  							# 9
		'HRookBoulderRoll02',							# 10
		'HRookHammerSlam04',							# 11
		'HRookTower03',								# 12
		'SAVE',  									# 13
		'SAVE2', 									# 14
		'HRookBoulderRoll03',	'HRookDizzyingForce', 'HRookPoison',	# 15			 
		'HRookTower04',								# 16
		'HRookGodStrength01', 							# 17
		'HRookGodStrength02', 							# 18
		'HRookGodStrength03', 							# 19
		'StatsBuff01',         							# 20
# 0.26.55 changed favor item to Blood of the Fallen			
			 FavorItems = {'AchievementHealth'}, 
			 ItemWeights = {	
					# Wand of Speed
					# Use: Increase Base Run Speed by 30%.
					Item_Consumable_050 = {
						Priority = 20,
					},	
# 0.27.05 added plenor to build
			--Plenor Battlecrown
			--+1000 Mana
			---25% to ability cooldowns
				Item_Helm_030 = {
				Priority = 50,
				},
					# Orb of Defiance
					# Use: Become invulnerable for 5 seconds. Cannot move, attack or use abilities.
					# +500 Health
					# +500 Armor
					Item_Consumable_150 = {
						Priority = 30,
					},
					
					# Bulwark of the Ages
					# +2500 Armor
					# All damage reduced by 25%.
					Item_Artifact_120 = {	
						Priority = 120,
					},	
			},
		},		
		
		
		
		
		

# 0.27.05 disabled existing hammer tower build 	
--[[
--# 0.26.55 Re-enabled hammer tower build	
--# 0.26.48 new build added but commented out to focus on hammerslam more
		Hammer_Tower = {
			 'HRookHammerSlam01',							# 1
             'HRookTower01',								# 2
             'SAVE',    									# 3
             'HRookTower02',	'HRookHammerSlam02',		# 4
             'HRookBoulderRoll01',							# 5
             'HRookArchers01',								# 6
             'HRookHammerSlam03',							# 7
             'HRookTower03',								# 8
             'SAVE', 										# 9
             'HRookBoulderRoll02',	'HRookHammerSlam04',	# 10
			 'HRookTowerOfLight01',							# 11
             'HRookTrebuchet01',  							# 12
             'HRookGodStrength01',						 	# 13
			 'SAVE',										# 14
			 'HRookBoulderRoll03',	'HRookDizzyingForce',	# 15
             'HRookPoison', 								# 16
             'HRookGodStrength02', 							# 17
             'HRookGodStrength03', 							# 18
             'StatsBuff01', 								# 19
             'StatsBuff02',         						# 20
# 0.26.55 changed favor item to Blood of the Fallen			
			 FavorItems = {'AchievementHealth'}, 
			 ItemWeights = {	
					# Wand of Speed
					# Use: Increase Base Run Speed by 30%.
					Item_Consumable_050 = {
						Priority = 20,
					},	
# 0.26.51 Updated equipmenet build based on the new priorities set in version 0.26.51
					
					# Orb of Defiance
					# Use: Become invulnerable for 5 seconds. Cannot move, attack or use abilities.
					# +500 Health
					# +500 Armor
					Item_Consumable_150 = {
						Priority = 30,
					},
					
					# Bulwark of the Ages
					# +2500 Armor
					# All damage reduced by 25%.
					Item_Artifact_120 = {	
						Priority = 120,
					},	
			},
		},		
--]]		
		
# 0.27.05 disabled build for now
--[[		
		Transfer_Tower = {
			'HRookTower01',			# 1
            'HRookStructuralTransfer01',	# 2
            'HRookArchers01', 		# 3
            'HRookTower02',			# 4
            'HRookBoulderRoll01',	# 5
            'HRookTowerOfLight01',	# 6
            'HRookTower03',			# 7
            'HRookTrebuchet01',		# 8
            'HRookStructuralTransfer02', 	# 9
            'HRookTower04',			# 10
			'HRookBoulderRoll02',	# 11
            'HRookStructuralTransfer03',  	# 12
            'HRookStructuralTransfer04', 	# 13
			'SAVE',					# 14
			'HRookBoulderRoll03','HRookEnergizer', 	# 15
            'HRookPoison', 			# 16
            'HRookGodStrength01', 	# 17
            'StatsBuff01', 			# 18
            'StatsBuff02', 			# 19
            'StatsBuff03',         	# 20
# 0.26.48 - Changed Rook's favor item to blood of the fallen
			FavorItems = {'AchievementHealth'}, 		
--			FavorItems = {'AchievementRefreshCooldowns'}, #'AchievementRunSpeed', 'AchievementHealth'
			ItemWeights = {	
					# Wand of Speed
					# Use: Increase Base Run Speed by 30%.
					Item_Consumable_050 = {
						Priority = 20,
					},	
# 0.26.51 Updated equipmenet build based on the new priorities set in version 0.26.51
					
					# Orb of Defiance
					# Use: Become invulnerable for 5 seconds. Cannot move, attack or use abilities.
					# +500 Health
					# +500 Armor
					Item_Consumable_150 = {
						Priority = 30,
					},
					
					# Bulwark of the Ages
					# +2500 Armor
					# All damage reduced by 25%.
					Item_Artifact_120 = {	
						Priority = 120,
					},	
			},
		},				
--]]		
	# -- Hammer_Slam  = {
			# -- 'HRookHammerSlam01',		# 1
            # -- 'HRookArchers01',			# 2
            # -- 'SAVE',    					# 3
            # -- 'HRookHammerSlam02', 'SAVE',# 4
            # -- 'HRookBoulderRoll01','HRookTowerOfLight01',	# 5
            # -- 'HRookGodStrength01',		# 6
            # -- 'HRookHammerSlam03',		# 7
            # -- 'HRookTrebuchet01',			# 8
            # -- 'SAVE', 					# 9
            # -- 'HRookBoulderRoll02', 'HRookHammerSlam04', # 10
			# -- 'HRookGodStrength02',	# 11
            # -- 'SAVE',  	# 12
            # -- 'SAVE2', 	# 13
			# -- 'SAVE3',	# 14
			# -- 'HRookBoulderRoll03', 'HRookGodStrength03','HRookPoison', 'HRookDizzyingForce',		# 15
            # -- 'StatsBuff01', 				# 16
            # -- 'StatsBuff02', 				# 17
            # -- 'StatsBuff03', 				# 18
            # -- 'StatsBuff04', 				# 19
            # -- 'StatsBuff05',         		# 20
			
			# -- FavorItems = {'AchievementHealth'}, #'AchievementRunSpeed'
			# -- ItemWeights = {	
					# -- # Wand of Speed
					# -- # Use: Increase Base Run Speed by 30%.
					# -- Item_Consumable_050 = {
						# -- Priority = 20,
					# -- },	
					
					# -- # Narmoth's Ring
					# -- # +15% Life Steal
					# -- # When struck by melee attacks, the wearer reflects 90 damage back to the attacker.
					# -- Item_Ring_050 = {
						# -- Priority = 40,
					# -- },
	
					
					# -- # Orb of Defiance
					# -- # Use: Become invulnerable for 5 seconds. Cannot move, attack or use abilities.
					# -- # +500 Health
					# -- # +500 Armor
					# -- Item_Consumable_150 = {
						# -- Priority = 30,
					# -- },
					
					# -- # Bulwark of the Ages
					# -- # +2500 Armor
					# -- # All damage reduced by 25%.
					# -- Item_Artifact_120 = {	
						# -- Priority = 5,
					# -- },	
			# -- },
		# -- },		
		

    },

    SkillWeights = {
        # =====================
        # Hammer Slam
        # =====================
        HRookHammerSlam01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.2,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                SpeedDesire = -0.1,
                HealthDesire = -0.2,
            },
        },
        HRookHammerSlam02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.2,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                SpeedDesire = -0.1,
                HealthDesire = -0.2,
            },
        },
        HRookHammerSlam03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.2,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                SpeedDesire = -0.1,
                HealthDesire = -0.2,
            },
        },
        HRookHammerSlam04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.2,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                SpeedDesire = -0.1,
                HealthDesire = -0.2,
            },
        },
        HRookDizzyingForce = {
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
        # Structure Transfer
        # =====================
        HRookStructuralTransfer01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.2,
                StructureKillValue = 0.6,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                SpeedDesire = -0.1,
                HealthDesire = -0.1,
            },
        },
        HRookStructuralTransfer02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.2,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                SpeedDesire = -0.1,
                HealthDesire = -0.1,
            },
        },
        HRookStructuralTransfer03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.2,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                SpeedDesire = -0.1,
                HealthDesire = -0.1,
            },
        },
        HRookStructuralTransfer04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.2,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                SpeedDesire = -0.1,
                HealthDesire = -0.1,
            },
        },
        HRookEnergizer = {
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
        # Tower Creation
        # =====================
        HRookTower01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.5,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.1,
            },
        },
        HRookTower02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.5,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.1,
            },
        },
        HRookTower03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.5,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.1,
            },
        },
        HRookTower04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.5,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.1,
            },
        },

        # =====================
        # God Strength
        # =====================
        HRookGodStrength01 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                SpeedDesire = -0.1,
                HealthDesire = -0.1,
            },
        },
        HRookGodStrength02 = {
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
                SpeedDesire = -0.1,
                HealthDesire = -0.1,
            },
        },
        HRookGodStrength03 = {
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
                SpeedDesire = -0.1,
                HealthDesire = -0.1,
            },
        },

        # =====================
        # Shoulder Upgrades
        # =====================
        HRookArchers01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.5,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                SpeedDesire = -0.1,
                HealthDesire = -0.1,
            },
        },
        HRookTowerOfLight01 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.3,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                SpeedDesire = -0.1,
                HealthDesire = -0.1,
            },
        },
        HRookTrebuchet01 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.2,
                StructureKillValue = 0.6,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                SpeedDesire = -0.1,
                HealthDesire = -0.1,
            },
        },
        HRookPoison = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.2,
                StructureKillValue = 0.6,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                SpeedDesire = -0.1,
                HealthDesire = -0.1,
            },
        },

        # =====================
        # Rook Roll
        # =====================
        HRookBoulderRoll01 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.7,
                PushValue = 0.2,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                SpeedDesire = -0.1,
            },
        },
        HRookBoulderRoll02 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.7,
                PushValue = 0.2,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                SpeedDesire = -0.1,
            },
        },
        HRookBoulderRoll03 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.7,
                PushValue = 0.2,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.2,
                SpeedDesire = -0.1,
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
                PrimaryWeaponDesire = -0.2,
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
                PrimaryWeaponDesire = -0.2,
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
                PrimaryWeaponDesire = -0.2,
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
                PrimaryWeaponDesire = -0.2,
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
                PrimaryWeaponDesire = -0.2,
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
                PrimaryWeaponDesire = -0.2,
            },
        },
    },
}