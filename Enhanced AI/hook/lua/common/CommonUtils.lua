local ScenarioName = false

--Returns the name of the current scenario in lowercase, minus _scenario suffix and file extension
--e.g. 'map10' for '/maps/map10/map10_scenario.lua'
function GetScenarioName()
    if ScenarioName then
        return ScenarioName
    else
        local scenName, scenFile
        if IsSim() then
            scenFile = ScenarioInfo.file
        elseif IsUser() then
            scenFile = SessionGetScenarioInfo().file
        end
        if scenFile then
            scenName = string.gsub(scenFile, '^.+/([^/_]+)_scenario%.lua$', '%1')
            ScenarioName = scenName
            return ScenarioName
        end
    end
    return false
end