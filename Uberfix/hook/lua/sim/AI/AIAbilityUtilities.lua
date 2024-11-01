--Mithy: Fix for AI area-targeted ability lock-on
--No non-destructive fix available
function UseTargetedAbility( unit, ability, target, timeout )
    if not ValidateAbility.HasAbility( unit, ability ) then
        return false
    end

    if not ValidateAbility.CanUseAbility( unit, ability ) then
        return false
    end

    local taskInfo = false

    if IsEntity(target) then
        taskInfo = {
            AbilityName = ability,
            UserVerifyScript='/lua/user/AbilityCommand.lua',
            TaskName = "AbilityTask",
            Target = {
                Type = 'entity',
                EntityId = target:GetEntityId(),
                Position = table.copy(target:GetPosition()), --now copies position
            },
        }
    else
        taskInfo = {
            AbilityName = ability,
            UserVerifyScript='/lua/user/AbilityCommand.lua',
            TaskName = "AbilityTask",
            Target = {
                Type = 'position',
                Position = target,
            },
        }
    end

    if(unit and not unit:IsDead()) then
        local cmd = IssueScript( {unit}, taskInfo )

        local counter = 0
        while not IsCommandDone(cmd) do
            WaitTicks(1)
            if unit:IsDead() then
                return false
            end
            counter = counter + 0.1
            if timeout then
                if counter >= timeout then
                    return false
                end
            end
        end

        return FinishCasting( unit )
    else
        return false
    end
end