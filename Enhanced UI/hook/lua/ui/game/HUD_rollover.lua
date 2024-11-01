function DisplayRollover(unit)
    
    function rollover.Update(self)
        while true do
            if IsDestroyed(unit) then break end
            local pct = (unit:GetHealth() / unit:GetMaxHealth()) * 100.0
            rollover.health:SetValue(pct)  
            local healthtxt = math.floor(unit:GetHealth()) .. ' / ' .. math.floor(unit:GetMaxHealth())
            rollover.healthvalues:SetText(healthtxt)
			
			--------------------------------
			local unitData = EntityData[unit:GetEntityId()]
			local unitMana = unitData.Energy
			local unitManaMax = unitData.EnergyMax
			
			if unitManaMax > 0 then
				local manaPct = (unitMana / unitManaMax) * 100.0
				rollover.mana:SetValue(manaPct)
			
				local manatxt = math.floor(unitMana) .. ' / ' .. math.floor(unitManaMax)
	            rollover.manavalues:SetText(manatxt)
			end
			--------------------------------
			
            WaitFrames(1)
        end
    end
    
    if not IsDestroyed(rollover) then
        if unit and (unit != hero) and not IsDestroyed(unit) and ((hero and not hero:IsDead()) or (not hero and import('/lua/ui/game/gamemain.lua').GetReplayState())) then
            local bp = unit:GetBlueprint()
            local entityId = unit:GetEntityId()
            local data = EntityData[entityId]
            
            if not data then
                local id = BlipMap[entityId]
                if id then
                    data = EntityData[id]
                end
                
                if not data then
					return
				end
            end

            if EntityCategoryContains( categories.HERO, unit) then
                local playername = Armies[unit:GetArmy()].nickname
                local playerlevel = data.HeroLevel
                
                # We need to truncate the name if it won't fit in the rollover
                local shorterName = ''
                local newStrSize = 0
                for i = 1, string.len(playername) do
                    if newStrSize < 160 then
                        local tmpname = LOC(playername)
                        local tmpsubname = string.sub(string.sub(tmpname, i, i+1), 1, 1)

                        local tmp2 = UIUtil.CreateText(GetFrame(0), '', 16, UIUtil.bodyFont)
                        newStrSize = newStrSize + Text.GetTextWidth(LOC(tmpsubname), function(text) return tmp2:GetStringAdvance(text) end)
                        shorterName = shorterName .. tmpsubname
                        tmp2:Destroy()  
                    else
                        shorterName = shorterName .. '...'
                        break
                    end   
                end
                
                local concatname = shorterName .. ' (' .. playerlevel .. ')'

                rollover.Name:SetText(LOC(concatname))

                if hero and IsAlly(unit:GetArmy(), hero:GetArmy()) then
                    rollover.Name:SetColor(green)
                elseif hero and IsEnemy(unit:GetArmy(), hero:GetArmy()) then
                    rollover.Name:SetColor(red)
                elseif unit:GetArmy() == GetFocusArmy() then
                    rollover.Name:SetColor(UIUtil.specialFontColor)
                elseif not hero and import('/lua/ui/game/gamemain.lua').GetReplayState() then
                    rollover.Name:SetColor(UIUtil.specialFontColor)
                end  
                
                rollover.flagControl:SetText('')
            else
                rollover.Name:SetText(LOC(bp.Name))
                
                if hero and IsAlly(unit:GetArmy(), hero:GetArmy()) then
                   rollover.Name:SetColor(green)
                elseif hero and IsEnemy(unit:GetArmy(), hero:GetArmy()) then
                    rollover.Name:SetColor(red)
                else
                    rollover.Name:SetColor(UIUtil.specialFontColor)
                end
            end
            
            local baseHeight = nil
			
			------------------------------------------
			local unitMana = EntityData[unit:GetEntityId()].Energy
			local unitManaMax = EntityData[unit:GetEntityId()].EnergyMax
			local hasManaBar = false
			if unitManaMax > 0 then
				hasManaBar = true
			end
			------------------------------------------
            
            if EntityCategoryContains( categories.INVULNERABLE, unit) then
                rollover.healthbg:Hide()
                #rollover.Height:Set(25)
				
				------------------------------------------
				if hasManaBar then
					rollover.manabg:Show()
					rollover.Height:Set(46)
				else
					rollover.manabg:Hide()
					rollover.Height:Set(25)
				end
				------------------------------------------
				
                if not bp.Rollover.Options.ShowControllingTeam then
                    LayoutHelpers.Below(rollover.Desc, rollover.Name, 10)
                    baseHeight = 36
                else
                    LayoutHelpers.Below(rollover.Desc, rollover.flagControl, 34)
                    baseHeight = 78
                end
            else
                rollover.healthbg:Show()
                #rollover.Height:Set(56)
				
				------------------------------------------
				if hasManaBar then
					rollover.manabg:Show()
					rollover.Height:Set(77)
				else
					rollover.manabg:Hide()
					rollover.Height:Set(56)
				end
				------------------------------------------
				
                LayoutHelpers.Below(rollover.Desc, rollover.healthbg, 10)
                baseHeight = 62
            end
            
			-----------------------------------------------------
			
			-- Hides the icons and text. They will be shown if needed.
			
			for k, v in rollover.equipmentbg do
				v:Hide()
			end
			
			for k, v in rollover.consumablesbg do
				v:Hide()
			end
			
			rollover.favourbg:Hide()
			
			rollover.goldText:Hide()
			rollover.goldIcon:Hide()
			
			if EntityCategoryContains(categories.HERO, unit) then
			
				-- Equipment
				
				local inventory = EntityData[unit:GetEntityId()].Inventory
				
				if inventory then
				
					local equipment = inventory.Equipment
					
					for k, v in equipment.Slots do
						if table.getn(v) > 0 then
							local itemData = EntityData[v[1]]
							local def = Items[itemData.BlueprintId]
							local def2 = Ability[def.Abilities[1]]
							local equip = rollover.equipmentbg[k]
							
							if equip.over then
								equip.over:Destroy()
							end
							
							local iconFile = '/abilities/icons/' .. (def2.Icon or def.Icon) .. '.dds'
							iconFile = iconFile:gsub("/+", "/")
							equip.over = Bitmap(equip, UIUtil.UIFile(iconFile))
							equip.over.Width:Set(function() return equip.Width() end)
							equip.over.Height:Set(function() return equip.Height() end)
							LayoutHelpers.AtCenterIn(equip.over, equip, 0, 0)
							LayoutHelpers.DepthOverParent(equip.over, equip, 2)
							equip.over:DisableHitTest()
							
							equip:Show()
						end
					end
				
				end
				
				-- Consumables
				
				local inventory = EntityData[unit:GetEntityId()].Inventory
				
				if inventory then
				
					local consumables = inventory.Clickables
					
					for k, v in consumables.Slots do
						if table.getn(v) > 0 then
							local itemData = EntityData[v[1]]
							local def = Items[itemData.BlueprintId]
							local def2 = Ability[def.Abilities[1]]
							local consumable = rollover.consumablesbg[k]
							
							if consumable.over then
								consumable.over:Destroy()
							end
							
							local iconFile = '/abilities/icons/' .. (def2.Icon or def.Icon) .. '.dds'
							iconFile = iconFile:gsub("/+", "/")
							consumable.over = Bitmap(consumable, UIUtil.UIFile(iconFile))
							consumable.over.Width:Set(function() return consumable.Width() end)
							consumable.over.Height:Set(function() return consumable.Height() end)
							LayoutHelpers.AtCenterIn(consumable.over, consumable, 0, 0)
							LayoutHelpers.DepthOverParent(consumable.over, consumable, 2)
							consumable.over:DisableHitTest()
							
							consumable:Show()
						end
					end
				
				end
				
				-- Favour Item
				
				local inventory = EntityData[unit:GetEntityId()].Inventory
				
				if inventory then
				
					local favour = inventory.Achievement
					
					if favour and favour.Slots and table.getn(favour.Slots) > 0 then
						local itemData = EntityData[favour.Slots[1][1]]
						local def = Items[itemData.BlueprintId]
						local def2 = Ability[def.Abilities[1]]
						local favouritem = rollover.favourbg
						
						if favouritem.over then
							favouritem.over:Destroy()
						end
						
						local iconFile = '/abilities/icons/' .. (def2.Icon or def.Icon) .. '.dds'
						iconFile = iconFile:gsub("/+", "/")
						favouritem.over = Bitmap(favouritem, UIUtil.UIFile(iconFile))
						favouritem.over.Width:Set(function() return favouritem.Width() end)
						favouritem.over.Height:Set(function() return favouritem.Height() end)
						LayoutHelpers.AtCenterIn(favouritem.over, favouritem, 0, 0)
						LayoutHelpers.DepthOverParent(favouritem.over, favouritem, 2)
						favouritem.over:DisableHitTest()
						
						favouritem:Show()
					end
				
				end
				
				-- Gold
				-- Code developed by miriyaka and added by pacov
				-- The following code changes the ui so that only allied gold is visible
				
				 if GetFocusArmy() < 1 or IsAlly(unit:GetArmy(), GetFocusArmy()) then
                     local gold = ArmyGold[unit:GetArmy()]
                     if gold and gold > 0 then
                         rollover.goldText:SetText(string.format("%d", math.floor(gold)))
                         rollover.goldText:Show()
                         rollover.goldIcon:Show()
                     end
                 end
			end
			
			-- Buffs and Debuffs
			
			local buffIconSize = 32
			
			rollover.buffs:DestroyAllItems(true)
			rollover.debuffs:DestroyAllItems(true)
			
			local buffTable = EntityData[unit:GetEntityId()].Buffs
			
			if buffTable then
				for index, buff in buffTable do
					local def = Buffs[buff]
					
					if def and def.Icon then
						local path = GetBuffIcon(def.Icon)
						local icon = Bitmap(rollover.buffs, path)
						icon.Width:Set(buffIconSize)
						icon.Height:Set(buffIconSize)
						icon.Depth:Set(function() return (rollover.buffs.Depth() + 1000) end)
						
						if def.Debuff then
							# Find next available buff slot
							for i = 1, 6 do
								if not rollover.debuffs:GetItem(i, 1) then
									rollover.debuffs:SetItem(icon, i, 1, true)
									break
								end
							end 
							rollover.debuffs:EndBatch()
						else
							# We're placing these right to left for symmetry in the Buffs
							for i = 6, 1, -1 do
								if not rollover.buffs:GetItem(i, 1) then
									rollover.buffs:SetItem(icon, i, 1, true)
									break
								end
							end 
							rollover.buffs:EndBatch()
						end
					end
				end
			end
			
			
			
            -----------------------------------------------------
            
            if bp.Rollover then
                local errorString = '<LOC ROLLOVER_0003>ROLLOVER DATA ERROR'
                local desc = errorString
                
                # Data useful for several rollovertypes
                local scenInfo = SessionGetScenarioInfo()
                local syncData = Common.GetSyncData(unit)
                
                # Get the appropriate description depending on what type of rollover this is
                if bp.Rollover.Source == 'Ability' then
                    local rolloverBP = Ability[ bp.Rollover.SourceName ]
                    desc = UIUtil.ProcessString( LOC(rolloverBP.Description), rolloverBP ) 
                    
                elseif bp.Rollover.Source == 'ArmyBonus' then
                    local rolloverBP = ArmyBonuses[ bp.Rollover.SourceName ]
                    desc = UIUtil.ProcessString( LOC(rolloverBP.Description), rolloverBP )
                             
                elseif bp.Rollover.Source == 'Buff' then
                    local rolloverBP = Buffs[ bp.Rollover.SourceName ]
                    desc = UIUtil.ProcessString( LOC(rolloverBP.Description), rolloverBP ) 
                    
                elseif bp.Rollover.Source == 'DroppedItem' then
                    local rolloverBP = Items[ syncData.BlueprintId ]
                    
                    local title = LOC(rolloverBP.DisplayName or errorString)
                    rollover.Name:SetText( title )

                    # Desc is an error msg by default, but for dropped items we want no error msg at all                    
                    desc = nil
                    
                elseif bp.Rollover.Source == 'Powerup' then                    
                    local rolloverBP = PowerUps[ syncData.BlueprintId ]
                    desc = UIUtil.ProcessString( LOC(rolloverBP.Description), rolloverBP )
                    
                    local title = LOC(rolloverBP.DisplayName or errorString)
                    rollover.Name:SetText( title )
                    
                elseif bp.Rollover.Source == 'RolloverBlock' then
                    desc = LOC(bp.Rollover.Description)
                    
                end
                
                
                # Overwrite the title of the rollover to something other than the blueprint name
                local titleOverwrite = bp.Rollover.TitleOverwrite
                if titleOverwrite then
                    local title
                    
                    if titleOverwrite.Type == 'Flag' then
                    
                        # Pull the title from the map save file
                        local saveData = {}
                        doscript('/lua/dataInit.lua', saveData)
                        doscript(scenInfo.save, saveData)
                        
                        local markerName = syncData.UnitName
                        title = saveData.Scenario.MasterChain._MASTERCHAIN_.Markers[ markerName ].FlagDisplayName
                    
                    elseif titleOverwrite.Type == 'Forces' then
                        
                        # Display one of two names depending on if the unit is on the Forces of Light or Forces of Dark
                        local team = Armies[ syncData.Army ].name
                        
                        if      team == 'TEAM_1' then   title = titleOverwrite.DisplayNameLight
                        elseif  team == 'TEAM_2' then   title = titleOverwrite.DisplayNameDark
                        end
                        
                    end
                    
                    rollover.Name:SetText( LOC(title or errorString) )                        
                end
                
                
                # Misc options that may be added to the rollover
                local options = bp.Rollover.Options

                # Display who the controlling army is
                if options.ShowControllingTeam == true then
                    local controlStr
                    local team = Armies[ syncData.Army ].name
                    
                    if      team == 'TEAM_1' then   controlStr = '<LOC ROLLOVER_0000>Forces of Light'
                    elseif  team == 'TEAM_2' then   controlStr = '<LOC ROLLOVER_0001>Forces of Darkness'
                    else                            controlStr = '<LOC ROLLOVER_0002>Contested'
                    end
                    
                    rollover.flagControl:SetText(LOC(controlStr))
                    
                    if not mouseoverFlagView then
                        mouseoverFlagView = import('/lua/ui/game/flagView.lua').Create(rollover, false)
                        LayoutHelpers.Below(mouseoverFlagView, rollover.flagControl, 7)
                        LayoutHelpers.AtHorizontalCenterIn(mouseoverFlagView, rollover)
                    end
                else                        
                    rollover.flagControl:SetText('')
                    if mouseoverFlagView then
                        mouseoverFlagView:Destroy()
                        mouseoverFlagView = nil
                    end
                end
                    
                # Display who the controlling hero is
                if options.ShowControllingArmy == true then
                    local controlStr = LOCF('<LOC ROLLOVER_0004>Controlled by %s', Armies[ syncData.Army ].nickname)
                    
                    # Caryn, work your magic and put controlStr here
                    # It uses the player nickname, be wary of exceptionally long names!
                    desc = desc .. '\n' .. controlStr
                else
                    # Caryn, update this appropriately
                    #rollover.ShowControllingArmyVariableName:SetText('')
                end                
                
                
                # Set the text
                if desc then
                    UIUtil.SetTextBoxText(rollover.Desc, desc)
                                           
                    # Determine the height
                    local tmp = UIUtil.CreateText(rollover, '', 16, UIUtil.bodyFont)
                    local lineWidth = rollover.Width() - 40
                    local lineHeight = 20
			        local tmptblDesc = Text.WrapText(desc, lineWidth, function(text) return tmp:GetStringAdvance(text) end)
			        tmp:Destroy() 

                    local descHeight = baseHeight + (table.getsize(tmptblDesc) * lineHeight)
                    rollover.Desc.Height:Set(function() return (table.getsize(tmptblDesc) * lineHeight) end)
                    rollover.Height:Set(descHeight)
                else
                    UIUtil.SetTextBoxText(rollover.Desc, '')
                end
                
            else
                #rollover.Desc:SetText("")
                UIUtil.SetTextBoxText(rollover.Desc, '')
            end

            if rollover:GetAlpha() == 0 then
                EffectHelpers.FadeIn(rollover, 0.2)
            end

            if thread then
                KillThread(thread)
                thread = false     
            end
            
            thread = ForkThread(rollover.Update)
        else 
            if thread then
                KillThread(thread)
                thread = false
            end
            
            if rollover:GetAlpha() == 1 then
                EffectHelpers.FadeOut(rollover, 0.2)
                rollover.healthbg:Hide()
				
				----------------------------------------
				rollover.manabg:Hide()
				
				for k, v in rollover.equipmentbg do
					v:Hide()
				end
				
				for k, v in rollover.consumablesbg do
					v:Hide()
				end
				
				rollover.favourbg:Hide()
				
				rollover.goldText:Hide()
				rollover.goldIcon:Hide()
				----------------------------------------
				
            end
        end
    end
end

function Create(parent)
    
    InGameUI.OnFocusArmyHeroChange:Add( OnHeroChange )

    rollover = Group(parent)
    rollover.Depth:Set(function() return parent.Depth() + 20000 end)
    rollover.Width:Set(250)
    rollover.Height:Set(42)
    
    local lineWidth = rollover.Width() - 40
    local tooltipHeight = 0
    
    local imgtop = Bitmap(rollover, '/textures/ui/common/tooltips/tooltip_top.dds')
    imgtop.Width:Set(250)
    imgtop.Height:Set(28)
    LayoutHelpers.AtLeftTopIn(imgtop, rollover)

    local imgmid = Bitmap(rollover, '/textures/ui/common/tooltips/tooltip_mid.dds')
    imgmid.Width:Set(250)
    imgmid.Height:Set(function() return rollover.Height() - imgtop.Height() end)
    LayoutHelpers.AnchorToBottom(imgmid, imgtop)
    LayoutHelpers.AtLeftIn(imgmid, imgtop)
    
    local imgbtm = Bitmap(rollover, '/textures/ui/common/tooltips/tooltip_btm.dds')
    imgbtm.Width:Set(250)
    imgbtm.Height:Set(27)
    LayoutHelpers.AnchorToBottom(imgbtm, imgmid)
    LayoutHelpers.AtLeftIn(imgbtm, imgmid)
    
    ### Name
    rollover.Name = UIUtil.CreateText(rollover, '', 18, UIUtil.bodyFont)
    LayoutHelpers.AtLeftTopIn(rollover.Name, rollover, 20, 15)
    rollover.Name:SetColor(green)
    
    ### Flag control, if needed
    rollover.flagControl = UIUtil.CreateText(rollover, '', 16, UIUtil.bodyFont)
    LayoutHelpers.AtLeftIn(rollover.flagControl, rollover.Name)
    LayoutHelpers.Below(rollover.flagControl, rollover.Name)
    rollover.flagControl:SetColor(UIUtil.specialFontColor)
    
    ### Health
    #rollover.healthbg = Bitmap(rollover, '/textures/ui/hud/bars/rollover_healthbar_overlay.dds')
    rollover.healthbg = Bitmap(rollover)
    rollover.healthbg.Width:Set(function() return rollover.Width() - 56 end)
    rollover.healthbg.Height:Set(18)
    LayoutHelpers.Below(rollover.healthbg, rollover.Name, 8)
    LayoutHelpers.AtHorizontalCenterIn(rollover.healthbg, rollover)
    LayoutHelpers.DepthOverParent(rollover.healthbg, rollover, 10)
    rollover.healthbg:SetSolidColor('88004400')

    rollover.health = StatusBar(rollover.healthbg, 0, 100, false, false, false, false, "Rollover Health Bar")
    LayoutHelpers.AtLeftTopIn(rollover.health, rollover.healthbg)
    rollover.health:DisableHitTest(true)
    LayoutHelpers.FillParent(rollover.health, rollover.healthbg)
    LayoutHelpers.DepthUnderParent(rollover.health, rollover.healthbg)
    LayoutHelpers.ResetWidth(rollover.health)
    LayoutHelpers.ResetHeight(rollover.health)
    rollover.health._bar:SetSolidColor(green)
    rollover.health:SetValue(100)
    
    rollover.healthoverlay = Bitmap(rollover.healthbg, '/textures/ui/hud/bars/rollover_healthbar_overlay.dds')
    rollover.healthoverlay.Width:Set(210)
    rollover.healthoverlay.Height:Set(26)
    LayoutHelpers.AtCenterIn(rollover.healthoverlay, rollover.healthbg, 0, 1)
    LayoutHelpers.DepthOverParent(rollover.healthoverlay, rollover.healthbg, 100)
    
    rollover.healthvalues = UIUtil.CreateText(rollover.healthbg, '', 12, UIUtil.bodyFont)
    rollover.healthvalues:SetColor(yellow)
    LayoutHelpers.AtCenterIn(rollover.healthvalues, rollover.healthbg)
    LayoutHelpers.DepthOverParent(rollover.healthvalues, rollover.healthoverlay, 2)
    rollover.healthvalues:SetDropShadow(true)
	
	--------------------------------------------------
	
	-- Mana
    rollover.manabg = Bitmap(rollover)
    rollover.manabg.Width:Set(function() return rollover.Width() - 56 end)
    rollover.manabg.Height:Set(18)
    LayoutHelpers.CenteredBelow(rollover.manabg, rollover.healthbg, 4)
    #LayoutHelpers.AtHorizontalCenterIn(rollover.manabg, rollover)
    LayoutHelpers.DepthOverParent(rollover.manabg, rollover, 10)
    rollover.manabg:SetSolidColor('440000ff')

    rollover.mana = StatusBar(rollover.manabg, 0, 100, false, false, false, false, "Rollover Mana Bar")
    LayoutHelpers.AtLeftTopIn(rollover.mana, rollover.manabg)
    rollover.mana:DisableHitTest(true)
    LayoutHelpers.FillParent(rollover.mana, rollover.manabg)
    LayoutHelpers.ResetWidth(rollover.mana)
    LayoutHelpers.ResetHeight(rollover.mana)
    rollover.mana._bar:SetSolidColor(blue)
    rollover.mana:SetValue(100)
	
	rollover.manaoverlay = Bitmap(rollover.manabg, '/textures/ui/hud/bars/rollover_healthbar_overlay.dds')
    rollover.manaoverlay.Width:Set(210)
    rollover.manaoverlay.Height:Set(26)
    LayoutHelpers.AtCenterIn(rollover.manaoverlay, rollover.manabg, 0, 1)
    LayoutHelpers.DepthOverParent(rollover.manaoverlay, rollover.manabg, 100)
    
    rollover.manavalues = UIUtil.CreateText(rollover.manabg, '', 12, UIUtil.bodyFont)
    rollover.manavalues:SetColor(yellow)
    LayoutHelpers.AtCenterIn(rollover.manavalues, rollover.manabg)
    LayoutHelpers.DepthOverParent(rollover.manavalues, rollover.mana, 2)
    rollover.manavalues:SetDropShadow(true)
	
	-- Equipment
	
	rollover.equipmentbg = {}
	for i=1, 5 do
		rollover.equipmentbg[i] = Bitmap(rollover, UIUtil.UIFile('/icons/icon_equipment.dds'))
		rollover.equipmentbg[i].Width:Set(50)
		rollover.equipmentbg[i].Height:Set(50)
		LayoutHelpers.Above(rollover.equipmentbg[i], rollover)
		if i == 1 then
			LayoutHelpers.AtLeftIn(rollover.equipmentbg[i], rollover, -2)
		else
			LayoutHelpers.RightOf(rollover.equipmentbg[i], rollover.equipmentbg[i-1])
		end
		LayoutHelpers.DepthOverParent(rollover.equipmentbg[i], rollover, 10)
		#rollover.equipmentbg[i]:SetSolidColor('44ffffff')
	end
	
	-- Consumables
	
	rollover.consumablesbg = {}
	for i=1, 3 do
		rollover.consumablesbg[i] = Bitmap(rollover, UIUtil.UIFile('/icons/icon_clickable.dds'))
		rollover.consumablesbg[i].Width:Set(25)
		rollover.consumablesbg[i].Height:Set(25)
		if i == 1 then
			LayoutHelpers.LeftOf(rollover.consumablesbg[i], rollover, -3)
			LayoutHelpers.AtTopIn(rollover.consumablesbg[i], rollover, 16)
		else
			LayoutHelpers.CenteredBelow(rollover.consumablesbg[i], rollover.consumablesbg[i-1])
		end
		LayoutHelpers.DepthOverParent(rollover.consumablesbg[i], rollover, 10)
		#rollover.consumablesbg[i]:SetSolidColor('44ffffff')
	end
	
	-- Favour Item
	
	rollover.favourbg = {}
	rollover.favourbg = Bitmap(rollover, UIUtil.UIFile('/icons/icon_achievement.dds'))
	rollover.favourbg.Width:Set(25)
	rollover.favourbg.Height:Set(25)
	LayoutHelpers.CenteredAbove(rollover.favourbg, rollover.consumablesbg[1])
	LayoutHelpers.DepthOverParent(rollover.favourbg, rollover, 10)
	#rollover.favourbg:SetSolidColor('44ffffff')
	
	-- Buffs
	
    rollover.buffs = Grid(rollover, GameCommon.iconWidth, GameCommon.iconHeight, "Rollover Hero Buffs")
	
    local rows = 1
    local cols = 6

    rollover.buffs:AppendRows(rows)
    rollover.buffs:AppendCols(cols)

    rollover.buffs.Width:Set( GameCommon.iconWidth * cols )
    rollover.buffs.Height:Set( GameCommon.iconHeight * rows )
    LayoutHelpers.CenteredBelow(rollover.buffs, rollover, 18)
	
    -- Debuffs
	
    rollover.debuffs = Grid(rollover, GameCommon.iconWidth, GameCommon.iconHeight, "Rollover Hero Debuffs")

    local rows = 1
    local cols = 6

    rollover.debuffs:AppendRows(rows)
    rollover.debuffs:AppendCols(cols)

    rollover.debuffs.Width:Set( GameCommon.iconWidth * cols )
    rollover.debuffs.Height:Set( GameCommon.iconHeight * rows )
    LayoutHelpers.CenteredBelow(rollover.debuffs, rollover.buffs)
	
	-- Gold
	
	rollover.goldText = UIUtil.CreateText(rollover, '', 14, UIUtil.bodyFont)
	rollover.goldText:SetDropShadow(true)
	rollover.goldText:SetColor('ffefda9c')
	LayoutHelpers.AtVerticalCenterIn(rollover.goldText, rollover.Name)
	LayoutHelpers.AtRightIn(rollover.goldText, rollover, 17)
	
	rollover.goldIcon = Bitmap(rollover, '/textures/ui/common/icons/gold.dds')
	rollover.goldIcon.Width:Set(20)
	rollover.goldIcon.Height:Set(20)
	LayoutHelpers.CenteredLeftOf(rollover.goldIcon, rollover.goldText)
	
	--------------------------------------------------
    
    ### Description
    #rollover.Desc = UIUtil.CreateText(rollover, '', 14, UIUtil.bodyFont)
    #LayoutHelpers.Below(rollover.Desc, rollover.healthbg, 5, 8)
    #rollover.Desc:SetColor(UIUtil.specialFontColor)
    
    rollover.Desc = UIUtil.CreateTextBox(rollover, 16, UIUtil.bodyFont, false)
    rollover.Desc.Width:Set(function() return rollover.Width() - 40 end)
    rollover.Desc.Height:Set(60)
    LayoutHelpers.Below(rollover.Desc, rollover.healthoverlay, 10)
    rollover.Desc:SetColors(white, '00000000', white, '00000000')
    
    #local mouseoverFlagView = import('/lua/ui/game/flagView.lua').Create(rollover, false)
    #LayoutHelpers.Below(mouseoverFlagView, rollover.flagControl, 7)
    #LayoutHelpers.AtHorizontalCenterIn(mouseoverFlagView, rollover)

    rollover:SetAlpha(0)
    rollover:Hide()
    
    return rollover
end

--------------------------------------------------
function GetBuffIcon(id)
    local icon = "/abilities/icons/" .. id .. ".dds"
    icon = icon:gsub("/+", "/")
    return UIUtil.SkinnableFile(icon)
end
--------------------------------------------------