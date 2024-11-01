local prevClass = HEMA01

HEMA01 = Class(prevClass) {

	--Update weapon sync for primary weapon
	--This is necessary because GPG overrode the ForgeUnit instance of this function
    OnWeaponEnabled = function(self, weapon)
        prevClass.OnWeaponEnabled(self, weapon)
        local label = weapon:GetBlueprint().Label
        if self.WeaponStats[label] then
        	self:UpdateWeaponSync(label)
        end
    end,

}