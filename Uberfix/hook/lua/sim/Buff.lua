--Mithy: Buff.lua hook for adding new utility functions

--RemoveBuffsByType: Does what it says on the tin
function RemoveBuffsByType(unit, buffType)
	if unit.Buffs.BuffTable[buffType] then
		local removeBuffs = {}
		for buffName, buffData in unit.Buffs.BuffTable[buffType] do
			table.insert(removeBuffs, buffName)
		end
		for k, buffName in removeBuffs do
			RemoveBuff(unit, buffName, true)
		end
	end
end

--HasBuffType: Returns true if unit has any buffs with of the specified type
--num specifies an optional minimum number of buffs of that type required to match
function HasBuffType(unit, buffType, num)
	num = num or 1
	local count = 0
	if unit.Buffs.BuffTable[buffType] then
		for buffName, buffData in unit.Buffs.BuffTable[buffType] do
			count = count + buffData.Count or 1
			if count >= num then
				return true
			end
		end
	end
	return false
end