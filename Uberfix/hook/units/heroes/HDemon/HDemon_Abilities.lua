--New Warp Area precast check to prevent ability use with no targets present
for i=1, 3 do
	local abilWarpArea = Ability['HDemonWarpArea0'..i]
	if abilWarpArea then
		abilWarpArea.PreCastCheck = function(self, unit)
		    local targetCategory = categories.ALLUNITS - categories.UNTARGETABLE - categories.STRUCTURE
		    --if self.TargetCategory then
		    --    targetCategory = ParseEntityCategoryEx(self.TargetCategory)
		    --end
		    local targets = unit:GetAIBrain():GetUnitsAroundPoint(targetCategory, unit:GetPosition(), self.WarpRange, 'Enemy')
		    if targets and table.getsize(targets) > 0 then
		    	return true
		    end
		    return false
		end
	end
end