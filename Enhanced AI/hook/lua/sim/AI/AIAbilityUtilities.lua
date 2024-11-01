--Shared function for determining when a general is at max summon count
# 0.26.41 - Added code from miriyaka.  Code is designed to provide a new function to ensure that the 
# AI is not resummoning minions if it already has the max available (shamblers/yetis/orbs only)
function ShouldSummon(unit, action)
    local abilityBP = Ability[action.Ability]
    local maxSummons, summonCat = false, false
    if abilityBP then
        if abilityBP.MaxYeti then
            maxSummons = abilityBP.MaxYeti
            summonCat = categories.YETI
            # LOG("ShouldSummon: MaxYeti: "..maxSummons)
        elseif abilityBP.MaxShamblers then
            maxSummons = abilityBP.MaxShamblers
            summonCat = categories.ENT
            # LOG("ShouldSummon: MaxShamblers: "..maxSummons)
        elseif abilityBP.MaxBalls then
            maxSummons = abilityBP.MaxBalls
            summonCat = categories.BALLLIGHTNING
            # LOG("ShouldSummon: MaxBalls: "..maxSummons)
        end
    else
        LOG("ShouldSummon: Error: Could not get ability BP for ability '"..repr(action.Ability).."', bypassing")
        return true
    end
    if maxSummons and summonCat then
        if table.getn(unit:GetAIBrain():GetListOfUnits(summonCat, false)) < maxSummons then
            return true
        else
            # LOG("ShouldSummon: Already at max, abort action")
        end
    else
        # LOG("ShouldSummon: Error: Could not find max summons for ability '"..action.Ability.."', bypassing")
        return true
    end
    return false
end

--InstantStatusFunction for general summons
function SummonStatusFunction(unit, action)
    # LOG("SummonStatusFunction "..repr(unit:GetAIBrain().Nickname).."/"..repr(unit:GetUnitId()))
    if DefaultStatusFunction(unit, action) and ShouldSummon(unit, action) then
        return true
    end
    return false
end

--ActionFunction for general summons
function SummonActionFunction(unit, action)
    # LOG("SummonActionFunction: "..repr(unit:GetAIBrain().Nickname).."/"..repr(unit:GetUnitId()))
    local actionBp = HeroAIActionTemplates[action.ActionName]
    local abilities = actionBp.Abilities
    local ready = GetReadyAbility( unit, abilities )
    if ready and ShouldSummon(unit, action) then
        local timeout = actionBp.InstantTimeout or 7
        return UseInstantAbility( unit, ready, timeout )
    end
    return false
end