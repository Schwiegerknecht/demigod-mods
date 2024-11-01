#################################################################################################################
# Cloak of Invisibility
#################################################################################################################
ItemBlueprint {
    Name = 'Item_Artifact_030',
    DisplayName = '<LOC ITEM_Artifact_0006>Cloak of Invisibility',
    Description = '<LOC ITEM_Artifact_0007>Use: Turn invisible for 20 seconds.',
    Mesh = '/meshes/items/chest/chest_mesh',
    Animation = '/meshes/items/chest/Animations/chest_Idle_anim.gr2',
    MeshScale = 0.10,
    Icon = 'NewIcons/Artifacts/cloakofinvisibility',
    Useable = true,
    InventoryType = 'Clickables',
    GetEnergyCost = function(self) return Ability['Item_Artifact_030'].EnergyCost end,
    GetCastTime = function(self) return Ability['Item_Artifact_030'].CastingTime end,
    GetCooldown = function(self) return Ability['Item_Artifact_030'].Cooldown end,
    Abilities = {
        AbilityBlueprint {
            Name = 'Item_Artifact_030',
            Icon = 'NewIcons/Artifacts/cloakofinvisibility',
            AbilityType = 'Instant',
            AbilityCategory = 'USABLEITEM',
            InventoryType = 'Clickables',
            EnergyCost = 0,
            Cooldown = 30,
            TargetAlliance = 'Ally',
            TargetCategory = 'MOBILE - UNTARGETABLE',
            FromItem = 'Item_Artifact_030',
            CanCastWhileMoving = true,
            OnStartAbility = function(self, unit)
                AttachEffectsAtBone( unit, EffectTemplates.Items.Artifacts.CloakOfInvisibilityActivate, -2 )
            end,
            Audio = {
                 OnStartCasting = {Sound = 'Forge/ITEMS/snd_item_conjure',},
                 OnFinishCasting = {Sound = 'Forge/ITEMS/Artifact/snd_item_artifact_Item_Artifact_030',},
                 OnAbortCasting = {Sound = 'Forge/ITEMS/snd_item_abort',},
             },
            Buffs = {
                BuffBlueprint {
                    Name = 'Item_Artifact_030',
                    BuffType = 'IARTINVISIBILITY',
                    DisplayName = '<LOC ITEM_Artifact_0006>Cloak of Invisibility',
                    Description = '<LOC ITEM_Artifact_0008>Invisible.',
                    Icon = 'NewIcons/Artifacts/cloakofinvisibility',
                    Debuff = false,
                    EntityCategory = 'MOBILE',
                    Stacks = 'IGNORE',
                    Duration = 20,
                    Affects = {
                        Cloak = {Bool = true},
                    },
                    OnApplyBuff = function(self, unit, instigator)
                        self.InvisibilityActive = true

                        # Set conditional callbacks that trigger invisibility removal
                        unit.Callbacks.OnTakeDamage:Add( self.Damaged, self )
                        unit.Callbacks.OnAbilityBeginCast:Add( self.CallBackAbilityBeginCast, self )
                        unit.Callbacks.OnWeaponFire:Add( self.CallBackWeaponFire, self )

                        unit:SetInvisible( true )
                        unit:SetInvisibleMesh( true )
                    end,
                    RemoveInvisibility = function( self, unit )
                        if not self.InvisibilityActive then
                            return
                        end
                        self.InvisibilityActive = false
                        unit.Callbacks.OnTakeDamage:Remove( self.Damaged )
                        unit.Callbacks.OnAbilityBeginCast:Remove( self.CallBackAbilityBeginCast )
                        unit.Callbacks.OnWeaponFire:Remove( self.CallBackWeaponFire )
                        unit:SetInvisible( false )
                        unit:SetInvisibleMesh( false )
                        unit:PlaySound('Forge/ITEMS/snd_item_buff_end')
                        if Buff.HasBuff(unit, 'Item_Artifact_030') then
                            Buff.RemoveBuff(unit, 'Item_Artifact_030')
                        end
                    end,
                    Damaged = function(self, unit, data)
                        # Don't remove invis on heals
                        if(data.Amount and data.Amount > 0) then
                            # Only remove invisibility if this is not self inflicted, fixes Unclean Beast and Sedna
                            # Also if the instigator is dead then we remove as well ... this fixes epic deaths
                            if data.Instigator:IsDead() or data.Instigator:GetEntityId() != unit:GetEntityId() then
                                self:RemoveInvisibility( unit )
                            end
                        end
                    end,
                    CallBackAbilityBeginCast = function(self, ability, unit)
                        self:RemoveInvisibility( unit )
                    end,
                    CallBackWeaponFire = function( self, unit )
                        self:RemoveInvisibility( unit )
                    end,
                    OnBuffRemove= function(self,unit)
                        self:RemoveInvisibility( unit )
                    end,
                },
            },
        },
    },
}
