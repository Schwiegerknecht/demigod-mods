--Mithy: Fix for Rook TOL targeting fixation issue
local ShoulderWeaponFix = import('/lua/shoulderweaponfix.lua').ShoulderWeaponFix

local prevClass = HRookTOL
HRookTOL = Class(prevClass) {
    Weapons = {
        LightBeam = ShoulderWeaponFix(prevClass.Weapons.LightBeam),
    },
}
TypeClass = HRookTOL