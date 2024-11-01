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

UnitAITemplates['hgsa01'] = {
    UnitId = 'hgsa01',
    SensorSets = {
        RangeHero = true,
    },
    ActionSets = {
        RangeHero = true,
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
	
# 0.26.41 Removed sniper_mines build and added minor change of getting impedance bolt at level 16
	        Snipe_Mine = {
                'HGSA01Snipe01',          	# 1
                'HGSA01ExplosiveMine01',  	# 2
                'SAVE',                   		# 3
                'HGSA01Snipe02', 'HGSA01ExplosiveMine02',     # 4
                'HGSA01Track',       	  	# 5
                'HGSA01Betrayer01',   	  	# 6
                'HGSA01ExplosiveMine03',  	# 7
                'HGSA01Snipe03',          	# 8
                'SAVE',                   		# 9
                'HGSA01ShrapnelMine01', 'HGSA01Snipe04',     # 10
                'HGSA01Betrayer02',       	# 11
                'HGSA01Maim01',           	# 12
                'HGSA01Maim02',           	# 13
                'HGSA01Maim03',           	# 14
                'HGSA01Betrayer03',       	# 15
                'HGSA01ImpedanceBolt01',  	# 16
                'HGSA01MaxRange01',           # 17
                'HGSA01MaxRange02',           # 18
                'HGSA01MaxRange03',           # 19
                'HGSA01Deadeye01',           	# 20
				FavorItems = {'AchievementHealth'}, 
				ItemWeights = {
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
				

					},
			},
	},

			
--[[ 0.26.41 removed by pacov	
	        sniper_mines = {
                'HGSA01Snipe01',          # 1
                'HGSA01ExplosiveMine01',  # 2
                'SAVE',                   # 3
                'HGSA01Snipe02', 'HGSA01ExplosiveMine02',     # 4
                'HGSA01Track',       	  # 5
                'HGSA01Betrayer01',   	  # 6
                'HGSA01ExplosiveMine03',  # 7
                'HGSA01Snipe03',          # 8
                'SAVE',                   # 9
                'HGSA01ShrapnelMine01', 'HGSA01Snipe04',     # 10
                'HGSA01Betrayer02',       # 11
                'HGSA01Maim01',           # 12
                'HGSA01Maim02',           # 13
                'HGSA01Maim03',           # 14
                'HGSA01Betrayer03',       # 15
                'StatsBuff01',            # 16
                'StatsBuff02',            # 17
                'StatsBuff03',            # 18
                'StatsBuff04',            # 19
                'StatsBuff05',            # 20
				FavorItems = {'AchievementRefreshCooldowns'}, #AchievementRefreshCooldowns 'AchievementManaLeech',
				ItemWeights = {
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
				

					},
			},
	
	        # -- auto_attack = {
            # -- 'HGSA01AngelicFury01',	# 1
            # -- 'HGSA01MaxRange01',		# 2
            # -- 'HGSA01Maim01',        	# 3
            # -- 'HGSA01AngelicFury02', 	# 4
            # -- 'HGSA01MaxRange02',		# 5
            # -- 'HGSA01Betrayer01', 	# 6
            # -- 'HGSA01AngelicFury03',	# 7
            # -- 'HGSA01MaxRange03', 	# 8
            # -- 'HGSA01Maim02',  		# 9
            # -- 'HGSA01AngelicFury04',	# 10
            # -- 'HGSA01Betrayer02',   	# 11
            # -- 'HGSA01Maim03',       	# 12
            # -- 'StatsBuff01',         	# 13
            # -- 'StatsBuff02',        	# 14
            # -- 'HGSA01Betrayer03',    	# 15
            # -- 'StatsBuff03',    		# 16
            # -- 'StatsBuff04',    		# 17
            # -- 'StatsBuff05',    		# 18
            # -- 'StatsBuff06',     		# 19
            # -- 'HGSA01ImpedanceBolt01',# 20
			# -- FavorItems = {'AchievementManaLeech'}, #'AchievementRefreshCooldowns'
			# -- ItemWeights = {
					# -- # Wand of Speed
					# -- # Use: Increase Base Run Speed by 30%.
					# -- Item_Consumable_050 = {
						# -- Priority = 20,
					# -- },	
					
					# -- # Boots of Speed
					# -- # +15% Base Run Speed
					# -- Item_Boot_020 = {
						# -- Priority = 20,
					# -- },
		
					# -- # Wyrmskin Handguards
					# -- # 20% chance on hit to eviscerate the target dealing 150 damage and reducing their Attack Speed and Base Run Speed 25%.
					# -- Item_Glove_040 = {
						# -- Priority = 30,
						# -- #AssassinItem = true,
					# -- },

					# -- # Orb of Veiled Storms
					# -- # Use: Unleash a wave of pure force in an area, dealing 500 damage.
					# -- # +80 Hit Points per second
					# -- Item_Artifact_110 = {
						# -- Priority = 100,
					# -- },
					
					
				# -- },
			# -- },	
	
    },
--]]
    SkillWeights = {
        # =====================
        # Max range
        # =====================
        HGSA01MaxRange01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.2,
                StructureKillValue = 0.4,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
            },
        },
        HGSA01MaxRange02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.2,
                StructureKillValue = 0.4,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
            },
        },
        HGSA01MaxRange03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.2,
                StructureKillValue = 0.4,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
            },
        },

        # =====================
        # Snipe attack
        # =====================
        HGSA01Snipe01 = {
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
        HGSA01Snipe02 = {
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
        HGSA01Snipe03 = {
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
        HGSA01Snipe04 = {
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
        HGSA01Deadeye01 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.3,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
        },

        # =====================
        # Maim
        # =====================
        HGSA01Maim01 = {
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
        HGSA01Maim02 = {
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
        HGSA01Maim03 = {
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
        HGSA01ImpedanceBolt01 = {
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
            },
        },

        # =====================
        # Mines
        # =====================
        HGSA01ExplosiveMine01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.6,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
            },
        },
        HGSA01ExplosiveMine02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.6,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
            },
        },
        HGSA01ExplosiveMine03 = {
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
            },
        },
        HGSA01ShrapnelMine01 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.4,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.1,
            },
        },

        # =====================
        # Mark of the Betrayer
        # =====================
        HGSA01Betrayer01 = {
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
        HGSA01Betrayer02 = {
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
        HGSA01Betrayer03 = {
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

        # =====================
        # Tracking
        # =====================
        HGSA01Track = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.2,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
        },

        # =====================
        # Angellic fury
        # =====================
        HGSA01AngelicFury01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.3,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.05,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HGSA01AngelicFury02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.3,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.05,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HGSA01AngelicFury03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.3,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.05,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HGSA01AngelicFury04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.3,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                ManaDesire = -0.05,
                PrimaryWeaponDesire = -0.2,
            },
        },
        HGSA01Vengeance01 = {
            BasePriority = 14,
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