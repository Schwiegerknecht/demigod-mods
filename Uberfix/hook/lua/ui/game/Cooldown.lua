--Mithy: Hook SetupCooldown to make cooling-down ability buttons show their modified (rather than unmodified)
--total cooldown times in the tooltip.  Dead demigods will still show unmodified values, as we don't have their
--last valid sync data accessible within the button itself (HUD_Abilities keeps a local copy of this, but that's
--not accessible here, and the amount of code required to maintain one within the button object itself is not
--worth the miniscule benefit).
local prevSetupCooldown = SetupCooldown

function SetupCooldown(button)
    prevSetupCooldown(button)

    local prevOverlayEvent = button.Overlay.HandleEvent
    button.Overlay.HandleEvent = function(self, event)
        if event.Type == 'MouseEnter' and button.Entity and not button.Entity:IsDead() then
            --applyModifications param to tooltip needs to be true
            self.Tip = Tooltip.CreateAbilityTooltip(self, button.abilityDef, button.Docked, true)
            --Skip original Overlay.HandleEvent on MouseEnter to prevent useless extra work
            --This breaks any other mods with an earlier load order that try to hook this
            --(their code will never be run) but not those with a later order
            return Button.HandleEvent(self, event)
        else
            return prevOverlayEvent(self, event)
        end
    end
end