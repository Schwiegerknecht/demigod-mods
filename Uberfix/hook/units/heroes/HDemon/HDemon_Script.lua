--Mithy: Fix for unnecessary range buff application pasted from Oak's script
--OnGotTarget and OnLostTarget overridden
local prevClass = HDemon

HDemon = Class(prevClass) {
    Weapons = {
        MeleeWeapon = Class(DefaultMeleeWeapon){
        	OnGotTarget = function(self)
                DefaultMeleeWeapon.OnGotTarget(self)
            end,

            OnLostTarget = function(self)
                DefaultMeleeWeapon.OnLostTarget(self)
            end,
        },
    },
}
TypeClass = HDemon