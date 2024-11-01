local prevClass = ForgeUnit

ForgeUnit = Class(prevClass) {
    OnCreate = function(self)
        prevClass.OnCreate(self)
    	--Mithy: New class table for Absorption re-write
        self.AbsorptionData = {
        	Buffs = {},
        	Mult = 1,
        }
        --Mithy: Fix for units not receiving base armor until armor is buffed
        self.Sync.Armor = self:GetBlueprint().Defense.BaseArmor or 0
    end,

	--Hook DoLifeSteal to perform mana add/leech
    DoLifeSteal = function(self, target, amount)
    	--Do normal lifesteal
    	prevClass.DoLifeSteal(self, target, amount)

        --Do energy add based on damage
        self:DoEnergyAdd(target, amount, self.EnergyAdd, true)

    	--Do energy leech based on damage and target energy
        self:DoEnergyLeech(target, amount, self.EnergyLeech, true)
    end,

	--Mithy: New energy leech/drain functions for associated BuffAffects
    --Adds mana based on damage done (similar to life steal, but demigod to mobile only)
    DoEnergyAdd = function(self, target, damage, pct, text)
    	if EntityCategoryContains(categories.HERO, self) and EntityCategoryContains(categories.MOBILE, target) and damage ~= 0 and pct and pct > 0 then
    		local energyAdd = damage * pct
    		self:AdjustEnergy(energyAdd, text)
    	end
	end,

    --Leeches mana from the target based on damage done (demigod to demigod only)
    DoEnergyLeech = function(self, target, damage, pct, text)
    	if EntityCategoryContains(categories.HERO, self) and EntityCategoryContains(categories.HERO, target) and damage ~= 0 and pct and pct > 0 then
    		local energyDrain = (damage * pct) * -1
    		energyDrain = target:AdjustEnergy(energyDrain, text) * -1
    		self:AdjustEnergy(energyDrain, text)
    	end
    end,

	--Utility function for adding/removing energy, floatText is an optional bool for displaying the amount
	--Returns actual change in energy, if any
	AdjustEnergy = function(self, amount, floatText)
		if amount ~= 0 and self.Energy then
			local currentEnergy = (self.Energy or self:GetBlueprint().Energy.EnergyStart) or 0
			local newEnergy = currentEnergy + amount

			if newEnergy > self.EnergyMax then
				newEnergy = self.EnergyMax
			elseif newEnergy < 0 then
				newEnergy = 1
			end

			local energyChange = newEnergy - currentEnergy
			if energyChange ~= 0 then
				self:SetEnergy(newEnergy)
				if floatText then
					local energyText = tostring(math.floor(energyChange))
					if energyChange > 0 then
						energyText = '+' .. energyText
					end
					FloatTextAt(self:GetFloatTextPositionOffset(0, 1, 0), energyText, 'EnergyRegen', self:GetArmy())
				end
			end
			return energyChange
		else
			return false
		end
	end,

    --New function for tabled Absorption re-write
    --Absorption buffs are now keyed and processed in numerical/chronological order to support any number of simultaneous absorption
    --affects concurrently.  Individual buffs (including multiple instances of the same buff) are removed as their absorption is depleted,
    --shifting buff [2] (if any) into key [1] for processing on the next loop iteration.
    --This insures that the oldest buffs take damage first and that the correct amount of absorption is removed upon buff removal.
    --
    --The whole process is seamless and completely transparent to the buffs themselves, and works with all existing buffs.  Existing buffs
    --with the same BuffType and Stacks == 'REPLACE', e.g. Bramble Shield, will still issue a removal on one another, resulting in exactly
    --the same behavior as before.  However, a much greater range of absorption functionality is now supported, and the co-existence of
    --different BuffTypes, e.g. Bramble Shield and Groffling Warplate, are now handled as you would expect them to be.
    --
    --Absorption.Mult, previously completely broken, now functions as a damage-taken multiplier for Absorption only, and is a unit-global
    --multiplier to all absorption damage.  As absorption happens prior to both Armor and DamageTakenMult, this is the only multiplier
    --that affects Absorption damage.  It is floored at 0.1, or 10%, and has no ceiling.  Stacking is additive, like all other buff affect Mults.
    DoAbsorption = function(self, data)
    	local absorbed = 0
    	local abData = self.AbsorptionData
    	--Process absorption buffs, if any, in numerical (chronological) order
        while data.Amount > 0 and abData.Buffs[1] do
        	local abBuff = abData.Buffs[1]

        	--Damage absorbed
        	local abDmg = math.min(abBuff.Absorption, data.Amount * abData.Mult)
            abBuff.Absorption = abBuff.Absorption - abDmg
            absorbed = absorbed + abDmg

            --Damage removed from Amount
            data.Amount = math.max(data.Amount - (abDmg / abData.Mult), 0)

			--Update sync value (also recalculated absolutely in BuffAffects.Absorption upon buff addition/removal)
            self.Sync.Absorption = self.Sync.Absorption - abDmg

			--If depleted, remove this buff instance, shifting the next one up via table.remove in BuffAffects.Absorption
            if abBuff.Absorption < 0.1 then
            	Buff.RemoveBuff(self, abBuff.BuffName, false, 1)
            end
        end
        if absorbed > 0 then
            --Handle float text - now only displayed for instigator and recipient, like all other damage floattext
            local txt = '( -'..absorbed..' )'
            local color = 'DamageHealing'
            if data.IsCrit then color = 'Crit' end
            local pos = self:GetFloatTextPositionOffset(0, 1.5, 0)

            if not data.NoFloatText and data.Instigator and not self == data.Instigator then
            	FloatTextAt(pos, txt, color, data.InstigatorArmy)
            end
            --Float text always shown for incoming absorption damage, even against NoFloatText weapons and on minions
            --if not EntityCategoryContains(categories.MINION, self) then
            	FloatTextAt(pos, txt, color, self:GetArmy())
            --end
        end
    end,

    --Mithy: Override DoTakeDamage to add no-kill support and reworked absorption
    DoTakeDamage = function(self, data)
        if self:CheckEvasion(data) then
            return
        end

        if data.Instigator:CheckMiss(self,data) then
            return
        end

        if not data.Type then
            WARN("*WARNING: No damage type specified hitting: ", self:GetUnitId())
            data.Type = 'Normal'
        end

        local isSpell = false
        if string.find(data.Type, 'Spell') then
            isSpell = true
        end

        if self.MagicImmune and isSpell then
            return
        end

        if data.CanCrit and data.Instigator.WeaponCrits then
            local damage = data.Amount
            #LOG('DEBUG: Default Damage = ' .. data.Amount)
            for abilityName,critBool in data.Instigator.WeaponCrits do
                if not data.CanCritFrom or (data.CanCritFrom and data.CanCritFrom[abilityName]) then
                    if not critBool then
                        continue
                    end

                    local critData = Ability[abilityName]

                    local critChance = critData.CritChance
                    if critData.CritChanceAbility and data.Type == 'Spell' then
                        #LOG('*DEBUG: Using Ability Crit Chance')
                        critChance = critData.CritChanceAbility
                    elseif critData.CritChanceRanged and not self.IsMelee then
                        #LOG('*DEBUG: Using Ranged Crit Chance')
                        critChance = critData.CritChanceRanged
                    end

                    if CalculateCritChance(critChance) then
                        data.Amount = data.Amount + ((CalculateCritDamage(damage, critData.CritMult)) - damage)
                        data.IsCrit = true

                        #LOG('DEBUG: Critical Hit! CritMult = ' .. critData.CritMult .. ', CritChance = ' .. critChance ..
                        #    ', newDamage = ' .. data.Amount .. ', CurrentTick = ' .. GetGameTick() )
                    end
                end
            end
            if data.IsCrit then
                if data.Instigator and not data.Instigator:IsDead() then
                    data.Instigator:OnCriticalHit(self, data)
                end
            end
        end

        # Absorption Check
        --Mithy: Added new absorption handling
        self:DoAbsorption(data)

        --[[ Old absorption code
        if self.Absorption > 0  and data.Amount > 0 then
            local unabsorbeddamage = data.Amount - self.Absorption
            if unabsorbeddamage < 0 then
                self.Absorption = self.Absorption - data.Amount
                data.Amount = 0
                FloatTextAt(table.copy(self:GetPosition()), "<LOC floattext_0003>ABSORBED!", 'DamageHealing')
            elseif unabsorbeddamage == 0 then
                self.Absorption = 0
                data.Amount = 0
                Buff.RemoveBuffsByAffect(self, 'Absorption')
                FloatTextAt(table.copy(self:GetPosition()), "<LOC floattext_0004>ABSORBED!", 'DamageHealing')
            else
                self.Absorption = 0
                data.Amount = unabsorbeddamage
                Buff.RemoveBuffsByAffect(self, 'Absorption')
            end
        end--]]

        if data.CanMagicResist and self.MagicResistance > 0 and isSpell then
            data.Amount = CalculateMagicResistDamage(data.Amount, self.MagicResistance)
        end

        #Armor!
        if not data.ArmorImmune then
            data.Amount = CalculateArmorDamage(data.Amount, self.Sync.Armor)
        end

        if self.DamageTakenMult and data.Amount > 0 then
            data.Amount = data.Amount * (1 + self.DamageTakenMult)
        end

        if data.Amount < 0 and ((self:GetHealth() - data.Amount) > self:GetMaxHealth()) then
            local amount = data.Amount
            data.Amount = self:GetHealth() - self:GetMaxHealth()
            # The overheal amount is the amount that you would have been healed if your health was low enough
            # This value is used in the floattext
            # Ignore the health crystal so its not too spammy when you're full health shopping etc
            if(data.Amount > amount and data.DamageAction != 'HealthStatueRegen01') then
                data.OverHeal = amount
            end
        end

        if data.Amount > 0 and data.Instigator != self then
            self:DoArmorProcs()
        end

        self:OnTakeDamage(data)

        #Added in another check so that we can do things like have buffs that make you not take damage but
        #still have your instigator act like it did full damage.
        if not self.CanTakeDamage and data.Amount > 0 then
            return
        end

        if CheckOverKill(self, data) then
            self:DoOverKill(data)
        end

        local preAdjHealth = self:GetHealth()
        self:AdjustHealth(-data.Amount)

        local health = self:GetHealth()
        if( health < 0.5 ) then
            --Mithy: Fix for Ooze suicide, and extension for other non-killing damage effects
            --Damage marked CannotKill will not kill anything, CannotKillSelf will not kill self, and CannotKillFriendly
            --will not kill friendlies (or self) unless the instigator is lost, in which case the flag will be ignored.
            if data.CannotKill
            or ( data.CannotKillFriendly and data.Instigator and IsAlly(self, data.Instigator) )
            or ( data.CannotKillSelf and data.Instigator and data.Instigator == self ) then
                self:SetHealth(1)
            else
                if not data.KillLocation then
                    data.KillLocation = table.copy(self:GetPosition())
                end
                self.KillData = data
                self:Kill()
            end
        end
    end,

    --New functions
    --These are mostly placeholders to allow BuffAffects to call them without checking
    --Their relevant functionality is handled in HeroUnit and only used for demigods
    UpdateWeaponStat = function(self, index, stat, value)
    end,

    UpdateWeaponSync = function(self, index)
    end,
}