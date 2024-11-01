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

UnitAITemplates['hoak'] = {
    UnitId = 'hoak',

    ActionSets = {
        MeleeHero = true,
        General = true,
    },
    SensorSets = {
    },

    GoapCreation = function(hero, planner)
        local lastStandFunction = function(unit, buffName, instigator)
            if buffName != 'HOAKLastStandTransition' then
                return
            end

            # Set goals for assassinate and push and kill structures higher
            unit.GOAP:UpdateGoal( 'KillHero', 'LastStandMode', 25 )
            unit.GOAP:UpdateGoal( 'KillUnits', 'LastStandMode', 25 )
            unit.GOAP:UpdateGoal( 'KillStructures', 'LastStandMode', 50 )
            unit.GOAP:UpdateGoal( 'KillSquadTarget', 'LastStandMode', 25 )

            # Lower goals for health and survival to -50
            unit.GOAP:UpdateGoal( 'Health', 'LastStandMode', -50 )
            unit.GOAP:UpdateGoal( 'Survival', 'LastStandMode', -50 )
            unit.GOAP:UpdateGoal( 'PurchaseItems', 'LastStandMode', -50 )

            # Flag some master sets as always valid
            local overrideGoals = {
                'Assassinate',
                'Attack',
                'DestroyStructures',
            }
            unit.GOAP:AddOverrideMasterSet( overrideGoals )

            # Request a new plan
            unit.GOAP:SelectGoal(true)
        end

        hero.Callbacks.OnBuffDeactivate:Add(lastStandFunction, hero)
    end,

	
	
#Custom Oak Builds	
	
SkillBuilds = {

# 0.26.41 Removed all oak builds and creating 1 from scratch
	Pen_Shield_Support = {
		'HOAKPenitence01', 				# 1
		'HOAKDivineJustice01',  			# 2
		'HOAKShield01',  					# 3 
		'HOAKPenitence02',		 		# 4
		'HOAKSurgeofFaith01',   			# 5
		'HOAKShield02',					# 6
		'HOAKShield03', 					# 7
		'HOAKPenitence03',				# 8
		'HOAKLastStand01',  				# 9
		'HOAKPenitence04',  				# 10
		'HOAKSurgeofFaith02',				# 11
		'HOAKDivineJustice02',  			# 12
		'HOAKDivineJustice03',  			# 13
		'SAVE',  						# 14
		'HOakRally','HOAKSurgeofFaith03',  		# 15
		'HOAKLastStand02',  				# 16
	        'HOAKShield04',  					# 17
		'HOakPurity',					# 18
		'GeneralStatsBuff01',				# 19			
		'GeneralStatsBuff02',				# 20			
			FavorItems = {'AchievementHealth'}, 
			ItemWeights = {
# 0.26.51 Updated equipmenet build based on the new priorities set in version 0.26.51				
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
				# Ashkandor
				# +30% Life Steal
				# +175 Weapon Damage
				Item_Artifact_100 = {
				Priority = 0,
				},
			},
		},
		--Added spirts for late DPS from soul power
		Pen_Shield_DPS = {
		'HOAKPenitence01', 				# 1
		'HOAKDivineJustice01',  			# 2
		'HOAKShield01',  					# 3 
		'HOAKPenitence02',		 		# 4
		'HOAKSurgeofFaith01',   			# 5
		'HOAKShield02',					# 6
		'HOAKShield03', 					# 7
		'HOAKPenitence03',				# 8
		'SAVE',  						# 9
		'HOAKPenitence04','HOAKSurgeofFaith02', 	# 10
		'HOAKRaiseDeadWard01',			# 11
		'HOAKSoulPower01',  				# 12
		'HOAKRaiseDeadWard02',  			# 13
		'HOAKRaiseDeadWard03',  			# 14
		'HOAKRaiseDeadWard04', 			# 15
		'HHOAKSurgeofFaith03',  			# 16
	        'HOAKSoulPower02',  				# 17
		'HOAKSoulPower03',				# 18
		'GeneralStatsBuff01',				# 19			
		'GeneralStatsBuff02',				# 20			
			FavorItems = {'AchievementHealth'}, 
			ItemWeights = {
# 0.26.51 Updated equipmenet build based on the new priorities set in version 0.26.51				
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


#0.26.41 removed by pacov
--[[
	Minion_Shield = {
            'HOAKPenitence01', 		# 1
            'HOAKRaiseDeadWard01',  # 2
            'HOAKShield01',  		# 3 
            'HOAKRaiseDeadWard02',  # 4
            'HOAKSurgeofFaith01',   # 5
            'HOAKDivineJustice01',	# 6
            'HOAKRaiseDeadWard03',	# 7
            'HOAKShield02',			# 8
            'SAVE',  				# 9
            'HOAKSurgeofFaith02','HOAKRaiseDeadWard04',  # 10
            'HOAKShield03',			# 11
            'HOAKSoulPower01',  	# 12
            'GeneralStatsBuff01',	# 13
            'SAVE',  				# 14
            'HOakSoulFrenzy', 'HOAKSurgeofFaith03',   # 15
            'GeneralStatsBuff02',	# 16
            'GeneralStatsBuff03',	# 17
            'GeneralStatsBuff04',	# 18
            'GeneralStatsBuff05',	# 19
            'GeneralStatsBuff06',	# 20
			FavorItems = {'AchievementHealth'}, #'AchievementMinionInvis',
			ItemWeights = {
				
				# Gloves of Fell-Darkur
				# +75 Weapon Damage
				# +10% Attack Speed
				# 20% chance on hit to unleash a fiery blast, dealing 175 damage.
				Item_Glove_060 = {
					Priority = 35,
				},				

				# Orb of Defiance
				# Use: Become invulnerable for 5 seconds. Cannot move, attack or use abilities.
				# +500 Health
				# +500 Armor
				Item_Consumable_150 = {
					Priority = 30,
				},

				
				# Girdle of the Giants
				# +2000 Hit Points
				# 40% chance on hit to perform a cleaving attack, damaging nearby enemies.
				Item_Artifact_090 = {
					riority = 15,
				},
				
				# Ashkandor
				# +30% Life Steal
				# +175 Weapon Damage
				Item_Artifact_100 = {
				Priority = 20,
				},
			},
		},
	
	Penitence_Shield = {
            'HOAKPenitence01', 		# 1
            'HOAKDivineJustice01',  # 2
            'HOAKShield01',  		# 3 
            'HOAKPenitence02',  	# 4
            'HOAKSurgeofFaith01',   # 5
            'HOAKShield02',			# 6
            'HOAKPenitence03',		# 7
            'HOAKShield03',			# 8
            'SAVE',  				# 9
            'HOAKSurgeofFaith02','HOAKPenitence04',  # 10
            'HOAKRaiseDeadWard01',	# 11
            'HOAKSoulPower01',		# 12
            'HOAKRaiseDeadWard02',	# 13
            'HOAKRaiseDeadWard03',	# 14
            'HOAKSurgeofFaith03',   # 15
            'HOAKRaiseDeadWard04',	# 16
            'GeneralStatsBuff01',	# 17
            'GeneralStatsBuff02',	# 18
            'GeneralStatsBuff03',	# 19
            'GeneralStatsBuff04',	# 20
			FavorItems = {'AchievementHealth'}, #'AchievementMinionInvis',
			ItemWeights = {
				
				# Gloves of Fell-Darkur
				# +75 Weapon Damage
				# +10% Attack Speed
				# 20% chance on hit to unleash a fiery blast, dealing 175 damage.
				Item_Glove_060 = {
					Priority = 35,
				},				

				# Orb of Defiance
				# Use: Become invulnerable for 5 seconds. Cannot move, attack or use abilities.
				# +500 Health
				# +500 Armor
				Item_Consumable_150 = {
					Priority = 30,
				},

				
				# Girdle of the Giants
				# +2000 Hit Points
				# 40% chance on hit to perform a cleaving attack, damaging nearby enemies.
				Item_Artifact_090 = {
					riority = 15,
				},
				
				# Ashkandor
				# +30% Life Steal
				# +175 Weapon Damage
				Item_Artifact_100 = {
				Priority = 20,
				},
			},
		},
	
	},	
--]]		

    SkillWeights = {

        # =====================
        # Shield
        # =====================
        HOAKShield01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HOAKShield02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HOAKShield03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HOAKShield04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HOakPurity = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
        },

        # =====================
        # Penitence
        # =====================
        HOAKPenitence01 = {
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
                HealthDesire = -0.1,
                PrimaryWeaponDesire = -0.1,
            },
        },
        HOAKPenitence02 = {
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
                HealthDesire = -0.1,
                PrimaryWeaponDesire = -0.1,
            },
        },
        HOAKPenitence03 = {
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
                HealthDesire = -0.1,
                PrimaryWeaponDesire = -0.1,
            },
        },
        HOAKPenitence04 = {
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
                HealthDesire = -0.1,
                PrimaryWeaponDesire = -0.1,
            },
        },

        # =====================
        # Raise Dead Ward
        # =====================
        HOAKRaiseDeadWard01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.4,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
                HOAKSoulPower01 = 0.5, HOAKSoulPower02 = 0.5, HOAKSoulPower03 = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.1,
                MinionDesire = -0.2,
            },
        },
        HOAKRaiseDeadWard02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.4,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
                HOAKSoulPower01 = 0.5, HOAKSoulPower02 = 0.5, HOAKSoulPower03 = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.1,
                MinionDesire = -0.2,
            },
        },
        HOAKRaiseDeadWard03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.4,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
                HOAKSoulPower01 = 0.5, HOAKSoulPower02 = 0.5, HOAKSoulPower03 = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.1,
                MinionDesire = -0.2,
            },
        },
        HOAKRaiseDeadWard04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.4,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
                HOAKSoulPower01 = 0.5, HOAKSoulPower02 = 0.5, HOAKSoulPower03 = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.1,
                MinionDesire = -0.2,
            },
        },
        HOakSoulFrenzy = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.4,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
                HOAKSoulPower01 = 0.5, HOAKSoulPower02 = 0.5, HOAKSoulPower03 = 0.5,
            },
        },

        # =====================
        # Surge of Faith
        # =====================
        HOAKSurgeofFaith01 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                MinionDesire = -0.1,
                HealthDesire = -0.2,
            },
        },
        HOAKSurgeofFaith02 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                MinionDesire = -0.1,
                HealthDesire = -0.2,
            },
        },
        HOAKSurgeofFaith03 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
                MinionDesire = -0.1,
                HealthDesire = -0.2,
            },
        },

        # =====================
        # Last Stand
        # =====================
        HOAKLastStand01 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.3,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HOAKSoulPower01 = 0.5, HOAKSoulPower02 = 0.5, HOAKSoulPower03 = 0.5,
            },
            ShopDesires = {
                SpeedDesire = -0.3,
                PrimaryWeaponDesire = -0.5,
            },
        },
        HOAKLastStand02 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.3,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HOAKSoulPower01 = 0.5, HOAKSoulPower02 = 0.5, HOAKSoulPower03 = 0.5,
            },
            ShopDesires = {
                SpeedDesire = -0.3,
                PrimaryWeaponDesire = -0.5,
            },
        },

        # =====================
        # Divine Justice
        # =====================
        HOAKDivineJustice01 = {
            BasePriority = 4,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HOAKSoulPower01 = 0.5, HOAKSoulPower02 = 0.5, HOAKSoulPower03 = 0.5,
            },
            ShopDesires = {
                HealthDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HOAKDivineJustice02 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HOAKSoulPower01 = 0.5, HOAKSoulPower02 = 0.5, HOAKSoulPower03 = 0.5,
            },
            ShopDesires = {
                HealthDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HOAKDivineJustice03 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HOAKSoulPower01 = 0.5, HOAKSoulPower02 = 0.5, HOAKSoulPower03 = 0.5,
            },
            ShopDesires = {
                HealthDesire = -0.2,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HOakRally = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HOAKSoulPower01 = 0.5, HOAKSoulPower02 = 0.5, HOAKSoulPower03 = 0.5,
            },
        },

        # =====================
        # Soul Power
        # =====================
        HOAKSoulPower01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HOAKRaiseDeadWard01 = 0.5, HOAKRaiseDeadWard02 = 0.5, HOAKRaiseDeadWard03 = 0.5, HOAKRaiseDeadWard04 = 0.5, HOakSoulFrenzy = 0.5,
            },
            ShopDesires = {
                SpeedDesire = -0.2,
                HealthDesire = -0.2,
                PrimaryWeaponDesire = -0.3,
            },
        },
        HOAKSoulPower02 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HOAKRaiseDeadWard01 = 0.5, HOAKRaiseDeadWard02 = 0.5, HOAKRaiseDeadWard03 = 0.5, HOAKRaiseDeadWard04 = 0.5, HOakSoulFrenzy = 0.5,
            },
            ShopDesires = {
                SpeedDesire = -0.2,
                HealthDesire = -0.2,
                PrimaryWeaponDesire = -0.3,
            },
        },
        HOAKSoulPower03 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HOAKRaiseDeadWard01 = 0.5, HOAKRaiseDeadWard02 = 0.5, HOAKRaiseDeadWard03 = 0.5, HOAKRaiseDeadWard04 = 0.5, HOakSoulFrenzy = 0.5,
            },
            ShopDesires = {
                SpeedDesire = -0.2,
                HealthDesire = -0.2,
                PrimaryWeaponDesire = -0.3,
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