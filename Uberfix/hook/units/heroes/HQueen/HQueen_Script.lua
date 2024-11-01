local prevClass = HQueen

HQueen = Class(prevClass) {

	--Hook CreateProjectileForWeapon to reduce projectile lifetime
    Weapons = {
        PrimaryWeapon = Class(prevClass.Weapons.PrimaryWeapon) {
            CreateProjectileForWeapon = function(self, bone)
                local proj = prevClass.Weapons.PrimaryWeapon.CreateProjectileForWeapon(self, bone)
                if proj then
                    proj:SetLifetime(.25)
                    return proj
                end
            end,
        },

        PackedWeapon = Class(prevClass.Weapons.PackedWeapon) {
            CreateProjectileForWeapon = function(self, bone)
                local proj = prevClass.Weapons.PackedWeapon.CreateProjectileForWeapon(self, bone)
                if proj then
                    proj:SetLifetime(.25)
                    return proj
                end
            end,
        },
    },

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
TypeClass = HQueen
