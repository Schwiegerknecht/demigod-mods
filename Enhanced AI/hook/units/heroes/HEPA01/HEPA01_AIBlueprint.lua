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

UnitAITemplates['hepa01'] = {
    UnitId = 'hepa01',

    SensorSets = {
    },
    ActionSets = {
        MeleeHero = true,
    },

    GoapCreation = function(hero, planner)
        local oozeOnFunction = function(unit, buffName, instigator)
            if buffName != 'HEPA01OozeSelf01' and buffName != 'HEPA01OozeSelf02' and buffName != 'HEPA01OozeSelf03' and buffName != 'HEPA01OozeSelf04' then
                return
            end
            unit.WorldStateData.OozeMode = true
            unit.WorldStateData.HeroKillBonus = unit.WorldStateData.HeroKillBonus - 1
            unit.WorldStateData.GruntKillBonus = unit.WorldStateData.GruntKillBonus - 1
        end

        local oozeOffFunction = function(unit, buffName, instigator)
            if buffName != 'HEPA01OozeSelf01' and buffName != 'HEPA01OozeSelf02' and buffName != 'HEPA01OozeSelf03' and buffName != 'HEPA01OozeSelf04' then
                return
            end
            unit.WorldStateData.OozeMode = false
            unit.WorldStateData.HeroKillBonus = unit.WorldStateData.HeroKillBonus + 1
            unit.WorldStateData.GruntKillBonus = unit.WorldStateData.GruntKillBonus + 1
        end

        local clawsAddFunction = function(unit, buffName, instigator)
            if buffName == 'HEPA01DiseasedClaws01' then
                unit.WorldStateData.HeroKillBonus = unit.WorldStateData.HeroKillBonus - 0.2
            elseif buffName == 'HEPA01DiseasedClaws02' then
                unit.WorldStateData.HeroKillBonus = unit.WorldStateData.HeroKillBonus - 0.4
            elseif buffName == 'HEPA01DiseasedClaws03' then
                unit.WorldStateData.HeroKillBonus = unit.WorldStateData.HeroKillBonus - 0.6
            end
        end

        local clawsRemoveFunction = function(unit, buffName, instigator)
            if buffName == 'HEPA01DiseasedClaws01' then
                unit.WorldStateData.HeroKillBonus = unit.WorldStateData.HeroKillBonus + 0.2
            elseif buffName == 'HEPA01DiseasedClaws02' then
                unit.WorldStateData.HeroKillBonus = unit.WorldStateData.HeroKillBonus + 0.4
            elseif buffName == 'HEPA01DiseasedClaws03' then
                unit.WorldStateData.HeroKillBonus = unit.WorldStateData.HeroKillBonus + 0.6
            end
        end

        local postMortemAddFunction = function(unit, abilityName)
            if abilityName == 'HEPA01PostMortem01' then
                unit.WorldStateData.GruntKillBonus = unit.WorldStateData.GruntKillBonus - 0.5
            end
        end

        local plagueAddFunction = function(unit, abilityName)
            if abilityName == 'HEPA01Plague01' then
                unit.WorldStateData.GruntKillBonus = unit.WorldStateData.GruntKillBonus - 0.25
            elseif abilityName == 'HEPA01Plague02' then
                unit.WorldStateData.GruntKillBonus = unit.WorldStateData.GruntKillBonus - 0.5
            end
        end

        local plagueRemoveFunction = function(unit, abilityName)
            if abilityName == 'HEPA01Plague01' then
                unit.WorldStateData.GruntKillBonus = unit.WorldStateData.GruntKillBonus + 0.25
            elseif abilityName == 'HEPA01Plague02' then
                unit.WorldStateData.GruntKillBonus = unit.WorldStateData.GruntKillBonus + 0.5
            end
        end

        hero.WorldStateData.OozeMode = false

        hero.Callbacks.OnBuffActivate:Add(oozeOnFunction, hero)
        hero.Callbacks.OnBuffDeactivate:Add(oozeOffFunction, hero)

        hero.Callbacks.OnBuffActivate:Add(clawsAddFunction, hero)
        hero.Callbacks.OnBuffDeactivate:Add(clawsRemoveFunction, hero)

        hero.Callbacks.OnAbilityAdded:Add(postMortemAddFunction, hero)

        hero.Callbacks.OnAbilityAdded:Add(plagueAddFunction, hero)
        hero.Callbacks.OnAbilityRemoved:Add(plagueRemoveFunction, hero)

    end,

    SkillBuilds = {
	
# 0.26.40 removed spit_ooze_mana build - not as valuable as other UB builds

--[[	
	        spit_ooze_mana = {
            'HEPA01VenomSpit01',        			# 1
            'HEPA01Ooze01',   					 	# 2
            'SAVE',    								# 3
            'HEPA01VenomSpit02','HEPA01Ooze02',     # 4
            'HEPA01FoulGrasp01',       				# 5
            'SAVE',        							# 6
            'HEPA01VenomSpit03','HEPA01Ooze03',    	# 7
            'HEPA01PostMortem01', 					# 8
            'SAVE',    								# 9
            'HEPA01VenomSpit04','HEPA01Ooze04',     # 10
            'HEPA01SpeedIncrease01',        		# 11
            'HEPA01SpeedIncrease02',    			# 12
            'HEPA01SpeedIncrease03',    			# 13
            'SAVE',        							# 14
            'HEPA01PutridFlow','HEPA01Acclimation', # 15
            'StatsBuff01',    						# 16
            'StatsBuff02',  						# 17
            'StatsBuff03', 							# 18
            'StatsBuff04',							# 19
            'StatsBuff05',							# 20
			FavorItems = {'AchievementManaLeech'}, #'AchievementManaLeech'
			ItemWeights = {
			
			
				# Vlemish Faceguard
				# Increases the Mana Regeneration of you and nearby allied Demigods by 40 Mana per second.
				Item_Helm_040 = {
					Priority = -50,
				},
	
				# Orb of Defiance
				# Use: Become invulnerable for 5 seconds. Cannot move, attack or use abilities.
				# +500 Health
				# +500 Armor
				Item_Consumable_150 = {
					Priority = 30,
				},
				
				# Narmoth's Ring
				# +15% Life Steal
				# When struck by melee attacks, the wearer reflects 90 damage back to the attacker.
				Item_Ring_050 = {
					Priority = 40,
				},

				
				# Bulwark of the Ages
				# +2500 Armor
				# All damage reduced by 25%.
				Item_Artifact_120 = {	
					Priority = 15,
				},	
				
				# Heart of Life
				# Use: Restore 3000 health and 3000 mana over 10 seconds. Any damage will break this effect.
				# +15 Health Regeneration
				# +50% Mana Regeneration
				Item_Consumable_160 = {
					Priority = -100,
				},	
			},
        },
--]]
	Spit_Ooze = {
            'HEPA01VenomSpit01',        			# 1
            'HEPA01Ooze01',   					# 2
            'SAVE',    						# 3
            'HEPA01VenomSpit02','HEPA01Ooze02',     	# 4
            'HEPA01FoulGrasp01',       				# 5
            'SAVE',        						# 6
            'HEPA01VenomSpit03','HEPA01Ooze03',    	# 7
            'HEPA01SpeedIncrease01', 			# 8
            'SAVE',    						# 9
            'HEPA01VenomSpit04','HEPA01Ooze04',     	# 10
            'HEPA01SpeedIncrease02',        			# 11
            'HEPA01SpeedIncrease03',    			# 12
            'StatsBuff01',    					# 13
            'SAVE',        						# 14
            'HEPA01Acclimation', 'HEPA01PutridFlow',	# 15
            'StatsBuff02',    					# 16
            'StatsBuff03',  					# 17
            'StatsBuff04', 						# 18
            'StatsBuff05',						# 19
            'StatsBuff06',						# 20
			FavorItems = {'AchievementHealth'}, #'AchievementHealth' 'AchievementManaLeech'
			ItemWeights = {
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
					Priority = 15,
				},	
				
				# Heart of Life
				# Use: Restore 3000 health and 3000 mana over 10 seconds. Any damage will break this effect.
				# +15 Health Regeneration
				# +50% Mana Regeneration
				Item_Consumable_160 = {
					Priority = -100,
				},	
			},
        },	
},		
--~ 		ooze_health = {
--~             'HEPA01Ooze01',        		# 1
--~             'HEPA01SpeedIncrease01',	# 2
--~             'HEPA01DiseasedClaws01',	# 3
--~             'HEPA01Ooze02',   			# 4
--~             'HEPA01FoulGrasp01', 		# 5
--~             'HEPA01SpeedIncrease02',	# 6
--~             'HEPA01Ooze03',    			# 7
--~             'HEPA01SpeedIncrease03',	# 8
--~             'StatsBuff01',    			# 9
--~             'HEPA01Ooze04',     		# 10
--~             'StatsBuff02',        		# 11
--~             'StatsBuff03',    			# 12
--~             'StatsBuff04',    			# 13
--~             'StatsBuff05',     			# 14
--~             'HEPA01Acclimation', 		# 15
--~             'StatsBuff06',    			# 16
--~             'HEPA01BestialWrath01', 	# 17
--~             'HEPA01BestialWrath02',		# 18
--~             'HEPA01BestialWrath03',		# 19
--~             'HEPA01BestialWrath04',		# 20
--~ 			FavorItems = {'AchievementHealth','AchievementPotion'}, #'AchievementHealth' 'AchievementManaLeech'
--~ 			ItemWeights = {
--~ # 0.26.51 Updated equipmenet build based on the new priorities set in version 0.26.51	
--~ 				# Vlemish Faceguard
--~ 				# Increases the Mana Regeneration of you and nearby allied Demigods by 40 Mana per second.
--~ 				Item_Helm_040 = {
--~ 					Priority = -80,
--~ 				},
--~ 				--Scaled Helm
--~ 				--+750 Mana
--~ 				Item_Helm_010 = {
--~ 					Priority = -80,
--~ 				},
--~ 			    --Plenor Battlecrown
--~ 				--+1000 Mana
--~ 				---25% to ability cooldowns
--~ 				Item_Helm_030 = {
--~ 					Priority = -80,
--~ 				},
--~ 			    --Slayer's Wraps
--~ 				--5% chance to crit for double damage
--~ 				Item_Glove_070 = {
--~ 					Priority = 60,
--~ 				},
--~ 				# Orb of Defiance
--~ 				# Use: Become invulnerable for 5 seconds. Cannot move, attack or use abilities.
--~ 				# +500 Health
--~ 				# +500 Armor
--~ 				Item_Consumable_150 = {
--~ 					Priority = 30,
--~ 				},
--~ 				# Boots of Speed
--~ 				# 15% Base Run Speed
--~ 				Item_Boot_020 = {
--~ 					Priority = 25,
--~ 				},
--~ 				
--~ 				--Nature's Reckoning
--~ 				--15% chance on hit to strike nearby enemies with lightning for 250 damage
--~ 				Item_Ring_030 = {
--~ 					Priority = 35,
--~ 				},
--~ # 0.27.06 reduced value from 40 to 15
--~ 				# Narmoth's Ring
--~ 				# +15% Life Steal
--~ 				# When struck by melee attacks, the wearer reflects 90 damage back to the attacker.
--~ 				Item_Ring_050 = {
--~ 					Priority = 15,
--~ 				},
--~ 				# Bulwark of the Ages
--~ 				# +2500 Armor
--~ 				# All damage reduced by 25%.
--~ 				Item_Artifact_120 = {	
--~ 					Priority = 15,
--~ 				},	
--~ 				
--~ 				# Heart of Life
--~ 				# Use: Restore 3000 health and 3000 mana over 10 seconds. Any damage will break this effect.
--~ 				# +15 Health Regeneration
--~ 				# +50% Mana Regeneration
--~ 				Item_Consumable_160 = {
--~ 					Priority = -100,
--~ 				},	
--~ 			},
--~         },
--~ 		
--~     },

    SkillWeights = {
        # =====================
        # Ooze
        # =====================
        HEPA01Ooze01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.6,
                StructureKillValue = 0,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.2,
                SpeedDesire = -0.1,
            },
        },
        HEPA01Ooze02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.6,
                StructureKillValue = 0,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.2,
                SpeedDesire = -0.1,
            },
        },
        HEPA01Ooze03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.6,
                StructureKillValue = 0,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.2,
                SpeedDesire = -0.1,
            },
        },
        HEPA01Ooze04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.4,
                PushValue = 0.6,
                StructureKillValue = 0,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.2,
                SpeedDesire = -0.1,
            },
        },

        # =====================
        # Diseased Claws
        # =====================
        HEPA01DiseasedClaws01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.7,
                PushValue = 0.2,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.1,
                SpeedDesire = -0.1,
            },
        },
        HEPA01DiseasedClaws02 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.7,
                PushValue = 0.2,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.1,
                SpeedDesire = -0.1,
            },
        },
        HEPA01DiseasedClaws03 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.7,
                PushValue = 0.2,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.1,
                SpeedDesire = -0.1,
            },
        },

        # =====================
        # Post Mortem & Plague
        # =====================
        HEPA01PostMortem01 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.2,
                PushValue = 0.7,
                StructureKillValue = 0.1,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.1,
                SpeedDesire = -0.1,
            },
        },
        HEPA01Plague01 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.6,
                StructureKillValue = 0.1,
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.1,
                SpeedDesire = -0.1,
            },
        },
        HEPA01Plague02 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.3,
                PushValue = 0.6,
                StructureKillValue = 0.1,
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.1,
                SpeedDesire = -0.1,
            },
        },

        # =====================
        # Venom Spit
        # =====================
        HEPA01VenomSpit01 = {
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
            },
        },
        HEPA01VenomSpit02 = {
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
            },
        },
        HEPA01VenomSpit03 = {
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
            },
        },
        HEPA01VenomSpit04 = {
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
            },
        },
        HEPA01PutridFlow = {
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
        # Inner Beast
        # =====================
        HEPA01SpeedIncrease01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.3,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.1,
            },
        },
        HEPA01SpeedIncrease02 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.3,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.1,
            },
        },
        HEPA01SpeedIncrease03 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.3,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                PrimaryWeaponDesire = -0.2,
                HealthDesire = -0.1,
            },
        },
        HEPA01Acclimation = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.5,
                PushValue = 0.3,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
        },

        # =====================
        # Foul Grasp
        # =====================
        HEPA01FoulGrasp01 = {
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
                HealthDesire = -0.1,
                SpeedDesire = -0.1,
            },
        },
        HEPA01FoulGrasp02 = {
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
                HealthDesire = -0.1,
                SpeedDesire = -0.1,
            },
        },
        HEPA01FoulGrasp03 = {
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
                HealthDesire = -0.1,
                SpeedDesire = -0.1,
            },
        },

        # =====================
        # Bestial Wrath
        # =====================
        HEPA01BestialWrath01 = {
            BasePriority = 5,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.2,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.1,
                PrimaryWeaponDesire = -0.3,
                SpeedDesire = -0.1,
            },
        },
        HEPA01BestialWrath02 = {
            BasePriority = 8,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.2,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.1,
                PrimaryWeaponDesire = -0.3,
                SpeedDesire = -0.1,
            },
        },
        HEPA01BestialWrath03 = {
            BasePriority = 11,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.2,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.1,
                PrimaryWeaponDesire = -0.3,
                SpeedDesire = -0.1,
            },
        },
        HEPA01BestialWrath04 = {
            BasePriority = 14,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.2,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.1,
                PrimaryWeaponDesire = -0.3,
                SpeedDesire = -0.1,
            },
        },
        HEPA01BestialWrath05 = {
            BasePriority = 19,
            StrategicWeights = {
                AssassinValue = 0.6,
                PushValue = 0.2,
                StructureKillValue = 0.2,
            },
            SkillBonuses = {
            },
            ShopDesires = {
                HealthDesire = -0.1,
                PrimaryWeaponDesire = -0.3,
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