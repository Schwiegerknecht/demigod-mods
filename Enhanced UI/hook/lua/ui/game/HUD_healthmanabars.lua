    local OriginalOnHeroChange = OnHeroChange
    function OnHeroChange(unit)
        OriginalOnHeroChange(unit)
        if hero and healthTxt and manaTxt then
            healthTxt:Show()
            manaTxt:Show()
        else
            barGroup:Hide()
        end
    end
    local OriginalCreate = Create
    function Create(parent)
        OriginalCreate(parent)
        local OriginalHandleEvent = barGroup.dummy.HandleEvent
        function barGroup.dummy.HandleEvent(self, event)
            OriginalHandleEvent(self, event)
            healthTxt:Show()
            manaTxt:Show()
        end
        return barGroup
    end