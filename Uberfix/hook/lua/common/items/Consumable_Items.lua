--Mithy: These two fixes were not actually taking effect previously, as the IgnoreFacing flag was added to
--the item and not the item's usable ability (even in 1.02).  I totally missed this when converting them to
--non-destructive hooking methods, but they should now actually be working correctly.

# Sludge Slinger - set IgnoreFacing to make it properly castable
Ability.Item_Consumable_040.IgnoreFacing = true

# Parasite Egg - set IgnoreFacing to make it properly castable
Ability.Item_Consumable_170_Use.IgnoreFacing = true


--Mithy: Warlord's Punisher cast animation needs to match cast time
Ability.Item_Consumable_130.CastAction = 'CastItem1sec'