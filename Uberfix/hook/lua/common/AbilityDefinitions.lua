--Mithy: Add stacking flag to Morale AddArmyBonus calls
--This is necessary because Morale armybonuses are the only normally-stacking armybonuses
--in the game, and AddArmyBonus has been adjusted to prevent unintentional infinite stacking
--in other functions by pre-removing any existing bonus unless the stacking flag is specified
for i = 1, 6 do
    local abilStats = Ability['GeneralStatsBuff0'..i]
    if abilStats then
	    abilStats.OnStartAbility = function(self, unit, params)
	        --Add stacking flag so that more than one Morale bonus can be stacked
	        unit:GetAIBrain():AddArmyBonus('GeneralStatsBuff01', unit, true)
	    end
	end
end