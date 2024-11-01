--Mithy: Hook OnStopBeingBuilt to add new Sync variables for UI stats

local prevClass = HeroUnit

HeroUnit = Class(prevClass) {

    OnStopBeingBuilt = function(self, builder, layer)
        local bp = self:GetBlueprint()
        self.Nickname = self:GetAIBrain().Nickname
        --New primary weapon stats
        --self.Sync.DamageRadius = bp.Weapon[1].DamageRadius or 0
        --self.Sync.SplashMult = 1

        --Set up a new table to tracks stats for any number of demigod 'primary' weapons
        --Modal demigods can use self:UpdateWeaponSync(n) to set the index of their current primary weapon,
        --and that weapon's current stats will be copied to the sync for UI display.
        --This system is completely modular and can support any number of weapon stats.  Individual weapon
        --stat values are both added and updated by BuffAffect functions, and any time the primary weapon's
        --stats change, they are immediately copied to the sync.
        --LOG("WeaponStats Setup: "..self.Nickname..": entityid = "..self:GetEntityId().." / bpid = "..bp.BlueprintId)
        self.WeaponStats = {}
        for i = 1, self.NumWeapons do
            local wep = self:GetWeapon(i)
            local wepbp = wep:GetBlueprint()
            if wep and wepbp then
                --Only create stat tables for valid, buffable weapons.  This controls which weapons have
                --stats tracked, and causes any update calls for non-tracked weapons to be ignored
                if not wepbp.NoWeaponBuffs then
                    --LOG("\t"..i..": "..wepbp.Label)
                    local weptable = {}
                    --Numeric index and label are both references to the same subtable
                    --This allows update functions to use either label or numeric index
                    self.WeaponStats[i] = weptable
                    self.WeaponStats[wepbp.Label] = weptable
                end
            end
        end
        --Default primary weapon to index 1
        self:UpdateWeaponSync(1)
        --Actual stat and sync values will be updated by InitialStats buffs via BuffAffects
        --This needs to be set to the appropriate index by modal demigod states to have any effect

        --Misc stats, default values as per BuffAffects.lua BuffCalculate calls
        self.Sync.MoveSlowCap = 0
        self.Sync.DamageReturn = 0
        self.Sync.LifeSteal = 0
        self.Sync.DeathPenaltyMult = 1
        self.Sync.DamageTakenMult = 0
        self.Sync.EvasionChance = 0
        self.Sync.VisionRadius = bp.Intel.VisionRadius or 0
        self.Sync.OmniRadius = bp.Intel.OmniRadius or 0
        self.Sync.GoldProduction = bp.General.ProductionPerSecondGold or 0
        self.Sync.ExperienceMod = 1
        self.Sync.MissChance = 0
        self.Sync.Absorption = 0
        self.Sync.BountyGivenMod = 1
        self.Sync.BountyReceivedMod = 1
        self.Sync.Invincible = false
        self.Sync.MagicImmune = false
        self.Sync.DebuffImmune = false
        self.Sync.StunImmune = false

        --New energy manipulation affects
        self.Sync.EnergyLeech = 0
        self.Sync.EnergyAdd = 0

        prevClass.OnStopBeingBuilt(self, builder, layer)
    end,

    SetCanTakeDamage = function(self, val)
        prevClass.SetCanTakeDamage(self, val)
        self.Sync.Invincible = (not val)
    end,

	--Update weapon sync for primary weapon
    OnWeaponEnabled = function(self, weapon)
        prevClass.OnWeaponEnabled(self, weapon)
        local label = weapon:GetBlueprint().Label
        if self.WeaponStats[label] then
        	self:UpdateWeaponSync(label)
        end
    end,

    --New function
    --Called by BuffAffects to add/update stats for a specific weapon index
    --Updates all indices if index is false or nil
    --Updates sync values via UpdateWeaponSync if the active weapon is being modified
    UpdateWeaponStat = function(self, index, stat, value)
    	if not index then
    		for index, wepstats in self.WeaponStats do
    			if type(index) == 'number' then
    				wepstats[stat] = value
     			end
    		end
    		self:UpdateWeaponSync(false, stat)
    	elseif self.WeaponStats[index] then
            self.WeaponStats[index][stat] = value
            if self.WeaponStats[index] == self.WeaponStats._Primary then
                self:UpdateWeaponSync(false, stat)
            end
        end
    end,

    --New function
    --Updates weapon sync values to reflect active primary weapon stats
    --If called with an index, first sets the demigod's active primary weapon to that index
    --  Index can be a weapon label or a numeric index
    --If called with stat, only that stat name is updated
    UpdateWeaponSync = function(self, index, stat)
        if index and self.WeaponStats[index] then
        	if self.WeaponStats._Primary == self.WeaponStats[index] then
        		return
        	else
	            self.WeaponStats._Primary = self.WeaponStats[index]
	        end
        end
        if self.WeaponStats._Primary then
        	if not stat then
	            for stat, value in self.WeaponStats._Primary do
	                self.Sync[stat] = value
	            end
	        else
	        	self.Sync[stat] = self.WeaponStats._Primary[stat]
	        end
        end
    end,
}