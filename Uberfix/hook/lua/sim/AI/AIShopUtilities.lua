--Mithy: Fix for AI inability to purchase citadel upgrades without a same-name buff
for upgradeId, upgradeData in Upgrades.Tree do
    if not Buffs[upgradeId] then
        --Create a dummy buff with this upgrade's name - this buff will never be
        --applied, only checked for existence by GetUpgradesList
        LOG("Uberfix - AIShopUtilities: Creating dummy buff '"..upgradeId.."'")
        BuffBlueprint {
            Name = upgradeId,
            BuffType = 'DUMMYBUFF_'..upgradeId,
            Debuff = false,
            Affects = {
                Dummy = {Add = 0},
            },
        }
    end
end