do
	local GameMain = import('/lua/ui/game/gamemain.lua')

	local minionButtons = { }
	local numMinionButtons = 0
	local nextMinionButtonId = 1

	local function StartsWith (txt, start)
		return string.sub(txt,1,string.len(start)) == start
	end

	local function GetAbilityMinionInfo(abilityDef)
		local maxUnits = nil;
		local category = nil;
		local mtype = nil;
		local selectsound = nil;
		if StartsWith(abilityDef.Name, "Item_High_Priest_") then
			maxUnits = abilityDef.MaxUnits
			category = "HIGHPRIEST"
			mtype = 'Priests'
			selectsound = 'Forge/UI/Hud/snd_ui_hud_priests_select'
		elseif StartsWith(abilityDef.Name, "Item_Minotaur_Captain_") then
			maxUnits = abilityDef.MaxUnits
			category = "MINOCAPTAIN"
			mtype = 'Soldiers'
			selectsound = 'Forge/UI/Hud/ZZsnd_ui_hud_soldiers_select'
		elseif StartsWith(abilityDef.Name, "Item_Siege_Archer_") then
			maxUnits = abilityDef.MaxUnits
			category = "SIEGEARCHER"
			mtype = 'Archers'
			selectsound = 'Forge/UI/Hud/snd_ui_hud_archers_select'
		elseif StartsWith(abilityDef.Name, "HSednaYeti") then
			maxUnits = abilityDef.MaxYeti
			mtype = 'Special'
			category = 'SPECIALUNIT'
			selectsound = 'Forge/UI/Hud/ZZsnd_ui_hud_special_minion_select'
--[[		elseif StartsWith(abilityDef.Name, "HVampireConversion") then
			local hero = InGameUI.GetFocusArmyHero()
			if (hero and not hero:IsDead()) then
				local syncData = Common.GetSyncData(hero)

				LOG('skills=' .. repr(syncData.Skills))
				maxUnits = 1#abilityDef.Buffs[abilityDef.Name].VampireMax
				mtype = 'Special'
				category = 'SPECIALUNIT'
				selectsound = 'Forge/UI/Hud/ZZsnd_ui_hud_special_minion_select'
			end
		elseif StartsWith(abilityDef.Name, "HRookTower") then
			maxUnits = abilityDef.GetMaxTowers()
			mtype = 'Special'
			category = 'SPECIALUNIT'
			selectsound = 'Forge/UI/Hud/ZZsnd_ui_hud_special_minion_select'
--]]		elseif StartsWith(abilityDef.Name, "HQueenShambler") then
			maxUnits = abilityDef.MaxShamblers
			mtype = 'Special'
			category = 'SPECIALUNIT'
			selectsound = 'Forge/UI/Hud/ZZsnd_ui_hud_special_minion_select'
		elseif StartsWith(abilityDef.Name, "HOculusBallLightning") then
			maxUnits = abilityDef.MaxBalls
			mtype = 'Special'
			category = 'SPECIALUNIT'
			selectsound = 'Forge/UI/Hud/ZZsnd_ui_hud_special_minion_select'
		elseif StartsWith(abilityDef.Name, "HOAKRaiseDeadWard") then
			maxUnits = Buffs[string.gsub(abilityDef.Name, 'HOAKRaiseDeadWard', 'HOAKSpiritOfWar')].SpiritMax
			mtype = 'Special'
			category = 'SPECIALUNIT'
			selectsound = 'Forge/UI/Hud/ZZsnd_ui_hud_special_minion_select'
		end

		return { maxUnits=maxUnits, category=category, mtype=mtype, selectsound=selectsound }
	end

	# The health colors
	local black = '/Mods/Enhanced UI/img/circle_black.dds'
	local red = '/Mods/Enhanced UI/img/circle_red.dds'
	local yellow = '/Mods/Enhanced UI/img/circle_yellow.dds'
	local green = '/Mods/Enhanced UI/img/circle_green.dds'

	local function GetMinionIndColor(minion)
		if minion == nil or IsDestroyed(minion) then return black end

		local hp = minion:GetHealth()
		if hp <= 0 then return black end

		local maxhp = minion:GetMaxHealth()
		if maxhp < 1 then return black end -- wtf

		local pctHealth = hp / maxhp

		if pctHealth > 0.666 then
			return green
		elseif pctHealth > 0.333 then
			return yellow
		else
			return red
		end
		
	end

	# The images we use for our minion indicators
	local function MinionButtonImages()
		return	'/Mods/Enhanced UI/img/circle_normal.dds',
			'/Mods/Enhanced UI/img/circle_glow.dds',
			'/Mods/Enhanced UI/img/circle_glow.dds',
			'/Mods/Enhanced UI/img/circle_normal.dds'
	end

	# Updates the color if necessary
	local function MinionIndSetColor(ind, newcolor)
		if ind.MinionColor ~= newcolor then
			ind.MinionColor = newcolor
			ind.MinionColorSpot:SetTexture(newcolor)
			ind.MinionColorSpot:Play()
		end
	end

	local function MinionIndChangeTexture(ind, newText)
		if ind.mNormal ~= newText then
			ind.mNormal = newText
			ind:ApplyTextures()
		end
	end

	local MinionIndicatorUnit = nil
	local MinionIndicatorId = nil

	# Updates the display of a minion button overlay
	local function MinionButtonUpdate(button, hero, syncData, minions, selectedUnits)
		local myminions = minions[button.minionInfo.mtype]
		local haveSeen = { }

		# Set the minion count
		if (button.minionCount ~= myminions.count) then
			button.minionCount = myminions.count
			button.minionCountLabel:SetText('' .. button.minionCount)
		end

		# Next go through our indicators and empty any that no longer have living minions, and update the ones that are still alive
		for i,ind in ipairs(button.MinionIndicators) do
			if ind.MinionId ~= nil then
				# Does this minion still exist?
				local minion = myminions.units[ind.MinionId]
				if minion then
					# Yes.  Update the indicator color
					MinionIndSetColor(ind, GetMinionIndColor(minion))
					# If this unit is selected then tag our indicator appropriately
					if selectedUnits[ind.MinionId] then
						MinionIndChangeTexture(ind, ind.mHighlight)
					else
						MinionIndChangeTexture(ind, ind.mDisabled)
					end
					# Now remember we have processed this minion
					haveSeen[ind.MinionId] = true
				else
					# Minion is dead.  Reset the indicator
					if MinionIndicatorId == ind.MinionId then
						MinionIndicatorId = nil
						MinionIndicatorUnit = nil
					end
					ind.MinionId = nil
					MinionIndSetColor(ind, black)
					MinionIndChangeTexture(ind, ind.mDisabled)
				end
			end
		end

		# Finally go through any minions that have not been processed and assign them to an indicator
		local nextInd = 1
		local lastInd = table.getn(button.MinionIndicators)
		if nextInd <= lastInd then
			for minionId, minion in pairs(myminions.units) do
				if not haveSeen[minionId] then
					# This minion needs to be assigned to the next available indicator
					local ind = nil
					while ind == nil and nextInd <= lastInd do
						if button.MinionIndicators[nextInd].MinionId == nil then
							# This indicator is available
							ind = button.MinionIndicators[nextInd]
						end
						nextInd = nextInd + 1
					end
					if ind == nil then
						# No more indicators available
						break
					end

					ind.MinionId = minionId
					MinionIndSetColor(ind, GetMinionIndColor(minion))
				end
			end
		end
		# All done!
	end
	local showBeatLog = false

	# Finds all of the minions assigned to this hero
	local function MinionGetMinions(hero, syncData)
		-- for each type of minion, count how many there are and build a dictionary of them that is keyed by EntityId (since our minion indicators keep an EntityId)
		local minions = { Priests = { count=0, units={ } }, Soldiers = { count=0, units={ } }, Archers = { count=0, units={ } }, Special = { count=0, units={ } } }
		local units = UIGetUnitsInCategory("MINION") -- returns only minions that belong to this hero

		if units then
			for i,minion in ipairs(units) do
				if minion and not IsDestroyed(minion) and minion:GetHealth() > 0 then
					local which = nil;
					if EntityCategoryContains( categories.MINOCAPTAIN, minion ) then
						which = 'Soldiers'
					elseif EntityCategoryContains( categories.SIEGEARCHER, minion ) then
						which = 'Archers'
					elseif EntityCategoryContains( categories.HIGHPRIEST, minion ) then
						which = 'Priests'
					else
						which = 'Special'
					end

					minions[which].count = minions[which].count + 1
					minions[which].units[minion:GetEntityId()] = minion
				elseif showBeatLog then
					if minion and IsDestroyed(minion) then
						LOG('Minion is destroyed.')
					elseif minion and minion:GetHealth() <= 0 then
						LOG('Minion health is ' .. minion:GetHealth())
					else
						LOG('minion is nil')
					end
				end
			end
		end

		if showBeatLog then
			LOG('Minions=' .. minions.Priests.count .. ' ' .. minions.Soldiers.count .. ' ' .. minions.Archers.count .. ' ' .. minions.Special.count)
		end

		return minions
	end

	# Called once per beat and updates all minion buttons
	local function MinionOverlayBeat()

		#LOG('MINION BEAT')
		local hero = InGameUI.GetFocusArmyHero()
		if (hero and not hero:IsDead()) then
			local syncData = Common.GetSyncData(hero)
			if not syncData.MinionCounts then
				return
			end

			local minions = MinionGetMinions(hero, syncData)
			local selectedUnits = GetSelectedUnits() or { }
			local selectedDict = { }
			for i,v in ipairs(selectedUnits) do
				selectedDict[v:GetEntityId()] = v
			end

			# Loop through each minion button and set it up
			for id, button in pairs(minionButtons) do MinionButtonUpdate(button, hero, syncData, minions, selectedDict) end
		end
	end

	local function MinionOverlayOnDestroy(button)

		#LOG('*************' .. button.abilityDef.Name .. '(' .. repr(button.minionSource) .. ') DESTROYED')
		minionButtons[button.minionId] = nil

		# Remove the BeatCallback if this was the last minion button
		numMinionButtons = numMinionButtons - 1
		if numMinionButtons < 1 then
			GameMain.BeatCallback:Remove(MinionOverlayBeat)
		end

		# Call original OnDestroy
		button.MinionOverlayOldOnDestroy(button)
	end

	local function MinionAddMinionToSelection(minion)
		local selected = GetSelectedUnits()
		if selected == nil then
			SelectUnits({minion})
		else
			# Toggle the minions selection
			local newSelected = { }
			local missing = true
			local minionId = minion:GetEntityId()
			for i,v in ipairs(selected) do
				if v:GetEntityId() == minionId then
					missing = false
				else
					table.insert(newSelected, v)
				end
			end
			if missing then
				table.insert(newSelected, minion)
			end

			SelectUnits(newSelected)
		end
	end

	# Creates all the minion health indicators
	local function CreateMinionIndicators(button, InvType)

		# First plan where they will go based on how many we will need for this ability
		local locations = { }
		local buttonHeight = button.Height()
		local indSize = 16
		if InvType == 'ability' then
			indSize = 20
			buttonHeight = 78
		end

		local radius = buttonHeight * 0.5 - indSize / 2
		if button.minionInfo.maxUnits == 1 then
			# due north
			table.insert(locations, { -radius, 0})
		elseif button.minionInfo.maxUnits == 2 then
			# NW and NE
			local xy = radius / math.sqrt(2)
			table.insert(locations, { -xy, -xy })
			table.insert(locations, { -xy, xy })
		elseif button.minionInfo.maxUnits == 3 then
			# W, N, E
			table.insert(locations, { 0, -radius })
			table.insert(locations, { -radius, 0 })
			table.insert(locations, { 0, radius })
		elseif button.minionInfo.maxUnits == 4 then
			# W, NW, NE, E
			local xy = radius / math.sqrt(2)
			table.insert(locations, { 0, -radius })
			table.insert(locations, { -xy, -xy })
			table.insert(locations, { -xy, xy })
			table.insert(locations, { 0, radius })
		end
		-- anything over 4 gets no locations which will cause no minion indicators to be created
		
		
		button.MinionIndicators = { }
		# Now loop through each location and make the indicator
		for i,loc in ipairs(locations) do
			local ind = Button(button, MinionButtonImages())
			ind.Width:Set(indSize)
			ind.Height:Set(indSize)
			LayoutHelpers.AtCenterIn(ind, button, loc[1], loc[2])
			LayoutHelpers.DepthOverParent(ind, button, 100) -- puts us on top of the cooldown overlay

			# Create center overlay that will color-code the health of the minion
			ind.MinionColorSpot = Bitmap(button, black)
			ind.MinionColorSpot.Width:Set(indSize)
			ind.MinionColorSpot.Height:Set(indSize)
			LayoutHelpers.AtCenterIn(ind.MinionColorSpot, button, loc[1], loc[2])
			LayoutHelpers.DepthOverParent(ind.MinionColorSpot, button, 101) -- puts us on top of the cooldown overlay
			ind.MinionColorSpot:DisableHitTest()

			ind:UseAlphaHitTest(false)
			ind.OnClick = function(self, modifiers)
				if self.MinionId == nil or (modifiers.Left and GameMain.GetReplayState()) then
					return
				end

				# Select the minion if we can find it
				local minion = GetUnitById(self.MinionId)
				if minion and not IsDestroyed(minion) and minion:GetHealth() > 0 then
					if modifiers.Left then
						if modifiers.Shift then
							MinionAddMinionToSelection(minion)
						else
							SelectUnits( { minion } )
						end
						PlaySound(button.minionInfo.selectsound)
					else
						-- center camera on minion
						local cam = GetCamera('WorldCamera')
						local settings = cam:SaveSettings()
						local hpr = { settings.Heading, settings.Pitch, 0.0 }
						cam:MoveTo (minion:GetPosition(), hpr, settings.Zoom, 0.5)
					end
				end
			end

			ind.HandleEvent = function(self, event)
				if event.Type == 'MouseEnter' then
					if self.MinionId ~= nil then
						MinionIndicatorUnit = GetUnitById(self.MinionId)
						MinionIndicatorId = self.MinionId
					else
						MinionIndicatorUnit = nil
					end
				elseif event.Type == 'MouseExit' then
					MinionIndicatorUnit = nil
				end

				return Button.HandleEvent(self, event)
			end

			ind.MinionColor = black
			ind.MinionId = nil
			table.insert(button.MinionIndicators, ind)
		end
	end

	local origDisplayRollover = nil

	local function CreateMinionOverlay(button, info, source, InvType)

		#LOG('*************' .. button.abilityDef.Name .. '(' .. repr(source) .. ') CREATED')

		# Override DisplayRollover if we need to
		if origDisplayRollover == nil then
			origDisplayRollover = import('/lua/ui/game/HUD_rollover.lua').DisplayRollover
			import('/lua/ui/game/HUD_rollover.lua').DisplayRollover = function(unit)
				local u = unit
				if not unit then u = MinionIndicatorUnit end
				origDisplayRollover(u)
			end
		end

		button.minionInfo = info
		button.minionCount = 0
		button.minionSource = source
		button.minionId = nextMinionButtonId
		nextMinionButtonId = nextMinionButtonId + 1
		minionButtons[button.minionId] = button

		local indSize = 16
		if InvType == 'ability' then
			indSize = 20
		end
		# Create the count indicator
		# button.minionCountBG = Bitmap(button, UIUtil.UIFile('/bg/bg_hotkey.dds'))
		button.minionCountBG = Button(button, MinionButtonImages())
		button.minionCountBG.Width:Set(indSize)
		button.minionCountBG.Height:Set(indSize)
		LayoutHelpers.AtBottomIn(button.minionCountBG, button, 4 - indSize, 1)
		LayoutHelpers.AtHorizontalCenterIn(button.minionCountBG, button)
		LayoutHelpers.DepthOverParent(button.minionCountBG, button, 100) -- puts us on top of the cooldown overlay

		button.minionCountLabel = UIUtil.CreateText(button.minionCountBG, '0', 11, 'Arial Bold')
		button.minionCountLabel:SetDropShadow(true)
		button.minionCountLabel:SetColor('ffc3ebff')
		LayoutHelpers.AtCenterIn(button.minionCountLabel, button.minionCountBG)
		LayoutHelpers.DepthOverParent(button.minionCountLabel, button.minionCountBG, 2)
		button.minionCountLabel:DisableHitTest()

		# Minion Count Click Handler
		button.minionCountBG.OnClick = function(self, modifiers)
			#showBeatLog = not showBeatLog
			#LOG('BEAT LOG=' .. repr(showBeatLog) .. ' numButtons=' .. numMinionButtons)

			if GameMain.GetReplayState() then
				return
			end

			UISelectionByCategory(info.category, false, false, false, false)
			PlaySound(info.selectsound)
		end
		button.minionCountBG:UseAlphaHitTest(false)

		CreateMinionIndicators(button, InvType)

		# Override OnDestroy
		button.MinionOverlayOldOnDestroy = button.OnDestroy
		button.OnDestroy = MinionOverlayOnDestroy

		# Add a beat callback if this is the first item in the array
		numMinionButtons = numMinionButtons + 1
		if numMinionButtons == 1 then
			GameMain.BeatCallback:Add(MinionOverlayBeat)
		end
	end

	local oldGetAbilityButton = GetAbilityButton
	GetAbilityButton = function(abilityName, itemId, InvType, slot, source)
		
		local button = oldGetAbilityButton(abilityName, itemId, InvType, slot, source)
		local info = GetAbilityMinionInfo(button.abilityDef)

		-- If it is a minion ability AND it is the "special unit" ability (which will have source==nil) or
		-- it is the totem ability with a source of HUD (source==nil is the totem ability button on the buy/sell screen)
		if info.maxUnits and (info.mtype == 'Special' or (source and source == 'HUD')) then
			CreateMinionOverlay(button, info, source, InvType)
		end

		return button
	end
end
