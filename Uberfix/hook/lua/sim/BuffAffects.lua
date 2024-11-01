#Ptarth's Comments
#Additive buffs are calculated as expected
#Multiplicative buffs are additive, so two buffs that grant 300% increases will only grant a 600% increase together.
#Negative Multiplicative buffs are not intuitive, a -100% buff will be canceled by a +100% buff. There is a max of a 0 multiplier, most likely to
#prevent crazy negative multipliers, and wierd cases with negative adds and negative multipliers
#Health and Energy DoTs do not seem to be implimented using Buffs
#I've added a set variable. If a buff has a set value, that affectType is set to that value, regardless of other factors
#This allows for Oculus's Electrocution ability which prevents health and energy regen.

--M Note: The Set method is still necessary in Demigod 1.3.  Neg mult is insufficient to counter anything but base regen.
function BuffCalculate( unit, buffName, affectType, initialVal, initialBool, weaponLabel, abilityName )

    local adds = 0
    local mults = 1.0
    local bool = initialBool or false
    local boolchanged = false
    --Added
    local set = false

    for k, v in unit.Buffs.Affects[affectType] do

        local def = Buffs[v.BuffName]
        if (not def.WeaponLabel or (def.WeaponLabel == weaponLabel)) and
            (not def.AbilityCategory or Ability[abilityName].AbilityCategory == def.AbilityCategory) then
            if v.Add and v.Add != 0 then
                adds = adds + (v.Add * v.Count)
            end

            if v.Mult then
                #mults = mults * math.pow( v.Mult, v.Count )
                mults = mults + (v.Mult * v.Count)
                if mults < 0 then
                    mults = 0
                end
            end
            if v.Bool != nil and not boolchanged then
                if not v.Bool then
                    bool = false
                else
                    bool = true
                end
                if bool != initialBool then
                    boolchanged = true
                end
            end
            --Added
            if v.Set then
                set = v.Set
                #LOG('v.set', v.Set)
            end
        end
        #LOG('*DEBUG: Weapon: ', repr(weaponLabel), ' Weapon in defintion: ', repr(def.WeaponLabel), ' set to: ', repr(tostring(bool)))
    end

    #Adds are calculated first, then the mults.  May want to expand that later.
    local returnVal = (initialVal + adds) * mults
    --Added
    #LOG('AffectType :', affectType, 'InitialVal: ', initialVal, ' Adds: ', adds, ' Mults: ', mults, 'set: ', set)
    if set then
        returnVal = set
    end

    return returnVal, bool
end


--Mithy: Full tabled re-write of Absorption to fix all overlap and refresh issues.
function Absorption( unit, buffName, buffDef, buffAffects, instigator, instigatorArmy, bAfterRemove )
    local abData = unit.AbsorptionData
    local abAffects = buffAffects.Absorption

    --Mult is a damage-taken multiplier for absorption.  Min 0.1 (10%), no max.
    if abAffects.Mult then
        --Bypass BuffCalculate to get mults without adds factored in
        local mult = 1
        for k, v in abAffects do
            if v.Mult then
                mult = mult + (v.Mult * v.Count)
            end
        end
        abData.Mult = math.max(mult, 0.1)
    end

    --Add/remove absorption amounts
    if abAffects.Add then
        if not bAfterRemove then
            local abBuff = {
                Absorption = abAffects.Add,
                BuffName = buffName,
            }
            table.insert(abData.Buffs, abBuff)
        else
            --Remove oldest (lowest key) instance of this buff name
            for i=1, (table.getn(abData.Buffs) or 1) do
                if abData.Buffs[i].BuffName == buffName then
                    table.remove(abData.Buffs, i)
                    break
                end
            end
        end
    end

    --Add up total absorption amounts and set sync var
    local total = 0
    for k, v in abData.Buffs do
        total = total + v.Absorption
    end
    unit.Sync.Absorption = total
    unit.Sync.AbsorptionMult = abData.Mult
end


--Mithy: Fix for Ooze suicide, support for no-kill damage flags, evasion flip, and moddable export of damagedata
function Health( unit, buffName, buffDef, buffAffects, instigator, instigatorArmy, bAfterRemove )
    if bAfterRemove then return end

    local health = unit:GetHealth()
    local val = ((buffAffects.Health.Add or 0) + health) * (buffAffects.Health.Mult or 1)
    if instigator and not instigator:IsDead() and buffAffects.Health.DamageRatingMult then
        val = val + buffAffects.Health.DamageRatingMult * CalculateDamageFromRating(instigator.Sync.DamageRating)
    end
    if buffAffects.Health.MaxHealthPercent then
        val = val + unit:GetMaxHealth() * buffAffects.Health.MaxHealthPercent
    end
    local healthadj = val - health
    local data = {
        Instigator = instigator,
        InstigatorBp = false,
        InstigatorArmy = instigatorArmy,
        Amount = -healthadj,
        Type = buffDef.Type or 'Spell',
        DamageAction = buffName or 'Unknown',
        Radius = buffDef.DamageRadius or 0,
        DamageSelf = buffDef.DamageSelf or false,
        DamageFriendly = true,
        ArmorImmune = true,
        CanBackfire = true,
        CanCrit = true,
        CanDamageReturn = false,
        CanBeEvaded = false, --Mithy: now defaults to false for ability damage
        CanOverKill = true,
        Vector = VDiff(instigator:GetPosition(), unit:GetPosition()),
        Group = "UNITS",
    }
    if instigator and not instigator:IsDead() then
        data.InstigatorBp = instigator:GetBlueprint()
    end

    data.CanMagicResist = buffDef.CanMagicResist
    if buffDef.CanMagicResist == nil and data.Amount < 0 then
        data.CanMagicResist = false
    elseif buffDef.CanMagicResist == nil and data.Amount > 0 then
        data.CanMagicResist = true
    end

    if buffDef.DamageFriendly == false then
        data.DamageFriendly = false
    end
    if buffDef.ArmorImmune == false then
        data.ArmorImmune = false
    end
    if buffDef.CanCrit == false then
        data.CanCrit = false
    end
    if buffDef.CanDamageReturn then
        data.CanDamageReturn = buffDef.CanDamageReturn
    end
    if buffDef.CanBackfire == false then
        data.CanBackfire = false
    end
    if buffDef.CanBeEvaded == true then
        data.CanBeEvaded = true
    end
    if buffDef.CanOverKill == false then
        data.CanOverKill = false
    end

    if buffDef.IgnoreDamageRangePercent then
        data.IgnoreDamageRangePercent = buffDef.IgnoreDamageRangePercent
    end

    data.NoFloatText = buffDef.NoFloatText

    --M: Added for no-kill support
    data.CannotKill = buffDef.CannotKill
    data.CannotKillFriendly = buffDef.CannotKillFriendly
    data.CannotKillSelf = buffDef.CannotKillSelf

    --M: This added global function, defined below, can be hooked to modify healing performed by buffs
    ModHealthDamageData(data, unit, instigator, buffDef)

    DealDamage(data,unit)
end

--Modders: Hook this function if you want to run additional checks on or modifications to +/- health buffs
function ModHealthDamageData(data, unit, instigator, buffDef)
end
--[[
This can be used, for example, to boost healing or ability damage if the caster or target have a certain
ability, buff, or class variable.  The 'data' table provided is the whole damageData table for the buff's
DealDamage event on the target, and any of its flags or values can be altered.
For additive changes, remember that data.Amount will be negative for healing, and positive for damage.

Example: +50% healing if target has any healing wind buff:
----------------------------------------
local prevMHDD = ModHealthDamageData
function ModHealthDamageData(data, unit, instigator, buffDef)
    prevMHDD(data, unit, instigator, buffDef)
    if data.Amount < 0 and HasBuffType(unit, 'HSEDNAHEALINGWIND') then
        data.Amount = data.Amount * 1.5
    end
end
----------------------------------------

If you don't want your mod to require the UberFix, there is a way you can still use this method if the
UberFix is running, or use a destructive override if it isn't, by looking for the new UberFix-added
BuffAffects (or any other UberFix-added global) in your BuffAffects hook:
----------------------------------------
if EnergyAdd and EnergyLeech and EnergyDrain then
    --Do UberFix-compatible hooks here
    local prevMHDD = ModHealthDamageData
    function ModHealthDamageData(data, unit, instigator, buffDef)
        prevMHDD(data, unit, instigator, buffDef)
        --etc
    end
else
    --Do destructive overrides here
    function Health( unit, buffName, buffDef, buffAffects, instigator, instigatorArmy, bAfterRemove )
        --etc
    end
end
----------------------------------------
This way the appropriate method will be chosen when the file is executed, and keeps you from either
having to constantly re-update your destructive hooks every time the UberFix is updated to include
the new fix code, or having to require the UberFix in your mod_info.lua.
Do keep in mind that this will only work if your mod loads after the UberFix, meaning that it needs
an alphanumerically-higher UID.  The UberFix has a very low UID, so this shouldn't be a problem.
--]]


--Mithy: New BuffAffects for mod use

--EnergyAdd - acts like life steal, adding mana based on damage done
function EnergyAdd(unit, buffName, buffDef, buffAffects, instigator, instigatorArmy, afterRemove)
    local val = BuffCalculate(unit, buffName, 'EnergyAdd', 0)
    if EnergyAddCap then
        val = math.min(val, EnergyAddCap)
    end
    unit.EnergyAdd = val
    unit.Sync.EnergyAdd = val
end

--EnergyLeech - as above, but actually takes mana from the target based on damage done and adds that amount
function EnergyLeech(unit, buffName, buffDef, buffAffects, instigator, instigatorArmy, afterRemove)
    local val = BuffCalculate(unit, buffName, 'EnergyLeech', 0)
    if EnergyLeechCap then
        val = math.min(val, EnergyLeechCap)
    end
    unit.EnergyLeech = val
    unit.Sync.EnergyLeech = val
end

--EnergyDrain - one-time transfer like Energy, except it steals from the target like EnergyLeech and adds that amount to the instigator
--Add must be >0 (although this amount is actually subtracted from the target)
function EnergyDrain(unit, buffName, buffDef, buffAffects, instigator, instigatorArmy, afterRemove)
    --Make sure instigator is alive, skip on remove since we're instant
    if afterRemove or not instigator or instigator:IsDead() then return end

    local amount = buffAffects.EnergyDrain.Add
    local text = not buffAffects.EnergyDrain.NoFloatText
    if amount > 0 then
        --Let ForgeUnit.DoEnergyLeech handle the checks and energy transaction
        instigator:DoEnergyLeech(unit, amount, 1, text)
    end

    --Nil out this buff affect table on the recipient unit, since it's a one-off like energy and health (not worth hard-overriding Buff.ApplyBuff for)
    unit.Buffs.Affects.EnergyDrain = nil
end

--[[ Mithy: The following changes enable further mod exensibility.
A) Several BuffAffect functions are overridden to mirror their changes in the unit's Sync table.
This allows UI mods to access these additional unit stats (which derive their names from their associated buff affects):
  EvasionChance
  MoveSlowCap
  LifeSteal
  DamageReturn
  DamageTakenMult
  VisionRadius
  OmniRadius
  GoldProduction
  ExperienceMod
  DeathPenaltyMult
  MissChance
  Absorption
  BountyGivenMod
  BountyReceivedMod
  MagicResistance
  Invincible (bool)
  MagicImmune (bool)
  StunImmune (bool)
  DebuffImmune (bool)
New BuffAffects values:
  EnergyAdd
  EnergyLeech
  AbsorptionMult (damage taken mult for absorption only)
New primary weapon values, Demigods only:
  DamageRadius
  SplashMult
  FiringRandomness
  MetaRadius
  MetaAmount

These should be accessible within user EntityData under these names, for any allied demigod.  EntityData is only propagated
to allied sync tables by the engine, so they will not be accessible to enemy players under any circumstances.  These variables
should exist in EntityData at the start of the game when this mod is running, and are initialized to their default values
(1 for mults e.g. DeathPenaltyMult, 0 for additives e.g. GoldProduction and EvasionChance).

Any UI mod making use of these will need to check for their presence before using them, as (as best as I can tell from the init process)
a UI mod cannot be made to require a sim mod, or vice-versa.
This means your mod should have fallback 'legacy' stat windows that only use the stock demigod sync values if these are not available.


B) The following globals allow other mods to easily and non-destructively change minimum and maximum values for things like evasion,
speed, cooldown, rof, etc. This was a natural extension of the sync enhancement, since all of the same functions were already being
overridden.  All of these values are identical to the GPG defaults previously found within the functions themselves.--]]
EvasionCap = 40
ROFCap = 2
CooldownCap = 0.4
MinSpeedMult = 0.66
MaxSpeedCap = 14

--Added to existing BuffAffects
LifeStealCap = false

--For new BuffAffects
EnergyAddCap = false
EnergyLeechCap = false


--Unfortunately, many of these functions have to be destructively overwritten
--Changed/added sections are commented
function DamageSplash( unit, buffName, buffDef )
    for i = 1, unit.NumWeapons do

        local wep = unit:GetWeapon(i)
        local wepbp = wep:GetBlueprint()

        if wepbp.NoWeaponBuffs then
            continue
        end

        if not buffDef.WeaponLabel or wepbp.Label == buffDef.WeaponLabel then
            local val = BuffCalculate(unit, buffName, 'DamageSplash', 1, nil, wepbp.Label)
            --M: Negative splash mult fix - avoid unintentional splash debuff
            --Only set < 1 splashmult if the weapon has no original damageradius, unless buff is a debuff
            --This fixes Trebuchet splash damage being reduced by structure attack upgrades
            if val >=1 or buffDef.Debuff or not wepbp.DamageRadius or wepbp.DamageRadius == 0 then
                #wep.SplashMult = val
                wep:SetSplashMult(val)
                #LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed splash multiplier to ', repr(val))

                --M: New weapon stat tracking
                unit:UpdateWeaponStat(i, 'SplashMult', val)
            end
        end
    end
end

function RateOfFire( unit, buffName, buffDef, buffAffects )
    for i = 1, unit.NumWeapons do
        local wep = unit:GetWeapon(i)
        local wepbp = wep:GetBlueprint()

        if wepbp.NoWeaponBuffs then
            continue
        end

        if not buffDef.WeaponLabel or wepbp.Label == buffDef.WeaponLabel then

            local weprof = wepbp.RateOfFire
            local val = BuffCalculate(unit, buffName, 'RateOfFire', weprof, nil, wepbp.Label)

            # Caps to mult so we limit the max buff/debuff percent to any unit
            local boost = val / weprof
            if boost < 0.01 then
                val = weprof * 0.01
            elseif boost > 50 then
                val = weprof * 50
            end

            --M: Now references global
            if val > ROFCap then
                val = ROFCap
            end

            local percentchg = val / weprof

            wep:SetDamageDelay(math.floor((((wepbp.DamageDelay or wepbp.RangedWeapon.ShotDelay) or 0) / percentchg) * 100) / 100)

            if unit.ScaleAttackAnimRate then
                unit:ScaleAttackAnimRate(wepbp.Label, percentchg)
            end

            --M: New weapon stat tracking
            unit:UpdateWeaponStat(i, 'AttackTime', 1 / val)
            unit:UpdateWeaponStat(i, 'AttackBoost', (1-(weprof/val)) * 100)

            wep:ChangeRateOfFire(val)
            #LOG('*BUFF: Unit ', repr(unit:GetUnitId()), ' ', wepbp.Label, ' weapon natural attack rate is ', repr(weprof))
            #LOG('*BUFF: Unit ', repr(unit:GetUnitId()), ' ', wepbp.Label, ' buffed attack rate of fire to ', repr(val))
        end
    end
end

function DamageBonus( unit, buffName, buffDef )
    for i = 1, unit.NumWeapons do

        local wep = unit:GetWeapon(i)
        local wepbp = wep:GetBlueprint()

        if wepbp.NoWeaponBuffs then
            continue
        end

        if not buffDef.WeaponLabel or wepbp.Label == buffDef.WeaponLabel then

            local val = BuffCalculate(unit, buffName, 'DamageBonus', 1, nil, wepbp.Label)
            wep:SetDamageBonus(val)

            --M: New weapon stat tracking
            unit:UpdateWeaponStat(i, 'PrimaryWeaponDamage', wep:GetBaseDamage())

            #LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed damage to ', repr(val))
        end
    end
end

function DamageRating( unit, buffName )
    local val = BuffCalculate(unit, buffName, 'DamageRating', 0, 0)
    unit.Sync.DamageRating = val
    local basedamagerating = unit:GetBlueprint().Stats.DamageRating

    --M: New weapon stat tracking
    for i = 1, unit.NumWeapons do
        local wep = unit:GetWeapon(i)
        if not wep:GetBlueprint().NoWeaponBuffs then
            unit:UpdateWeaponStat(i, 'PrimaryWeaponDamage', wep:GetBaseDamage())
            if basedamagerating then
                unit:UpdateWeaponStat(i, 'DamageRatingIncrease', wep:GetBaseDamage() - basedamagerating)
            end
        end
    end
end

function DamageRadius( unit, buffName, buffDef )
    for i = 1, unit.NumWeapons do

        local wep = unit:GetWeapon(i)
        local wepbp = wep:GetBlueprint()

        if not buffDef.WeaponLabel or wepbp.Label == buffDef.WeaponLabel then
            local weprad = wepbp.DamageRadius
            local val = BuffCalculate(unit, buffName, 'DamageRadius', weprad, nil, wepbp.Label)
            wep:SetDamageRadius(val)
            #LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed damage radius to ', repr(val))

            --M: New weapon stat tracking
            unit:UpdateWeaponStat(i, 'DamageRadius', val)
        end
    end
end

function MaxRadius( unit, buffName, buffDef )
    for i = 1, unit.NumWeapons do

        local wep = unit:GetWeapon(i)
        local wepbp = wep:GetBlueprint()

        if wepbp.NoWeaponBuffs then
            continue
        end

        if not buffDef.WeaponLabel or wepbp.Label == buffDef.WeaponLabel then
            local weprad = wepbp.MaxRadius
            local val = BuffCalculate(unit, buffName, 'MaxRadius', weprad, nil, wepbp.Label)
            wep:ChangeMaxRadius(val)
            wep:ChangeMovementRadius(val)

            --M: New weapon stat tracking
            unit:UpdateWeaponStat(i, 'Range', val)
            unit:UpdateWeaponStat(i, 'RangeGrowth', val - weprad)

            #LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed max radius to ', repr(val))
        end
    end
end

function FiringRandomness( unit, buffName, buffDef )
    for i = 1, unit.NumWeapons do

        local wep = unit:GetWeapon(i)
        local wepbp = wep:GetBlueprint()

        if not buffDef.WeaponLabel or wepbp.Label == buffDef.WeaponLabel then
            local weprad = wepbp.FiringRandomness
            local val = BuffCalculate(unit, buffName, 'FiringRandomness', weprad, nil, wepbp.Label)
            wep:SetFiringRandomness(val)

            --M: New weapon stat tracking
            unit:UpdateWeaponStat(i, 'FiringRandomness', val)
            #LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed damage radius to ', repr(val))
        end
    end
end

function MetaRadius( unit, buffName, buffDef )
    for i = 1, unit.NumWeapons do

        local wep = unit:GetWeapon(i)
        local wepbp = wep:GetBlueprint()

        if wepbp.NoWeaponBuffs then
            continue
        end

        if not buffDef.WeaponLabel or wepbp.Label == buffDef.WeaponLabel then
            local val, bool = BuffCalculate(unit, buffName, 'MetaRadius', 0, true, wepbp.Label)
            wep.MetaRadiusMod = val

            --M: New weapon stat tracking
            unit:UpdateWeaponStat(i, 'MetaRadius', val)
        end
    end
end

function MetaAmount( unit, buffName, buffDef )
    for i = 1, unit.NumWeapons do

        local wep = unit:GetWeapon(i)
        local wepbp = wep:GetBlueprint()

        if wepbp.NoWeaponBuffs then
            continue
        end

        if not buffDef.WeaponLabel or wepbp.Label == buffDef.WeaponLabel then
            local val, bool = BuffCalculate(unit, buffName, 'MetaAmount', 0, true, wepbp.Label)
            wep.MetaAmountMod = val

            --M: New weapon stat tracking
            unit:UpdateWeaponStat(i, 'MetaAmount', val)
        end
    end
end

--End weapon BuffAffects

function MoveSlowCap( unit, buffName )
    local val = BuffCalculate(unit, buffName, 'MoveSlowCap', unit:GetBlueprint().Physics.MaxSpeed)
    unit.MoveSlowCap = val

    --Added sync var for UI display
    unit.Sync.MoveSlowCap = val
end

function MoveMult( unit, buffName )
    local moveSpeed = BuffCalculate(unit, buffName, 'MoveMult', unit:GetBlueprint().Physics.MaxSpeed)

    moveSpeed = math.max(moveSpeed, unit.MoveSlowCap or 0)

    # Cap both min speed and max speed
    --M: Now references globals
    moveSpeed = math.max(moveSpeed, unit:GetBlueprint().Physics.MaxSpeed * MinSpeedMult)
    moveSpeed = math.min(moveSpeed, MaxSpeedCap)

    unit.Sync.MovementSpeed = moveSpeed

    # Figure out what the percent change is from the unit's base speed
    # We use that multiplier to figure out how much to increase/decrease the move

    local val = moveSpeed / unit:GetBlueprint().Physics.MaxSpeed

    unit.Sync.MoveBoost = val * 100 - 100

    unit:SetSpeedMult(val)
    unit:SetAccMult(val)
    unit:SetTurnMult(val)
    #LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed speed/accel/turn mult to ', repr(val))
end

function DamageReturn( unit, buffName )
    local val = BuffCalculate(unit, buffName, 'DamageReturn', 1)
    unit.DamageReturnMod = val - 1

    --Added sync var for UI display
    unit.Sync.DamageReturn = val
end

function LifeSteal( unit, buffName )
    local val = BuffCalculate(unit, buffName, 'LifeSteal', 0)
    --New global cap
    if LifeStealCap then
        val = math.min(val, LifeStealCap)
    end
    unit.LifeSteal = val

    --Added sync var for UI display
    unit.Sync.LifeSteal = val
end

function DeathPenaltyMult( unit, buffName )
    local val = BuffCalculate(unit, buffName, 'DeathPenaltyMult', 1)
    unit.DeathPenaltyMult = val

    --Added sync var for UI display
    unit.Sync.DeathPenaltyMult = val
end

function DamageTakenMult( unit, buffName )
    local val = BuffCalculate(unit, buffName, 'DamageTakenMult', 0)
    unit.DamageTakenMult = val

    --Added sync var for UI display
    unit.Sync.DamageTakenMult = val
end

function Evasion( unit, buffName )
    local val = BuffCalculate(unit, buffName, 'Evasion', 0)

    --M: Now references global
    if val > EvasionCap then
        val = EvasionCap
    end

    unit.EvasionChance = val

    --Added sync var for UI display
    unit.Sync.EvasionChance = val
end

function Cooldown( unit, buffName )
    local val = BuffCalculate(unit, buffName, 'Cooldown', 1)

    --M: Now references global
    if val < CooldownCap then
        val = CooldownCap
    end

    unit.Sync.CooldownMod = val
end

function VisionRadius( unit, buffName )
    local val = BuffCalculate(unit, buffName, 'VisionRadius', unit:GetBlueprint().Intel.VisionRadius or 0)
    unit:SetIntelRadius('Vision', val)

    --Added sync var for UI display
    unit.Sync.VisionRadius = val
end

function OmniRadius( unit, buffName )
    local val = BuffCalculate(unit, buffName, 'OmniRadius', unit:GetBlueprint().Intel.OmniRadius or 0)

    if not unit:IsIntelEnabled('Omni') then
        unit:InitIntel(unit:GetArmy(),'Omni', val)
        unit:EnableIntel('Omni')
    else
        unit:SetIntelRadius('Omni', val)
        unit:EnableIntel('Omni')
    end

    if val <= 0 then
        unit:DisableIntel('Omni')
    end

    --Added sync var for UI display
    unit.Sync.OmniRadius = val
end

function GoldProduction( unit, buffName )
    local val = BuffCalculate(unit, buffName, 'GoldProduction', unit:GetBlueprint().General.ProductionPerSecondGold or 0)
    unit:SetProductionPerSecondGold(val)
    if val > 0 then
        unit:SetProductionActive(true)
    end

    --Added sync var for UI display
    unit.Sync.GoldProduction = val
end

function Experience(unit, buffName)
    local val = BuffCalculate(unit, buffName, 'Experience', 1)
    unit.ExperienceMod = val

    --Added sync var for UI display
    unit.Sync.ExperienceMod = val
end

function MissChance( unit, buffName )
    local val = BuffCalculate(unit, buffName, 'MissChance', 0)
    unit.MissChance = val

    --Added sync var for UI display
    unit.Sync.MissChance = val
end

function MagicResistance( unit, buffName )
    local val = BuffCalculate(unit, buffName, 'MagicResistance', 0)
    unit.MagicResistance = val

    --Added sync var for UI display
    unit.Sync.MagicResistance = val
end

function Invincible( unit, buffName )
    local val, bool = BuffCalculate(unit, buffName, 'Invincible', 0, false)
    unit:SetCanTakeDamage(not bool)

    --Added sync var for UI display
    unit.Sync.Invincible = bool
end

function MagicImmune( unit, buffName )
    local val, bool = BuffCalculate(unit, buffName, 'MagicImmune', 0, false)
    unit.MagicImmune = bool

    --Added sync var for UI display
    unit.Sync.MagicImmune = val
end

function DebuffImmune( unit, buffName )
    local val, bool = BuffCalculate(unit, buffName, 'DebuffImmune', 0, false)
    unit.DebuffImmune = bool

    --Added sync var for UI display
    unit.Sync.DebuffImmune = val
end

function StunImmune( unit, buffName )
    local val, bool = BuffCalculate(unit, buffName, 'StunImmune', 0, false)
    unit.StunImmune = bool

    --Added sync var for UI display
    unit.Sync.StunImmune = val
end

function BountyGiven( unit, buffName )
    local val = BuffCalculate(unit, buffName, 'BountyGiven', 1)
    unit.BountyGivenMod = val

    --Added sync var for UI display
    unit.Sync.BountyGivenMod = val
end

function BountyRecieved( unit, buffName )
    local val = BuffCalculate(unit, buffName, 'BountyRecieved', 1)
    unit.BountyRecievedMod = val

    --Added sync var for UI display
    unit.Sync.BountyRecievedMod = val
end