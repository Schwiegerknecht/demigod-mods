local prevClass = Weapon

Weapon = Class(prevClass) {
    GetDamageTable = function(self)
    	local damagetable = prevClass.GetDamageTable(self)
        local bp = self:GetBlueprint()

        --Kill prevention flags
        damagetable.CannotKill = bp.CannotKill
        damagetable.CannotKillSelf = bp.CannotKillSelf
        damagetable.CannotKillFriendly = bp.CannotKillFriendly

        return damagetable
    end,
}