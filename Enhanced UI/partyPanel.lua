#*****************************************************************************
#* File: lua/modules/ui/game/partyPanel.lua
#* Summary: shows status of team members
#*
#* bman654
#*****************************************************************************

--[[
Armies table looks like this:
{
    numArmies (int),
    focusArmy (index),
    armiesTable (table) {
        [1] {
            name (string),
            nickname (string)
            faction (index),
            color (color),
            iconColor (color),
            showScore (bool),
        }
        etc... for all armies
    }
}
--]]


local Game = import('/lua/game.lua')
local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Grid = import('/lua/maui/grid.lua').Grid
local Button = import('/lua/maui/button.lua').Button
local CM = import('/lua/ui/game/commandmode.lua')
local InGameUI = import('/lua/ui/game/InGameUI.lua')
local StatusBar = import('/lua/maui/statusbar.lua').StatusBar
local Text = import('/lua/maui/text.lua')
local Common = import('/lua/common/CommonUtils.lua')
local CheckTargets = import('/lua/common/ValidateAbility.lua').CheckTargets
local UserScriptCommand = import('/lua/user/UserScriptCommand.lua')
local Shop = import('/lua/ui/game/SCREEN_shop_tabbed.lua')
local Character = import('/lua/ui/game/SCREEN_hero.lua')
local Skills = import('/lua/ui/game/SCREEN_skilltree.lua')
local AchievementShop = import('/lua/ui/game/SCREEN_shopachievements.lua')
local Citadel = import('/lua/ui/game/SCREEN_citadel.lua')
local Scoreboard = import('/lua/ui/game/HUD_scoreboard.lua')


local blue      = 'ff0040d0'
local red       = 'ffd71400'
local green     = 'ff00cf00'
local white     = 'ffececec'
local yellow    = 'fffff799'
local gray      = 'ffa0a0a0'
local armyLineHeight = 67
local armyLinePadding = 25
local thread = false

local function GetHeroType(entity)
	if entity.Abilities then
		# Look at the death ability to figure out the hero
		for name,val in entity.Abilities do
			local lname = string.lower(name)
			local ans
			local c
			ans,c = string.gsub(lname, "death01", "", 1, true)
			if c == 1 then
				# LOG("pp: " .. name .. " " .. ans)
				if ans == "hrook01" then
					return "hrook"
				elseif ans == "hoculus" then
					return "oc"
				elseif ans == "hdemon" then
					return "da"
				end
				return ans
			end
		end
	end
	# not found
	return "hsedna"
end

local function CenterCameraOnUnit(partyPanel, unit)
	local cam = GetCamera('WorldCamera')
	local settings = cam:SaveSettings()
	local hpr = { settings.Heading, settings.Pitch, 0.0 }
	cam:MoveTo (unit:GetPosition(), hpr, settings.Zoom, 0.5)
end

local function LaunchTargetedAbility(hero, target, ability)
	local taskInfo = {
		AbilityName = ability.AbilityName,
		UserValidated = true,
		TaskName = ability.TaskName,
		Location = table.copy(target:GetPosition()),
		Target = {
			Type = 'Entity',
			Entity = target:GetEntityId(),
			Position = table.copy(target:GetPosition())
		},
	}
	LOG("ISSUE COMMAND: " .. repr(taskInfo))
	CM.EndCommandMode(true)
	LOG("Calling IssueUnitCommand()");
	IssueUnitCommand({hero.Entity}, "UNITCOMMAND_Script", taskInfo)
	LOG("Done calling IssueUnitcommand()");
end

local function HandleLeftClickOnUnit(partyPanel, unit)
	# Disable all this attempt to execute an ability for now since I cannot make it work
	# without the engine crashing
	--[[
	# See what command mode we are in.
	local mode = CM.GetCommandMode()
	if mode[1] == "order" and mode[2].AbilityName then
		# We are targeting an ability.
		# See if this ally is a valid target for the ability
		local def = Ability[mode[2].AbilityName]
		if def.AbilityType == 'TargetedUnit' then
			local hero = InGameUI.GetFocusArmyHero()
			if hero and not hero:IsDead() then
				if CheckTargets(hero, def, {unit}, true) then
					# Execute command
					LaunchTargetedAbility(hero, unit, mode[2])
				end
			end
			# All done with this case
			return
		end
	end
]]
	CenterCameraOnUnit(partyPanel, unit)
end

PartyPanelMouseOverUnit = nil

local function CreateArmyLine(partyPanel, parent, entity)
    local line = Group(parent)
    line.Width:Set(100)
    line.Height:Set(armyLineHeight)

    # Draw the border
    local imgtop = Bitmap(line, '/textures/ui/common/tooltips/tooltip_top.dds')
    imgtop.Width:Set(100)
    imgtop.Height:Set(25)
    LayoutHelpers.AtLeftTopIn(imgtop, line)

    local imgmid = Bitmap(line, '/textures/ui/common/tooltips/tooltip_mid.dds')
    imgmid.Width:Set(100)
    imgmid.Height:Set(armyLineHeight-50)
    LayoutHelpers.AnchorToBottom(imgmid, imgtop)
    LayoutHelpers.AtLeftIn(imgmid, imgtop)
    
    local imgbtm = Bitmap(line, '/textures/ui/common/tooltips/tooltip_btm.dds')
    imgbtm.Width:Set(100)
    imgbtm.Height:Set(25)
    LayoutHelpers.AnchorToBottom(imgbtm, imgmid)
    LayoutHelpers.AtLeftIn(imgbtm, imgmid)
    
    ### Image
    line.HeroType = GetHeroType(entity)
    line.HeroUp = "/textures/ui/common/heroes/selection_" .. line.HeroType .. "_btn_up.dds"
    line.HeroDown = "/textures/ui/common/heroes/selection_" .. line.HeroType .. "_btn_down.dds"
    line.HeroEnter = "/textures/ui/common/heroes/selection_" .. line.HeroType .. "_btn_over.dds"
    line.HeroDis = "/textures/ui/common/heroes/selection_" .. line.HeroType .. "_btn_dis.dds"
    line.Image = Bitmap(line, line.HeroUp)
    line.Image.Width:Set(40)
    line.Image.Height:Set(33)
    LayoutHelpers.AtLeftTopIn(line.Image, line, 2, 7)

    ### Name
    line.Name = UIUtil.CreateText(line, '', 12, UIUtil.bodyFont)
    LayoutHelpers.Below(line.Name, line.Image, 2)
    LayoutHelpers.AtLeftIn(line.Name, line.Image, 4)
    line.Name:SetColor(yellow)
    
    ### Health
    line.healthbg = Bitmap(line)
    line.healthbg.Width:Set(55) # 45
    line.healthbg.Height:Set(12) # 8
    LayoutHelpers.AnchorToRight(line.healthbg, line.Image, -2) # 2
    LayoutHelpers.AtTopIn(line.healthbg, line.Image, 4) # 8
    LayoutHelpers.DepthOverParent(line.healthbg, line, 10)
    line.healthbg:SetSolidColor('88001100')

    line.health = StatusBar(line.healthbg, 0, 100, false, false, false, false, "Rollover Health Bar")
    LayoutHelpers.AtLeftTopIn(line.health, line.healthbg)
    line.health:DisableHitTest(true)
    LayoutHelpers.FillParent(line.health, line.healthbg)
    LayoutHelpers.DepthOverParent(line.health, line.healthbg, 1)
    LayoutHelpers.ResetWidth(line.health)
    LayoutHelpers.ResetHeight(line.health)
    line.health._bar:SetSolidColor(green)
    line.health:SetValue(100)
    
    line.healthoverlay = Bitmap(line.healthbg, '/textures/ui/hud/bars/rollover_healthbar_overlay.dds')
    line.healthoverlay.Width:Set(60) # 50
    line.healthoverlay.Height:Set(16) # 12
    LayoutHelpers.AtCenterIn(line.healthoverlay, line.healthbg, 0, 1)
    LayoutHelpers.DepthOverParent(line.healthoverlay, line.healthbg, 100)
    
    line.healthvalues = UIUtil.CreateText(line.healthbg, '', 12, UIUtil.bodyFont) # 7
    line.healthvalues:SetColor(yellow)
    LayoutHelpers.AtCenterIn(line.healthvalues, line.healthbg, -1) # 0
    LayoutHelpers.DepthOverParent(line.healthvalues, line.healthoverlay, 2)
    line.healthvalues:SetDropShadow(true)

    ### Energy
    line.energybg = Bitmap(line)
    line.energybg.Width:Set(function() return line.healthbg.Width() end)
    line.energybg.Height:Set(function() return line.healthbg.Height() end)
    LayoutHelpers.Below(line.energybg, line.healthbg, 3) # 5
    LayoutHelpers.DepthOverParent(line.energybg, line, 10)
    line.energybg:SetSolidColor('88000011')

    line.energy = StatusBar(line.energybg, 0, 100, false, false, false, false, "Rollover Energy Bar")
    LayoutHelpers.AtLeftTopIn(line.energy, line.energybg)
    line.energy:DisableHitTest(true)
    LayoutHelpers.FillParent(line.energy, line.energybg)
    LayoutHelpers.DepthOverParent(line.energy, line.energybg, 1)
    LayoutHelpers.ResetWidth(line.energy)
    LayoutHelpers.ResetHeight(line.energy)
    line.energy._bar:SetSolidColor(blue)
    line.energy:SetValue(100)
    
    line.energyoverlay = Bitmap(line.energybg, '/textures/ui/hud/bars/rollover_healthbar_overlay.dds')
    line.energyoverlay.Width:Set(function() return line.healthoverlay.Width() end)
    line.energyoverlay.Height:Set(function() return line.healthoverlay.Height() end)
    LayoutHelpers.AtCenterIn(line.energyoverlay, line.energybg, 0, 1)
    LayoutHelpers.DepthOverParent(line.energyoverlay, line.energybg, 100)
    
    line.energyvalues = UIUtil.CreateText(line.energybg, '', 12, UIUtil.bodyFont) # 7
    line.energyvalues:SetColor(yellow)
    LayoutHelpers.AtCenterIn(line.energyvalues, line.energybg, -1) # 0
    LayoutHelpers.DepthOverParent(line.energyvalues, line.energyoverlay, 2)
    line.energyvalues:SetDropShadow(true)

    # Button
    line.button = Button(line)
    LayoutHelpers.AtLeftTopIn(line.button, line.Image)
    line.button.Bottom:Set(function() return line.Name.Bottom() end)
    line.button.Right:Set(function() return line.healthbg.Right() end)
    LayoutHelpers.ResetWidth(line.button)
    LayoutHelpers.ResetHeight(line.button)
    LayoutHelpers.DepthOverParent(line.button, line, 11000)
    line.button:SetSolidColor('00000000')
    line.button.HandleEvent = function(self, event)
    	local unit = Common.ResolveUnit(line.EntityId)
        if event.Type == "ButtonPress" and event.Modifiers.Left then
		if unit and not unit:IsDead() then
			HandleLeftClickOnUnit(partyPanel, unit)
		end
		--[[
        elseif event.Type == "ButtonPress" and event.Modifiers.Right then
            #Play Sound when double clicking on demigod icon to zoom
            if unit and not unit:IsDead() then
		    # walk to unit....cant do right now
            end]]
        elseif event.Type == 'MouseEnter' then
		if unit and not unit:IsDead() then
			PartyPanelMouseOverUnit = unit
			line.Image:SetTexture (line.HeroEnter)
			line.Image:Play()
		end
        elseif event.Type == 'MouseExit' then
		PartyPanelMouseOverUnit = nil
		if unit and not unit:IsDead() then
			line.Image:SetTexture (line.HeroUp)
			line.Image:Play()
		end
        end
        return Button.HandleEvent(line.button, event)
    end

    line.EntityId = entity.EntityId
    line.CurrentLevel = -1
    line.HeroAlive = true

    return line
end

function IsConquestTeam(army)
    return string.sub(army.name,1,5) == "TEAM_"
end

local function GetArmyName(entity, army)
	# We need to truncate name if it is too long
	local name = army.nickname
	local lvl = entity.HeroLevel
	local shorterName = ''
	local newStrSize = 0

	for i = 1, string.len(LOC(name)) do
		if newStrSize < 60 then
			local tmpname = LOC(name)
			local tmpsubname = string.sub(string.sub(tmpname,i,i+1),1,1)
			local tmp2 = UIUtil.CreateText(GetFrame(0),'', 12, UIUtil.bodyFont)
			newStrSize = newStrSize + Text.GetTextWidth(LOC(tmpsubname), function(text) return tmp2:GetStringAdvance(text) end)
			shorterName = shorterName .. tmpsubname
			tmp2:Destroy()
		else
			shorterName = shorterName .. '...'
			break
		end
	end

	local concatname = shorterName .. ' (' .. lvl .. ')'
	return concatname
end

local function UpdateArmy(armyLine, armies)
	# Get the entity
	local entity = Common.GetSyncDataById(armyLine.EntityId)
	if entity then
		local army = armies.armiesTable[entity.Army]
		if army then
			# Update the name if the level changed
			if entity.HeroLevel ~= armyLine.CurrentLevel then
				armyLine.Name:SetText(GetArmyName(entity, army))
				armyLine.CurrentLevel = entity.HeroLevel
			end
			local unit = Common.ResolveUnit(armyLine.EntityId)
			if unit then
				# Update the health
				local hp = unit:GetHealth()
				local maxhp = unit:GetMaxHealth()
				armyLine.healthvalues:SetText(string.format("%.0f / %.1fk", hp, maxhp/1000))
				if maxhp > 0 then
					local pct = math.floor(100 * hp / maxhp)
					armyLine.health:SetValue(pct)
					if pct < 34 then
						armyLine.healthvalues:SetColor(red)
					else
						armyLine.healthvalues:SetColor(yellow)
					end
				end

				# Energy
				local en = entity.Energy
				local maxen = entity.EnergyMax
				armyLine.energyvalues:SetText(string.format("%.0f / %.1fk", en, maxen/1000))
				if maxen > 0 then
					local pct = math.floor(100 * en / maxen)
					armyLine.energy:SetValue(pct)
				end

				# Update button status
				if armyLine.HeroAlive and unit:IsDead() then
					armyLine.Image:SetTexture(armyLine.HeroDis)
					armyLine.Image:Play()
					armyLine.HeroAlive = nil
				elseif not armyLine.HeroAlive and not unit:IsDead() then
					#LOG('Hero is now alive! ' .. GetArmyName(entity, army))
					armyLine.Image:SetTexture(armyLine.HeroUp)
					armyLine.Image:Play()
					armyLine.HeroAlive = true
				end
				#else
				#LOG ('no unit for ' .. GetArmyName(entity, army))
			end
			#else
			#LOG ('No army for ' .. entity.Army)
		end
		#else
		#LOG('No Entity for ' .. armyLine.EntityId)
	end
end

local function AssignHero(partyPanel, entity, army)
	partyPanel.partyCount = partyPanel.partyCount + 1
	local group = partyPanel.Group1
	local slot = partyPanel.partyCount
	if partyPanel.partyCount > 2 then
		group = partyPanel.Group2
		slot = partyPanel.partyCount - 2
	end
	local armyLine = CreateArmyLine(partyPanel, group, entity)
	partyPanel.ArmyLines[partyPanel.partyCount] = armyLine
	group:SetItem(armyLine, slot, 1, true)
	LayoutHelpers.DepthOverParent(armyLine, group, 2)
end

local function OnHeroChange(partyPanel, unit)
	partyPanel.nextFocusArmy = GetFocusArmy()
end

local function AssignHeroes (partyPanel)
    partyPanel.partyCount = 0
    partyPanel.focusArmy = partyPanel.nextFocusArmy
    local armies = GetArmiesTable()

    local player = armies.armiesTable[partyPanel.focusArmy]
    #LOG("pp: Player is " .. player.nickname)
    #LOG("pp: " .. repr(partyPanel))
    # Loop through the entities and find the heroes on the same team
    for id,ent in EntityData do
	    if ent.HeroLevel and ent.HeroLevel >= 1 # is a hero
		    and ent.Army ~= partyPanel.focusArmy # is not player
		    and armies.armiesTable[ent.Army] then # has an army entry
		    local army = armies.armiesTable[ent.Army]
		    if not IsConquestTeam(army) then
			    if army.team == player.team then
				    AssignHero (partyPanel, ent, army)
			    end
		    end
	    end
    end
    partyPanel.Group1:EndBatch()
    partyPanel.Group2:EndBatch()

end

local function DisplayPanel (partyPanel)

    if partyPanel.nextFocusArmy ~= 0 and partyPanel.nextFocusArmy ~= partyPanel.focusArmy then
	    AssignHeroes (partyPanel)
	    partyPanel:Show()
    end

        local skillTreeVis = Skills.CheckSkillTreeVisible()
        local shopVis = Shop.CheckShopVisible()
        local scoresVis = Scoreboard.CheckScoresVisible()
        local achShopVis = AchievementShop.CheckAchShopVisible()
        local characterVis = Character.CheckCharacterScreenVisible()
        local citadelVis = Citadel.CheckCitadelScreenVisible()
        
        if skillTreeVis or shopVis or scoresVis or achShopVis or characterVis or citadelVis then
		if not partyPanel:IsHidden() then
			partyPanel:Hide()
			partyPanel.Group1:Hide()
			partyPanel.Group2:Hide()
		end
        else
		if partyPanel:IsHidden() then
			partyPanel:Show()
			partyPanel.Group1:Show()
			partyPanel.Group2:Show()
		end
	    local armies = GetArmiesTable()
	    for i,armyLine in ipairs(partyPanel.ArmyLines) do
		    UpdateArmy(armyLine, armies)
	    end
        end
end

local function OnFrameCallback (partyPanel)
	if partyPanel.nextFocusArmy ~= 0 then
		DisplayPanel (partyPanel)
	end
end



function Create(parent)
    # Create new version of DisplayRollover that checks if unit is null
    # and if it is, use whatever party panel button is under the mouse (if any)
    # when calling the real DisplayRollover()
    local oldDisplayRollover = import('/lua/ui/game/HUD_rollover.lua').DisplayRollover
    import('/lua/ui/game/HUD_rollover.lua').DisplayRollover = function(unit)
	    local u = unit
	    if not unit then u = import('/Mods/Enhanced UI/partyPanel.lua').PartyPanelMouseOverUnit end
	    oldDisplayRollover(u)
    end

    local panel = Group(parent)
    panel.Width:Set(function() return parent.Width() end)
    panel.Height:Set(armyLineHeight)
    
    panel.Group1 = Grid(parent, 100, armyLineHeight, "Party 1")
    panel.Group1:AppendRows(1)
    panel.Group1:AppendCols(2)
    panel.Group1.Width:Set (210)
    panel.Group1.Height:Set(armyLineHeight)
    LayoutHelpers.AtCenterIn(panel.Group1, panel, 0, -155)

    panel.Group2 = Grid(parent, 100, armyLineHeight, "Party 2")
    panel.Group2:AppendRows(1)
    panel.Group2:AppendCols(2)
    panel.Group2.Width:Set (210)
    panel.Group2.Height:Set(armyLineHeight)
    LayoutHelpers.AtCenterIn(panel.Group2, panel, 0, 165)
    
    panel.ArmyLines = {}
    panel.focusArmy = 0
    panel.nextFocusArmy = 0
    panel.partyCount = 0

    InGameUI.OnFocusArmyHeroChange:Add( OnHeroChange, panel )

    panel:Hide()

    import('/lua/ui/game/gamemain.lua').BeatCallback:Add(function() OnFrameCallback(panel) end)

    return panel
end
