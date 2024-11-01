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

UnitAITemplates['hema01'] = {
    UnitId = 'hema01',
    SensorSets = {
        RangeHero = true,
    },

    ActionSets = {
        RangeHero = true,
        MagicAssassin = true,
    },

    GoapCreation = function(hero, planner)
        local fireOnFunction = function(unit, buffName, instigator)
            if buffName != 'HEMA01FireWeaponEnable' then
                return
            end
            unit.WorldStateData.FireMode = true
        end

        local fireOffFunction = function(unit, buffName, instigator)
            if buffName != 'HEMA01FireWeaponEnable' then
                return
            end
            unit.WorldStateData.FireMode = false
        end

        hero.WorldStateData.FireMode = false

        hero.Callbacks.OnBuffActivate:Add(fireOnFunction, hero)
        hero.Callbacks.OnBuffDeactivate:Add(fireOffFunction, hero)
    end,

    SkillBuilds = {
# 0.26.40 removed the hybrid_fire_ice build from tb
--[[       
		 Hybrid_Fire_ICE = {
            'HEMA01RainIce01',          # 1
            'HEMA01Fireball01',         # 2
            'HEMA01FrostAura01',  		# 3
            'HEMA01RainIce02',          # 4
            'HEMA01Fireball02',         # 5
            'HEMA01FireNova01',  		# 6
            'HEMA01RainIce03',     		# 7
            'HEMA01Fireball03', 		# 8
            'HEMA01FrostAura02',  		# 9
            'HEMA01Fireball04',         # 10
            'HEMA01RainIce04',          # 11
            'HEMA01FireNova02',  		# 12
            'HEMA01FrostAura03',		# 13
            'HEMA01FreezeStructure01',	# 14
            'HEMA01Clarity',         	# 15
            'HEMA01FreezeStructure02',	# 16
            'HEMA01FreezeStructure03',	# 17
            'HEMA01FreezeStructure04',	# 18
            'HEMA01FireandIce',        	# 19
            'HEMA01FireNova03',        	# 20
			FavorItems = {'AchievementRunSpeed', 'AchievementHealth'}, #AchievementRunSpeed 'AchievementManaLeech', 
			ItemWeights = {
					# Wand of Speed
					# Use: Increase Base Run Speed by 30%.
					Item_Consumable_050 = {
						Priority = 20,
					},	
					
					# Boots of Speed
					# +15% Base Run Speed
					Item_Boot_020 = {
						Priority = 20,
					},	
		
			},
        },
--]]
		 Pure_Ice = {
            'HEMA01RainIce01',          # 1
            'HEMA01FrostAura01',       	# 2
            'HEMA01FreezeStructure01', 	# 3
            'HEMA01RainIce02',          # 4
            'HEMA01FrostAura02',       	# 5
            'HEMA01FrostNova01',  		# 6
            'HEMA01RainIce03',     		# 7
            'HEMA01FrostAura03', 		# 8
            'SAVE', 					# 9
            'HEMA01RainIce04','HEMA01FrostNova02', # 10
            'HEMA01FreezeStructure02',	# 11
            'HEMA01FreezeStructure03',	# 12
            'HEMA01FreezeStructure04',	# 13
            'SAVE', 					# 14
            'HEMA01FrostNova03','HEMA01Clarity',	# 15
            'StatsBuff01',			# 16
            'StatsBuff02',			# 17
            'StatsBuff03',			# 18
            'StatsBuff04',        	# 19
            'StatsBuff05',        	# 20
# 0.26.41 Removed all favor items but Blood of the Fallen
			FavorItems = {'AchievementHealth'},
--			FavorItems = {'AchievementHealth', 'AchievementHealth'},  #AchievementRunSpeed 'AchievementManaLeech', 
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


		 Pure_Fire = {
            'HEMA01RingOfFire01',  	# 1
            'HEMA01Fireball01',    	# 2
            'HEMA01FireAura01',  	# 3
            'HEMA01Fireball02',   	# 4
            'HEMA01FireNova01',    	# 5
            'HEMA01FireAura02',  	# 6
            'HEMA01Fireball03',    	# 7
            'HEMA01FireAura03', 	# 8
            'SAVE',  				# 9
            'HEMA01FireNova02','HEMA01Fireball04',	# 10
            'HEMA01RingOfFire02', 	# 11
            'HEMA01RingOfFire03',  	# 12
            'HEMA01RingOfFire04',	# 13
            'SAVE',					# 14
            'HEMA01FireNova03','HEMA01InspFlame',	# 15
            'StatsBuff01',			# 16
            'StatsBuff02',			# 17
            'StatsBuff03',			# 18
            'StatsBuff04',        	# 19
            'StatsBuff05',        	# 20
# 0.26.41 Removed all favor items but Blood of the Fallen
			FavorItems = {'AchievementHealth'},
--			FavorItems = {'AchievementHealth', 'AchievementRunSpeed'},  #'AchievementManaLeech', 
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

    SkillWeights = {

        # =====================
        # Fire Aura
        # =====================
        HEMA01FireAura01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HEMA01Fireball01 = 0.5, HEMA01Fireball02 = 0.5, HEMA01Fireball03 = 0.5, HEMA01Fireball04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01FireNova01 = 0.5, HEMA01FireNova02 = 0.5, HEMA01FireNova03 = 0.5,
                HEMA01RingOfFire01 = 0.5, HEMA01RingOfFire02 = 0.5, HEMA01RingOfFire03 = 0.5, HEMA01RingOfFire04 = 0.5, HEMA01InspFlame = 0.5,
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.2,
            },
        },
        HEMA01FireAura02 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HEMA01Fireball01 = 0.5, HEMA01Fireball02 = 0.5, HEMA01Fireball03 = 0.5, HEMA01Fireball04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01FireNova01 = 0.5, HEMA01FireNova02 = 0.5, HEMA01FireNova03 = 0.5,
                HEMA01RingOfFire01 = 0.5, HEMA01RingOfFire02 = 0.5, HEMA01RingOfFire03 = 0.5, HEMA01RingOfFire04 = 0.5, HEMA01InspFlame = 0.5,
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.2,
            },
        },
        HEMA01FireAura03 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HEMA01Fireball01 = 0.5, HEMA01Fireball02 = 0.5, HEMA01Fireball03 = 0.5, HEMA01Fireball04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01FireNova01 = 0.5, HEMA01FireNova02 = 0.5, HEMA01FireNova03 = 0.5,
                HEMA01RingOfFire01 = 0.5, HEMA01RingOfFire02 = 0.5, HEMA01RingOfFire03 = 0.5, HEMA01RingOfFire04 = 0.5, HEMA01InspFlame = 0.5,
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.2,
            },
        },

        # =====================
        # Fireball
        # =====================
        HEMA01Fireball01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.1,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
                HEMA01FireAura01 = 0.5, HEMA01FireAura02 = 0.5, HEMA01FireAura03 = 0.5,
                HEMA01FireNova01 = 0.5, HEMA01FireNova02 = 0.5, HEMA01FireNova03 = 0.5,
                HEMA01RingOfFire01 = 0.5, HEMA01RingOfFire02 = 0.5, HEMA01RingOfFire03 = 0.5, HEMA01RingOfFire04 = 0.5, HEMA01InspFlame = 0.5,
                HEMA01FreezeStructure01 = 0.5, HEMA01FreezeStructure02 = 0.5, HEMA01FreezeStructure03 = 0.5, HEMA01FreezeStructure04 = 0.5, HEMA01FireandIce = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.3,
                HealthDesire = -0.1,
            },
        },
        HEMA01Fireball02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.1,
                StructureKillValue = 0.3,
            },
            SkillBonuses = {
                HEMA01FireAura01 = 0.5, HEMA01FireAura02 = 0.5, HEMA01FireAura03 = 0.5,
                HEMA01FireNova01 = 0.5, HEMA01FireNova02 = 0.5, HEMA01FireNova03 = 0.5,
                HEMA01RingOfFire01 = 0.5, HEMA01RingOfFire02 = 0.5, HEMA01RingOfFire03 = 0.5, HEMA01RingOfFire04 = 0.5, HEMA01InspFlame = 0.5,
                HEMA01FreezeStructure01 = 0.5, HEMA01FreezeStructure02 = 0.5, HEMA01FreezeStructure03 = 0.5, HEMA01FreezeStructure04 = 0.5, HEMA01FireandIce = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.3,
                HealthDesire = -0.1,
            },
        },
        HEMA01Fireball03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HEMA01FireAura01 = 0.5, HEMA01FireAura02 = 0.5, HEMA01FireAura03 = 0.5,
                HEMA01FireNova01 = 0.5, HEMA01FireNova02 = 0.5, HEMA01FireNova03 = 0.5,
                HEMA01RingOfFire01 = 0.5, HEMA01RingOfFire02 = 0.5, HEMA01RingOfFire03 = 0.5, HEMA01RingOfFire04 = 0.5, HEMA01InspFlame = 0.5,
                HEMA01FreezeStructure01 = 0.5, HEMA01FreezeStructure02 = 0.5, HEMA01FreezeStructure03 = 0.5, HEMA01FreezeStructure04 = 0.5, HEMA01FireandIce = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.3,
                HealthDesire = -0.1,
            },
        },
        HEMA01Fireball04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HEMA01FireAura01 = 0.5, HEMA01FireAura02 = 0.5, HEMA01FireAura03 = 0.5,
                HEMA01FireNova01 = 0.5, HEMA01FireNova02 = 0.5, HEMA01FireNova03 = 0.5,
                HEMA01RingOfFire01 = 0.5, HEMA01RingOfFire02 = 0.5, HEMA01RingOfFire03 = 0.5, HEMA01RingOfFire04 = 0.5, HEMA01InspFlame = 0.5,
                HEMA01FreezeStructure01 = 0.5, HEMA01FreezeStructure02 = 0.5, HEMA01FreezeStructure03 = 0.5, HEMA01FreezeStructure04 = 0.5, HEMA01FireandIce = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.3,
                HealthDesire = -0.1,
            },
        },

        # =====================
        # Fire Nova
        # =====================
        HEMA01FireNova01 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.5,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HEMA01FireAura01 = 0.5, HEMA01FireAura02 = 0.5, HEMA01FireAura03 = 0.5,
                HEMA01Fireball01 = 0.5, HEMA01Fireball02 = 0.5, HEMA01Fireball03 = 0.5, HEMA01Fireball04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01RingOfFire01 = 0.5, HEMA01RingOfFire02 = 0.5, HEMA01RingOfFire03 = 0.5, HEMA01RingOfFire04 = 0.5, HEMA01InspFlame = 0.5,
                HEMA01FrostNova01 = 1.0, HEMA01FrostNova02 = 1.0, HEMA01FrostNova03 = 1.0,
            },
            ShopDesires = {
                ManaDesire = -0.3,
                HealthDesire = -0.2,
                SpeedDesire = -0.2,
            },
        },
        HEMA01FireNova02 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HEMA01FireAura01 = 0.5, HEMA01FireAura02 = 0.5, HEMA01FireAura03 = 0.5,
                HEMA01Fireball01 = 0.5, HEMA01Fireball02 = 0.5, HEMA01Fireball03 = 0.5, HEMA01Fireball04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01RingOfFire01 = 0.5, HEMA01RingOfFire02 = 0.5, HEMA01RingOfFire03 = 0.5, HEMA01RingOfFire04 = 0.5, HEMA01InspFlame = 0.5,
                HEMA01FrostNova01 = 1.0, HEMA01FrostNova02 = 1.0, HEMA01FrostNova03 = 1.0,
            },
            ShopDesires = {
                ManaDesire = -0.3,
                HealthDesire = -0.2,
                SpeedDesire = -0.2,
            },
        },
        HEMA01FireNova03 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.7,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HEMA01FireAura01 = 0.5, HEMA01FireAura02 = 0.5, HEMA01FireAura03 = 0.5,
                HEMA01Fireball01 = 0.5, HEMA01Fireball02 = 0.5, HEMA01Fireball03 = 0.5, HEMA01Fireball04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01RingOfFire01 = 0.5, HEMA01RingOfFire02 = 0.5, HEMA01RingOfFire03 = 0.5, HEMA01RingOfFire04 = 0.5, HEMA01InspFlame = 0.5,
                HEMA01FrostNova01 = 1.0, HEMA01FrostNova02 = 1.0, HEMA01FrostNova03 = 1.0,
            },
            ShopDesires = {
                ManaDesire = -0.3,
                HealthDesire = -0.2,
                SpeedDesire = -0.2,
            },
        },

        # =====================
        ## Ring of Fire
        # =====================
        HEMA01RingOfFire01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.4,
                StructureKillValue = 0.4,
            },
            SkillBonuses = {
                HEMA01FireAura01 = 0.5, HEMA01FireAura02 = 0.5, HEMA01FireAura03 = 0.5,
                HEMA01Fireball01 = 0.5, HEMA01Fireball02 = 0.5, HEMA01Fireball03 = 0.5, HEMA01Fireball04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01FireNova01 = 0.5, HEMA01FireNova02 = 0.5, HEMA01FireNova03 = 0.5,
                HEMA01RainIce01 = 0.5, HEMA01RainIce02 = 0.5, HEMA01RainIce03 = 0.5, HEMA01RainIce04 = 0.5, HEMA01Clarity = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.1,
                SpeedDesire = -0.1,
            },
        },
        HEMA01RingOfFire02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.4,
                StructureKillValue = 0.4,
            },
            SkillBonuses = {
                HEMA01FireAura01 = 0.5, HEMA01FireAura02 = 0.5, HEMA01FireAura03 = 0.5,
                HEMA01Fireball01 = 0.5, HEMA01Fireball02 = 0.5, HEMA01Fireball03 = 0.5, HEMA01Fireball04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01FireNova01 = 0.5, HEMA01FireNova02 = 0.5, HEMA01FireNova03 = 0.5,
                HEMA01RainIce01 = 0.5, HEMA01RainIce02 = 0.5, HEMA01RainIce03 = 0.5, HEMA01RainIce04 = 0.5, HEMA01Clarity = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.1,
                SpeedDesire = -0.1,
            },
        },
        HEMA01RingOfFire03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.4,
                StructureKillValue = 0.4,
            },
            SkillBonuses = {
                HEMA01FireAura01 = 0.5, HEMA01FireAura02 = 0.5, HEMA01FireAura03 = 0.5,
                HEMA01Fireball01 = 0.5, HEMA01Fireball02 = 0.5, HEMA01Fireball03 = 0.5, HEMA01Fireball04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01FireNova01 = 0.5, HEMA01FireNova02 = 0.5, HEMA01FireNova03 = 0.5,
                HEMA01RainIce01 = 0.5, HEMA01RainIce02 = 0.5, HEMA01RainIce03 = 0.5, HEMA01RainIce04 = 0.5, HEMA01Clarity = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.1,
                SpeedDesire = -0.1,
            },
        },
        HEMA01RingOfFire04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.4,
                StructureKillValue = 0.4,
            },
            SkillBonuses = {
                HEMA01FireAura01 = 0.5, HEMA01FireAura02 = 0.5, HEMA01FireAura03 = 0.5,
                HEMA01Fireball01 = 0.5, HEMA01Fireball02 = 0.5, HEMA01Fireball03 = 0.5, HEMA01Fireball04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01FireNova01 = 0.5, HEMA01FireNova02 = 0.5, HEMA01FireNova03 = 0.5,
                HEMA01RainIce01 = 0.5, HEMA01RainIce02 = 0.5, HEMA01RainIce03 = 0.5, HEMA01RainIce04 = 0.5, HEMA01Clarity = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.1,
                SpeedDesire = -0.1,
            },
        },
        HEMA01InspFlame = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.4,
                StructureKillValue = 0.4,
            },
            SkillBonuses = {
                HEMA01FireAura01 = 0.5, HEMA01FireAura02 = 0.5, HEMA01FireAura03 = 0.5,
                HEMA01Fireball01 = 0.5, HEMA01Fireball02 = 0.5, HEMA01Fireball03 = 0.5, HEMA01Fireball04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01FireNova01 = 0.5, HEMA01FireNova02 = 0.5, HEMA01FireNova03 = 0.5,
                HEMA01RainIce01 = 0.5, HEMA01RainIce02 = 0.5, HEMA01RainIce03 = 0.5, HEMA01RainIce04 = 0.5, HEMA01Clarity = 0.5,
            },
        },

        # =====================
        # Frost Aura
        # =====================
        HEMA01FrostAura01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HEMA01RainIce01 = 0.5, HEMA01RainIce02 = 0.5, HEMA01RainIce03 = 0.5, HEMA01RainIce04 = 0.5, HEMA01Clarity = 0.5,
                HEMA01FreezeStructure01 = 0.5, HEMA01FreezeStructure02 = 0.5, HEMA01FreezeStructure03 = 0.5, HEMA01FreezeStructure04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01FrostNova01 = 0.5, HEMA01FrostNova02 = 0.5, HEMA01FrostNova03 = 0.5,
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.2,
            },
        },
        HEMA01FrostAura02 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HEMA01RainIce01 = 0.5, HEMA01RainIce02 = 0.5, HEMA01RainIce03 = 0.5, HEMA01RainIce04 = 0.5, HEMA01Clarity = 0.5,
                HEMA01FreezeStructure01 = 0.5, HEMA01FreezeStructure02 = 0.5, HEMA01FreezeStructure03 = 0.5, HEMA01FreezeStructure04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01FrostNova01 = 0.5, HEMA01FrostNova02 = 0.5, HEMA01FrostNova03 = 0.5,
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.2,
            },
        },
        HEMA01FrostAura03 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.4,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HEMA01RainIce01 = 0.5, HEMA01RainIce02 = 0.5, HEMA01RainIce03 = 0.5, HEMA01RainIce04 = 0.5, HEMA01Clarity = 0.5,
                HEMA01FreezeStructure01 = 0.5, HEMA01FreezeStructure02 = 0.5, HEMA01FreezeStructure03 = 0.5, HEMA01FreezeStructure04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01FrostNova01 = 0.5, HEMA01FrostNova02 = 0.5, HEMA01FrostNova03 = 0.5,
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.2,
            },
        },

        # =====================
        # Rain of Ice
        # =====================
        HEMA01RainIce01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HEMA01FrostAura01 = 0.5, HEMA01FrostAura02 = 0.5, HEMA01FrostAura03 = 0.5,
                HEMA01FreezeStructure01 = 0.5, HEMA01FreezeStructure02 = 0.5, HEMA01FreezeStructure03 = 0.5, HEMA01FreezeStructure04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01FrostNova01 = 0.5, HEMA01FrostNova02 = 0.5, HEMA01FrostNova03 = 0.5,
                HEMA01RingOfFire01 = 0.5, HEMA01RingOfFire02 = 0.5, HEMA01RingOfFire03 = 0.5, HEMA01RingOfFire04 = 0.5, HEMA01InspFlame = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.3,
            },
        },
        HEMA01RainIce02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HEMA01FrostAura01 = 0.5, HEMA01FrostAura02 = 0.5, HEMA01FrostAura03 = 0.5,
                HEMA01FreezeStructure01 = 0.5, HEMA01FreezeStructure02 = 0.5, HEMA01FreezeStructure03 = 0.5, HEMA01FreezeStructure04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01FrostNova01 = 0.5, HEMA01FrostNova02 = 0.5, HEMA01FrostNova03 = 0.5,
                HEMA01RingOfFire01 = 0.5, HEMA01RingOfFire02 = 0.5, HEMA01RingOfFire03 = 0.5, HEMA01RingOfFire04 = 0.5, HEMA01InspFlame = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.3,
            },
        },
        HEMA01RainIce03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HEMA01FrostAura01 = 0.5, HEMA01FrostAura02 = 0.5, HEMA01FrostAura03 = 0.5,
                HEMA01FreezeStructure01 = 0.5, HEMA01FreezeStructure02 = 0.5, HEMA01FreezeStructure03 = 0.5, HEMA01FreezeStructure04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01FrostNova01 = 0.5, HEMA01FrostNova02 = 0.5, HEMA01FrostNova03 = 0.5,
                HEMA01RingOfFire01 = 0.5, HEMA01RingOfFire02 = 0.5, HEMA01RingOfFire03 = 0.5, HEMA01RingOfFire04 = 0.5, HEMA01InspFlame = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.3,
            },
        },
        HEMA01RainIce04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HEMA01FrostAura01 = 0.5, HEMA01FrostAura02 = 0.5, HEMA01FrostAura03 = 0.5,
                HEMA01FreezeStructure01 = 0.5, HEMA01FreezeStructure02 = 0.5, HEMA01FreezeStructure03 = 0.5, HEMA01FreezeStructure04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01FrostNova01 = 0.5, HEMA01FrostNova02 = 0.5, HEMA01FrostNova03 = 0.5,
                HEMA01RingOfFire01 = 0.5, HEMA01RingOfFire02 = 0.5, HEMA01RingOfFire03 = 0.5, HEMA01RingOfFire04 = 0.5, HEMA01InspFlame = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.3,
            },
        },
        HEMA01Clarity = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.6,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
                HEMA01FrostAura01 = 0.5, HEMA01FrostAura02 = 0.5, HEMA01FrostAura03 = 0.5,
                HEMA01FreezeStructure01 = 0.5, HEMA01FreezeStructure02 = 0.5, HEMA01FreezeStructure03 = 0.5, HEMA01FreezeStructure04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01FrostNova01 = 0.5, HEMA01FrostNova02 = 0.5, HEMA01FrostNova03 = 0.5,
                HEMA01RingOfFire01 = 0.5, HEMA01RingOfFire02 = 0.5, HEMA01RingOfFire03 = 0.5, HEMA01RingOfFire04 = 0.5, HEMA01InspFlame = 0.5,
            },
        },

        # =====================
        # Deep Freeze
        # =====================
        HEMA01FreezeStructure01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
                HEMA01FrostAura01 = 0.5, HEMA01FrostAura02 = 0.5, HEMA01FrostAura03 = 0.5,
                HEMA01RainIce01 = 0.5, HEMA01RainIce02 = 0.5, HEMA01RainIce03 = 0.5, HEMA01RainIce04 = 0.5, HEMA01Clarity = 0.5,
                HEMA01FrostNova01 = 0.5, HEMA01FrostNova02 = 0.5, HEMA01FrostNova03 = 0.5,
                HEMA01Fireball01 = 0.5, HEMA01Fireball02 = 0.5, HEMA01Fireball03 = 0.5, HEMA01Fireball04 = 0.5, HEMA01FireandIce = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.2,
            },
        },
        HEMA01FreezeStructure02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
                HEMA01FrostAura01 = 0.5, HEMA01FrostAura02 = 0.5, HEMA01FrostAura03 = 0.5,
                HEMA01RainIce01 = 0.5, HEMA01RainIce02 = 0.5, HEMA01RainIce03 = 0.5, HEMA01RainIce04 = 0.5, HEMA01Clarity = 0.5,
                HEMA01FrostNova01 = 0.5, HEMA01FrostNova02 = 0.5, HEMA01FrostNova03 = 0.5,
                HEMA01Fireball01 = 0.5, HEMA01Fireball02 = 0.5, HEMA01Fireball03 = 0.5, HEMA01Fireball04 = 0.5, HEMA01FireandIce = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.2,
            },
        },
        HEMA01FreezeStructure03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
                HEMA01FrostAura01 = 0.5, HEMA01FrostAura02 = 0.5, HEMA01FrostAura03 = 0.5,
                HEMA01RainIce01 = 0.5, HEMA01RainIce02 = 0.5, HEMA01RainIce03 = 0.5, HEMA01RainIce04 = 0.5, HEMA01Clarity = 0.5,
                HEMA01FrostNova01 = 0.5, HEMA01FrostNova02 = 0.5, HEMA01FrostNova03 = 0.5,
                HEMA01Fireball01 = 0.5, HEMA01Fireball02 = 0.5, HEMA01Fireball03 = 0.5, HEMA01Fireball04 = 0.5, HEMA01FireandIce = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.2,
            },
        },
        HEMA01FreezeStructure04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
                HEMA01FrostAura01 = 0.5, HEMA01FrostAura02 = 0.5, HEMA01FrostAura03 = 0.5,
                HEMA01RainIce01 = 0.5, HEMA01RainIce02 = 0.5, HEMA01RainIce03 = 0.5, HEMA01RainIce04 = 0.5, HEMA01Clarity = 0.5,
                HEMA01FrostNova01 = 0.5, HEMA01FrostNova02 = 0.5, HEMA01FrostNova03 = 0.5,
                HEMA01Fireball01 = 0.5, HEMA01Fireball02 = 0.5, HEMA01Fireball03 = 0.5, HEMA01Fireball04 = 0.5, HEMA01FireandIce = 0.5,
            },
            ShopDesires = {
                ManaDesire = -0.2,
            },
        },
        HEMA01FireandIce = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.8,
                PushValue = 0.1,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
                HEMA01FrostAura01 = 0.5, HEMA01FrostAura02 = 0.5, HEMA01FrostAura03 = 0.5,
                HEMA01RainIce01 = 0.5, HEMA01RainIce02 = 0.5, HEMA01RainIce03 = 0.5, HEMA01RainIce04 = 0.5, HEMA01Clarity = 0.5,
                HEMA01FrostNova01 = 0.5, HEMA01FrostNova02 = 0.5, HEMA01FrostNova03 = 0.5,
                HEMA01Fireball01 = 0.5, HEMA01Fireball02 = 0.5, HEMA01Fireball03 = 0.5, HEMA01Fireball04 = 0.5, HEMA01FireandIce = 0.5,
            },
        },

        # =====================
        # Frost Nova
        # =====================
        HEMA01FrostNova01 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.7,
                PushValue = 0.2,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
                HEMA01FrostAura01 = 0.5, HEMA01FrostAura02 = 0.5, HEMA01FrostAura03 = 0.5,
                HEMA01RainIce01 = 0.5, HEMA01RainIce02 = 0.5, HEMA01RainIce03 = 0.5, HEMA01RainIce04 = 0.5, HEMA01Clarity = 0.5,
                HEMA01FreezeStructure01 = 0.5, HEMA01FreezeStructure02 = 0.5, HEMA01FreezeStructure03 = 0.5, HEMA01FreezeStructure04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01FireNova01 = 1.0, HEMA01FireNova02 = 1.0, HEMA01FireNova03 = 1.0,
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.2,
                SpeedDesire = -0.2,
            },
        },
        HEMA01FrostNova02 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.7,
                PushValue = 0.2,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
                HEMA01FrostAura01 = 0.5, HEMA01FrostAura02 = 0.5, HEMA01FrostAura03 = 0.5,
                HEMA01RainIce01 = 0.5, HEMA01RainIce02 = 0.5, HEMA01RainIce03 = 0.5, HEMA01RainIce04 = 0.5, HEMA01Clarity = 0.5,
                HEMA01FreezeStructure01 = 0.5, HEMA01FreezeStructure02 = 0.5, HEMA01FreezeStructure03 = 0.5, HEMA01FreezeStructure04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01FireNova01 = 1.0, HEMA01FireNova02 = 1.0, HEMA01FireNova03 = 1.0,
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.2,
                SpeedDesire = -0.2,
            },
        },
        HEMA01FrostNova03 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.7,
                PushValue = 0.2,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
                HEMA01FrostAura01 = 0.5, HEMA01FrostAura02 = 0.5, HEMA01FrostAura03 = 0.5,
                HEMA01RainIce01 = 0.5, HEMA01RainIce02 = 0.5, HEMA01RainIce03 = 0.5, HEMA01RainIce04 = 0.5, HEMA01Clarity = 0.5,
                HEMA01FreezeStructure01 = 0.5, HEMA01FreezeStructure02 = 0.5, HEMA01FreezeStructure03 = 0.5, HEMA01FreezeStructure04 = 0.5, HEMA01FireandIce = 0.5,
                HEMA01FireNova01 = 1.0, HEMA01FireNova02 = 1.0, HEMA01FireNova03 = 1.0,
            },
            ShopDesires = {
                ManaDesire = -0.2,
                HealthDesire = -0.2,
                SpeedDesire = -0.2,
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