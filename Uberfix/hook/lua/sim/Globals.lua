--Override MetaImpact to perform a kill and give partial damage credit to the instigator
function MetaImpact(data, metaEntities)
    if not data.Radius or data.Radius <= 0 then
        error('MetaImpact Radius <=0')
    end

    if not data.Category then
        error('No category specified.')
    end

    local category = data.Category
    if type(category) == 'string' then
        category = ParseEntityCategoryEx(data.Category)
    end

    local instArmy = data.InstigatorArmy

    local shieldHits = GetShieldHits(data)
    local entities = metaEntities or GetEntitiesInSphere("UNITS", data.Origin, data.Radius)

    for k,entity in entities do

        if entity:IsDead() then
            continue
        end

        if entity.CanTakeImpulse == false then
            continue
        end

        if not entity:IsMobile() then
            continue
        end

        if not EntityCategoryContains(category,entity) then
            continue
        end

        if not data.DamageFriendly and instArmy >= 0 then
            if IsAlly(instArmy,entity:GetArmy()) then
                continue
            end
        end

        if EntityIsShielded(entity,shieldHits) then
            continue
        end

        # Calculate the impact vector to fling the unit around
        local impactVec = VDiff(entity:GetPosition(), data.Origin)
        impactVec.y = 0
        local distToCenter = VLength(impactVec)
        if data.SpecialInnerRadius and distToCenter < data.SpecialInnerRadius then
            data.SpecialInnerRadiusFunc(entity)
            continue
        end
        impactVec.y = data.Radius - distToCenter
        impactVec = VNormal(impactVec)
        impactVec = VMult(impactVec, data.Amount * (1.0 - (distToCenter/data.Radius) * 0.25))

        # Apply the impulse force
        local result = entity:AddImpulseEx(impactVec,true)
        if result and EntityCategoryContains(categories.ALLUNITS, entity) then
            entity.KillData = {
                InstigatorArmy = instArmy,
                Instigator = data.Instigator,
                InstigatorBp = data.InstigatorBp,
                DamageAction = 'MetaImpact',
                KillLocation = table.copy(entity:GetPosition()),
            }
            entity.Damagers[instArmy] = (entity.Damagers[instArmy] or 0) + entity:GetMaxHealth()
            entity.DamagerTimes[instArmy] = GetGameTimeSeconds()
            entity.DamageTotal = (entity.DamageTotal or 0) + entity:GetMaxHealth()
            entity:Kill()
        end
    end
end