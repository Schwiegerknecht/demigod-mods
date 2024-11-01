--Mithy: Add positive damage and IsEnemy checks to Maim, to insure that it cannot
--affect Regulus or his teammates, nor trigger on healing
for i=1, 3 do
    local maimAbil = Ability['HGSA01Maim0'..i]
    if maimAbil and maimAbil.MaimTarget then
        local prevMaimTarget = maimAbil.MaimTarget
        maimAbil.MaimTarget = function(self, unit, target, data)
            if data.Amount > 0 and IsEnemy(target:GetArmy(), unit:GetArmy()) then
                prevMaimTarget(self, unit, target, data)
            end
        end
    end
end

--LORD ORION:
--Fix for Vengeance meta hit bug (Vengeance Meta hit does not work because the called definition is incorrect)
#################################################################################################################
# CE: Vengeance
#################################################################################################################
function VengeanceThread(def, unit, params)
    local army = unit:GetArmy()
    local pos = unit:GetPosition()
    pos[2] = 100

    Buff.ApplyBuff(unit, 'HGSA01Vengeance01', unit)
    Buff.ApplyBuff(unit, 'RangeAttackLock', unit)
    Buff.ApplyBuff(unit, 'Immobile', unit)

    if unit.Character.CharBP.Name != 'SniperFury' then
        unit.Character:SetCharacter('SniperFury', true)
    end

    # Destroy ambient blood dripping/feather effects
    unit:DestroyAmbientEffects()

    # Show wings and hide stubs
    unit:ShowBone("sk_Sniper_Rightwing1", true)
    unit:ShowBone("sk_Sniper_Leftwing1", true)
    unit:ShowBone("sk_Sniper_Wingsbase", true)
    unit:HideBone("sk_Sniper_Leftwingstub", true)
    unit:HideBone("sk_Sniper_Rightwingstub", true)
    unit:HideBone("sk_Sniper_Wingstubsbase", true)

    unit.Character:PlayAction('AngelOn')

    # Pre-Fury effects, ray of light downward/etc.
    AttachCharacterEffectsAtBone( unit, 'sniper', 'AngelicFuryWarmup01' )

    # Ring rune that holds it all together, feathers burst as wings grow
    CreateCharacterEffectsAtPos( unit, 'sniper', 'AngelicFuryWarmup02', pos )

    WaitSeconds(0.4)

    # Runes play at feet of Hero, sets of concentric rune rings
    FxVengeanceRunes01 ( unit, pos, 8, 2.75 )
    WaitSeconds(0.4)
    FxVengeanceRunes01 ( unit, pos, 15, 5 )
    WaitSeconds(0.2)

    #CreateCharacterEffectsAtPos( unit, 'sniper', 'AngelicFuryWarmup03', pos )
    FxVengeanceRunes02( unit, pos, 8 )
    #WaitSeconds(0.2)
    CreateTemplatedEffectAtPos( 'Regulus', nil, 'AngelicFuryWarmup04', unit:GetArmy(), pos, nil )

    WaitSeconds(0.3)
    AttachCharacterEffectsAtBone( unit, 'sniper', 'AngelicFuryBurst01' )

    WaitSeconds(0.2)


    if def.VengMetaImpactAmount then
        data = {
            Instigator = unit,
            InstigatorBp = unit:GetBlueprint(),
            InstigatorArmy = unit:GetArmy(),
            Origin = pos,
            Radius = def.VengAffectRadius,
            Amount = def.VengMetaImpactAmount,
            Category = 'METAINFANTRY',
        }
        MetaImpact(data)
    end
    data = {
        Instigator = unit,
        InstigatorBp = unit:GetBlueprint(),
        InstigatorArmy = army,
        Origin = pos,
        Amount = def.VengDamageAmt,
        Type = def.VengDamageType,
        DamageAction = def.VengDamageName,
        Radius = def.VengAffectRadius,
        DamageFriendly = false,
        DamageSelf = false,
        Group = "UNITS",
        CanBeEvaded = false,
        CanCrit = false,
        CanBackfire = false,
        CanDamageReturn = false,
        CanMagicResist = true,
        CanOverKill = false,
        ArmorImmune = true,
    }
    DamageArea(data)

    # Create Fury impact effects
    CreateCharacterEffectsAtPos( unit, 'sniper', 'AngelicFuryImpact01', pos )

    # Wait for anim to finish
    WaitSeconds(1.2)

    # Create Angelic Fury ambient effects
    unit:CreateAmbientEffects()

    Buff.RemoveBuff(unit, 'RangeAttackLock')
    Buff.RemoveBuff(unit, 'HGSA01Vengeance01')
    Buff.RemoveBuff(unit, 'Immobile')

end