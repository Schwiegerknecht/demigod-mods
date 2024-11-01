--Mithy: Fix for Rook Trebuchet targeting fixation issue
local ShoulderWeaponFix = import('/lua/shoulderweaponfix.lua').ShoulderWeaponFix

local prevClass = HRookTrebuchet
HRookTrebuchet = Class(prevClass) {
    Weapons = {
        Boulder = ShoulderWeaponFix(prevClass.Weapons.Boulder),
    },
}
TypeClass = HRookTrebuchet