--Mithy: Balance Fix for Blast Off Level I having half the radius of all other levels.  This cannot
--possibly be intended, especially given the initial damage of 200.  No other Demigod's level I AE
--damage ability has a shorter affect/damage radius than further levels, only reduced damage.
Ability.HOculusBlastOff01.DamageRadius = 6 # 3
Ability.HOculusBlastOff01.AffectRadius = 6 # 2.5

--Mithy: Brain Storm function overridden to fix debuff removal (from caster to target) and add
--effects and debuff removal at all levels, not just with Mental Agility.
function BrainStorm(abilityDef, unit, params)
    local target = params.Targets[1]
    local maxEnergy = target:GetMaxEnergy()
    local currentEnergy = target:GetEnergy()
    if currentEnergy + abilityDef.HealAmt > maxEnergy then
        target:SetEnergy(maxEnergy)
    else
        target:SetEnergy(currentEnergy + abilityDef.HealAmt)
    end

    if Validate.HasAbility(unit, 'HOculusMentalAgility') then
        Buff.ApplyBuff(target, 'HOculusMentalAgility', unit)
    end

    --Mithy: Removed the following from above conditional block
    Buff.RemoveBuffsByDebuff(target, true)

    # Mana regain effects at targeted unit
    AttachBuffEffectAtBone( target, 'Energize01', -2 );

    # Casting effects on hand
    AttachEffectsAtBone( unit, EffectTemplates.Oculus.BrainstormCast01, 'sk_Puppet02_staff_effects' )

    # Glow at base of Oculus
    AttachEffectsAtBone( unit, EffectTemplates.Sedna.CastHeal02, -2 )
end

# Electrocution - patch 1.3 solution insufficient, still only works to counter base regen.  Other buffs still allow significant regen.
Buffs.HOculusElectrocution01.Affects.Regen = {Set = 0.0}
Buffs.HOculusElectrocution01.Affects.EnergyRegen = {Set = 0.0}

# Lightning Blast: OnWeaponProc overridden to disable DamageFriendly and move damage origin to target from attacker
local NewWeaponProc = function(self, unit, target, damageData)
    AttachEffectsAtBone( target, EffectTemplates.Buff.LightningBlast01, -1 )

    data = {
        Instigator = unit,
        InstigatorBp = unit:GetBlueprint(),
        InstigatorArmy = unit:GetArmy(),
        Amount = self.DamageAmount,
        Type = 'Spell',
        Radius = self.DamageRadius,
        DamageFriendly = false,
        DamageSelf = false,
        Origin = target:GetPosition(),
        CanCrit = false,
        CanBackfire = false,
        CanBeEvaded = false,
        CanMagicResist = true,
        ArmorImmune = true,
        NoFloatText = false,
        Group = 'UNITS',
    }

    DamageArea(data)
end

Ability.HOculusLightningBlast01Ally.OnWeaponProc = NewWeaponProc
Ability.HOculusLightningBlast02Ally.OnWeaponProc = NewWeaponProc
Ability.HOculusLightningBlast03Ally.OnWeaponProc = NewWeaponProc


# Func: Ball Lightning
--Overridden to directly issue an attack move order instead of searching for targets.  This is to fix a common issue where
--Ball Lightning are not given any orders when there is a target within 40, but outside their comparatively short autoattack range.
function BallLightning(abilityDef, unit, params)
    local orient = unit:GetOrientation()
    local pos = unit:GetPosition()
    local spawnedBalls = {}
    local aiBrain = unit:GetAIBrain()
    local dir = 5 * VNormal( VDiff(pos,params.Target.Position) )
    local cross = 0.5 * VCross(dir, Vector(0,1,0))

    for i = 1, abilityDef.NumberOfBalls do
        local offset = -2 + i
        local fixedPos = unit:FindEmptySpotNear({(pos[1] - dir[1])-(cross[1] * offset), pos[2], (pos[3] - dir[3])-(cross[3] * offset)})
        local ball = CreateUnitHPR(abilityDef.BallUnit, unit:GetArmy(), fixedPos[1], fixedPos[2], fixedPos[3], orient[1], orient[2], orient[3])
        table.insert(spawnedBalls, ball)
    end
    local platoon = aiBrain:MakePlatoon('', '')
    for k,v in spawnedBalls do
        if not v:IsDead() then
            if Validate.HasAbility(unit, 'HOculusExplosiveEnd') then
                v.Callbacks.OnKilled:Add(BallDeath, abilityDef)
            end
            v:AdjustHealth( v:GetMaxHealth() )
            CountBalls(abilityDef.MaxBalls, v)
            aiBrain:AssignUnitsToPlatoon( platoon, {v}, 'Attack', 'BlockFormation' )
        end
    end
    --Mithy: Target check removed, attack move order issued
    --platoon:AggressiveMoveToLocation(params.Target.Position)
    --AggresiveMoveToLocation does not seem to do anything, using normal per-unit attack move order
    IssueAggressiveMove(spawnedBalls, params.Target.Position)

    --Return the table of units for mods to work with
    return spawnedBalls
end



# Func: Chain Lightning
--Overridden to attempt to fix 'sticky lightning'.  The only errors related to this that I've seen in the log
--have been from to trying to fix a beam to or from a chain target that is already destroyed, and sure enough, the function
--doesn't check whether or not its chain target exists, ('not v:IsDead()' still passes if the target is destroyed, since that
--will return nil). It also does no checks whatsoever on the existence or dead status of the previous target ('target' in the
--inner loop) before attaching the beam, and it inexplicably does a wait AFTER acquiring targets but before performing the chain/damage.
--
--All of these weaknesses should be fixed, although there's still a good chance that this problem has additional causes.
function ChainLightning(abilityDef, unit, params)
    local radius = abilityDef.ChainAffectRadius
    local aiBrain = unit:GetAIBrain()
    local beamTrash = TrashBag()
    local chainedUnits = {}
    local target = params.Targets[1]

    #### Impact Emitters
    local emitIds = AttachEffectsAtBone(target, EffectTemplates.Oculus.LightningImpact01, -1)

    #### Lightning from hand to first target, cleans up manually at end of ability.
    local emitIds = AttachEffectsAtBone(unit, EffectTemplates.Oculus.LightningLaunch01, 'sk_Puppet02_LeftWrist')
    if emitIds then
        for kEffect, vEffect in emitIds do
            beamTrash:Add(vEffect)
        end
    end

    #### Beam Emitters
    emitIds = AttachBeamEffectOnEntities( abilityDef.Effects.Base, abilityDef.Effects.Group, abilityDef.Effects.Beams, unit, 'sk_Puppet02_LeftWrist', target, -1, unit:GetArmy(), unit.Trash, target.Trash )
    if emitIds then
        for kEffect, vEffect in emitIds do
            beamTrash:Add(vEffect)
        end
    end

    local data = {
        Instigator = unit,
        InstigatorBp = unit:GetBlueprint(),
        InstigatorArmy = unit:GetArmy(),
        Amount = abilityDef.DamageAmt,
        Origin = unit:GetPosition(),
        IgnoreDamageRangePercent = true,
        CanBackfire = false,
        CanLifeSteal = false,
        CanCrit = false,
        CanBeEvaded = false,
        Type = 'Spell',
        CanMagicResist = true,
        ArmorImmune = true,
    }

    local targetAdj = 0

    local pos = unit:GetPosition()

    if not target:IsDead() then
        DealDamage(data, target)
        if Validate.HasAbility(unit, 'HOculusElectrocution') then
            Buff.ApplyBuff(target, 'HOculusElectrocution01', unit)
        end
        table.insert(chainedUnits, target)
        targetAdj = 1 -- adjust the number of chains if we hit the target
        pos = target:GetPosition()
    end

    --Mithy: Added because the outer-loop wait was moved to below the inner loop
    WaitSeconds(abilityDef.ChainTime or 0)

    for i = 1, abilityDef.Chains - targetAdj do

        local targets = aiBrain:GetUnitsAroundPoint(categories.ALLUNITS - categories.UNTARGETABLE, pos, radius, 'Enemy')

        if not targets then
            break
        end

        local noTarget = true

        for k, v in targets do

            --Mithy: More thorough checking for next target
            if v and v:BeenDestroyed() == false and v:IsDead() == false then

                local allied = IsAlly(unit:GetArmy(), v:GetArmy())

                if not allied then
                    local notchained = true

                    for key, chndunit in chainedUnits do
                        if chndunit == v then
                            notchained = false
                        end
                    end

                    if notchained or (abilityDef.ChainSameTarget and (target != v or table.getn(targets) <= 1) ) then
                        noTarget = false

                        local startBone = false

                        if i == 1 and targetAdj == 0 then
                            startBone = 'sk_Puppet02_LeftWrist'
                        end

                        #### Impact Emitters
                        emitIds = AttachEffectsAtBone(v, EffectTemplates.Oculus.LightningImpact01, -1)

                        #### Beam Emitters
                        --Mithy: Added checks for previous target existence; beam effect is simply
                        --skipped for this link in the chain if the previous target is no longer viable,
                        --but the chain will continue on just fine - this avoids the most common cause
                        --of 'sticky lightning' (a destroyed previous target due to the chain delay)
                        if target and target:BeenDestroyed() == false then
                            emitIds = AttachBeamEffectOnEntities( abilityDef.Effects.Base, abilityDef.Effects.Group, abilityDef.Effects.Beams, target, startBone or -1, v, -1, target:GetArmy(), target.Trash, v.Trash )
                        end
                        if emitIds then
                            for kEffect, vEffect in emitIds do
                                beamTrash:Add(vEffect)
                            end
                        end

                        pos = v:GetPosition()

                        DealDamage(data, v)
                        if Validate.HasAbility(unit, 'HOculusElectrocution') then
                            Buff.ApplyBuff(v, 'HOculusElectrocution01', unit)
                        end

                        target = v

                        table.insert(chainedUnits, v)

                        break
                    end
                end
            end

        end

        if noTarget then
            break
        end

        --Mithy: Moved from above, to insure that target acquisition and beam generation happen in the same tick
        --This should radically reduce the occurrence of destroyed chain targets, though it doesn't really help with
        --destroyed sources / previous targets.
        WaitSeconds(abilityDef.ChainTime or 0)

    end
    beamTrash:Destroy()
    beamTrash = nil
end