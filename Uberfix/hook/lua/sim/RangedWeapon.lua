--Mithy: Fix for ranged demigod rapid attack stutter on stuck/follow
local prevClass = RangedWeapon

RangedWeapon = Class(prevClass) {

    --OMHEC overridden
    OnMotionHorzEventChange = function(self, new, old)
        Weapon.OnMotionHorzEventChange(self, new, old)
        if old == 'Stopped' and not self.ContinueAttack and not Buff.HasBuff(self.unit, 'RangeAttackLock') then
            --Abort attack
            self:AbortAttack()
            if self.unit.Character then
                self.unit.Character:AbortAction()
            end
            --Skip aborts for the 0.6s following the next 0.2s
            if not self.SkipThread then
                self.SkipThread = self:ForkThread(function()
                    WaitTicks(2)
                    self.ContinueAttack = true
                    WaitTicks(6)
                    self.ContinueAttack = nil
                    self.SkipThread = nil
                end)
            end
        end
    end,
}
