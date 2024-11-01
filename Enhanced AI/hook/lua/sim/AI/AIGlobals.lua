-- [MOD]  Many priorities have been changed to control what the AI purchases.
-- Citidel upgrades have a custom priority function to match the built in custom priority function
-- With that Citiadel upgrade priorities can dynamically change based on the world state (warrank, warscore, gold, etc)
-- Most items have been zeroed to allow each character build to set priority by items it uses
-- RandomItemWeights added to end of file.  These priorities are added to the globals when a build does not have custom items priorities.

# 0.27.00 Generic item weight balance
--[[
Item 				Priority 	Cost
scalemail 			20 			400
scaled helm 		30		 	550
banded armor 		40		 	550
unbreakable boots 	50 			1500
narmoth 			60		 	4000
vlemish 			70 			1750
nimoth 				80		 	1500
groffling 			90			5200
jtreads 			100		 	6700
mageslayer 			110 		8000
godplate 			120		 	10000
--]]


--[version .24] added following sections to make citadel upgrades more dynamic
--[MOD] TE Common item priorities.

local allHeroes= {
    hema01 = {DisplayName = 'Torch Bearer', HeroType = 'Assassin'},
    hqueen = {DisplayName = 'Queen of Thorns', HeroType = 'General'},
    hepa01 = {DisplayName = 'Unclean Beast', HeroType = 'Assassin'},
    hvampire = {DisplayName = 'Lord Erebus', HeroType = 'General'},
    hsedna = {DisplayName = 'Sedna', HeroType = 'General'},
    hgsa01 = {DisplayName = 'Regulus', HeroType = 'Assassin'},
    hoak = {DisplayName = 'Oak', HeroType = 'General'},
    hrook = {DisplayName = 'Rook', HeroType = 'Assassin'},
    hoculus = {DisplayName = 'Oculus', HeroType = 'General'},
    hdemon = {DisplayName = 'Demon Assassin', HeroType = 'Assassin'},
}


local Game = import('/lua/game.lua')
local Upgrades = import('/lua/common/CitadelUpgrades.lua').Upgrades
local AIShop = import('/lua/sim/ai/AIShopUtilities.lua')
--Utility functions for expanding PriorityFunction versatility
---- ShouldAssignHealer = function(unit, healer, assignee)
    ---- if not assignee or assignee:IsDead() or not healer or healer:IsDead() then
        ---- return false
    ---- end
    ---- if not assignee.AIHealers then
        ---- return true
    ---- else
        ---- local healertype = healer:GetBlueprint().BlueprintId --unused; for healer type comp checks
        ---- local maxhealers, currenthealers = 2, 0
        ---- for army, curhealer in assignee.AIHealers do
            ---- if curhealer and not curhealer:IsDead() then
                ---- currenthealers = currenthealers + 1
            ---- end
        ---- end
        ---- return currenthealers < maxhealers
    ---- end
---- end

---- AssignHealer = function(unit, healer, assignee)
    ---- if ShouldAssignHealer(unit, healer, assignee) then
        ---- if not assignee.AIHealers then
            ---- assignee.AIHealers = {}
        ---- end
        ---- assignee.AIHealers[unit:GetArmy()] = healer
        ---- IssueGuard({healer}, assignee) --I don't recall the syntax, this may be wrong
        ---- --add OnKilled callbacks to assignee and healer(?) here?
        ---- return true
    ---- else
        ---- return false
    ---- end
---- end


function teamIdolCount (unit, item, shop)
    local allyGenerals = {}
    local myBrain = unit:GetAIBrain()

    for k, brain in ArmyBrains do
        if brain.Score.HeroId and IsAlly(myBrain:GetArmyIndex(), brain:GetArmyIndex()) then
            if allHeroes[brain.Score.HeroId].HeroType == 'General' then
                local heroUnit = brain:GetListOfUnits(categories.HERO, false)
                --WARN('General ' .. brain.Score.HeroId .. ' = ' .. allHeroes[brain.Score.HeroId].DisplayName)
                table.insert(allyGenerals,  heroUnit[1])
            end
        end
    end

    local myCount = 0
    for k, hero in allyGenerals do
        if AIShop.UnitHasItem(hero, item, shop) then
            myCount = myCount + 1
        end
    end

    return { Count = myCount, Generals = table.getn(allyGenerals) }
end

function highGold(unit)
    local goldTable = {}
    local aiBrain = unit:GetAIBrain()

    --Make sure we have the most gold of the AIs on our team

    for k, brain in ArmyBrains do
        if brain.Score.HeroId and IsAlly(aiBrain:GetArmyIndex(), brain:GetArmyIndex()) and brain.BrainController != 'Human' then
            table.insert(goldTable, {Army = brain:GetArmyIndex(), Gold = brain.mGold  })
        end
    end
    table.sort(goldTable, sort_down_by 'Gold' )

    if goldTable[1].Army == aiBrain:GetArmyIndex() then
        return true
    else
        return false
    end
end

# 0.26.43 Added Miri's new system for saving
--Mithy: New system for determining which upgrade an AI should be saving for, if any
--This is only run once per item or upgrade shopping check

--Map table for upgrades to save for, and from what rank / enemy rank
--Rank is the own War Rank to begin saving for this upgrade
--ERank an optional enemy War Rank at which to begin saving
--EHas is an optional bool that tells the AI to save if the enemy has this upgrade
-- all of these conditions are OR; any of them will trigger saving
-- item cost mod (e.g. coin purse) is taken into account when determining how much to save

# 0.27.00 moved saving for angels to WR 7 from 6
--0.26.46 added instruction to save for fs1 at ws 200
SaveForUpgrades = {
	[1] = { Name = 'CBuildingHealth01', Score = 200 },
	[2] = { Name = 'CGoldIncome01', Rank = 2 },
	[3] = { Name = 'CTroopNumber03', Rank = 6, ERank = 7, EHas = true },
	[4] = { Name = 'CTroopNumber05', Rank = 7, ERank = 7, EHas = true },
	[5] = { Name = 'CTroopNumber04', Rank = 7 },
	[6] = { Name = 'CTroopNumber06', Rank = 9 },
}

--Table for holding upcoming upgrades
local upgradeQueue = false

--Returns a number corresponding to this AI's current gold ranking among team AIs
function GetGoldRank(unit, brain)
    local goldTable = {}
    for k, abrain in ArmyBrains do
        if not abrain.TeamBrain and abrain.BrainController == 'AI' and IsAlly(brain:GetArmyIndex(), abrain:GetArmyIndex()) then
            table.insert(goldTable, {Army = abrain:GetArmyIndex(), Gold = abrain.mGold})
        end
    end
    if table.getn(goldTable) < 2 then
        return 1
    else
        table.sort(goldTable, sort_down_by 'Gold')
        return table.find(goldTable, brain:GetArmyIndex(), function(a, b) return a.Army == b end)
    end
    return false
end

# 0.26.46 Added updated code from miriyaka that allows enables us to use warscore as well to determine when to shop - disabled logging as well - see if that helps lag issue
--Main function for handling save logic; returns false, or upgrade name and upgrade cost
function SaveForUpgrade(unit, brain)
    --LOG("SaveForUpgrade: "..repr(brain.Nickname).." / "..repr(unit:GetUnitId()).." @ "..repr(GetMinute()))
    local goldRank = GetGoldRank(unit, brain)
    local warRank = brain.Score.WarRank
    local warScore = brain.Score.WarScore
    local enemyRank = GetEnemyTeamBrain(unit).Score.WarRank
    --LOG("\tGold Rank: "..repr(goldRank)..", War Rank: "..repr(warRank)..", Enemy War Rank: "..repr(enemyRank))

    --Deferred init for the upgrade queue, to allow other mods to hook SaveForUpgrades
    if upgradeQueue == false then
     --   LOG("\tInitializing upgrade queue..")
        --Assign costs on startup
        for num, upgrade in SaveForUpgrades do
            upgrade.Cost = UpgradeCost(upgrade.Name)
        end
        --Then copy the map table to the queue
        upgradeQueue = table.deepcopy(SaveForUpgrades)
    end

    --Prune purchased upgrades
    while TeamHasUpgrade(unit, upgradeQueue[1].Name) do
    --    LOG("\tTeam has upgrade "..repr(upgradeQueue[1].Name)..", removing from queue..")
        table.remove(upgradeQueue, 1)
    end

    --Get a list of upgrades that we should be saving for now
    local currentUpgrades = {}
    --LOG("\tUpgrades to save for:")
    for num, data in upgradeQueue do
        if (data.Rank and warRank >= data.Rank) or (data.Score and warScore >= data.Score)
        or (data.ERank and enemyRank >= data.ERank) or (data.EHas and EnemyHasUpgrade(unit, data.Name)) then
            --LOG("\t\t"..repr(data.Name).." - "..repr(data.Cost))
            table.insert(currentUpgrades, table.copy(data))
        end
    end
    if table.getn(currentUpgrades) < 1 then
     --   LOG("\t\t(none)")
    end

    --Return which one this AI should save for, if any
    local saveFor = currentUpgrades[goldRank]
    if saveFor then
    --    LOG("\tSaving for upgrade "..repr(saveFor.Name)..", cost "..repr(saveFor.Cost))
        return saveFor.Name, saveFor.Cost
    else
     --   LOG("\tNot saving.")
        return false
    end
end

function GetDeathMult()
    return Game.GameData.DeathPenaltyMultiplier[ScenarioInfo.Options.DeathPenalty or 'Normal']
end

function GetGoldMult()
    return Game.GameData.GoldIncomeMultiplier[ScenarioInfo.Options.GoldIncome or 'Normal']
end

function GetXPMult()
    return Game.GameData.ExperienceMultiplier[ScenarioInfo.Options.ExperienceRate or 'Normal']
end

function GetMinute()
    return math.floor(GetGameTimeSeconds() / 60)
end

function IsGeneral(unit)
    return EntityCategoryContains(categories.GENERAL, unit)
end

function IsAssassin(unit)
    return EntityCategoryContains(categories.ASSASSIN, unit)
end

--Returns AI difficulty level, 1 for Easy, 4 for Nightmare
function GetAIDifficulty(unit)
    return ScenarioInfo.ArmySetup[unit:GetAIBrain().Name].Difficulty
end

function UpgradeCost(upgradeName)
    if Upgrades.Tree[upgradeName] then
        return Upgrades.Tree[upgradeName].Cost
    else
        WARN("AIGlobals.UpgradeCost -- Tried to get cost of non-existent upgrade '"..upgradeName.."'")
        return 0
    end
end

--Returns a fractional modifier from 0 to 1 based on the provided demigod's gold reserves, starting at the minimum specified
--amount of gold and ending at the min amount * rec multiplier.  If the rec multiplier is not specified, it defaults to 2.
function GoldThreshold(unit, min, rec)
    rec = min * (rec or 2)
    return math.min(1, math.max(0, unit:GetGold() - min) / (rec - min))
end

--Get our team's average hero level
function GetAverageLevel(unit)
    local levels, heroes = unit.Score.HeroLevel, 1
    for k, brain in unit:GetAIBrain():GetAlliedArmies() do
        if not brain.IsTeamArmy then
            heroes = heroes + 1
            levels = levels + brain.Score.HeroLevel
        end
    end
    return math.floor( (levels / heroes) + 0.5 )
end

--Get our team's total deaths
function GetTeamDeaths(unit)
    local deaths = unit.Score.HeroDeaths
    for k, brain in unit:GetAIBrain():GetAlliedArmies() do
        if not brain.IsTeamArmy then
            deaths = deaths + brain.Score.HeroDeaths
        end
    end
    return deaths
end

--Get our team's citadel health fraction
function GetCitadelHealth(unit)
    local cithealth = false
    local citadel = unit:GetAIBrain():GetStronghold()

    if citadel then
        cithealth = citadel:GetHealth() / citadel:GetMaxHealth()
    end

    return cithealth
end

function GetEnemyTeamBrain(unit)
    local unitbrain = unit:GetAIBrain()

    if not unitbrain.EnemyTeamBrain then
        for k, brain in ArmyBrains do
            if brain.TeamBrain and IsEnemy(unit:GetArmy(), brain:GetArmyIndex()) then
                unitbrain.EnemyTeamBrain = brain
                break
            end
        end
    end

    return unitbrain.EnemyTeamBrain
end

--Used to get info on enemy citadel upgrades
function HasUpgradeByTeamBrain(brain, upgradeName)
    local upgradesTable = brain:GetStronghold().Sync.Upgrades

    if upgradesTable then
        for k,v in upgradesTable do
            if v == upgradeName then
                return true
            end
        end
    end

    return false
end

--Check our team's upgrades
function TeamHasUpgrade(unit, upgradeName)
    local hasupgrade = false
    local tBrain = unit:GetAIBrain():GetTeamArmy()

    if tBrain then
        hasupgrade = HasUpgradeByTeamBrain(tBrain, upgradeName)
    end

    return hasupgrade
end

--Check enemy team's upgrades
function EnemyHasUpgrade(unit, upgradeName)
    local hasupgrade = false
    local etBrain = GetEnemyTeamBrain(unit)

    if etBrain then
        hasupgrade = HasUpgradeByTeamBrain(etBrain, upgradeName)
    end

    return hasupgrade
end

TeleportAbilities = {
    'AchievementTeleport',
    'Item_Consumable_010',
}

StunBuffs = {
    'Item_Artifact_020',
}

DefaultDisables = {
    'Purchase Base Item',
    'Sell Item - Clickables',
    'Sell Item - Equipment',
    'Sell Item - Generals',
    'Purchase Base Item - Use Sell Refund',
    'Purchase Citadel Upgrade',
}

HealthDisables = {
    'Use Health Potion',
    'Use Regeneration of the Seraphim',
    'Use Heart of Life',
}

EnergyDisables = {
    'Use Energy Potion',
    'Use Cape of Plentiful Mana',
    'Use Blade of the Serpent',
    'Use Purified Essence of Magic',
    'Use Magus Rod',
    'Use Heart of Life',
}

ShopDisables = {
    'Purchase Base Item',
    'Purchase Base Item - Use Sell Refund',
    'Purchase Citadel Upgrade',
}

MoveDisables = {
    'Move to healers',
    'MoveToNearbyTower',
    'Back Away from enemy tower',
    'Back Away from combat',
    'MoveToPortalSpawnInfantry',
    'MoveToEnemyInfantry',
    'Move - Squad defined location',
    'Move - Infantry near Squad defined location',
    'Move - Defense near Squad defined location',
    'Teleport to Structure near Squad Location',
    'Move To Squad Target',
    'Move To Health Statue',
    'Capture Closest Flag',
    --'Capture Portal',
    'Capture Anything',
    'Teleport to Portal',
    'Teleport to Tower',
    'Structural Transfer',
}

SprintDisables = {
    'Sprint - Flee',
    'Sprint - Attack',
}

InvisibilityDisables = {
    'Cloak of Invisibility - Flee',
}

AttackDisables = {
    'AttackClosestInfantry',
    'Attack Closest Infantry with friendly Creep',
    'Attack from back line',
    'Attack Squad Target',
    'Attack Closest Hero - Ranged Hero',
    'Attack Closest Hero - Melee Hero',
    'AttackClosestTower',
    'Attack Closest Building',

}

FirstDepthDisables = {
    'Two Second Wait',
    'MoveToPortalSpawnInfantry',
    'MoveToEnemyInfantry',
    'Teleport to Health Statue',
    'MoveToNearbyTower',
    'Back Away from enemy tower',
    'Back Away from combat',
    'Use Staff of Renewal',
    'Use Purified Essence of Magic',
}

StatPrefix = 'AI Systems_'

MaximumActions = 400

--==== PING GLOBALS ==== --
AIPingDuration = 31
AIPingMaximumWeight = 37
AIPingRadiusDefault = 24 * 24
AIPingRadiusLane = 32 * 32

--==== MISC GLOBALS ==== --
AISquadLocationDistance = 25
AISquadLocationDistSq = 625

--=======================
--AI Calculations tables
--=======================

--This is a table we use to store out damage so that we can calculate
--the amount of damage an ability will do only once;
--ie - Foul Grasp does not have a single amount of damage; we calc it only once for all heroes
AbilityDamage = {}

--------------------------------------------------------------------------------
--ITEMS
--------------------------------------------------------------------------------
ItemWeights = {

    ----------------------------------------------
    --CONSUMABLES
    ----------------------------------------------

    --Health Potion
    --Use: Heal 750 health.
    Item_Health_Potion = {
        --MaxPurchase = 1,
        --sellpriority = 1,
        PriorityFunction = function(unit, itemCount)
            if unit:GetMaxHealth() > 3500 then
                return 0
            end

            if itemCount == 0 then
                return 7
            elseif itemCount == 1 then
                return 4
            else
                return 0
            end
        end,
    },

    --Robust Health Potion
    --Use: Heal 3000 health.
    Item_Large_Health_Potion = {
        --MaxPurchase = 2,
        --sellpriority = 1,
        PriorityFunction = function(unit, itemCount)
            if unit:GetMaxHealth() < 3500 then
                return 0
            end

            if itemCount == 0 then
                return 7
            elseif itemCount == 1 then
                return 4
            else
                return 0
            end
        end,
    },

    --Mana Potion
    --Use: Restore 1000 Mana
    Item_Mana_Potion = {
        --MaxPurchase = 2,
        --sellpriority = 1,
        PriorityFunction = function(unit, itemCount)
            if unit:GetMaxEnergy() > 4000 then
                return 0
            end

            if itemCount == 0 then
                return 0
            elseif itemCount == 1 then
                return 0
            else
                return 0
            end
        end,
    },

    --Robust Mana Potion
    --Use: Restore 2500 Mana
    Item_Large_Mana_Potion = {
        --MaxPurchase = 2,
        --sellpriority = 1,
        PriorityFunction = function(unit, itemCount)
            if unit:GetMaxEnergy() < 4000 then
                return 0
            end

            if itemCount == 0 then
                return 0
            elseif itemCount == 1 then
                return 0
            else
                return 0
            end
        end,
    },

    --Rejuvenation Elixir
    --Use: Restore 750 health and 750 Mana.
    Item_Rejuv_Elixir = {
        --MaxPurchase = 1,
        --sellpriority = 1,
        PriorityFunction = function(unit, itemCount)
            if unit:GetMaxEnergy() > 3000 or unit:GetMaxHealth() > 3000 then
                return 0
            end

            if itemCount == 0 then
                return 0
            elseif itemCount == 1 then
                return 0
            else
                return 0
            end
        end,
    },

    --Robust Rejuvenation Elixir
    --Use: Restore 1875 health and 1875 Mana.
    Item_Large_Rejuv_Elixir = {
        --MaxPurchase = 2,
        --sellpriority = 1,
        PriorityFunction = function(unit, itemCount)
            if unit:GetMaxEnergy() < 3000 and unit:GetMaxHealth() < 3000 then
                return 0
            end

            if itemCount == 0 then
                return 0
            elseif itemCount == 1 then
                return 0
            else
                return 0
            end
        end,
    },

    --Scroll of Teleporting
    --Use: Teleport to targeted friendly structure.
    --[version .24] changed priority for itemCount and added warrank conditional statements
    Item_Consumable_010 = {
        --sellpriority = 10,
        --MaxPurchase = 2,
        PriorityFunction = function(unit, itemCount)
            if itemCount == 0 and unit:GetAIBrain().Score.WarRank > 1 then
                return  25
            elseif itemCount == 0 then
                return 8
            end
            if itemCount == 1 and unit:GetAIBrain().Score.WarRank > 1 then
                return  10
            elseif itemCount == 1 then
                return 0
            end
            if itemCount == 2 and unit:GetAIBrain().Score.WarRank >= 8 then
                return 40
            elseif itemCount == 2 then
                return 0
            end

            return 0
        end,
    },

    --Totem of Revelation
    --Use: Place an observer ward that can reveal cloaked enemies. Can also reveal mines.
    Item_Consumable_020 = {
        Priority = 0,
    },

# 0.27.03 changed desire back from wr 4 to wr 6
--# 0.26.52 changed desire back from wr 3 to wr 4
--# 0.26.49 bumped desire for locks after ws 3 (from 4)
-- # 0.26.47 commented out old code - bumped desire for locks after ws 4
--[version .24] changed priority for itemCount and added warrank conditional statements
	--Capture Lock
	--Use: Selected ally flag cannot be captured by the enemy for 30 seconds.
    Item_Consumable_030 = {
        --MaxPurchase = 2,
        --Priority = 10,
        --sellpriority = 10,
        PriorityFunction = function(unit, itemCount)
            if itemCount < 2 and unit:GetAIBrain().Score.WarRank >= 6 then
                return 40
			else
				return 0
            end
     end,
    },
--[[
#    # Capture Lock
#    # Use: Selected ally flag cannot be captured by the enemy for 30 seconds.
     #[version .24] changed priority for itemCount and added warrank conditional statements
    Item_Consumable_030 = {
        #MaxPurchase = 2,
        #Priority = 10,
		#sellpriority = 10,
		
		PriorityFunction = function(unit, itemCount)
			if itemCount == 0 and unit:GetAIBrain().Score.WarRank >= 7 then
				return 40
			elseif itemCount == 0 and GetEnemyTeamBrain(unit).Score.WarRank >= 8 then
				return 40
			elseif itemCount == 1 and unit:GetAIBrain().Score.WarRank >= 7 then
				return 40
			elseif itemCount == 1 and GetEnemyTeamBrain(unit).Score.WarRank >= 8 then
				return 40
			elseif itemCount == 2 and unit:GetAIBrain().Score.WarRank >= 9 then	
				return 40
			elseif itemCount == 2 and GetEnemyTeamBrain(unit).Score.WarRank >= 9 then
				return 40
			else
				return 0
			end
		end,
    },
--]]
	
	
	
    --Sludge Slinger
    --Use: Decreases target's attack speed.
    Item_Consumable_040 = {
        --MaxPurchase = 1,
        Priority = 0,
    },

    --Wand of Speed
    --Use: Increase Base Run Speed by 30%.
    Item_Consumable_050 = {
        Priority = 0,
    },

    --Targeting Dummy
    --Use: Draws fire from towers of light when placed nearby.
    Item_Consumable_060 = {
        Priority = 0,
    },

    --Warpstone
    --Use: Warp to a nearby location.
    Item_Consumable_070 = {
        Priority = 0,
    },

    --Universal Gadget
    --Use: Heal an allied unit for 3,000 or damage an enemy unit for 500.
    Item_Consumable_080 = {
        Priority = 0,
    },

    --Restorative Scroll
    --Use: Any negative effects on your army are removed.
    Item_Consumable_090 = {
        --MaxPurchase = 1,
        Priority = 0,
        GeneralItem = true,
    },

    --Hex Scroll
    --Use: Weapon damage dealt by the targeted Demigod and their army reduced by 25% for 10 seconds.
    Item_Consumable_100 = {
        --MaxPurchase = 1,
        Priority = 0,
    },

	# 0.26.45 bumped sigil priority - reduced the max health condition from 4k to 2750 - increase if itemcount = 0 from 8 to 15, added wr rule so ai gets more often after ws4
    --Sigil of Vitality
    --Use: Temporarily increase Maximum Health by 50% for 10 seconds.
    Item_Consumable_110 = {
        --sellpriority = 10,
        --MaxPurchase = 2,
    PriorityFunction = function(unit, itemCount)
	    if itemCount == 0 and unit:GetAIBrain().Score.WarRank >= 2 and unit:GetMaxHealth() > 2750 then 
                return 600
			else
                return 0
            end
		end,
    },

	
# original code commented by pacov
--[[
    # Sigil of Vitality
    # Use: Temporarily increase Maximum Health by 50% for 10 seconds.
    Item_Consumable_110 = {

		PriorityFunction = function(unit, itemCount)
            if unit:GetMaxHealth() < 4000 then
                return 0
            end
            
            if itemCount == 0 then
                return 8
            elseif itemCount == 1 then
                return 0
            else
                return 0
            end
        end,
    },
--]]
	
	
    --Twig of Life
    --Use: Your army restores 25% of their maximum Health.
    Item_Consumable_120 = {
        Priority = 0,
        GeneralItem = true,
    },

    --Warlord's Punisher
    --Use: Cast a bolt of lightning at the target, dealing 250 damage and arcing to nearby enemies. Demigods struck also lose 400 Mana.
    Item_Consumable_130 = {
        Priority = 0,
    },

    --Magus Rod
    --Use: The cost of abilities is reduced by 50% for 5 seconds.
    Item_Consumable_140 = {
        Priority = 0,
    },

    --Orb of Defiance
    --Use: Become invulnerable for 5 seconds. Cannot move, attack or use abilities.
    --+500 Health
    --+500 Armor
    Item_Consumable_150 = {
        Priority = 0,
    },



    --Parasite Egg
    --Use: Infest target Demigod with a parasite. Whenever you deal damage to that Demigod, their army takes damage as well. The effects lasts 10 seconds.
    --+30 Weapon Damage
    --+10% Attack Speed
    Item_Consumable_170 = {
        Priority = 0,
    },

    ----------------------------------------------
    --BREASTPLATES
    ----------------------------------------------

    --Scalemail
    --+600 Armor
# 0.26.51 changed from 18 to 20 for balancing
--# 0.26.47 droped from 20 to 18 for balancing
    Item_Chest_010 = {
        Priority = 20,
    },

# 0.26.51 changed from 22 to 40 for balancing
--# 0.26.47 changed from 25 to 22 for balancing
    --Banded Armor
    --+500 Hit Points
    Item_Chest_020 = {
        Priority = 40,
    },

# 0.26.51 changed from 52 to 80 for balancing
--# 0.26.48 - changed from 40 to 52 for balancing
    --Nimoth Chest Armor
    --+1100 Armor
    --+10% Dodge
    Item_Chest_030 = {
        Priority = 80,
    },

# 0.26.51 dropped priority level to 0 for balancing - AI builds must prioritize this if needed - only useful for generals
--# 0.26.40 - dropped priority from 40 to 35
    --HaubHauberk of Life
    --+750 Hit Points
    --+20 Hit Points per second
    Item_Chest_040 = {
        Priority = 0,
    },

    --Armor of Vengeance
    --+1300 Armor
    --When struck by melee attacks, wearers of this mystical armor reflect 50 damage back to the attacker.
    Item_Chest_050 = {
        Priority = 0,
    },

    --Platemail of the Crusader
    --+25 Hit Points per second
    --15% chance on hit to heal 600 Hit Points
    Item_Chest_060 = {
        Priority = 0,
    },

# 0.26.51 changed from 50 to 90 for balancing
--# 0.26.45 increased priority from 0 to 50
	--Groffling's Warplate
    --+850 Hit Points
    --+1500 Armor
    --Armor proc chance on hit to gain a damage absorb
    Item_Chest_070 = {
        Priority = 90,
    },

# 0.26.53 changed from 50 to 120 for balancing
    --Godplate
    --incorrect description
    Item_Chest_080 = {
        Priority = 120,
    },

--removed by pacov
--[[
    --Godplate
    --+1300 Hit Points
    --+1000 Armor
    --When struck by melee attacks, wearers of this mystical armor reflect 60 damage back to the attacker.
    Item_Chest_080 = {
    PriorityFunction = function(unit, itemCount)
        if itemCount == 1 then
            return 50
        end

        if unit:GetAIBrain().mGold  >= 10000 then
            return 50
        else
            return 0
        end
    end,
    },
--]]

    --Duelist's Cuirass
    --+350 Armor
    --+500 Health
    --5% chance deal a critical strike for 1.5x damage
    Item_Chest_090 = {
        Priority = 0,
    },

    ----------------------------------------------
    --HELMS
    ----------------------------------------------

# 0.26.51 changed from 25 to 30 for balancing
--# 0.26.48 changed from 20 to 25 for balancing
    --Scaled Helm
    --+750 Mana
    Item_Helm_010 = {
        Priority = 30,
    },

    --Plate Visor
    --+30 Mana per second
    Item_Helm_020 = {
        Priority = 0,
    },

# 0.26.51 dropped priority level to 0 for balancing - AI builds must prioritize this in their own blueprints if more mana is needed; otherwise it will not be purchased
    --Plenor Battlecrown
    --+1000 Mana
    ---25% to ability cooldowns
    Item_Helm_030 = {
        Priority = 0,
    },

# 0.26.51 changed from 50 to 70 for balancing
    --Vlemish Faceguard
    --Increases the Mana Regeneration of you and nearby allied Demigods by 40 Mana per second.
    Item_Helm_040 = {
        Priority = 70,
    },

    --Vinling Helmet
    --+1500 Mana
    --+30 Mana per second
    --15% chance on hit to restore 700 Mana.
    Item_Helm_050 = {
        Priority = 0,
    },

    --Hungarling's Crown
    --Reduces the cost of abilities for you and all nearby Demigods by 35%.
    Item_Helm_060 = {
        Priority = 0,
    },

    --Theurgist's Cap
    --+10 Health Regeneration
    --+50% Mana Regeneration
    --5% chance on being hit to reduce the target's Health Regeneration by 50% and Mana Regeneration by 50% for 10 seconds.
    Item_Helm_070 = {
        Priority = 0,
    },

    ----------------------------------------------
    --BOOTS
    ----------------------------------------------

    --Footman's Sabatons
    --+10% Dodge
    Item_Boot_010 = {
        Priority = 0,
    },


# 0.26.51 dropped priority level to 0 for balancing - AI builds must prioritize this if needed
    --Boots of Speed
    --+15% Base Run Speed
    Item_Boot_020 = {
        Priority = 0,
    },

    --Assassin's Footguards
    --+30 Mana per second
    --+15% Dodge
    Item_Boot_030 = {
        Priority = 0,
    },

# 0.26.51 changed from 39 to 50 for balancing
    --Unbreakable Boots
    --+600 HP
    --+5 HPS
    --+800 Mana
    Item_Boot_040 = {
        Priority = 50,
    },


--[[ --removed by pacov
    --Unbreakable Boots
    --+360 Hit Points
    --+540 Armor
    Item_Boot_040 = {
        PriorityFunction = function(unit, itemCount)
            if GetGameTimeSeconds() < 20 then
                return 39
            else
                return 30
            end
     end,
    },
--]]

# 0.26.51 changed from 70 to 100 for balancing
    --Journeyman Treads
    --+340 Armor
    --+15% Base Run Speed
    --20% chance on hit to increase Base Run Speed by 50% for 10 seconds.
    Item_Boot_050 = {
        Priority = 100,
    },

    --Desperate Boots
    --+500 Armor
    --+10% Attack Speed
    --Whenever health is under 20%, Evasion is increased by 20%.
    Item_Boot_060 = {
        Priority = 0,
    },

    --Ironwalkers
    --Whenever Movement Speed is under 4, Armor is increased by 1000.
    --+ 100 Minion Armor
    Item_Boot_070 = {
        Priority = 0,
    },

    ----------------------------------------------
    --GLOVES
    ----------------------------------------------

    --Gauntlets of Brutality
    --+50 Weapon Damage
    Item_Glove_010 = {
        Priority = 0,
    },

    --Gladiator Gloves
    --+5% Attack Speed
    Item_Glove_020 = {
        Priority = 0,
    },

    --Gauntlets of Despair
    --+8% Attack Speed
    --15% chance on hit to drain 100 mana.
    Item_Glove_030 = {
        Priority = 0,
    },

    --Wyrmskin Handguards
    --20% chance on hit to eviscerate the target dealing 150 damage and reducing their Attack Speed and Base Run Speed 25%.
    Item_Glove_040 = {
        Priority = 0,
        --AssassinItem = true,
    },

    --Doomspite Grips
    --+50 Weapon Damage
    --+15% Attack Speed
    --20% chance on hit to perform a cleaving attack, damaging nearby enemies.
    Item_Glove_050 = {
        Priority = 0,
    },

    --Gloves of Fell-Darkur
    --+75 Weapon Damage
    --+10% Attack Speed
    --20% chance on hit to unleash a fiery blast, dealing 175 damage.
    Item_Glove_060 = {
        Priority = 0,
    },

    --Slayer's Wraps
    --5% chance to crit for double damage
    Item_Glove_070 = {
        Priority = 0,
    },

    ----------------------------------------------
    --RINGS
    ----------------------------------------------

    --Bloodstone Ring
    --+15% Life Steal
    Item_Ring_020 = {
        Priority = 0,
    },

    --Nature's Reckoning
    --15% chance on hit to strike nearby enemies with lightning for 250 damage
    Item_Ring_030 = {
        Priority = 0,
    },

    --Ring of the Ancients
    --+500 Armor
    --+30 Weapon Damage
    --Increases experience gained by 10%.
    Item_Ring_040 = {
        Priority = 0,
    },

# 0.26.51 changed from 50 to 60 for balancing
--# 0.26.47 increased value from 0 to 50 for balancing
	--Narmoth's Ring
    --+15% Life Steal
    --When struck by melee attacks, the wearer reflects 90 damage back to the attacker.
    Item_Ring_050 = {
        Priority = 60,
    },

    --Forest Band
    --5% on attack to heal your army for 250 health.
    Item_Ring_060 = {
        Priority = 0,
        GeneralItem = true,
    },

    ----------------------------------------------
    --GENERALS
    ----------------------------------------------

--0.26.40 - dropped priority from 10 to 0
    --Minotaur Captain Idol I
    --Use: Summons the least amount of Minotaur Captains.
    Item_Minotaur_Captain_010 = {
        Priority = 0,
        --MinionDesire = 0.1,
    },

# 0.26.51 dropped priority from 5 to 0
--0.26.40 - dropped priority from 15 to 5
    --Minotaur Captain Idol II
    --Use: Summons a moderate amount of Minotaur Captains.
    Item_Minotaur_Captain_020 = {
        Priority = 0,
        --MinionDesire = 0.25,
    },

# 0.26.51 dropped priority from 10 to 5
--0.26.40 - dropped priority from 20 to 10
    --Minotaur Captain Idol III
    --Use: Summons the most amount of Minotaur Captains.
    Item_Minotaur_Captain_030 = {
        Priority = 5,
        --MinionDesire = 0.5,
    },
	
# 0.26.51 dropped priority from 15 to 10
--0.26.40 - dropped priority from 25 to 15
    --Minotaur Captain Idol IV
    --Use: Summons the most amount of Minotaur Captains and passive bonuses.
    Item_Minotaur_Captain_040 = {
        Priority = 10,
        --MinionDesire = 0.75,
    },
--0.26.40 - dropped priority from 15 to 0
    --Siege Archer Idol I
    --Use: Summons the least amount of Siege Archers.
    Item_Siege_Archer_010 = {
        Priority = 0,
        --MinionDesire = 0.1,
    },

# 0.26.51 dropped priority from 20 to 10
    --Siege Archer Idol II
    --Use: Summons a moderate amount of Siege Archers.
    Item_Siege_Archer_020 = {
        Priority = 10,
        --MinionDesire = 0.25,
    },

# 0.26.51 dropped priority from 25 to 15
    --Siege Archer Idol III
    --Use: Summons the most amount of Siege Archers.
    Item_Siege_Archer_030 = {
        Priority = 15,
        --MinionDesire = 0.5,
    },

# 0.26.51 dropped priority from 30 to 18
    --Siege Archer Idol IV
    --Use: Summons the most amount of Siege Archers and passive bonuses.
    Item_Siege_Archer_040 = {
        Priority = 18,
        --MinionDesire = 0.75,
    },

# 0.26.51 increased priority from 55/35 to 140/130
    --High Priest Idol I (Monks)
    --Use: Summons the least amount of High Priests.
    Item_High_Priest_010 = {
        PriorityFunction = function(unit, itemCount)
            if GetGameTimeSeconds() < 30 then
                return 145  --Tie with clerics for random select by Hard AI or above
            else
                return 130
            end
        end,
        },

# 1.01 removed conditional statement and set clerics to a static value of 140
-- 0.26.51 increased priority from 55/30 to 140/125
    --High Priest Idol II
    --Use: Summons a moderate amount of High Priests.
    Item_High_Priest_020 = {
         Priority = 145,
        },
		
# 0.26.51 increased priority from 60 to 150
    --High Priest Idol III
    --Use: Summons the most amount of High Priests.
    Item_High_Priest_030 = {
        Priority = 150,
        },

# 1.01 changed priorities so that high priests/bishops would not be sold
-- 0.26.51 increased priority from 65/55 to 160/145
    --High Priest Idol IV
    --Use: Summons the most amount of High Priests and passive bonuses.
    Item_High_Priest_040 = {
	PriorityFunction = function(unit, itemCount)
		local idolsCount = teamIdolCount(unit, 'Item_High_Priest_040', 'ugbshop09')
		if idolsCount.Count == 0 or idolsCount.Generals - idolsCount.Count > 1 then
			return 155  #  +5 from High Priest to allow replacement.  
		else
			return 146  #  Below High Priest priority to ensure High Priest is selected over bishops when all but one own bishops.
					    #  Set to 4 lower as at 5 or more lower Bishop would be sold for High Priest.
		end
     end,
    },

    ----------------------------------------------
    --ARTIFACT ITEMS
    ----------------------------------------------

# 0.26.53 increased artifact weight so items will not be sold if they have been purchased already
    --Heart of Life
    --Use: Restore 3000 health and 3000 mana over 10 seconds. Any damage will break this effect.
    --+15 Health Regeneration
    --+50% Mana Regeneration
    Item_Consumable_160 = {
        PriorityFunction = function(unit, itemCount)
            if itemCount == 1 then
                return 200
            end

            if unit:GetAIBrain().mGold  >= 10000 then

                return 0
            else
                return 0
            end
     end,
    },



    --Bracelet of Rage
    --Use: Nearby allied units gain +300% Weapon Damage for 15 seconds.
    Item_Artifact_010 = {
    PriorityFunction = function(unit, itemCount)
        if itemCount == 1 then
            return 200
        end

        if unit:GetAIBrain().mGold  >= 10000 then
            return 0
        else
            return 0
        end
     end,
    },

# 0.26.53 removed conditional statements and gave mageslayer a static value
    --Mage Slayer
    --+20% Life Steal
    --40% chance on hit to stun target for 0.4 seconds.
	    Item_Artifact_020 = {
		        Priority = 120,
			},
    
# 0.27.00 set priority value to 0 for cloak
-- 0.26.51 removed cloak as its not selectable in game

    --Cloak of Invisibility
    --Use: Turn invisible for 20 seconds.
    Item_Artifact_030 = {
    	    Priority = 0,
        },


    --Cloak of Flames
    --Use: Cast a ring of fire around yourself, damaging enemies for 600 damage over 10 seconds.
    --+50% Attack Speed
    Item_Artifact_040 = {
    PriorityFunction = function(unit, itemCount)
        if itemCount == 1 then
            return 200
        end

        if unit:GetAIBrain().mGold  >= 10000 then

            return 0
        else
            return 0
        end
     end,
    },

    --Cloak of Elfinkind
    --Use: Warp to a targeted location.
    --+25% Dodge
    --+20% Base Run Speed
    Item_Artifact_050 = {
    PriorityFunction = function(unit, itemCount)
        if itemCount == 1 then
            return 200
        end

        if unit:GetAIBrain().mGold  >= 10000 then
            return 0
        else
            return 0
        end
    end,
    },

    --Unmaker
    --Use: Deal +300% Weapon Damage for 15 seconds.
    --15% chance to increase attack speed by 30% for 5 seconds.
    Item_Artifact_060 = {
    PriorityFunction = function(unit, itemCount)
        if itemCount == 1 then
            return 200
        end

        if unit:GetAIBrain().mGold  >= 10000 then
            return 0
        else
            return 0
        end
     end,
    },

    --Deathbringer
    --Use: Silence target, preventing any abilities for 8 seconds.
    --+125 Weapon Damage
    --+70 Mana per second
    Item_Artifact_070 = {
    PriorityFunction = function(unit, itemCount)
        if itemCount == 1 then
            return 200
        end

        if unit:GetAIBrain().mGold  >= 10000 then
            return 0
        else
            return 0
        end
     end,
    },

    --Stormbringer
    --+3000 Mana
    ---25% to ability cooldowns
    --100% chance on hit to gain 20% of your damage in mana.
    Item_Artifact_080 = {
    PriorityFunction = function(unit, itemCount)
        if itemCount == 1 then
            return 200
        end

        if unit:GetAIBrain().mGold  >= 10000 then
            return 0
        else
            return 0
        end
     end,
    },

    --Girdle of the Giants
    --+2000 Hit Points
    --40% chance on hit to perform a cleaving attack, damaging nearby enemies.
    Item_Artifact_090 = {
    PriorityFunction = function(unit, itemCount)
        if itemCount == 1 then
            return 200
        end

        if unit:GetAIBrain().mGold  >= 16000 then
            return 0
        else
            return 0
        end
    end,
    },

	
    --Ashkandor
    --+30% Life Steal
    --+175 Weapon Damage
    Item_Artifact_100 = {
    PriorityFunction = function(unit, itemCount)
        if itemCount == 1 then
            return 200
        end

        if unit:GetAIBrain().mGold  >= 16000 then
            return 200
        else
            return 0
        end
    end,
    },

    --Orb of Veiled Storms
    --Use: Unleash a wave of pure force in an area, dealing 500 damage.
    --+80 Hit Points per second
    Item_Artifact_110 = {
    PriorityFunction = function(unit, itemCount)
        if itemCount == 1 then
            return 200
        end

        if unit:GetAIBrain().mGold  >= 10000 then
            return 0
        else
            return 0
        end
    end,
    },

    --Bulwark of the Ages
    --+2500 Armor
    --All damage reduced by 25%.
    Item_Artifact_120 = {
    PriorityFunction = function(unit, itemCount)
        if itemCount == 1 then
            return 200
        end

        if unit:GetAIBrain().mGold  >= 16000 then
            return 200
        else
            return 0
        end
    end,
    },

    --All Father's Ring
    --+1500 Hit Points
    --+2500 Mana
    --+1500 Armor
    --+10% Base Run Speed
    Item_Artifact_130 = {
    PriorityFunction = function(unit, itemCount)
        if itemCount == 1 then
            return 200
        end

        if unit:GetAIBrain().mGold  >= 25000 then
            return 200
        else
            return 0
        end
    end,
    },

    ----------------------------------------------
    --ARTIFACT POTIONS
    ----------------------------------------------

    --Enhanced Health Potion
    Item_Health_Potion_Art = {
        Priority = 0,
        --MaxPurchase = 1,
    },

    Item_Large_Health_Potion_Art = {
        Priority = 0,
        --MaxPurchase = 1,
    },

    Item_Mana_Potion_Art = {
        Priority = 0,
        --MaxPurchase = 1,
    },

    Item_Large_Mana_Potion_Art = {
        Priority = 0,
        --MaxPurchase = 1,
    },

    Item_Rejuv_Elixir_Art = {
        Priority = 0,
        --MaxPurchase = 1,
    },

    Item_Large_Rejuv_Elixir_Art = {
        Priority = 0,
        --MaxPurchase = 1,
    },

}

--AI sensor wants to shop
--Sensor asks FriendlyAsset for a sorted list of upgrades, SortCitadelUpgradePriorities(unit)
--FriendlyAsset asks AIshoputilities for GetUpgradesList()
--AIshoputilities gets the list of upgrades from AIglobals
CitadelUpgradeWeights = {
    --Fortified Structure - upgrades based on team fortress health, whether enemy has certain troops, warrank, and warscore (Fs1)
    --0.26.39 Commented out original code for cbuildhealth01 to raise the priority to get fs1 as soon as warscore 2 is hit.
    --This code means nothing unless the ai returns to base, so use HeroGOAP to send an order to the AI with the most goal to return at ws2.
    CBuildingHealth01 = {
        PriorityFunction = function(unit)
# 0.27.04 Changed value to WS >= 275
-- 0.26.46 changed to warscore > = 300
            if unit:GetAIBrain().Score.WarScore  >= 275 then
                return 500
            else
                return 0
            end
     end,
    },
--[[
 CBuildingHealth01 = {
        PriorityFunction = function(unit)
--0.26.40 Changed the priority level trigger from WarScore to WarRank for fs1
            if unit:GetAIBrain().Score.WarRank  >= 2 then
                return 500
            else
                return 0
            end
     end,
    },
--]]
--[[ --original code
    CBuildingHealth01 = {
        PriorityFunction = function(unit)

            if unit:GetAIBrain().Score.WarScore  >= 100 then
                return 200
            else
                return 0
            end
     end,
    },
--]]
    CBuildingHealth02 = {
    PriorityFunction = function(unit)
    --local priority = 0
        if GetCitadelHealth(unit) < 0.95 then
            return 500
        elseif EnemyHasUpgrade(unit, 'CTroopNumber04') then
            return 200
        elseif unit:GetAIBrain().Score.WarRank >= 7 or GetEnemyTeamBrain(unit).Score.WarRank >= 7 then
            return 5
        else
            return 0
        end
    end,
    },

    CBuildingHealth03 = {
    PriorityFunction = function(unit)
    --local priority = 0
        if GetCitadelHealth(unit) < 0.8 then
            return 500
        elseif EnemyHasUpgrade(unit, 'CTroopNumber04') then
            return 40
        elseif unit:GetAIBrain().Score.WarRank >= 10 or GetEnemyTeamBrain(unit).Score.WarRank >= 10 then
            return 5
        else
            return 0
        end
    end,
   },

    CBuildingHealth04 = {
    PriorityFunction = function(unit)
    --local priority = 0
        if GetCitadelHealth(unit) < 0.8 then
            return 500
        elseif EnemyHasUpgrade(unit, 'CTroopNumber04') then
            return 40
        elseif unit:GetAIBrain().Score.WarRank >= 10 or GetEnemyTeamBrain(unit).Score.WarRank >= 10 then
            return 5
        else
            return 0
        end
        end,
   },

    --Building Firepower - upgrades based on troop types possessed by team or enemy team, warrank, and citadel structure upgrades (trebuchet and Finger of God)
# 0.26.47 restored original code
    CBuildingStrength01 = {
	PriorityFunction = function(unit)
        if EnemyHasUpgrade(unit, 'CTroopNumber06') then
            return 20
        elseif TeamHasUpgrade(unit, 'CUpgradeStructure01') then
            return 10
        elseif unit:GetAIBrain().Score.WarRank >= 7 or GetEnemyTeamBrain(unit).Score.WarRank >= 7 then
            return 10
        else
            return 0
        end
    end,
},

    CBuildingStrength02 = {
    PriorityFunction = function(unit)
    --local priority = 0
        if EnemyHasUpgrade(unit, 'CTroopNumber06') then
            return 20
        elseif TeamHasUpgrade(unit, 'CUpgradeStructure01') then
            return 10
        elseif unit:GetAIBrain().Score.WarRank >= 9 or GetEnemyTeamBrain(unit).Score.WarRank >= 9 then
            return 10
        else
            return 0
        end
    end,
},

    CBuildingStrength03 = {
    PriorityFunction = function(unit)
    --local priority = 0
        if EnemyHasUpgrade(unit, 'CTroopNumber06') then
            return 20
        elseif TeamHasUpgrade(unit, 'CUpgradeStructure01') then
            return 10
        elseif unit:GetAIBrain().Score.WarRank >= 10 or GetEnemyTeamBrain(unit).Score.WarRank >= 10 then
            return 10
        else
            return 0
        end
    end,
},

    CBuildingStrength04 = {
    PriorityFunction = function(unit)
    --local priority = 0
        if EnemyHasUpgrade(unit, 'CTroopNumber06') then
            return 20
        elseif TeamHasUpgrade(unit, 'CUpgradeStructure01') then
            return 10
        elseif unit:GetAIBrain().Score.WarRank >= 10 or GetEnemyTeamBrain(unit).Score.WarRank >= 10 then
            return 5
        else
            return 0
        end
    end,
},

    --Currency - timed priorities
    CGoldIncome01 = {
        Priority = 500,
    },
    --0.26.39 Commented out original code for cgoldincome to; setting to static value of 500 so it is purchased every game
    --this might not seem logical, but I want the ai picking up cur1 and cur2 under all circumstances
#0.26.47 reduced Ai priority from 500 to 40
    CGoldIncome02 = {
        Priority = 40,
    },
    --[[
    CGoldIncome02 = { --7/11 minute cutoff for normal AI on normal/high gold, 15/22 min for nightmare AI, starting pri 30/60
        PriorityFunction = function(unit)
            local mult = 4 * math.floor(GetMinute())
            local base = 30 * GetGoldMult() * (GetAIDifficulty(unit)/2)
            local priority = math.max(0, base - mult)
            --LOG("mithy: CitadelUpgradeWeights: CGoldIncome02: "..repr(unit:GetAIBrain():GetTeamArmy().Name)..": "..repr(base).." - "..repr(mult).." = "..repr(priority))
            return priority
        end,
    },
    --]]
# 0.26.47 removed AI's desire to purchase currency 3 - dropped value to stactic 0 - old code commented out
    CGoldIncome02 = {
        Priority = 0,
    },
--[[
    CGoldIncome03 = { --5/7 min for normal, 10/15 for nightmare, starting pri 20/40
        PriorityFunction = function(unit)
            local mult = 4 * math.floor(GetMinute())
            local base = 20 * GetGoldMult() * (GetAIDifficulty(unit)/2)
            local priority = math.max(0, base - mult)
            --LOG("mithy: CitadelUpgradeWeights: CGoldIncome03: "..repr(unit:GetAIBrain():GetTeamArmy().Name)..": "..repr(base).." - "..repr(mult).." = "..repr(priority))
            return priority
        end,
    },
--]]

    --Blacksmith - match enemy upgrades, ultra-prioritize if either team has giants
    CTroopStrength01 = {
    PriorityFunction = function(unit)
        if TeamHasUpgrade(unit, 'CTroopNumber06') or EnemyHasUpgrade(unit, 'CTroopNumber06') then
            return 200
        elseif TeamHasUpgrade(unit, 'CTroopNumber03') or EnemyHasUpgrade(unit, 'CTroopStrength01') then
            return  35
        elseif unit:GetAIBrain().Score.WarRank >= 8 then
            return 10
        else
            return 0
        end
     end,
},

    CTroopStrength02 = {
    PriorityFunction = function(unit)
        if TeamHasUpgrade(unit, 'CTroopNumber06') or EnemyHasUpgrade(unit, 'CTroopNumber06') then
            return 150
        elseif TeamHasUpgrade(unit, 'CTroopNumber05') or EnemyHasUpgrade(unit, 'CTroopStrength02') then
            return  35
        elseif unit:GetAIBrain().Score.WarRank >= 9 then
            return 5
        else
            return 0
        end
    end,
},

    CTroopStrength03 = {
    PriorityFunction = function(unit)
        if TeamHasUpgrade(unit, 'CTroopNumber06') or EnemyHasUpgrade(unit, 'CTroopNumber06') then
            return 100
        elseif TeamHasUpgrade(unit, 'CTroopNumber04') or EnemyHasUpgrade(unit, 'CTroopStrength03') then
            return  35
        elseif unit:GetAIBrain().Score.WarRank >= 9 then
            return 5
        else
            return 0
        end
    end,
},

    CTroopStrength04 = {
    PriorityFunction = function(unit)
        if TeamHasUpgrade(unit, 'CTroopNumber06') or EnemyHasUpgrade(unit, 'CTroopNumber06') then
            return 75
        elseif EnemyHasUpgrade(unit, 'CTroopStrength04') then
            return 35
        elseif unit:GetAIBrain().Score.WarRank >= 10 then
            return 5
        else
            return 0
        end
    end,
},

    --Armory - match enemy upgrades, ultra-prioritize if either team has giants

    CTroopArmor01 = {
    PriorityFunction = function(unit)
        if TeamHasUpgrade(unit, 'CTroopNumber06') or EnemyHasUpgrade(unit, 'CTroopNumber06') then
            return 200
        elseif TeamHasUpgrade(unit, 'CTroopNumber03') or EnemyHasUpgrade(unit, 'CTroopArmor01') then
            return  35
        elseif unit:GetAIBrain().Score.WarRank >= 8 then
            return 15
        else
            return 0
        end
    end,
},

    CTroopArmor02 = {
    PriorityFunction = function(unit)
        if TeamHasUpgrade(unit, 'CTroopNumber06') or EnemyHasUpgrade(unit, 'CTroopNumber06') then
            return 150
        elseif TeamHasUpgrade(unit, 'CTroopNumber05') or EnemyHasUpgrade(unit, 'CTroopArmor02') then
            return 35
        elseif unit:GetAIBrain().Score.WarRank >= 9 then
            return 5
        else
            return 0
        end
    end,
},

    CTroopArmor03 = {
    PriorityFunction = function(unit)
        if TeamHasUpgrade(unit, 'CTroopNumber06') or EnemyHasUpgrade(unit, 'CTroopNumber06') then
            return 100
        elseif TeamHasUpgrade(unit, 'CTroopNumber04') or EnemyHasUpgrade(unit, 'CTroopArmor03') then
            return 35
        elseif unit:GetAIBrain().Score.WarRank >= 9 then
            return 5
        else
            return 0
        end
    end,
},

    CTroopArmor04 = {
    PriorityFunction = function(unit)
        if TeamHasUpgrade(unit, 'CTroopNumber06') or EnemyHasUpgrade(unit, 'CTroopNumber06') then
            return 75
        elseif EnemyHasUpgrade(unit, 'CTroopArmor04') then
            return 35
        elseif unit:GetAIBrain().Score.WarRank >= 10 then
            return 5
        else
            return 0
        end
    end,
},

    --Experience  
# 0.26.47 dropped priority from 50 to 0
    CPortalFrequency01 = {
        Priority =  0,
    ---- PriorityFunction = function(unit)
        ---- if TeamHasUpgrade(unit, 'CGoldIncome01') then
            ---- return 35
        ---- else
            ---- return 0
        ---- end
    ---- end,
    },

--0.26.40 - Set priority for experience 2-4 to ZERO
    CPortalFrequency02 = {
        Priority = 0,
    },
    CPortalFrequency03 = {
        Priority = 0,
    },
    CPortalFrequency04 = {
        Priority = 0,
    },

--[[  --original code
    CPortalFrequency02 = {
        PriorityFunction = function(unit)
            local mult = 3 * math.floor( (GetMinute() + GetAverageLevel(unit)) )
            local base = math.floor( 60 / GetXPMult() ) * (GetAIDifficulty(unit)/2)
            local priority = math.max(0, base - mult)
            --LOG("mithy: CitadelUpgradeWeights: CPortalFrequency02: "..repr(unit:GetAIBrain():GetTeamArmy().Name)..": "..repr(base).." - "..repr(mult).." = "..repr(priority))
            return priority
        end,
    },
    CPortalFrequency03 = {
        PriorityFunction = function(unit)
            local mult = 3 * math.floor( (GetMinute() + GetAverageLevel(unit)) )
            local base = math.floor( 45 / GetXPMult() ) * (GetAIDifficulty(unit)/2)
            local priority = math.max(0, base - mult)
            --LOG("mithy: CitadelUpgradeWeights: CPortalFrequency03: "..repr(unit:GetAIBrain():GetTeamArmy().Name)..": "..repr(base).." - "..repr(mult).." = "..repr(priority))
            return priority
        end,
    },
    CPortalFrequency04 = {
        PriorityFunction = function(unit)
            local mult = 3 * math.floor( (GetMinute() + GetAverageLevel(unit)) )
            local base = math.floor( 30 / GetXPMult() ) * (GetAIDifficulty(unit)/2)
            local priority = math.max(0, base - mult)
            --LOG("mithy: CitadelUpgradeWeights: CPortalFrequency04: "..repr(unit:GetAIBrain():GetTeamArmy().Name)..": "..repr(base).." - "..repr(mult).." = "..repr(priority))
            return priority
        end,
    },
--]]
    --Graveyard - priority based on death penalty, number of team deaths, average team level, and AI difficulty.
    CDeathPenalty01 = {
        PriorityFunction = function(unit)
            local mult = 4 * math.floor(GetTeamDeaths(unit) + GetAverageLevel(unit))
            local minimum = math.floor( 100 / GetDeathMult() / (GetAIDifficulty(unit)/2) )
            local priority = math.max(0, mult - minimum)
            --LOG("mithy: CitadelUpgradeWeights: CDeathPenalty01: "..repr(unit:GetAIBrain():GetTeamArmy().Name)..": " ..repr(mult).." - "..repr(minimum).." = "..repr(priority))
            return priority
        end,
    },

# 0.26.47 Removed AI's desire to pick up graveyard 2 and 3.  Should reduce some overhead.  Commented out old code
    CDeathPenalty02 = {
        Priority = 0,
    },

    CDeathPenalty03 = {
        Priority = 0,
    },
	
--[[	
    CDeathPenalty02 = {
        PriorityFunction = function(unit)
            local mult = 4 * math.floor(GetTeamDeaths(unit) + GetAverageLevel(unit))
            local minimum = math.floor( 200 / GetDeathMult() / (GetAIDifficulty(unit)/2) )
            local priority = math.max(0, mult - minimum)
            --LOG("mithy: CitadelUpgradeWeights: CDeathPenalty02: "..repr(unit:GetAIBrain():GetTeamArmy().Name)..": " ..repr(mult).." - "..repr(minimum).." = "..repr(priority))
            return priority
        end,
    },
    CDeathPenalty03 = {
        PriorityFunction = function(unit)
            if GetDeathMult() >= 1 then
            local mult = 4 * math.floor(GetTeamDeaths(unit) + GetAverageLevel(unit))
                local minimum = math.floor( 300 / GetDeathMult() / (GetAIDifficulty(unit)/2) )
                local priority = math.max(0, mult - minimum)
                --LOG("mithy: CitadelUpgradeWeights: CDeathPenalty03: "..repr(unit:GetAIBrain():GetTeamArmy().Name)..": " ..repr(mult).." - "..repr(minimum).." = "..repr(priority))
                return priority
            else
                return 0
            end
        end,
    },
--]]

    --Additional troops - AI will now attempt to match troop upgrades with their opponent even before WR 8
    --This keeps AI games from becoming too one-sided once one team gets priests+
    --Priests
    CTroopNumber03 = {
         PriorityFunction = function(unit)
            if EnemyHasUpgrade(unit, 'CTroopNumber03') or unit:GetAIBrain().Score.WarRank >= 8 then
                return 500
            else
                return 0
            end
        end,
    },
    --Angels
    CTroopNumber05 = {
         PriorityFunction = function(unit)
            if EnemyHasUpgrade(unit, 'CTroopNumber05') or unit:GetAIBrain().Score.WarRank >= 8 then
                return 500
            else
                return 0
            end
        end,
    },
    --Catapults
    CTroopNumber04 = {
         PriorityFunction = function(unit)
            if EnemyHasUpgrade(unit, 'CTroopNumber04') or unit:GetAIBrain().Score.WarRank >= 8 then
                return 500
            else
                return 0
            end
        end,
    },
    --Giants
    CTroopNumber06 = {
         PriorityFunction = function(unit)
            if EnemyHasUpgrade(unit, 'CTroopNumber06') or unit:GetAIBrain().Score.WarRank >= 8 then
                return 500
            else
                return 0
            end
        end,
    },

--Trebuchets - match, prioritize vs catapults+, take into account fort totals
CUpgradeStructure01 = {
    PriorityFunction = function(unit)
        local priority = 0
        local ourForts = unit:GetAIBrain():GetTeamArmy():GetListOfUnits(categories.FORT, false)
        if table.getn(ourForts) < 2 then
            return 0
        end

        local enemyForts = GetEnemyTeamBrain(unit):GetListOfUnits(categories.FORT, false)
        if EnemyHasUpgrade(unit, 'CTroopNumber04') and not TeamHasUpgrade(unit, 'CTroopNumber04') then
            priority = 15
        elseif EnemyHasUpgrade(unit, 'CUpgradeStructure02') then
            priority = 2 * table.getn(enemyForts)
        end

        return priority * table.getn(ourForts) * GoldThreshold(unit, UpgradeCost('CUpgradeStructure02'))
    end,
},

--Finger of God - match, prioritize vs catapults+
# 0.26.47 Removed AI's desire to pick up the finger of God.  Should reduce some overhead.  Commented out old code
    CUpgradeStructure02 = {
        Priority = 0,
    },
--[[


    CUpgradeStructure02 = {
    PriorityFunction = function(unit)
    --local priority = 0
        if EnemyHasUpgrade(unit, 'CUpgradeStructure02') or EnemyHasUpgrade(unit, 'CTroopNumber04') then
            return 100
        elseif GetEnemyTeamBrain(unit).Score.WarRank >= 9 then
            return 10
        else
            return 0
        end
   end,
},
--]]
}