#****************************************************************************
#**
#**  File     :  /lua/sc/ability.lua
#**
#**  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
# -- local BuffSystem = import('/lua/sim/buff.lua')
# -- local ValidateAbility = import('/lua/common/ValidateAbility.lua').ValidateAbility
# -- local HasAbility = import('/lua/common/ValidateAbility.lua').HasAbility
# -- local Common = import('/lua/common/CommonUtils.lua')
--[[
# FIXME: Gross hack. Sync table can't detect changes in subtables so we have to make
# a copy of the whole table and reassign.
function SyncAbilities(unit)
    local copy = table.copy(unit.Sync.Abilities)
    unit.Sync.Abilities = copy

    local cooldownCopy = table.copy(unit.Sync.SharedCooldowns)
    unit.Sync.SharedCooldowns = cooldownCopy
end

function AddAbility(unit, abilityName, quiet)
    local def = Ability[abilityName]

    #LOG('add abil: ',abilityName)
    if not unit.Sync.Abilities then
        unit.Sync.Abilities = {}
        unit.Sync.SharedCooldowns = {}
    end

    if unit.Sync.Abilities[abilityName] then
        if unit.Sync.Abilities[abilityName].Removed then
            unit.Sync.Abilities[abilityName].Removed = false
        else
            # Already have it
            return
        end
    else
        unit.Sync.Abilities[abilityName] = {
            Cooldown = 0,
            Disabled = false,
            Hidden = false,
            Removed = false,
        }
    end

    if def.SharedCooldown and not unit.Sync.SharedCooldowns[def.SharedCooldown] then
        unit.Sync.SharedCooldowns[def.SharedCooldown] = 0
    end

    #Save the ability on the unit so we can get rid of stuff later
    if not unit.Abilities then
        unit.Abilities = {}
    end
    local data = {
        Destroyables = TrashBag(),
    }
    unit.Abilities[abilityName] = data

    if not unit.AbilityData[abilityName] then
        unit.AbilityData[abilityName] = { ActiveEffectDestroyables = TrashBag() }
    else
        if not unit.AbilityData[abilityName].ActiveEffectDestroyables then
            unit.AbilityData[abilityName].ActiveEffectDestroyables = TrashBag()
        end
    end

#    if not quiet then
#        FloatTextOn(unit, Ability[abilityName].DisplayName, 'NewAbility')
#    end

    #If it's an aura ability then we handle it immediately.

    if def.AbilityType == 'Aura' or def.AbilityType == 'Quiet' or ((def.AbilityType == 'PassiveMinions' or def.AbilityType == 'PassiveAll' or def.AbilityType == 'Passive') and (not def.Cooldown or def.Cooldown == 0)) then
        local params = { AbilityName = abilityName }
        HandleAbility(unit, params)
    end

    if def.CreateAbilityAmbients then
        def:CreateAbilityAmbients(unit, unit.AbilityData[abilityName].ActiveEffectDestroyables )
    end

    # If this ability is a proc; Add the proc for this ability to the unit
    if def.AbilityType == 'WeaponProc' then
        SetupWeaponProc(unit, abilityName)
    end

    # If this ability is an armor proc; Add the proc for this ability to the unit
    if def.AbilityType == 'ArmorProc' then
        SetupArmorProc(unit, abilityName)
    end

    # If this ability is a weapon crit; Add the crit to the unit
    if def.AbilityType == 'WeaponCrit' then
        SetupWeaponCrit(unit, abilityName)
    end

    # Call the OnAbilityAdded function on the actual ability if one exists
    if def.OnAbilityAdded then
        def:OnAbilityAdded(unit)
    end

    # Inform the unit that we have just added an ability if it needs to do any work
    if unit.OnAbilityAdded then
        unit:OnAbilityAdded(abilityName)
    end

    unit.Callbacks.OnAbilityAdded:Call(abilityName)

    SyncAbilities(unit)
end

function RemoveAbility(unit, abilityName)
    #LOG('removeAbil: ',abilityName)
    local def = Ability[abilityName]
    if def.OnRemoveAbility then
        def:OnRemoveAbility(unit)
    end

    unit.Callbacks.OnAbilityRemoved:Call(abilityName)

    # if the ability is a weapon proc; Remove the proc for it
    if def.AbilityType == 'WeaponProc' then
        RemoveWeaponProc(unit, abilityName)
    end

    # if the ability is an armor proc; Remove the proc for it
    if def.AbilityType == 'ArmorProc' then
        RemoveArmorProc(unit, abilityName)
    end

    # if ability is a weapon crit; remove the crit from the unit
    if def.AbilityType == 'WeaponCrit' then
        RemoveWeaponCrit(unit, abilityName)
    end

    if unit.Abilities[abilityName].Destroyables then
        unit.Abilities[abilityName].Destroyables:Destroy()
        unit.Abilities[abilityName].Destroyables = nil
    end

    if unit.AbilityData[abilityName].ActiveEffectDestroyables then
        unit.AbilityData[abilityName].ActiveEffectDestroyables:Destroy()
    end

    #Remove perma-buffs applied through quiet or passive abilities
    if def.Buffs and (def.AbilityType == 'Quiet' or def.AbilityType == 'Passive' or def.AbilityType == 'PassiveAll') then
        for k,buff in def.Buffs do
            if BuffSystem.HasBuff(unit, buff) then
                BuffSystem.RemoveBuff(unit, buff, false)
            end
        end
    end

    # Remove buffs from minions
    if def.Buffs and (def.AbilityType == 'PassiveMinions' or def.AbilityType == 'PassiveAll') then
        for k, buff in def.Buffs do
            local minions = unit:GetAIBrain():GetListOfUnits(categories.MINION, false)
            for num, minion in minions do
                BuffSystem.RemoveBuff(minion, buff, false)
            end
        end
    end

    unit.Sync.Abilities[abilityName].Removed = true
    SyncAbilities(unit)
end

function HideAbility(unit, abilityName)
    if not unit.Sync.Abilities[abilityName] then
        error('Unit does not have ability: ' .. abilityName)
    end
    unit.Sync.Abilities[abilityName].Hidden = true
    SyncAbilities(unit)
end

# Hides all abilities that match the given ability category
function HideAbilities(unit, abilityCategory)
    for k, v in unit.Sync.Abilities do
        if(Ability[k].AbilityCategory == abilityCategory) then
            unit.Sync.Abilities[k].Hidden = true
            #LOG('*DEBUG: Hiding ability - ' .. k)
        end
    end
    SyncAbilities(unit)
end

function ShowAbility(unit, abilityName)
    if not unit.Sync.Abilities[abilityName] then
        error('Unit does not have ability: ' .. abilityName)
    end
    unit.Sync.Abilities[abilityName].Hidden = false
    SyncAbilities(unit)
end

# Shows all abilities that match the given ability category
function ShowAbilities(unit, abilityCategory)
    for k, v in unit.Sync.Abilities do
        if(Ability[k].AbilityCategory == abilityCategory) then
            unit.Sync.Abilities[k].Hidden = false
            #LOG('*DEBUG: Showing ability - ' .. k)
        end
    end
    SyncAbilities(unit)
end

function IsHidden(unit, abilityName)
    if not unit.Sync.Abilities[abilityName] then
        error('Unit does not have ability: ' .. abilityName)
    end
    return unit.Sync.Abilities[abilityName].Hidden
end

#All this does is apply the buff to the params.Targets table of targets.
#Do validation before you try to pass buffs to it.
function ApplyBuffs(unit, def, params)
    if not def.Buffs then return end
    if params.Targets then
        for kt, target in params.Targets do
            for k,buff in def.Buffs do
                BuffSystem.ApplyBuff(target, buff, unit, unit:GetArmy())
            end
        end
    end
end

function SetAbilityState(unit, abilityName, offState)
    unit.Sync.Abilities[abilityName].Disabled = offState
    SyncAbilities(unit)

    local def = Ability[abilityName]

    if offState then
        if def.OnDisableAbility then
            def:OnDisableAbility( unit )
        end
        if unit.AbilityData[abilityName].ActiveEffectDestroyables then
            unit.AbilityData[abilityName].ActiveEffectDestroyables:Destroy()
        end
    else
        if HasAbility( unit, abilityName ) then
            if def.OnEnableAbility then
                def:OnEnableAbility( unit )
            end
            if def.CreateAbilityAmbients then
                def:CreateAbilityAmbients(unit, unit.AbilityData[abilityName].ActiveEffectDestroyables )
            end
        end
    end
end

function MoveToTarget(unit,params)
    local def = Ability[params.AbilityName]
    if def.OnMoveToTarget then
        def:OnMoveToTarget(unit, params)
    end
end

function AbilityCleanup(unit,params)
    local def = Ability[params.AbilityName]
    if def.OnAbilityCleanup then
        def:OnAbilityCleanup(unit)
    end
end

function HandleAbility(unit,params)

    if not ValidateAbility(unit,params) then
        return false
    end

    #LOG('params: ',repr(params))

    local def = Ability[params.AbilityName]
    if def.TargetCategory then
        params.TargetCategory = ParseEntityCategoryEx(def.TargetCategory)
    end
    local appbuffs = false

    # If the ability is granted by an item, use a charge if necessary
    local item = nil
    if def.FromItem then

        # Find the item; can be in any of the unit's Inventories
        local found = false
        for invName,inv in unit.Inventory do
            item = inv:FindItem(def.FromItem)
            if item then
                found = true
                break
            end
        end
        if not found then
            error('Unit does not have item (' .. def.FromItem .. ') that granted ability ' .. params.AbilityName)
        end

        if item.Blueprint.Charges then
            if item:HasCharge() then
                item:UseCharge()
            else
                WARN('HandleAbility called on an item granted ability with no charges left.')
                WARN('Ability = ', params.AbilityName)
                WARN('ItemName = ', item.Sync.BlueprintId)
                return false
            end
        end
    end

    PlayAbilityCasterEffect(unit, params.AbilityName)

    if def.AbilityType == 'Aura' then

        #LOG('*ABILITY: Handling Aura ability ', repr(params.AbilityName), ' on unit ', repr(unit:GetUnitId()))
        local thread = ForkThread(AuraThread, unit, def, params)
        unit.TrashOnKilled:Add(thread)
        unit.Abilities[params.AbilityName].Destroyables:Add(thread)

        if def.OnStartAbility then
            def:OnStartAbility(unit, params)
        end

    elseif def.AbilityType == 'TargetedArea' then
        #LOG('Target Area: ', repr(params.Target.Position), ' radius=',def.AffectRadius)

        if def.OnStartAbility then
            def:OnStartAbility(unit, params)
        end

        if def.WarpToLocation then
            unit:GetNavigator():AbortMove()
            Warp(unit, params.Target.Position)
            if def.WarpMinions then
                WarpMinions(unit)
            end
        end

        AreaAbility(unit, def, params)

    elseif def.AbilityType == 'TargetedUnit' then
        params.Targets = {Common.ResolveUnit(params.Target.EntityId)}

        if params.Targets[1].MagicImmune then
            FloatTextAt(params.Targets[1]:GetFloatTextPosition(), "<LOC floattext_0000>Immune!", 'Immune')
        else
            PlayAbilityTargetEffect(unit, params.AbilityName, params.Targets)

            if def.WarpToLocation and unit:FindAdjacentSpot(params.Targets[1]) then
                unit:GetNavigator():AbortMove()
                unit:MeleeWarpAdjacentToTarget(params.Targets[1])
                #Warp(unit, params.Targets[1]:GetPosition())
                WarpMinions(unit)
            end
            if def.OnStartAbility then
                def:OnStartAbility(unit, params)
            end
            ApplyBuffs(unit,def,params)

            if def.Chains and def.Chains > 0 then
                local thread = ForkThread(ChainThread, unit, def, params)
                unit.TrashOnKilled:Add(thread)
            end
        end
    elseif def.AbilityType == 'Instant' or def.AbilityType == 'Quiet' or def.AbilityType == 'Passive' then

        if def.OnStartAbility then
            def:OnStartAbility(unit, params)
        end

        if def.AffectRadius then
            AreaAbility(unit, def, params)
        else
            params.Targets = {unit}
            ApplyBuffs(unit,def,params)
        end
    elseif def.AbilityType == 'PassiveMinions' then
        if def.OnStartAbility then
            def:OnStartAbility(unit, params)
        end

        params.Targets = unit:GetAIBrain():GetListOfUnits(categories.MINION, false)
        ApplyBuffs(unit, def, params)
    elseif def.AbilityType == 'PassiveAll' then
        if def.OnStartAbility then
            def:OnStartAbility(unit, params)
        end

        params.Targets = unit:GetAIBrain():GetListOfUnits(categories.MINION + categories.HERO, false)
        ApplyBuffs(unit, def, params)
    end

    if def.EnergyCost then
        local spellCostMult = 1 + (unit.Sync.SpellCostMult or 0)
        unit:UseEnergy(def.EnergyCost * spellCostMult)
    end

    if def.Cooldown > 0 then
        local coolMod = 0
        if not def.NoCooldownMod then
            coolMod = def.Cooldown - (def.Cooldown * (unit.Sync.CooldownMod or 1))
        end
        if not def.SharedCooldown then
            unit.Sync.Abilities[params.AbilityName].Cooldown = GetGameTimeSeconds() - coolMod
        else
            unit.Sync.SharedCooldowns[def.SharedCooldown] = GetGameTimeSeconds() - coolMod
        end
        SyncAbilities(unit)
    end

    # If this ability was granted by an item and the item is consumable, do consume.
    if item and item.Blueprint.Consumable then
        item:Consume()
    end

    return true
end

# ===========================================
# Weapon Procs
# ===========================================
function SetupWeaponProc(unit, abilityName)
    local def = Ability[abilityName]

    if not def.WeaponProcChance then
        error('AbilityType WeaponProc requires an WeaponProcChance integer - AbilityName = ' .. abilityName)
    end

    if not def.OnWeaponProc then
        error('AbilityType WeaponProc requires an OnWeaponProc function - AbilityName = ' .. abilityName)
    end

    if not unit.WeaponProcs then
        unit.WeaponProcs = {}
    end

    unit.WeaponProcs[abilityName] = true
end

function RemoveWeaponProc(unit, abilityName)
    if not unit.WeaponProcs then
        return
    end
    
    unit.WeaponProcs[abilityName] = false
end

function WeaponProc(unit, target, damageData, abilityName, postDamage)
    local def = Ability[abilityName]

    if postDamage and def.ProcType != 'PostDamage' then
        # This is not a post damage proc
        return
    elseif not postDamage and def.ProcType != 'PreDamage' then
        # This is not a pre damage proc
        return
    end

    # Find out if the proc goes off for this weapon proc; do this first as it's pretty cheap
    local rand = Random(1, 100)
    if not def.WeaponProcChanceRanged or unit.IsMelee then
        if rand > (def.WeaponProcChance or 0) then
            return
        end
    else
        if rand > def.WeaponProcChanceRanged then
            return
        end
    end

    # Make sure the unit can actually use this ability
    if not ValidateAbility(unit, { AbilityName = abilityName } ) then
        return false
    end

    # Get the weapon that caused the proc; We need to validate that this weapon is capable of causing a weapon proc
    local weapon = unit:GetWeaponByLabel( damageData.DamageAction )
    if not weapon then
        return
    end

    # Make sure this weapon can cause an effect; if not return out
    local wepbp = weapon:GetBlueprint()
    if wepbp.NoItemEffect then
        return
    end

    # LOG( '*DEBUG: Weapon proc = ' .. abilityName .. ' - Weapon = ' .. damageData.DamageAction .. '; Tick = ' .. GetGameTick() )

    # If the ability is granted by an item, use a charge if necessary
    local item = nil
    if def.FromItem then

        # Find the item; can be in any of the unit's Inventories
        local found = false
        for invName,inv in unit.Inventory do
            item = inv:FindItem(def.FromItem)
            if item then
                found = true
                break
            end
        end
        if not found then
            error('Unit does not have item (' .. def.FromItem .. ') that granted ability ' .. abilityName)
        end

        if item.Blueprint.Charges then
            if item:HasCharge() then
                item:UseCharge()
            else
                WARN('HandleAbility called on an item granted ability with no charges left.')
                WARN('Ability = ', abilityName)
                WARN('ItemName = ', item.Sync.BlueprintId)
                return false
            end
        end
    end

    PlayAbilityCasterEffect(unit, abilityName)

    # Weapon procs require the damage data as well as the target hit
    def:OnWeaponProc(unit, target, damageData)

    # If we have a cost to use this proc; then use the cost
    if def.EnergyCost then
        unit:UseEnergy(def.EnergyCost)
    end

    if def.Cooldown > 0 then
        if not def.SharedCooldown then
            unit.Sync.Abilities[abilityName].Cooldown = GetGameTimeSeconds()
        else
            unit.Sync.SharedCooldowns[def.SharedCooldown] = GetGameTimeSeconds()
        end
        SyncAbilities(unit)
    end

    # If this ability was granted by an item and the item is consumable, do consume.
    if item and item.Blueprint.Consumable then
        item:Consume()
    end

    return true
end

# ===========================================
# Armor Procs
# ===========================================
function SetupArmorProc(unit, abilityName)
    local def = Ability[abilityName]

    if not def.ArmorProcChance then
        error('AbilityType WeaponProc requires an WeaponProcChance integer - AbilityName = ' .. abilityName)
    end

    if not def.OnArmorProc then
        error('AbilityType WeaponProc requires an OnWeaponProc function - AbilityName = ' .. abilityName)
    end

    if not unit.ArmorProcs then
        unit.ArmorProcs = {}
    end

    unit.ArmorProcs[abilityName] = true
end

function RemoveArmorProc(unit, abilityName)
    unit.ArmorProcs[abilityName] = false
end

function ArmorProc(unit, abilityName)
    local def = Ability[abilityName]

    # Find out if the proc goes off for this weapon proc; do this first as it's pretty cheap
    local rand = Random(1, 100)
    if rand > def.ArmorProcChance then
            return
    end

    # Make sure the unit can actually use this ability
    if not ValidateAbility(unit, { AbilityName = abilityName } ) then
        return false
    end

    # LOG( '*DEBUG: Weapon proc = ' .. abilityName .. ' - Weapon = ' .. damageData.DamageAction .. '; Tick = ' .. GetGameTick() )

    # If the ability is granted by an item, use a charge if necessary
    local item = nil
    if def.FromItem then

        # Find the item; can be in any of the unit's Inventories
        local found = false
        for invName,inv in unit.Inventory do
            item = inv:FindItem(def.FromItem)
            if item then
                found = true
                break
            end
        end
        if not found then
            error('Unit does not have item (' .. def.FromItem .. ') that granted ability ' .. abilityName)
        end

        if item.Blueprint.Charges then
            if item:HasCharge() then
                item:UseCharge()
            else
                WARN('HandleAbility called on an item granted ability with no charges left.')
                WARN('Ability = ', abilityName)
                WARN('ItemName = ', item.Sync.BlueprintId)
                return false
            end
        end
    end

    def:OnArmorProc(unit)

    # If we have a cost to use this proc; then use the cost
    if def.EnergyCost then
        unit:UseEnergy(def.EnergyCost)
    end

    if def.Cooldown > 0 then
        if not def.SharedCooldown then
            unit.Sync.Abilities[abilityName].Cooldown = GetGameTimeSeconds()
        else
            unit.Sync.SharedCooldowns[def.SharedCooldown] = GetGameTimeSeconds()
        end
        SyncAbilities(unit)
    end

    # If this ability was granted by an item and the item is consumable, do consume.
    if item and item.Blueprint.Consumable then
        item:Consume()
    end

    return true
end

# ===========================================
# Weapon Crits
# ===========================================
function SetupWeaponCrit(unit, abilityName)
    local def = Ability[abilityName]

    if not def.CritChance then
        error('AbilityType WeaponCrit requires an CritChance integer - AbilityName = ' .. abilityName)
    end

    if not def.CritMult then
        error('AbilityType WeaponCrit requires an CritMult number - AbilityName = ' .. abilityName)
    end

    if not unit.WeaponCrits then
        unit.WeaponCrits = {}
    end

    unit.WeaponCrits[abilityName] = true
end

function RemoveWeaponCrit(unit, abilityName)
    unit.WeaponCrits[abilityName] = false
end

function AreaAbility(unit, def, params)
    if not ValidateAbility(unit,params) then
        return false
    end

    if not def.TargetAlliance then
        local stg = "*ERROR: No TargetAlliance set in ability :" .. def.Name
        error(stg, 2)
    end

    local radius = def.AffectRadius or 5
    local pos = params.Target.Position or unit:GetPosition()
    local aiBrain = unit:GetAIBrain()
    params.Targets = {}

    if def.TargetAlliance == 'Any' then
        params.Targets = aiBrain:GetUnitsAroundPoint( params.TargetCategory or categories.ALLUNITS, pos, radius )
    else
        params.Targets = aiBrain:GetUnitsAroundPoint( params.TargetCategory or categories.ALLUNITS, pos, radius, def.TargetAlliance )
    end

    if table.empty(params.Targets) then
        # LOG('no targets')
        return
    end

    PlayAbilityTargetEffect(unit, def.Name, params.Targets)

    if def.OnAreaAbility then
        def:OnAreaAbility(unit, params)
    end

    ApplyBuffs(unit, def, params)
end

function AuraThread(unit, def, params)
    while not unit:IsDead() do
        if ValidateAbility(unit,params) then
            params.Target = unit
            params.Target.Position = unit:GetPosition()
            AreaAbility(unit, def, params)

            if def.OnAuraPulse then
               def:OnAuraPulse(unit, params)
            end
        end
        WaitSeconds(def.AuraPulseTime)
    end
end

#Standard way to take a
function ChainThread(unit, def, params)
    local lastUnit = params.Targets[1] or unit
    local radius = def.ChainAffectRadius or 5
    local beamTrash = TrashBag()
    local chainedUnits = {}

    if def.ChainBeams then
        for beamkey, beambp in def.ChainBeams do
            local beam = AttachBeamEntityToEntity(unit, 0, lastUnit, 0, unit:GetArmy(), beambp)
            beamTrash:Add(beam)
            unit.TrashOnKilled:Add(beam)
        end
    end

    for i = 1, def.Chains do

        if lastUnit:IsDead() then
            lastUnit = unit
        end
        local pos = lastUnit:GetPosition()
        local rect = Rect(pos[1] - radius, pos[3] - radius, pos[1] + radius, pos[3] + radius)
        local targets = GetUnitsInRect( rect )
        targets = EntityCategoryFilterDown(params.TargetCategory, targets)
        local noTarget = true

        WaitSeconds(def.ChainTime or 0)

        for k, v in targets do

            if not v:IsDead() then

                local allied = IsAlly(unit:GetArmy(), v:GetArmy())

                if ((def.TargetAlliance == 'Enemy' and not allied) or (def.TargetAlliance == 'Ally' and allied)) or def.TargetAlliance == 'Any' then
                    local notchained = true

                    if not def.ChainSameTarget then
                        for key, chndunit in chainedUnits do
                            if chndunit == v then
                                notchained = false
                            end
                        end
                    end

                    if notchained or (def.ChainSameTarget and (lastUnit != v or table.getn(targets) <= 1) ) then
                        params.Targets = {v}
                        noTarget = false

                        if def.ChainBeams then
                            for beamkey, beambp in def.ChainBeams do
                                local beam = AttachBeamEntityToEntity(lastUnit, 0, v, 0, unit:GetArmy(), beambp)
                                beamTrash:Add(beam)
                                unit.TrashOnKilled:Add(beam)
                            end
                        end


                        if def.WarpToLocation and unit:FindAdjacentSpot(params.Targets[1]) then
                            unit:GetNavigator():AbortMove()
                            unit:MeleeWarpAdjacentToTarget(params.Targets[1])
                            #Warp(unit, params.Targets[1]:GetPosition())
                        end

                        if def.OnChained then
                            def:OnChained(unit, lastUnit, v, i)
                        end

                        lastUnit = v
                        table.insert(chainedUnits, v)

                        break
                    end
                end
            end
        end

        if noTarget then
            break
        end

        ApplyBuffs(unit, def, params)
    end
    beamTrash:Destroy()
    beamTrash = nil

    if def.OnChainEnd then
        def:OnChainEnd(unit)
    end
end
]]--
function WarpMinions(unit)
    # If I have minions, warp them
    local brain = unit:GetAIBrain()
    if(not brain.Conquest.IsTeamArmy and not brain.Conquest.IsNeutralArmy) then
        local minions = brain:GetListOfUnits(categories.MINION, false)
		local myCount = 0
		local keepHealer
		if brain.BrainController != 'Human' then
			for k, v in minions do
			#WARN('WARPED -- ' .. LOC(brain.Nickname) .. ' Minion = '.. v.A_ID )	
				if (v.A_ID == 'highpriest01' or  v.A_ID == 'highpriest02'  or  v.A_ID == 'highpriest03'  or  v.A_ID == 'highpriest04') then
					myCount = myCount + 1
					if myCount > 1 then
						keepHealer = k
					end
				end
			end
		end
		
        for k, v in minions do
            if(v and not v:IsDead()) then
                local pos = unit:FindEmptySpotNearby()
                v:GetNavigator():AbortMove()
                Warp(v, pos)
                v:OccupyGround(true)

				if myCount > 0 and keepHealer != k and (v.A_ID == 'highpriest01' or  v.A_ID == 'highpriest02'  or  v.A_ID == 'highpriest03'  or  v.A_ID == 'highpriest04') then

					local allyHeroes = {}

					for k, brainA in ArmyBrains do

						if brainA.Score.HeroId and brain:GetArmyIndex() !=  brainA:GetArmyIndex() and IsAlly(brain:GetArmyIndex(), brainA:GetArmyIndex()) then	
							local heroUnit = brainA:GetListOfUnits(categories.HERO, false)
							local hero = brainA:GetHero()
							if(hero and not hero:IsDead()) then
								table.insert(allyHeroes,  heroUnit[1])
							end
						end
					end
			
					if table.getn(allyHeroes) > 0 then
						#WARN('WARPED -- ' .. LOC(brain.Nickname) .. ' Sent Healer to Ally' )	
						IssueGuard({v}, allyHeroes[ math.random(1, table.getn(allyHeroes) ) ] )
					else
						IssueGuard({v}, unit)
					end

				else
					IssueGuard({v}, unit)
				end
			end
		end
        for k, v in minions do
            if(v and not v:IsDead()) then
                v:OccupyGround(false)
            end
        end
    end
end
--[[
function PlayAbilityTargetEffect(unit, abilityName, targets)
    local def = Ability[abilityName]
    if def.TargetEffects then
        for k, fx in def.TargetEffects do
            for key, target in targets do
                local abilfx = CreateAttachedEmitter(target, 0, target:GetArmy(), fx):ScaleEmitter(def.TargetEffectsScale or 1)
                target.Trash:Add(abilfx)
            end
        end
    end
end

function PlayAbilityCasterEffect(unit, abilityName)
    local def = Ability[abilityName]

    if def.CharacterCasterEffect then
        if def.CharacterCasterEffect.Bones then
            AttachCharacterEffectsAtBones( unit, unit.Character.CharName, def.CharacterCasterEffect.Template, def.CharacterCasterEffect.Bones, unit.Trash, nil )
        else
            AttachCharacterEffectsAtBone( unit, unit.Character.CharName, def.CharacterCasterEffect.Template, 0, unit.Trash, nil )
        end
    end

    if def.CasterEffect then
        CreateTemplatedEffectAtPos( def.CasterEffect.Base, def.CasterEffect.Group, def.CasterEffect.Template, unit:GetArmy(), unit:GetPosition(), nil, unit.Trash )
    end
end

#
# DEBUG FUNCTIONS
#
_G.PrintAbilities = function()
    for k,unit in __selected_units do
        if unit.Sync.Abilities then
            LOG('Abilities = ', repr(unit.Sync.Abilities))
        end
    end
end

]]--