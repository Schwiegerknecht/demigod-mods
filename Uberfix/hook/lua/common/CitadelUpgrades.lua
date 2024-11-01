--Mithy: Fix for experience 3 citadel upgrade bonus not being removed
Upgrades.Tree.CPortalFrequency04.Loses = {'CPortalFrequency03'}

--Mithy: Fix for Structure Firepower upgrades not affecting Trebuchets
for i=1, 4 do
	ArmyBonuses['CBuildingStrength0'..i].UnitCategory = 'STRUCTURE * (DEFENSE + ARTILLERY) -NOBUFFS'
end