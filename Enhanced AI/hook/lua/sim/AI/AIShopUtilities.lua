-- [MOD] Increased item comparison for selling to fixed amount to prevent sell loops.
-- [MOD] Announce Citadel Upgrades
-- [MOD] TE All WaitTicks set to 10 = 1 second

local ValidateAbility = import('/lua/common/ValidateAbility.lua')
local ValidateInventory = import('/lua/common/ValidateInventory.lua')
local ValidateShop = import('/lua/common/ValidateShop.lua')
local CanPickItem = import('/lua/common/ValidateShop.lua').CanPickItem
local AIChatGlobals = import('/lua/sim/AI/AIChatGlobals.lua').AIChat
local Buff = import('/lua/sim/Buff.lua')
local Common = import('/lua/common/CommonUtils.lua')
local ValidateUpgrade = import('/lua/common/ValidateUpgrade.lua')
local Upgrades = import('/lua/common/CitadelUpgrades.lua').Upgrades

local AIUtils = import('/lua/sim/ai/aiutilities.lua')

local AIGlobals = import('/lua/sim/ai/AIGlobals.lua')

local ITEM_RESELL_MULTIPLIER = import('/lua/game.lua').GameData.SellMult
local ShopDistance = import('/lua/game.lua').GameData.ShopDistance


--===== Shop functions ===== --
function ShopCleanup(unit, action)
    if unit.Sync.ShopId then
        --Leave the shop
        commandData = {
            TaskName = 'EndShopTask',
        }
        IssueScript( {unit}, commandData )

        WaitTicks(6)
        if unit:IsDead() then
            return false
        end
    end

    return true
end

function MoveToShop( unit, shop, aiBrain )
    local path = AIUtils.GetSafePathBetweenPoints(aiBrain, unit.Position, shop.Position)
    local cmd = false
    if not path then
        return IssueMove( {unit}, shop.Position )
    end

    for k,v in path do
        cmd = IssueMove( {unit}, v )
    end
    return cmd
end

--Set up the sell routine
function SellItemAction( unit, action )
    local actionBp = HeroAIActionTemplates[action.ActionName]
    local item, itemPri = FindLowestInventoryItem( unit, action, actionBp.InventoryType )

    if not item then
        return false
    end

    local itemType = item.Sync.Name

    local shopPos = false
    if unit.ShopInformation.BuyItem['Purchase Base Item - Use Sell Refund'] and unit.ShopInformation.BuyItem['Purchase Base Item - Use Sell Refund'].PurchaseShopPosition then
        shopPos = unit.ShopInformation.BuyItem['Purchase Base Item - Use Sell Refund'].PurchaseShopPosition
    else
        shopPos = unit.Position
    end
    local shop = unit:GetAIBrain().GoalPlanner:GetClosestFriendlyShop(shopPos)

    if SellItem( unit, itemType, shop ) == 'Stuck' then
        action:LockAction( 2 )
    end

    --if unit:GetArmy() == 1 then
    --   WARN('*AI SHOP DEBUG: Brain= ' .. unit:GetArmy() .. ' - Selling item= ' .. itemType .. ' - Priority= ' .. itemPri)
    --end

    ShopCleanup(unit, action)
end

--If we have an item in the slot, we can sell it
function SellItemStatus( unit, action )
    local aiBrain = unit:GetAIBrain()

    if not unit.ShopInformation.SellItem[action.ActionName] then
        unit.ShopInformation.SellItem[action.ActionName] = {}
    end
    local actionInformation = unit.ShopInformation.SellItem[action.ActionName]
    actionInformation.SellItem = false
    actionInformation.SellItemPriority = false
    actionInformation.SellItemRefund = false
    actionInformation.SellItemInventoryType = false

    local actionBp = HeroAIActionTemplates[action.ActionName]
    local item,priority,shopType = FindLowestInventoryItem( unit, action, actionBp.InventoryType )
    if not item or not priority or not shopType then
        return false
    end

    local nearby = aiBrain.GoalPlanner:GetFriendlyShop(shopType, unit:GetPosition())
    if not nearby then
        return false
    end

    actionInformation.SellItemRefund = math.floor(item.Sync.PurchasePrice * ITEM_RESELL_MULTIPLIER )
    actionInformation.SellItem = item.Sync.Name
    actionInformation.SellItemPriority = priority
    actionInformation.SellItemInventoryType = actionBp.InventoryType

    --if (unit:GetArmy() == 1) then
    --   LOG('*AI SHOP DEBUG: SellItemStatus - Item= ' .. item.Sync.Name .. ' - ItemPriority = ' .. priority)
    --end

    return true
end

--Get weight of selling this item
function SellItemWeights(action, aiBrain, agent, initialAgent)
    if not agent.WorldStateData.CanMove then
        return false
    end

    local actionInformation = initialAgent.ShopInformation.SellItem[action.ActionName]
    if not actionInformation or not actionInformation.SellItem then
        return false
    end

    agent.WorldStateData.ItemSold = true
    agent.WorldStateData.ItemSoldPriority = actionInformation.SellItemPriority
    agent.WorldStateConsistent = false

    agent.Gold = agent.Gold + actionInformation.SellItemRefund
    agent.InventoryData[actionInformation.SellItemInventoryType] = agent.InventoryData[actionInformation.SellItemInventoryType] + 1

    return { PurchaseItems = ( actionInformation.SellItemPriority ), }, 0
end

--Moves to shop, sells item, closes shop
function SellItem( unit, item, shop )
    if unit.Sync.ShopId and not ShopCleanup(unit) then
        return false
    end

    local aiBrain = unit:GetAIBrain()
    if VDist3XZSq( unit.Position, shop.Position ) > 200 then
        local cmd = MoveToShop( unit, shop, aiBrain )
        while VDist3XZSq( unit.Position, shop.Position ) > 200 do
            WaitTicks(6)

            if unit:IsDead() or shop:IsDead() then
                return false
            end
        end
    end

    --Go to the shop
    local commandData = {
        TaskName = 'BeginShopTask',
        TargetId = shop:GetEntityId(),
    }
    local cmd = IssueScript( {unit}, commandData )

    local stuckCount = 0
    local oldPos = table.copy(unit.Position)
    if unit:IsDead() or shop:IsDead() then
        return
    end

    while shop and not shop:IsDead() and shop.CheckShopper and not shop:CheckShopper(unit) do
        WaitTicks(6)

        if unit:IsDead() or shop:IsDead() then
            return
        end

        local newPos = unit:GetPosition()
        if newPos[1] == oldPos[1] and newPos[2] == oldPos[2] and newPos[3] == oldPos[3] then
            stuckCount = stuckCount + 1
        else
            stuckCount = 0
        end

        if stuckCount >= 10 then
            LOG('*AI DEBUG: Unit Stuck getting to shop - Sell Item')
            return 'Stuck'
        end

        oldPos = table.copy(newPos)
    end

    if unit:IsDead() or shop:IsDead() or not shop.CheckShopper or not shop:CheckShopper(unit) then
        return false
    end

    local itemEntity = unit.Inventory[ Items[item].InventoryType ]:FindItem( item )

    if not itemEntity then
        return false
    end

    --Sell the item
    CODE_SellItem(unit, itemEntity:GetEntityId())
    WaitTicks(6)
    --WARN( LOC(unit:GetAIBrain().Nickname) .. ' Sold: ' .. LOC(Items[item].DisplayName))


    return true
end


--==== Item purchasing functions ==== --

--== Action CalculateWeights Function == --
function PurchaseItemCalculateWeights( action, aiBrain, agent, initialAgent )




    if not agent.WorldStateData.CanMove then
        return false
    end

    local actionInformation = initialAgent.ShopInformation.BuyItem[action.ActionName]

    if agent.InventoryData[actionInformation.PurchaseItemInventoryType] <= 0 then
        return false
    end

    local actionBp = HeroAIActionTemplates[action.ActionName]
    if actionBp.UseSellRefund and not agent.WorldStateData.ItemSold then
        return false
    end

    local actionBp = HeroAIActionTemplates[action.ActionName]
    if not actionBp.UseSellRefund and agent.WorldStateData.ItemSold then
        return false
    end

    if not actionInformation or not actionInformation.PurchaseItem then
        return false
    end

    if actionInformation.PurchaseItemCost > agent.Gold then
        return false
    end

    --if actionBp.UseSellRefund then
    --   if agent.WorldStateData.ItemSoldPriority >= actionInformation.PurchaseItemPriority then
    --       return false
    --   end
    --end

    local shopPos = actionInformation.PurchaseShopPosition
    if agent.Gold - actionInformation.PurchaseItemCost < 0 then
        return false
    end
    agent.Gold = agent.Gold - actionInformation.PurchaseItemCost

    agent.InventoryData[actionInformation.PurchaseItemInventoryType] = agent.InventoryData[actionInformation.PurchaseItemInventoryType] - 1

    if not agent.AgentHasMoved then
        distance = initialAgent.GOAP.BrainAsset:GetDistance( actionInformation.PurchaseShopType, 'Ally' )
    else
        distance = VDist3XZ( agent.Position, shopPos )
    end

    if not distance then
        return false
    end

    agent:SetPosition( shopPos )

    return { PurchaseItems = ( actionInformation.PurchaseItemPriority * -1 ), }, math.max( distance / agent.Speed, 2 )
end

--== StatusTrigger for buying items == --
function PurchaseItemStatus(unit, action)
    local aiBrain = unit:GetAIBrain()
    local actionBp = HeroAIActionTemplates[action.ActionName]
    unit.ShopInformation.CanBuyItem[action.ActionName] = false

    if not unit.ShopInformation.BuyItem[action.ActionName] then
        unit.ShopInformation.BuyItem[action.ActionName] = false
    end
    local actionInformation = {}

    actionInformation.PurchaseItem = false
    actionInformation.PurchaseItemPriority = false
    actionInformation.PurchaseShopPosition = false
    actionInformation.PurchaseItemCost = false
    actionInformation.PurchaseItemInventoryType = false
    actionInformation.PurchaseItemBaseShopType = false

    unit.ShopInformation.BuyItem[action.ActionName] = actionInformation

    local sellItemData = {}
    if actionBp.UseSellRefund then
        for k,v in unit.ShopInformation.SellItem do
            if not v.SellItem then
                continue
            end

            sellItemData[v.SellItemInventoryType] = v
        end
    end



    if actionBp.UseSellRefund then
        if table.empty(sellItemData) then
            return false
        end
    end

    local bestItem = FindBestBaseItem( unit, aiBrain, action, sellItemData )
    if not bestItem then
        return false
    end
    --[MOD] TE Citadel Check

    local bestCitadel = FindBestCitadelUpgrade( unit, aiBrain, action)
    if bestCitadel and bestCitadel.ItemPriority > bestItem.ItemPriority then
        return false
    end

    local nearby = bestItem.Shop
    if not nearby then
        return false
    end




    --TODO: VALIDATE IF WE CAN BUY MORE OF A STACKED ITEM HERE
    if ValidateInventory.NumFreeSlots( unit.Inventory[bestItem.InventoryType] ) <= 0 and not actionBp.UseSellRefund then
        return false
    end

    actionInformation.PurchaseItem = bestItem.ItemName
    actionInformation.PurchaseItemPriority = bestItem.ItemPriority
    actionInformation.PurchaseShopType = bestItem.ShopType
    actionInformation.PurchaseItemBaseShopType = bestItem.BaseShopType
    actionInformation.PurchaseShopPosition = bestItem.Shop:GetPosition()
    actionInformation.PurchaseItemCost = bestItem.ItemCost
    actionInformation.PurchaseItemInventoryType = bestItem.InventoryType

    unit.ShopInformation.BuyItem[action.ActionName] = actionInformation
    unit.ShopInformation.CanBuyItem[action.ActionName] = true

    --if (unit:GetArmy() == 1) then
    --   LOG('*AI SHOP DEBUG: ' .. action.ActionName .. 'Status - Item= ' .. bestItem.ItemName
    --       .. ' - ItemPriority = ' .. bestItem.ItemPriority)
    --end



    return true
end

--== Action ActionFunction == --
function PurchaseItemAction( unit, action )
    local aiBrain = unit:GetAIBrain()

    local bestItem = FindBestBaseItem( unit, aiBrain, action )

    if not bestItem then
        return
    end

    --if (unit:GetArmy() == 1) then
    --   WARN('*AI SHOP DEBUG: Army= ' .. unit:GetArmy() .. ' - Purchasing item= ' .. bestItem.ItemName
    --       .. ' - Priority= ' .. bestItem.ItemPriority
    --       .. ' - Quantity= ' .. bestItem.NumPurchase .. '\n\n' )
    --end

    --WARN(aiBrain.Nickname.. ' Buying ' .. bestItem.ItemName)
    if PurchaseItem( unit, bestItem.ItemName, bestItem.Shop, bestItem.NumPurchase, bestItem.BaseShopType ) == 'Stuck' then
        action:LockAction( 2 )
    end

    ShopCleanup(unit, action)

    unit.GOAP:ForcePurchaseUpdate()
end

--Purchase item - moves unit to shop, buys item, closes shop
function PurchaseItem( unit, itemName, shop, quantity, baseShopType )
    local shopItemId = false
    local aiBrain = unit:GetAIBrain()
    local shopBp = false
    if baseShopType then
        shopBp = GetUnitBlueprintByName(baseShopType)
        shopItemId = FindShopItemId( itemName, nil, shopBp )
    else
        shopBp = shop:GetBlueprint()
        shopItemId = FindShopItemId( itemName, shop )
    end

    quantity = quantity or 1

    if not shopItemId then
        return false
    end


        --[MOD] TE Check idol priority against current idol
    local sellIdol = false
    local syncData = Common.GetSyncData(unit)
    local itemEntity
    local sellItem
    if syncData.Inventory.Generals then
        for slot, invData in syncData.Inventory.Generals.Slots do
            local invItemData = EntityData[invData[1]].Data  --[MOD] TE Refrence .Data so item def can get blueprint.
            local invItemDef = Items[invItemData.BlueprintId]
            if invItemDef then
                local idolInSlot = string.sub(invItemDef.Name, 1, -5)
                local idolInShop = string.sub(shopItemId, 1, -5)
                if idolInSlot == idolInShop then
                    sellIdol = true
                    sellItem = invItemDef
                    itemEntity = unit.Inventory[ Items[invItemDef.Name].InventoryType ]:FindItem( invItemDef.Name )
                    --WARN(aiBrain.Nickname .. ' Sell Idol ' .. invItemDef.Name.. ' Type ' .. Items[invItemDef.Name].InventoryType .. ' , Entity - '.. tostring(itemEntity) )
                end
            end
        end
    end


    if not CanPickItem( unit, shopBp, shopItemId ) then
        return false
    end

    if unit.Sync.ShopId and not ShopCleanup(unit) then
        return false
    end


    if VDist3XZSq( unit.Position, shop.Position ) > 200 then
        local cmd = MoveToShop( unit, shop, aiBrain )
        while VDist3XZSq( unit.Position, shop.Position ) > 200 do
            WaitTicks(6)

            if unit:IsDead() or shop:IsDead() then
                return false
            end
        end
    end

    --Go to the shop
    local commandData = {
        TaskName = 'BeginShopTask',
        TargetId = shop:GetEntityId(),
    }
    local cmd = IssueScript( {unit}, commandData )

    local oldPos = table.copy( unit:GetPosition() )
    local stuckCount = 0

    --Wait until we are in the shop
    while not shop:CheckShopper(unit) do
        WaitTicks(6)

        if unit:IsDead() or shop:IsDead() then
            return
        end

        local newPos = unit:GetPosition()
        if newPos[1] == oldPos[1] and newPos[2] == oldPos[2] and newPos[3] == oldPos[3] then
            stuckCount = stuckCount + 1
        else
            stuckCount = 0
        end

        if stuckCount >= 10 then
            LOG('*AI DEBUG: Unit Stuck getting to shop - Sell Item')
            return 'Stuck'
        end

        oldPos = table.copy(newPos)
    end


    if sellIdol then
        --WARN('Entity - ' .. tostring(itemEntity) )
        --WARN( LOC(unit:GetAIBrain().Nickname) .. ' Idol Sold: ' .. LOC(sellItem.DisplayName) )
        CODE_SellItem(unit, itemEntity:GetEntityId())
        WaitTicks(6)
    end

    for i=1,quantity do
        --Purchase the item
        CODE_PurchaseItem(unit, shopItemId, shopBp.BlueprintId)

        WaitTicks(6)
    end


    if shopBp.BlueprintId == 'ugbshop05' then
        local def = shopBp.Shop.Tree[shopItemId]
        if Items[def.ItemBP].DisplayName then
            WaitTicks(6)
            local announcement = "Artifact Purchased: "..LOC(Items[def.ItemBP].DisplayName)
            AIUtils.AIChat(unit, announcement)

        end
    end

    if shopBp.BlueprintId == 'ugbshop09' then
        local def = shopBp.Shop.Tree[shopItemId]
        if Items[def.ItemBP].DisplayName then
            WaitTicks(6)
            ---- local announcement = "Idol Purchased: "..LOC(Items[def.ItemBP].DisplayName)
            ---- AIUtils.AIChat(unit, announcement)
            --WARN( LOC(aiBrain.Nickname) .. ' Idol Purchased: ' .. LOC(Items[def.ItemBP].DisplayName))
        end
    end

    return true
end



--==== Helper functions ==== --

--iterates through the shop's items and sees if there is an item found
function FindShopItemId( itemName, shop, shopBp )
    if shop then
        shopBp = shop:GetBlueprint()
    end

    if not shopBp then
        WARN('AI ERROR: Could not find a shop bp')
        return false
    end

    for shopItemId,item in shopBp.Shop.Tree do
        if item.ItemBP == itemName then
            return shopItemId
        end
    end

    return false
end

function GetItemCount(unit, itemName)
    local numItems = 0
    for _,inv in unit.Inventory do
        local temp = inv:GetCount( itemName )
        if table.empty(temp) then
            continue
        end

        for k,v in temp do
            numItems = numItems + v.Count
        end
    end

    return numItems
end

--Check if the unit already has the item or not
function UnitHasItem( unit, itemName, baseShopType )
    local shopBp = GetUnitBlueprintByName(baseShopType)

    local itemTree = Common.GetShopTreeByBlueprint(shopBp)

    local shopItemId = FindShopItemId( itemName, nil, shopBp )

    local itemData = itemTree[shopItemId]

    if not itemData then
        WARN('*AI ERROR: No item data found for item - ' .. itemName )
        return false
    end

    local syncData = Common.GetSyncData(unit)
    local counts = ValidateInventory.GetCount(syncData.Inventory[ Items[itemName].InventoryType ], itemData.ItemBP)

    --We have none return out
    if table.empty(counts) then
        return false, 0
    end

    --Find out how many we have
    local numHeld = 0
    for k,v in counts do
        numHeld = numHeld + v.Count
    end

    if numHeld > 0 then
        return true, numHeld
    end

    return false, 0
end


--Returns the best item that can be purchased by the agent
--  Returned Table = { ItemName, Shop, ItemCost, ItemPriority }
function FindBestBaseItem( unit, aiBrain, action, sellItemData )
    local bestValue = 0
    local bestItems = {}
    local shops = {}

    local asset = action.StrategicAsset
    if not asset or not asset.ItemPriorities then
        return false
    end

    local inventoryOpen = {}
    for invName,inv in unit.Inventory do
        inventoryOpen[invName] = ValidateInventory.NumFreeSlots( inv )
    end

    local highestPriority = false

    local maxCost = false

    --Mithy: New save-for logic that takes into account item cost mods
    local savingForUpgrade, savingForCost = AIGlobals.SaveForUpgrade(unit, aiBrain)
    local gold = aiBrain.mGold - (savingForCost or 0 * (unit.Sync.ItemCostMod or 1))

    local syncData = Common.GetSyncData(unit)

    for _,itemData in asset.ItemPriorities do

        --this number can increase for stackable items
        local purchaseQuantity = 1
        local currentPriority = 0

        if itemData.Priority <= 0 then
            continue
        end



        --If we have a highest priority and this next item won't be higher; break the loop
        if highestPriority and itemData.Priority < highestPriority then
            continue
        end

        --Store out each shop only once; this way we don't have to find shops more like crazy
        if shops[itemData.ItemTable.ShopType] == nil then
            local shop = aiBrain.GoalPlanner:GetFriendlyShop(itemData.ItemTable.ShopType, unit:GetPosition())
            if shop then
                shops[itemData.ItemTable.ShopType] = shop
            else
                shops[itemData.ItemTable.ShopType] = false
            end

            --all shops of this time seem dead, continue to next item
            if not shop then
                continue
            end
        end



        local nearby = shops[itemData.ItemTable.ShopType]
        if not nearby then
            continue
        end

        local hasItem, numHeld = UnitHasItem( unit, itemData.ItemTable.ItemId, itemData.ItemTable.BaseShopType )
        --Figure out if we can carry this item; We have two checks - one for non-stacked items and one for stacks
        if itemData.ItemTable.StacksPerSlot > 1 then
            if hasItem and numHeld >= itemData.ItemTable.StacksPerSlot then
                continue
            end

            local maxPurchasable = itemData.ItemTable.StacksPerSlot - numHeld
            --Already at max; this item is bankrupt
            if maxPurchasable <= 0 then
                continue
            end

            maxPurchasable = math.min( maxPurchasable, AIGlobals.ItemWeights[itemData.ItemTable.ItemId].MaxPurchase or 1 )

            --Mithy: Take into account item cost mult, and make sure we can actually afford one
            local maxAffordable = math.floor( gold / (itemData.ItemTable.ItemCost * (unit.Sync.ItemCostMod or 1)) )
            if maxAffordable < 1 then --was <= 0
                continue
            end

            currentPriority = itemData.Priority

            --Make sure the new item is better than the old item
            if sellItemData[itemData.ItemTable.InventoryType] then
                --[MOD] Fixed amount added to sell priority to ensure new item is greater than 5 priority better.  Prevents buy/sell loops
                if sellItemData[itemData.ItemTable.InventoryType].SellItemPriority + 5 > itemData.Priority then
                    continue
                end
            end

        else
            --Handle non-stacked items here
            if hasItem then
                continue
            end

--0.26.40 - removed the code that placed a limitation on what items could be purchased at the start of the game
--[[            --[MOD] TE   Buy more cheaper items at start
            if GetGameTimeSeconds() < 30 and gold < 5000 and itemData.ItemTable.ItemCost >= 1750 then
                continue
            elseif  GetGameTimeSeconds() < 30 and gold < 35000 and itemData.ItemTable.ItemCost > 10000 then
                continue
            end
--]]

            --Get our sell refund and make sure the new item is better than the old item
            local addAmount = 0
            if sellItemData[itemData.ItemTable.InventoryType] then
                addAmount = sellItemData[itemData.ItemTable.InventoryType].SellItemRefund


                --[MOD] Fixed amount added to sell priority to ensure new item is greater than 5 priority better.   Prevents buy/sell loops
                if sellItemData[itemData.ItemTable.InventoryType].SellItemPriority + 5 > itemData.Priority then
                    continue
                end
            end

            --Mithy: Factor item cost mult
            if gold + (addAmount * (unit.Sync.ItemCostMod or 1)) < (itemData.ItemTable.ItemCost * (unit.Sync.ItemCostMod or 1)) then
                continue
            end

            --[MOD] TE Check idol priority against current idol
            if syncData.Inventory.Generals then
                local buyItem = true
                for slot, invData in syncData.Inventory.Generals.Slots do
                    local invItemData = EntityData[invData[1]].Data  --[MOD] TE Refrence .Data so item def can get blueprint.
                    local invItemDef = Items[invItemData.BlueprintId]
                    if invItemDef then
                        local idolInSlot = string.sub(invItemDef.Name, 1, -5)
                        local idolInShop = string.sub(itemData.ItemTable.ItemId, 1, -5)
                        if idolInSlot == idolInShop then
                            local invPriority = 0
                            for k,v in asset.ItemPriorities do
                                if v.ItemTable.ItemId == invItemDef.Name then
                                    invPriority = v.Priority
                                    break
                                end

                            end


                            if invPriority + 5 > itemData.Priority then
                                --WARN( LOC(aiBrain.Nickname) ..' Current: '..invItemDef.Name ..' - ' .. invPriority + 5 .. ' | vs | ' .. itemData.ItemTable.ItemId .. ' - ' .. itemData.Priority )
                                buyItem = false
                            else
                                buyItem = true
                                --WARN( LOC(aiBrain.Nickname) ..' Sell: '..invItemDef.Name ..' - ' .. invPriority .. ' | Buy: ' .. itemData.ItemTable.ItemId .. ' - ' .. itemData.Priority )
                            end
                        end
                    end
                end
                if not buyItem then
                    continue
                end
            end


            currentPriority = itemData.Priority
        end

        --Make sure we'll have room for the item
        if inventoryOpen[itemData.ItemTable.InventoryType] <= 0 and not sellItemData[itemData.ItemTable.InventoryType] then
            continue
        end

        --WARN('Items - ' ..  itemData.ItemTable.ItemId .. ' - Inventory Type - ' ..  inventoryOpen[itemData.ItemTable.InventoryType] )


        --Do NOT allow rebuying of the same item
        if sellItemData[itemData.ItemTable.InventoryType].SellItem == itemData.ItemTable.ItemId then
            continue
        end

        highestPriority = currentPriority

        --[[if (unit:GetArmy() == 1) then
            WARN('*AI SHOP DEBUG: Find Best Item Army= ' .. unit:GetArmy() .. ' - Purchasing item= ' .. itemData.ItemTable.ItemId
                .. ' - Priority= ' .. highestPriority
                .. ' - Quantity= ' .. purchaseQuantity  )
        end--]]

        table.insert( bestItems, { ItemName = itemData.ItemTable.ItemId, ShopType = itemData.ItemTable.ShopType,
            Shop = nearby, ItemCost = itemData.ItemTable.ItemCost, ItemPriority = highestPriority, NumPurchase = purchaseQuantity,
            InventoryType = itemData.ItemTable.InventoryType, BaseShopType = itemData.ItemTable.BaseShopType } )
    end

    if table.getn( bestItems ) > 0 then
        return bestItems[Random( 1, table.getn(bestItems) )]
    end

    return false
end

function FindLowestInventoryItem( unit, action, inventoryType )
    local lowestPriority = false
    local lowestItem = false
    local shopType = false
    local aiBrain = unit:GetAIBrain()

    local asset = action.StrategicAsset

    if not asset.ItemPriorities then
        return false
    end

    --[MOD] Block selling Generals item (sale of old is handled on idol purchase)
    if inventoryType == 'Generals' then
        --WARN('Generals Item')
        return false
    end

    if ValidateInventory.NumFreeSlots(unit.Inventory[inventoryType]) > 0 then
        return false
    end

    local inv = unit.Inventory[inventoryType]
    for i=1,8 do
        local itemId = inv:GetItemFromSlot( i )
        if not itemId then
            continue
        end

        local item = GetEntityById( itemId )
        if not item then
            continue
        end






        --[MOD] TE  Don't Sell Portals and capture locks
        if item.Sync.Name == 'Item_Consumable_010' or item.Sync.Name == 'Item_Consumable_030'  then
            --WARN( LOC(aiBrain.Nickname) .. 'Skipped TP/Capture Lock ' .. item.Sync.Name )
            continue
        end

        local numItems = 0
        for k,v in inv:GetCount( item.Sync.Name ) do
            numItems = numItems + v.Count
        end

        --Do not sell a stack of items
        if numItems > 1 then
            continue
        end


        local itemType = item.Sync.Name
        local tempPriority, tempShop
        for k,v in asset.ItemPriorities do
            if v.ItemTable.ItemId == itemType then
                if v.SellPriority > 0 then
                    tempPriority = v.SellPriority
                    tempShop = v.ItemTable.ShopType
                    LOG('*AI DEBUG: Using SellPriority for item - ' .. v.ItemTable.ItemId)
                elseif v.Priority > 0 then
                    tempPriority = v.Priority
                    tempShop = v.ItemTable.ShopType
                end
                break
            end
        end



        --WARN('Inventory Priority - ' .. tostring(item.Blueprint.SubInventoryType) )

        if tempPriority and ( not lowestPriority or tempPriority < lowestPriority ) then        --[MOD] TE Don't sell idols
            lowestPriority = tempPriority
            lowestItem = item
            shopType = tempShop
        end
    end

    ---- local myString = ' '
    ---- for kk, vv in lowestItem.Blueprint do
        ---- myString = myString .. 'column: ' .. kk .. ' value: ' .. tostring(vv) .. ' || '
    ---- end
    ---- WARN('Inventory Priority - ' .. myString )
    return lowestItem, lowestPriority, shopType
end

function GetItemDesires(itemId)
    if not ScenarioInfo.AIItemsList then
        return false
    end

    for k,itemTable in ScenarioInfo.AIItemsList do
        if itemTable.ItemId != itemId then
            continue
        end

        return {
            HealthDesire = itemTable.ItemWeights.HealthDesire,
            ManaDesire = itemTable.ItemWeights.ManaDesire,
            PrimaryWeaponDesire = itemTable.ItemWeights.PrimaryWeaponDesire,
            MinionDesire = itemTable.ItemWeights.MinionDesire,
            SpeedDesire = itemTable.ItemWeights.SpeedDesire,
        }
    end
end

function GetPriorityFromCost(cost)
    if cost < 1250 then
        return 5
    elseif cost < 2000 then
        return 15
    elseif cost < 4000 then
        return 30
    elseif cost < 7500 then
        return 50
    elseif cost < 11000 then
        return 100
    elseif cost < 17500 then
        return 150
    else
        return 200
    end
end

function GetItemsList()
    --We've already built the list once; return the list - it should NOT change mid game
    if ScenarioInfo.AIItemsList then
        return ScenarioInfo.AIItemsList
    end

    ScenarioInfo.AIItemsList = {}

    --Get all the shops
    local shops = {}
    for _,brain in ArmyBrains do
        shops = table.append( shops, brain:GetListOfUnits( categories.SHOP, false, false ) )
    end
    local shopIds = {
        Boots           = 'ugbshop10',  --[MOD] TE Fixed to correct boot shop ugbshop01 -> ugbshop10
        Breastplates    = 'ugbshop02',
        Gloves          = 'ugbshop03',
        Helms           = 'ugbshop04',
        Artifacts       = 'ugbshop05',
        Rings           = 'ugbshop06',
        Consumables     = 'ugbshop07',
        Generals        = 'ugbshop09',
    }

    --Iterate through the shops
    for shopType,shopId in shopIds do

        local shopBp = __blueprints[shopId]

        --Get the shop tree which has the costs and ItemBPs for all the items
        local shopTree = Common.GetShopTreeByBlueprint(shopBp)

        --Go through all the items in the shop tree
        for shopItemId,itemData in shopTree do
            if not Items[itemData.ItemBP] then
                continue
            end

            --Blank template used by all items
            local itemTable = {
                ItemWeights = {
                    HealthDesire = 0,
                    ManaDesire = 0,
                    PrimaryWeaponDesire = 0,
                    MinionDesire = 0,
                    SpeedDesire = 0,

                    Priority = 0,
                    SellPriority = -1,
                },
            }
            if not AIGlobals.ItemWeights[itemData.ItemBP].Priority and not AIGlobals.ItemWeights[itemData.ItemBP].PriorityFunction then
                WARN('*AI DEBUG: No priority set for item = ' .. itemData.ItemBP)
                WARN('*AI DEBUG: Item Cost = ' .. itemData.Cost)
                WARN('*AI DEBUG: ItemData = ' .. repr(Items[itemData.ItemBP]) )
                LOG('*AI DEBUG: ======================')
            end

            if AIGlobals.ItemWeights[itemData.ItemBP].Priority == -1 then
                itemTable.ItemWeights.Priority = GetPriorityFromCost(itemData.Cost)
            end

            if AIGlobals.ItemWeights[itemData.ItemBp].SellPriority then
                itemTable.ItemWeights.SellPriority = AIGlobals.ItemWeights[itemData.ItemBp].SellPriority
            end

            --Store out some basic info we'll use when trying to shop
            itemTable.ShopItemId = shopItemId

            if (shopId == 'ugbshop05') then
                itemTable.ShopType = shopId
            else
                itemTable.ShopType = 'ugbshop01'
            end
            itemTable.BaseShopType = shopId
            itemTable.ItemCost = itemData.Cost
            itemTable.ItemId = itemData.ItemBP

            --Figure out the weight for each item sold at this shop
            local itemBp = Items[itemData.ItemBP]
            itemTable.SlotLimit = itemBp.SlotLimit
            itemTable.StacksPerSlot = itemBp.StacksPerSlot or 1
            itemTable.InventoryType = itemBp.InventoryType
            itemTable.GeneralItem = AIGlobals.ItemWeights[itemTable.ItemId]['GeneralItem'] or false
            itemTable.AssassinItem = AIGlobals.ItemWeights[itemTable.ItemId]['AssassinItem'] or false


            --Go through all the abilities on the item and figure out what the ability does for demigods
            for _,abilityName in itemBp.Abilities do
                if not Ability[abilityName] then
                    ERROR('*AI ERROR: Could not find ability information for Ability - ' .. abilityName)
                end

                --make sure we are taking into account the item even if the ability is a clicky
                --if Ability[abilityName].AbilityType != 'Quiet' and not AIGlobals.ItemWeights[itemTable.ItemId] then
                    --LOG('*AI DEBUG: Click Ability = ' .. abilityName .. ' - Data = ' .. repr(Ability[abilityName]) )
                --end

                --TODO: Intelligently balance desire for procs & crits
                if Ability[abilityName].AbilityType == 'WeaponProc' then
                    itemTable.ItemWeights.PrimaryWeaponDesire = itemTable.ItemWeights.PrimaryWeaponDesire + 0.1
                elseif Ability[abilityName].AbilityType == 'ArmorProc' then
                    itemTable.ItemWeights.HealthDesire = itemTable.ItemWeights.HealthDesire + 0.1
                elseif Ability[abilityName].AbilityType == 'WeaponCrit' then
                    itemTable.ItemWeights.PrimaryWeaponDesire = itemTable.ItemWeights.PrimaryWeaponDesire + 0.1
                end

                if Ability[abilityName].Buffs then
                    for _,buffName in Ability[abilityName].Buffs do
                        local buffWeights = GetBuffWeights( buffName )

                        for k,v in buffWeights do
                            itemTable.ItemWeights[k] = v + itemTable.ItemWeights[k]
                        end
                    end
                end
            end


            --Get item default weighting
            if AIGlobals.ItemWeights[itemTable.ItemId] then
                for weightName,weightValue in AIGlobals.ItemWeights[itemTable.ItemId] do
                    if weightName == 'MaxPurchase' or weightName == 'GeneralItem' or weightName == 'AssassinItem' then
                        continue
                    end

                    if (weightName == 'Priority' and weightValue == -1) or weightName == 'PriorityFunction' or weightName == 'SellPriority' then
                        continue
                    end

                    itemTable.ItemWeights[weightName] = itemTable.ItemWeights[weightName] + weightValue
                end
            end

            --Uncomment to see the default weights for items
            --LOG('*AI DEBUG: Item = ' .. itemTable.ItemId .. ' - WeightsTable = ' .. repr(itemTable.ItemWeights) )

            --Store the cost and weight for this item in the global items list
            table.insert( ScenarioInfo.AIItemsList, itemTable )
        end
    end

    --return the global items list
    return ScenarioInfo.AIItemsList
end

function GetBuffWeights(buffName)
    local buffData = Buffs[buffName]

    --We currently are NOT dealing with items that have variable durations
    if buffData.Duration > -1 then
        return {}
    end

    local returnTable = {
        HealthDesire = 0,
        ManaDesire = 0,
        PrimaryWeaponDesire = 0,
        MinionDesire = 0,
        SpeedDesire = 0,
    }

    if not buffData.Affects then
        WARN('*AI WARNING: Item with buff - ' .. buffName .. ' - Does not have an Affects block')
        return returnTable
    end

    for aName,aData in buffData.Affects do
        --LOG('*AI DEBUG: BuffAffects = ' .. repr(buffData.Affects))

        --Damage Rating
        if aName == 'DamageRating' then
            local addAmount = aData.Add / 100
            returnTable.PrimaryWeaponDesire = returnTable.PrimaryWeaponDesire + addAmount

        --Health
        elseif aName == 'Regen' then
            local addAmount = ((aData.Add or 0) / 75 ) + ((aData.Mult or 0) / 5)
            returnTable.HealthDesire = returnTable.HealthDesire + addAmount

        elseif aName == 'MaxHealth' then
            local addAmount = aData.Add / 4000
            returnTable.HealthDesire = returnTable.HealthDesire + addAmount

        --Energy
        elseif aName == 'MaxEnergy' then
            local addAmount = ( aData.Add / 6000 )
            returnTable.ManaDesire = returnTable.ManaDesire + addAmount

        elseif aName == 'EnergyRegen' then
            local addAmount = ( (aData.Add or 0) / 25 ) + ((aData.Mult or 0) )
            returnTable.ManaDesire = returnTable.ManaDesire + addAmount

        --Armor
        elseif aName == 'Armor' then
            local addAmount = ( aData.Add / 4000 )
            returnTable.HealthDesire = returnTable.HealthDesire + addAmount

        --Move Speed
        elseif aName == 'MoveMult' then
            local addAmount = ( (aData.Mult or 0) )
            returnTable.SpeedDesire = returnTable.SpeedDesire + addAmount

        --Lifesteal
        elseif aName == 'LifeSteal' then
            local addAmount = aData.Add
            returnTable.PrimaryWeaponDesire = returnTable.PrimaryWeaponDesire + addAmount
            returnTable.HealthDesire = returnTable.HealthDesire + ( addAmount / 2 )

        --Damage return
        elseif aName == 'DamageReturn' then
            local addAmount = ( aData.Add / 100 )
            returnTable.HealthDesire = returnTable.HealthDesire + addAmount

        --Rate of Fire
        elseif aName == 'RateOfFire' then
            local addAmount = ((aData.Mult or 0) * 2)
            returnTable.PrimaryWeaponDesire = returnTable.PrimaryWeaponDesire + addAmount

        --Cooldown
        elseif aName == 'Cooldown' then
            local addAmount = aData.Mult * -1
            returnTable.ManaDesire = returnTable.ManaDesire + addAmount

        --Evasion
        elseif aName == 'Evasion' then
            local addAmount = ( aData.Add / 50 )
            returnTable.HealthDesire = returnTable.HealthDesire + addAmount

        --Damage Taken
        elseif aName == 'DamageTakenMult' then
            local addAmount = ( aData.Add * -1.5 )
            returnTable.HealthDesire = returnTable.HealthDesire + addAmount

        --Item cost reduction
        elseif aName == 'ItemCost' then
            local addAmount = ( aData.Add * -2 )
            returnTable.SpeedDesire = returnTable.SpeedDesire + addAmount

        --Item cost reduction
        elseif aName == 'Experience' then
            local addAmount = aData.Add
            returnTable.SpeedDesire = returnTable.SpeedDesire + addAmount

        elseif aName == 'Dummy' then
            --Valid name for dummy buffs used for persistent effects on actors
        else
            --Find any we don't handle and report
            LOG('*AI DEBUG: Unhandled buff data = ' .. aName .. ' - ' .. repr(buffData))
        end
    end

    return returnTable
end

--------------------------------------------------------------------------------
--Purchase Achievement Items
--------------------------------------------------------------------------------
function PurchaseAchievementItem(unit)
    local result = false
    local bestItem = FindBestAchievementItem(unit)

    if(bestItem) then
        local itemName = bestItem.ItemName
        local baseShopType = bestItem.BaseShopType
        local shopItemId = false

        local shopBp = false
        if(baseShopType) then
            shopBp = GetUnitBlueprintByName(baseShopType)
            shopItemId = FindShopItemId(itemName, nil, shopBp)
        end

        if(shopItemId and CanPickItem(unit, shopBp, shopItemId, true)) then
            --Purchase the item
            CODE_PurchaseItem(unit, shopItemId, shopBp.BlueprintId)
            result = true
            --LOG('*AI DEBUG: Army ' .. unit.Army .. ' buying achievement item ' .. shopItemId)
        end
    end

    return result
end

--Returns the best item that can be purchased
function FindBestAchievementItem(unit)
    local result = false
    local bestItem = {}

    if(ValidateInventory.NumFreeSlots(unit.Inventory.Achievement) > 0) then
        -- local difficulty = ScenarioInfo.ArmySetup[unit:GetAIBrain().Name].Difficulty
        -- local maxPoints = 1125 --GameData.DifficultyHandicaps[difficulty].MaxPoints
        -- local minPoints = 1125 --GameData.DifficultyHandicaps[difficulty].MinPoints

        local isGeneral = EntityCategoryContains( categories.GENERAL, unit )
        local isAssassin = EntityCategoryContains( categories.ASSASSIN, unit )

        local itemList = GetAchievementItemsList()
        local achievementItems = {}



         --[MOD]  Favor items added as list of items ot select from in each demigod build
         local unitId = unit:GetUnitId()--..'peppe'

         if(UnitAITemplates[unitId].SkillBuilds) then
            local brain = unit:GetAIBrain()
            if(not brain.UseSkillWeights) then
                local build = nil
                build = UnitAITemplates[unitId].SkillBuilds[brain.SkillBuild]

                if(build.FavorItems) then
                    local myFavorItems = {}
                    for k, v in build.FavorItems do
                        table.insert(myFavorItems, k)
                    end
                    local num = math.random(table.getn(myFavorItems))

                    for k, v in itemList do

                        if(v.BaseShopType == 'ugbshop08_general' and not isGeneral) then
                            continue
                        elseif(v.BaseShopType == 'ugbshop08_assassin' and not isAssassin) then
                            continue
                        end

                        if v.ItemId == build.FavorItems[num] then
                            table.insert(achievementItems, {ItemTable = v})
                        end
                    end

                end
            end
        end

        local numItems = table.getn(achievementItems)
        if(numItems == 0) then
            local myFavorItems = {'AchievementHealth','AchievementRunSpeed'} --'AchievementTeleport',
            local num = math.random(table.getn(myFavorItems))
            for k, v in itemList do
                if(v.BaseShopType == 'ugbshop08_general' and not isGeneral) then
                    continue
                elseif(v.BaseShopType == 'ugbshop08_assassin' and not isAssassin) then
                    continue
                end

                if v.ItemId == myFavorItems[num] then
                    table.insert(achievementItems, {ItemTable = v})
                end
            end
            numItems = table.getn(achievementItems)
        end
        if(numItems > 0) then
            result = achievementItems[Random(1, numItems)]
            table.insert(bestItem, {ItemName = result.ItemTable.ItemId, ItemCost = result.ItemTable.ItemCost, BaseShopType = result.ItemTable.BaseShopType})
        end
    end

    if(result) then
        return bestItem[1]
    else
        return result
    end
end

function GetAchievementItemsList()
    --We've already built the list once; return the list - it should NOT change mid game
    if ScenarioInfo.AIAchievementItemsList then
        return ScenarioInfo.AIAchievementItemsList
    end

    ScenarioInfo.AIAchievementItemsList = {}

    local shopIds = {
        Generic         = 'ugbshop08',
        General         = 'ugbshop08_general',
        Assassin        = 'ugbshop08_assassin',
    }

    for shopType,shopId in shopIds do
        local shopBp = __blueprints[shopId]


        --Get the shop tree which has the costs and ItemBPs for all the items
        local shopTree = Common.GetShopTreeByBlueprint(shopBp)

        --Go through all the items in the shop tree
        for shopItemId,itemData in shopTree do
            if not Items[itemData.ItemBP] then
                continue
            end

            local itemTable = {}
            itemTable.BaseShopType = shopId
            itemTable.ItemCost = itemData.Cost
            itemTable.ItemId = itemData.ItemBP

            table.insert(ScenarioInfo.AIAchievementItemsList, itemTable)
        end
    end

    --return the global items list
    return ScenarioInfo.AIAchievementItemsList
end

--------------------------------------------------------------------------------
--Purchase Citadel Upgrades
--------------------------------------------------------------------------------
function GetUpgradesList()
    --We've already built the list once; return the list - it should NOT change mid game
    if ScenarioInfo.AIUpgradesList then
        return ScenarioInfo.AIUpgradesList
    end

    ScenarioInfo.AIUpgradesList = {}

    --Get the shop tree which has the costs and BPs for all the upgrades
    local shopTree = Upgrades.Tree

    --Go through all the items in the shop tree
    for upgradeId, upgradeData in shopTree do



        --[MOD] TE  Ignore buff constraint to allow all upgrades to be purchased.
        ---- if not Buffs[upgradeId] then
            ---- continue

        ---- end

        --Blank template used by all upgrades
        local itemTable = {
            ItemWeights = {
                HealthDesire = 0,
                ManaDesire = 0,
                PrimaryWeaponDesire = 0,
                MinionDesire = 0,
                SpeedDesire = 0,

                Priority = 0,
            },
        }



        --Store out some basic info we'll use when trying to shop
        itemTable.ShopItemId = upgradeId

        itemTable.ShopType = 'ugbshop01'
        itemTable.BaseShopType = 'stronghold01'
        itemTable.ItemCost = upgradeData.Cost
        itemTable.ItemId = upgradeId
        itemTable.WarRank = upgradeData.Level

        --Get item default weighting

        -- [MOD] Set priority if it is available otherwise leave it to FriendlyAsset to process a PriorityFunction.
        if(AIGlobals.CitadelUpgradeWeights[upgradeId] and AIGlobals.CitadelUpgradeWeights[upgradeId].Priority != -1 and AIGlobals.CitadelUpgradeWeights[upgradeId].Priority != nil) then
           itemTable.ItemWeights.Priority = AIGlobals.CitadelUpgradeWeights[upgradeId].Priority
        end

        -- [MOD] If prioty is set to -1 (auto) convert it to a priority.
        if (AIGlobals.CitadelUpgradeWeights[upgradeId].Priority == -1) then
            itemTable.ItemWeights.Priority = GetPriorityFromCost(itemTable.ItemCost)
        end

        --Uncomment to see the default weights for items
        --LOG('*AI DEBUG: Item = ' .. itemTable.ItemId .. ' - WeightsTable = ' .. repr(itemTable.ItemWeights) )

        --Store the cost and weight for this upgrade in the global upgrades list
        table.insert( ScenarioInfo.AIUpgradesList, itemTable )
    end


    --return the global upgrades list
    return ScenarioInfo.AIUpgradesList
end

function PurchaseCitadelUpgradeCalculateWeights( action, aiBrain, agent, initialAgent )
    if not agent.WorldStateData.CanMove then
        return false
    end





    local actionInformation = initialAgent.ShopInformation.BuyItem[action.ActionName]
    if not actionInformation or not actionInformation.PurchaseItem then
        return false
    end

    if actionInformation.PurchaseItemCost > agent.Gold then
        return false
    end

    local shopPos = actionInformation.PurchaseShopPosition
    if agent.Gold - actionInformation.PurchaseItemCost < 0 then
        return false
    end
    agent.Gold = agent.Gold - actionInformation.PurchaseItemCost

    if not agent.AgentHasMoved then
        distance = initialAgent.GOAP.BrainAsset:GetDistance( 'STRONGHOLD', 'Ally' )
    else
        distance = VDist3XZ( agent.Position, shopPos )
    end

    if not distance then
        return false
    end

    agent:SetPosition( shopPos )

    return { PurchaseItems = ( actionInformation.PurchaseItemPriority * -1 ), }, math.max( distance / agent.Speed, 2 )
end

function PurchaseCitadelUpgradeStatus(unit, action)
    local aiBrain = unit:GetAIBrain()
    local actionBp = HeroAIActionTemplates[action.ActionName]

    unit.ShopInformation.CanBuyItem[action.ActionName] = false

    if(not unit.ShopInformation.BuyItem[action.ActionName]) then
        unit.ShopInformation.BuyItem[action.ActionName] = false
    end

    local actionInformation = {}
    actionInformation.PurchaseItem = false
    actionInformation.PurchaseItemPriority = false
    actionInformation.PurchaseShopPosition = false
    actionInformation.PurchaseItemCost = false

    unit.ShopInformation.BuyItem[action.ActionName] = actionInformation

    local bestItem = FindBestCitadelUpgrade(unit, aiBrain, action)
    if not bestItem then
        return false
    end

    actionInformation.PurchaseItem = bestItem.ItemName
    actionInformation.PurchaseItemPriority = bestItem.ItemPriority
    actionInformation.PurchaseShopType = bestItem.ShopType
    actionInformation.PurchaseShopPosition = bestItem.Shop:GetPosition()
    actionInformation.PurchaseItemCost = bestItem.ItemCost

    unit.ShopInformation.BuyItem[action.ActionName] = actionInformation
    unit.ShopInformation.CanBuyItem[action.ActionName] = true

    --if (unit:GetArmy() == 1) then
    --   LOG('*AI SHOP DEBUG: ' .. action.ActionName .. 'Status - Upgrade = ' .. bestItem.ItemName
    --       .. ' - ItemPriority = ' .. bestItem.ItemPriority)
    --end

    return true
end

function PurchaseCitadelUpgradeAction(unit, action)
    local aiBrain = unit:GetAIBrain()

    local bestItem = FindBestCitadelUpgrade( unit, aiBrain, action )
    if not bestItem then
        return
    end

    --if (unit:GetArmy() == 1) then
    --   WARN('*AI SHOP DEBUG: Army= ' .. unit:GetArmy() .. ' - Purchasing item= ' .. bestItem.ItemName
    --       .. ' - Priority= ' .. bestItem.ItemPriority
    --       .. ' - Quantity= ' .. bestItem.NumPurchase .. '\n\n' )
    --end

    if(PurchaseCitadelUpgrade(unit, bestItem.ItemName) == 'Stuck') then
        action:LockAction(2)
    end

    ShopCleanup(unit, action)

    unit.GOAP:ForcePurchaseUpdate()
end

function FindBestCitadelUpgrade(unit, aiBrain, action)
    local bestValue = 0
    local bestItems = {}
    local shop = aiBrain:GetStronghold()

    local asset = action.StrategicAsset
    if not asset or not asset.CitadelUpgradePriorities or not shop then
        return false
    end

    local highestPriority = false

    --Mithy: New save-for-upgrade method that only runs once per shopping check
    local savingForUpgrade, savingForCost = AIGlobals.SaveForUpgrade(unit, aiBrain)

    for _,itemData in asset.CitadelUpgradePriorities do
        local purchaseQuantity = 1
        local currentPriority = 0

        if itemData.Priority <= 0 then
            continue
        end

        --If we have a highest priority and this next item won't be higher; break the loop
        if highestPriority and (itemData.Priority) < highestPriority then
            break
        end

        if ValidateUpgrade.CanPickUpgrade(Upgrades.Tree, unit, aiBrain.Score.WarRank, itemData.ItemTable.ItemId) != true then
            continue
        end

        --Mithy: New save-for logic that runs after CanPickUpgrade and takes into account item cost mods
        --Are we saving, and is this what we're saving for?
        if savingForUpgrade and savingForUpgrade ~= itemData.ItemTable.ItemId then
            --If saving, do we have enough excess gold to purchase this?
            if aiBrain.mGold - (savingForCost * (unit.Sync.ItemCostMod or 1)) < (itemData.ItemTable.ItemCost * (unit.Sync.ItemCostMod or 1)) then
                continue
            end
        end

        highestPriority = itemData.Priority

        table.insert( bestItems, { ItemName = itemData.ItemTable.ItemId, ShopType = itemData.ItemTable.ShopType,
            Shop = shop, ItemCost = itemData.ItemTable.ItemCost, ItemPriority = highestPriority } )
    end

    if table.getn( bestItems ) > 0 then
        return bestItems[ Random( 1, table.getn(bestItems) ) ]
    end

    return false
end

function PurchaseCitadelUpgrade(unit, upgradeName)
    if not ValidateUpgrade.CanPickUpgrade(Upgrades.Tree, unit, unit:GetAIBrain().Score.WarRank, upgradeName) then
        return false
    end

    if unit.Sync.ShopId and not ShopCleanup(unit) then
        return false
    end

    local aiBrain = unit:GetAIBrain()
    local shop = aiBrain:GetStronghold()
    if VDist3XZSq( unit.Position, shop.Position ) > 200 then
        local cmd = MoveToShop( unit, shop, aiBrain )
        while VDist3XZSq( unit.Position, shop.Position ) > 200 do
        WaitTicks(6)

            if unit:IsDead() or shop:IsDead() then
                return false
            end
        end
    end

    --Go to the shop
    local commandData = {
        TaskName = 'BeginShopTask',
        TargetId = shop:GetEntityId(),
    }
    local cmd = IssueScript( {unit}, commandData )

    local oldPos = table.copy( unit:GetPosition() )
    local stuckCount = 0

    --Wait until we are in the shop
    while not shop:CheckShopper(unit) do
        WaitTicks(6)

        if unit:IsDead() or shop:IsDead() then
            return
        end

        local newPos = unit:GetPosition()
        if newPos[1] == oldPos[1] and newPos[2] == oldPos[2] and newPos[3] == oldPos[3] then
            stuckCount = stuckCount + 1
        else
            stuckCount = 0
        end

        if stuckCount >= 10 then
            LOG('*AI DEBUG: Unit Stuck getting to shop - PurchaseCitadelUpgrade')
            return 'Stuck'
        end

        oldPos = table.copy(newPos)
    end

    --Purchase the upgrade

    local result = import('/lua/sim/upgradesys.lua').HandleUpgrade(unit, upgradeName)
    WaitTicks(6)


    if(result) then
        local announcement = LOCF(AIChatGlobals.Named.PurchasingUpgrade, ArmyBonuses[upgradeName].DisplayName)
        AIUtils.AIChat(unit, announcement)
    end

    return result
end