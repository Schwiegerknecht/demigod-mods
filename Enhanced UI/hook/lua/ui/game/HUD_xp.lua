    --save a local copy of the original OnHeroChange
    local prevOnHeroChange = OnHeroChange
    --re-define the function
    function OnHeroChange(unit)
        --call the saved instance
        prevOnHeroChange(unit)
        --make sure the saved instance set the 'hero' variable
        --that is declared at the top of the original file
        --if it's nil, that means we're in observer mode
        --we could also check 'unit', as that's what the original
        --sets 'hero' to, I'm just mimicking the check that
        --the original does in case I missed something
        if hero then
            --these will have all been hidden by the original
            --instance of the function that we just ran, but
            --we can just Show() them afterward without any
            --visual disruption
            xpTxt:Show()
            xptolevelTxt:Show()
        else
            --if no hero, then insure that the bar is hidden
            bar:Hide()
        end
    end
    local prevCreate = Create
    function Create(parent)
        --call saved, storing what it returns in a local
        local xpBarImg = prevCreate(parent)
        --change the position of the controls the original function created
        --in this particular case, their reference variables are defined
        --at the top of the file, so we don't need to reference them
        --within the table/control that the saved function returns
        LayoutHelpers.AtLeftIn(xptolevelTxt, bar, 76)
       
        --un-do the Hide() that the bar's HandleEvent does on mouseover
        --first we need to save a copy of the original HandleEvent so that
        --other mods' hooks of this function are preserved
        --we could just nil this function out - the whole dummy object,
        --in fact - but then if another mod attempted to hook it, it would
        --generate an error and/or not work at all, so we need to play nice
        local prevHandleEvent = bar.dummy.HandleEvent
        --redefine it
        bar.dummy.HandleEvent = function(self, event)
            --call the saved copy
            prevHandleEvent(self, event)
            --counteract the appropriate Hide() on mouse enter/exit
            if event.Type == 'MouseEnter' then
                xpTxt:Show()
		    elseif event.Type == 'MouseExit' then
                xptolevelTxt:Show()
            end
        end
       
        --return stored local, i.e. what the original function returned
        --this must be done, because the UI function that calls Create
        --uses the control object it returns
        return xpBarImg
    end