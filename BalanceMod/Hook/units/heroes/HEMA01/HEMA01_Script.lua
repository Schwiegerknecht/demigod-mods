--This level of override is necessary to play nice with Uberfix's weapon management system
--We are hooking the class itself so Uberfix's changes remain intact through inheritance, rather than having Balance Mod override the entire script destructively

local prevClass = HEMA01
HEMA01 = Class(prevClass) {
    IceState = State(prevClass.IceState) {
        Main = function(self)
            --Override to change WaitSeconds from 1.5 to 0.8
	    IssueStop({self})
	    #LOG("*DEBUG: Ice State")
	    self:SetAbilities(false, false)
	    local changechar = false
	    if self.Character.CharBP.Name != 'Mage' then
		changechar = true
		end
		
	if Buff.HasBuff(self, 'HEMA01FireWeaponEnable') then
		Buff.RemoveBuff(self, 'HEMA01FireWeaponEnable')
	end

	Buff.ApplyBuff(self, 'HEMA01FireWeaponDisable', self)

            # stop this dude in his tracks
            self:GetNavigator():AbortMove()

            #LOG("*DEBUG: Immobile: TRUE")
            #Buff.ApplyBuff(self, 'Immobile')

            self:SetAmbientSound(nil, nil)
            

            self.Sync.AvatarState = 1

            if changechar then
                self.Character:SetCharacter('Mage', true)
            end

            self:DestroyAmbientEffects()

            if changechar then
                self.Character:PlayAction('CastFrostMode')
                WaitSeconds(0.8)
            end

            self.Character:PlayIdle()
            WaitSeconds(0.2)

            self:CreateAmbientEffects()

            if Buff.HasBuff(self, 'HEMA01IceWeaponDisable') then
                Buff.RemoveBuff(self, 'HEMA01IceWeaponDisable')
                Buff.ApplyBuff(self, 'HEMA01IceWeaponEnable', self)
            end

            self:SetAbilities(false, true)

            #LOG("*DEBUG: Immobile: FALSE")
           # Buff.RemoveBuff(self, 'Immobile')
            WaitSeconds(0.1)

            if self.Character.IsMoving then
                self.Character:PlayMove()
            end
            #self:SetAmbientSound( 'Forge/DEMIGODS/Torch_Bearer/snd_dg_torch_idle_ice_lp', nil)
        end,

        CreateAmbientEffects = function(self)
            AttachCharacterEffectsAtBone( self, 'mage', 'Ambient_FrostGlow01', -2, self.Trash, self.AmbientEmitters  )
            AttachCharacterEffectsAtBones( self, 'mage', 'Ambient_Arms01', {self.FxBones[1], self.FxBones[2], self.FxBones[3], self.FxBones[4], self.FxBones[5], self.FxBones[6]}, self.Trash, self.AmbientEmitters )
            AttachCharacterEffectsAtBones( self, 'mage', 'Ambient_FaintSphere01', {self.FxBones[3], self.FxBones[4], self.FxBones[6]}, self.Trash, self.AmbientEmitters )
            AttachCharacterEffectsAtBones( self, 'mage', 'Ambient_GroundSteam01', {self.FxBones[12], self.FxBones[13]}, self.Trash, self.AmbientEmitters )
            AttachCharacterEffectsAtBone( self, 'mage', 'Torch01', 'sk_TorchBearer_Staff_Muzzle_REF', self.Trash, self.AmbientEmitters )
        end,

        OnAbilityAdded = function(self, ability)
            self:SetAbilities(false, true)
        end,

        CreateIceBlockMesh = function( self, bone, scale )
            self.IceBlockEffectEntity = import('/lua/sim/Entity.lua').Entity()
            self.IceBlockEffectEntity:AttachBoneTo( -1, self, bone )
            self.IceBlockEffectEntity:SetMesh( '/characters/Mage/Mage_Iceblock_mesh' )
            self.IceBlockEffectEntity:SetDrawScale( scale )
            self.IceBlockEffectEntity:SetVizToAllies('Intel')
            self.IceBlockEffectEntity:SetVizToNeutrals('Intel')
            self.IceBlockEffectEntity:SetVizToEnemies('Intel')
            self.TrashOnKilled:Add(self.IceBlockEffectEntity)
        end,
    },

    FireState = State(prevClass.FireState) {
        Main = function(self)
            --Override to change WaitSeconds from 1.5 to 0.8
	    #LOG("*DEBUG: Fire State")
            # Setup delay time between ice and fire mode.
            if Buff.HasBuff(self, 'HEMA01IceWeaponEnable') then
                Buff.RemoveBuff(self, 'HEMA01IceWeaponEnable')
            end

            Buff.ApplyBuff(self, 'HEMA01IceWeaponDisable', self)
            self:SetAbilities(true, false)

            self:DestroyAmbientEffects()

            # stop this dude in his tracks
            self:GetNavigator():AbortMove()

            #LOG("*DEBUG: Immobile: TRUE")
            Buff.ApplyBuff(self, 'Immobile')

            self.Sync.AvatarState = 2

            # Create character based fire ambient effects
            self:ForkThread(self.PlayFxFireAmbients, 0.1)

            self.Character:SetCharacter('MageFire', true)
            self.Character:PlayAction('CastEndFireMode')
            WaitSeconds(0.8)

            #LOG("*DEBUG: Immobile: FALSE")
            if Buff.HasBuff(self, 'HEMA01FireWeaponDisable') then
                Buff.RemoveBuff(self, 'HEMA01FireWeaponDisable')
                Buff.ApplyBuff(self, 'HEMA01FireWeaponEnable', self)
            end
            self.Character:PlayIdle()
            WaitSeconds(0.2)

            
            
            Buff.RemoveBuff(self, 'Immobile')
            WaitSeconds(0.1)
            
            self:SetAbilities(true, true)

            if self.Character.IsMoving then
                self.Character:PlayMove()
            end

            #local params = { AbilityName = 'HTorchFireMode01' }
            #Abil.HandleAbility(self, params)
            #self:SetAmbientSound( 'Forge/DEMIGODS/Torch_Bearer/snd_dg_torch_idle_fire_lp', nil)
        end,

        CreateAmbientEffects = function(self )
            AttachCharacterEffectsAtBone( self, 'magefire', 'Torch02', 'sk_TorchBearer_Staff_Muzzle_REF', self.Trash, self.AmbientEmitters )
            AttachCharacterEffectsAtBone( self, 'magefire', 'Ambient_Distort01', self.FxBones[5], self.Trash, self.AmbientEmitters )
            AttachCharacterEffectsAtBones( self, 'magefire', 'Ambient_Sphere01', {self.FxBones[1], self.FxBones[2]}, self.Trash, self.AmbientEmitters )
            AttachCharacterEffectsAtBone( self, 'magefire', 'Ambient_Sphere02', self.FxBones[5], self.Trash, self.AmbientEmitters )
            AttachCharacterEffectsAtBone( self, 'magefire', 'Ambient_Sphere02', self.FxBones[6], self.Trash, self.AmbientEmitters )
            AttachCharacterEffectsAtBones( self, 'magefire', 'Ambient_Arms01', {self.FxBones[3], self.FxBones[4]}, self.Trash, self.AmbientEmitters )
            AttachCharacterEffectsAtBones( self, 'magefire', 'Ambient_FaintSphere01', {self.FxBones[3], self.FxBones[4]}, self.Trash, self.AmbientEmitters )
            AttachCharacterEffectsAtBones( self, 'magefire', 'Ambient_Legs02', {self.FxBones[7], self.FxBones[8]}, self.Trash, self.AmbientEmitters )
            AttachCharacterEffectsAtBone( self, 'magefire', 'Ambient_Base01', -2, self.Trash, self.AmbientEmitters )
            AttachCharacterEffectsAtBones( self, 'magefire', 'Ambient_Legs01', {self.FxBones[9], self.FxBones[10]}, self.Trash, self.AmbientEmitters )
            AttachCharacterEffectsAtBone( self, 'magefire', 'Ambient_FireGlow01', -2, self.Trash, self.AmbientEmitters  )
        end,

        PlayFxFireAmbients = function(self, transitionTime)
            local delay = transitionTime / 5

            # Fire torch effects
            AttachCharacterEffectsAtBone( self, 'magefire', 'Torch02', 'sk_TorchBearer_Staff_Muzzle_REF', self.Trash, self.AmbientEmitters )

            # ROOT/BASE POSITION
            AttachCharacterEffectsAtBone( self, 'magefire', 'Ignite01', -2, self.Trash, self.AmbientEmitters )

            WaitSeconds(delay)
            # CHEST
            AttachCharacterEffectsAtBone( self, 'magefire', 'Ambient_Distort01', self.FxBones[5], self.Trash, self.AmbientEmitters )
            # SHOULDERS
            AttachCharacterEffectsAtBones( self, 'magefire', 'Ambient_Sphere01', {self.FxBones[1], self.FxBones[2]}, self.Trash, self.AmbientEmitters )

            WaitSeconds(delay)
            # CHEST
            AttachCharacterEffectsAtBone( self, 'magefire', 'Ambient_Sphere02', self.FxBones[5], self.Trash, self.AmbientEmitters )

            WaitSeconds(delay)
            # PELVIS
            AttachCharacterEffectsAtBone( self, 'magefire', 'Ambient_Sphere02', self.FxBones[6], self.Trash, self.AmbientEmitters )
            # FOREARMS
            AttachCharacterEffectsAtBones( self, 'magefire', 'Ambient_Arms01', {self.FxBones[3], self.FxBones[4]}, self.Trash, self.AmbientEmitters )
            AttachCharacterEffectsAtBones( self, 'magefire', 'Ambient_FaintSphere01', {self.FxBones[3], self.FxBones[4]}, self.Trash, self.AmbientEmitters )

            WaitSeconds(delay)
            # UPPER LEGS
            AttachCharacterEffectsAtBones( self, 'magefire', 'Ambient_Legs02', {self.FxBones[7], self.FxBones[8]}, self.Trash, self.AmbientEmitters )
            # ROOT/BASE POSITION
            AttachCharacterEffectsAtBone( self, 'magefire', 'Ambient_Base01', -2, self.Trash, self.AmbientEmitters )

            WaitSeconds(delay)
            # LOWER LEGS
            AttachCharacterEffectsAtBones( self, 'magefire', 'Ambient_Legs01', {self.FxBones[9], self.FxBones[10]}, self.Trash, self.AmbientEmitters )
            # FIRE GLOW
            AttachCharacterEffectsAtBone( self, 'magefire', 'Ambient_FireGlow01', -2, self.Trash, self.AmbientEmitters  )
        end,

        OnAbilityAdded = function(self, ability)
            self:SetAbilities(true, true)
        end,
    },
}
TypeClass = HEMA01
