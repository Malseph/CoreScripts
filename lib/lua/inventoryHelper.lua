local inventoryHelper = {};

function inventoryHelper.containsItem(inventory, refId, charge, soul)
    for itemIndex, item in pairs(inventory) do
        if item.refId == refId then
            if charge == nil or charge == item.charge then
                if soul == nil or string.len(soul) == 0 or soul == item.soul then
                    return true
                end
            end
        end
    end
    return false
end

function inventoryHelper.getItemIndex(inventory, refId, charge, soul)
    for itemIndex, item in pairs(inventory) do
        if item.refId == refId then
            if charge == nil or charge == item.charge then
                if soul == nil or string.len(soul) == 0 or soul == item.soul then
                    return itemIndex
                end
            end
        end
    end
    return nil
end

return inventoryHelper
