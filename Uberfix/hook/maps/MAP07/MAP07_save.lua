--Several Forces of Darkness ToLs were incorrectly waiting until WR4 to spawn
--Move their references from UPGRADELEVEL4 to INITIAL so they spawn immediately
for _, towername in {'UNIT_1056', 'UNIT_1472', 'UNIT_1473', 'UNIT_107', 'UNIT_1475', 'UNIT_1469'} do
	if Scenario.Armies.TEAM_2.Units.Units.UPGRADELEVEL4.Units[towername] then
		Scenario.Armies.TEAM_2.Units.Units.INITIAL.Units.DEFENSES.Units[towername] = Scenario.Armies.TEAM_2.Units.Units.UPGRADELEVEL4.Units[towername]
		Scenario.Armies.TEAM_2.Units.Units.UPGRADELEVEL4.Units[towername] = nil
	end
end