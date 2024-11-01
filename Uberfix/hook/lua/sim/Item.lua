--Mithy: Added dead/exist checks to HandleItemPurchase and HandleItemSell to insure against
--gold loss/gain when dying during an item transaction.  There have only been a few scattered
--reports of this bug, and I have no log data, but this should at least prevent any gold from
--being exchanged if conditions are present where the item could not also be exchanged.


local prevItemPurchase = HandleItemPurchase
function HandleItemPurchase(unit, itemName, shopBp)
    if unit and not unit:IsDead() and unit.Inventory then
        prevItemPurchase(unit, itemName, shopBp)
    end
end

local prevItemSell = HandleItemSell
function HandleItemSell(unit, item)
    if unit and not unit:IsDead() and unit.Inventory then
        prevItemSell(unit, item)
    end
end