
local prevClass = AIBrain

AIBrain = Class(prevClass) {

    --Mithy: New function for checking for ArmyBonus presence (and existence)
    --Returns false if bonus doesn't exist or isn't present, otherwise returns the number of instances
    HasArmyBonus = function(self, bonusName)
        local bonusNum = false
        if ArmyBonuses[bonusName] then
            for k, name in self.ArmyBonusData do
                if name == bonusName then
                    if not bonusNum then
                        bonusNum = 1
                    else
                        bonusNum = bonusNum + 1
                    end
                end
            end
        end
        return bonusNum
    end,

    --Mithy: Fix for infinite ArmyBonus table stacking: unless 'stack' parameter (bool) is
    --specified, one instance of the ArmyBonus being added (if present) is removed before addition
    --
    --Mods using stacking ArmyBonuses can harmlessly specify the stack parameter as true even
    --if the UberFix is not present, to make sure their ArmyBonuses stack properly in any case
    --Note that this should only be used for ArmyBonuses whose buffs have 'ALWAYS' stacking,
    --as with the Morale skill bonuses, otherwise you're just creating pointless overhead
    --
    --1.05 Change: The ArmyBonus's Buffs are now checked for REPLACE stacking before removal
    --This should insure that the stacking flag isn't needed for bonuses that stack, e.g.
    --flag bonuses
    AddArmyBonus = function(self, bonusName, unit, stack)
        if not stack and self:HasArmyBonus(bonusName) then
            if ArmyBonuses[bonusName].Buffs then
                for k, buffName in ArmyBonuses[bonusName].Buffs do
                    local buffDef = Buffs[buffName]
                    if buffDef and buffDef.Stacks and buffDef.Stacks == 'REPLACE' then
                    	SPEW("AddArmyBonus: Stacking detection - removing one instance of ArmyBonus '"..bonusName.."'")
                        self:RemoveArmyBonus(bonusName, 1, true)
                        break
                    end
                end
            end
        end
        prevClass.AddArmyBonus(self, bonusName, unit)
    end,

    --Mithy: Fix for proceeding with the entire ArmyBonus removal process without bonus being present:
    --bonus presence is checked (unless fourth optional skip param is specified) before proceeding
    --Can not prevent accrual of OnKilled callbacks, but does remove virtually all of their execution
    --overhead (which only occurs at demigod death, after which they are cleared out)
    --
    --New third parameter: 'removeNum' specifies the number of instances to remove
    --Default when not specified is 1, keeping the same behaviour for existing calls (plus the check)
    --Specify 0 or -1 to remove all instances
    --This is particularly useful for procedural abilities that add and remove ArmyBonuses repeatedly
    --(e.g. Compost) to remove all instances of a bonus and further insure against infinite stacking
    --
    --Fourth param, skip (bool), skips the presence check if only one instance is to be removed
    --This is used by the AddArmyBonus pre-remove above to save redundant work
    --
    --As with AddArmyBonus, these parameters are harmless if the UberFix is not present, although your
    --mod's ArmyBonus behaviour should be modified to prevent the infinite stacking problems that
    --vanilla Compost had if you're not planning to require the UberFix (by calling at least one remove
    --per add for each ArmyBonus)
    RemoveArmyBonus = function(self, bonusName, removeNum, skip)
        --Normal behaviour: first check for presence, then remove one instance
        if not removeNum or removeNum == 1 or type(removeNum) ~= 'number' then
            if skip or self:HasArmyBonus(bonusName) then
                prevClass.RemoveArmyBonus(self, bonusName)
            end
        --Multi-instance removal: remove number of instances specified up to number present
        else
            local numInstances = self:HasArmyBonus(bonusName)
            if numInstances then
                if removeNum <= 0 then
                    removeNum = numInstances
                else
                    removeNum = math.min(numInstances, removeNum)
                end
                SPEW("RemoveArmyBonus: Removing "..removeNum.." instance(s) of ArmyBonus '"..bonusName.."'")
                for i = 1, removeNum do
                    prevClass.RemoveArmyBonus(self, bonusName)
                end
            end
        end
    end,

    --Mithy: Remove non-allied gold amounts from sync, except for observers
    InternalGiveResources = function(self, type, amount)
        prevClass.InternalGiveResources(self, type, amount)
        if Sync.ArmyGold and Sync.ArmyGold[self:GetArmyIndex()] > 0
        and GetFocusArmy() ~= -1 and not IsAlly(GetFocusArmy(), self:GetArmyIndex()) then
            Sync.ArmyGold[self:GetArmyIndex()] = 0
        end
    end,

    TakeResource = function(self, type, amount)
        prevClass.TakeResource(self, type, amount)
        if Sync.ArmyGold and Sync.ArmyGold[self:GetArmyIndex()] > 0
        and GetFocusArmy() ~= -1 and not IsAlly(GetFocusArmy(), self:GetArmyIndex()) then
            Sync.ArmyGold[self:GetArmyIndex()] = 0
        end
    end,

    --Mithy: Support function for flag fix
    GetEnemyTeamArmy = function(self)
        if self.EnemyTeamArmy then
            return self.EnemyTeamArmy
        end

        if self.Name ~= 'NEUTRAL_CIVILIAN' then
            for k, brain in ArmyBrains do
                if brain.TeamBrain and IsEnemy(brain:GetArmyIndex(), self:GetArmyIndex()) then
                    self.EnemyTeamArmy = brain
                    return brain
                end
            end
        end

        return false
    end,

}