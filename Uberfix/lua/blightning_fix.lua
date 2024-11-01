--Called from Ball Lightning unit scripts to centralize their weapon's sticky beam fix
function BallLightningFix(prevClass)
	local DefaultMeleeWeapon = import('/lua/sim/MeleeWeapon.lua').DefaultMeleeWeapon
    return Class(prevClass) {
        Weapons = {
            MeleeWeapon = Class(prevClass.Weapons.MeleeWeapon) {
                DoMeleeDamage = function(self, target)
                    DefaultMeleeWeapon.DoMeleeDamage(self, target)

                    --Mithy: This entire block is now forked, to avoid possible problems
                    --that might arise from waiting inside a core weapon function
                    ForkThread(function()
	                    local Effects = {
	                        Base = 'Oculus',
	                        Beams = 'LightningBeam01',
	                    }
	                    local beamTrash = TrashBag()

	                    #### Impact Emitters
	                    emitIds = AttachEffectsAtBone(target, EffectTemplates.Oculus.LightningImpact01, -1)

	                    #### Beam Emitters
	                    --Mithy: Main fix for sticky lightning
	                    if target and target:BeenDestroyed() == false then --IsDead check omitted, we want the effect even on a target we've killed
	                        emitIds = AttachBeamEffectOnEntities( Effects.Base, Effects.Group, Effects.Beams, self.unit, 'sk_HOculus_eye_root', target, -1, target:GetArmy(), self.unit.TrashOnKilled, target.Trash )
	                    end
	                    self:PlaySound('Forge/CREEPS/Eye/snd_cr_eye_attack')
	                    if emitIds then
	                        for kEffect, vEffect in emitIds do
	                            beamTrash:Add(vEffect)
	                        end
	                    end

                        WaitSeconds(0.5)
                        beamTrash:Destroy()
                        beamTrash = nil --this should not be doing anything as beamTrash is a local table/bag?
                    end)
                end,
            },
        },
    }
end