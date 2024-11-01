--Shared code for Rook shoulder weapon fix, used by both units' weapons

function ShoulderWeaponFix(prevClass)
    return Class(prevClass) {
        OnFire = function(self)
            local targetblip = self:GetTarget():GetRealTargetEntity():GetBlip(self.unit:GetArmy())
            if not targetblip or ( not EntityCategoryContains(categories.STRUCTURE, targetblip) and not targetblip:IsSeenNow() ) then
                --[[
                local unitnames = { hrooktol = 'TOL', hrooktrebuchet = 'Trebuchet', }
                local reason = self.unit:GetAIBrain().Nickname..':'..unitnames[self.unit:GetBlueprint().BlueprintId]..'@'..math.floor(GetGameTimeSeconds())..'s: Attempted to fire at non-visible target: '..targetblip:GetSource():GetBlueprint().BlueprintId
                print(reason)
                LOG('\n'..reason..'\n')--]]
                self:ResetTarget()
                self:ResetFireClock()
                return
            end
            prevClass.OnFire(self)
            if self.TargetCheckThread then
                KillThread(self.TargetCheckThread)
            end
            self.TargetCheckThread = self:ForkThread(self.CheckTarget)
        end,

        --This thread runs every time the weapon fires, waiting 3x ROF and then checking for a stuck target
        CheckTarget = function(self)
            local firetarget = self:GetTarget()
            WaitSeconds( (1 / self:GetBlueprint().RateOfFire) * 3 )
            local target = self:GetTarget()
            local reset = false
            --local unitnames = { hrooktol = 'TOL', hrooktrebuchet = 'Trebuchet', }
            --local reason = self.unit:GetAIBrain().Nickname..':'..unitnames[self.unit:GetBlueprint().BlueprintId]..'@'..math.floor(GetGameTimeSeconds())..'s: '
            if target and target == firetarget then
                --[[
                reason = reason..'Stuck Target: '
                if target:IsDestroyed() or not target:IsAlive() then
                    reason = reason..'Target is dead/destroyed; '
                else
                    local unit = target:GetRealTargetEntity()
                    reason = reason..'Target: '..unit:GetBlueprint().Name or unit:GetBlueprint().BlueprintId..'; '

                    local blip = unit:GetBlip(self.unit:GetArmy())
                    if not blip or ( not blip:IsSeenNow() and not blip:IsOnOmni() ) then
                        reason = reason..'Target blip not visible; '
                    end
                    local range = self:CheckTargetRange(target)
                    if range > self:GetMaxRadius() then
                        reason = reason..'Target out of range (Range:'..range..'); '
                    elseif range < self:GetMinRadius() or 0 then
                        reason = reason..'Target inside minradius (Range:'..range..'); '
                    end
                end--]]
                reset = true
                --[[
            elseif target ~= firetarget then
                reason = reason..'New target, idling.'
            else
                reason = reason..'No target, idling.'
                --]]
            end

            if reset then
                self:ResetTarget()
                --print(reason)
            end
            --LOG('\n'..reason..'\n')
            self.TargetCheckThread = nil
        end,
    }
end