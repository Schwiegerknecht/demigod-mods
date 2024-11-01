--Mithy: Desperate Boots: Buff removal on sell/drop
local oldORA = Ability.Item_Boot_060_Desperation.OnRemoveAbility
Ability.Item_Boot_060_Desperation.OnRemoveAbility = function(self, unit)
    if oldORA then
        oldORA(self, unit)
    end
    if Buff.HasBuff(unit, 'Item_Boot_060_Desperation') then
        Buff.RemoveBuff(unit, 'Item_Boot_060_Desperation')
    end
end


--Mithy: Ironwalkers: Fix always-on for Rook, display actual trigger speed
--Now maintains ~5.5 activation speed for 6.0 base speed Demigods.  This is still somewhat useless, and should probably be addressed in a balance mod.
--1.06 LORD-ORION fixed property call from Physics.Speed to Physics.MaxSpeed
Items.Item_Boot_070.GetTriggerAmount = function(self) return math.floor(Ability['Item_Boot_070'].TriggerPercent * 100) end
Items.Item_Boot_070.Tooltip.ChanceOnHit = 'Whenever Movement Speed is reduced below [GetTriggerAmount]% of base, Armor is increased by [GetArmorBonus].'
Ability.Item_Boot_070.TriggerPercent = 0.90
Ability.Item_Boot_070.OnAuraPulse = function(self, unit, params)
    if unit.Sync.MovementSpeed/unit:GetBlueprint().Physics.MaxSpeed >= self.TriggerPercent then
        if Buff.HasBuff(unit, 'Item_Boot_070_Armor') then
            Buff.RemoveBuff(unit, 'Item_Boot_070_Armor')
        end
    else
        Buff.ApplyBuff(unit, 'Item_Boot_070_Armor', unit)
    end
end
--Buff removal on sell/drop
local oldORA = Ability.Item_Boot_070.OnRemoveAbility
Ability.Item_Boot_070.OnRemoveAbility = function(self, unit)
	if oldORA then
		oldORA(self, unit)
	end
	if Buff.HasBuff(unit, 'Item_Boot_070_Armor') then
		Buff.RemoveBuff(unit, 'Item_Boot_070_Armor')
	end
end