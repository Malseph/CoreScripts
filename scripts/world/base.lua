stateHelper = require("stateHelper")
local BaseWorld = class("BaseWorld")

function BaseWorld:__init(test)

    self.data =
    {
        general = {
            currentMpNum = 0,
            currentDynamicRecordNum = 0
        },
        journal = {},
        factionRanks = {},
        factionExpulsion = {},
        factionReputation = {},
        topics = {},
        kills = {},
        customVariables = {}
    };
end

function BaseWorld:HasEntry()
    return self.hasEntry
end

function BaseWorld:GetCurrentMpNum()
    return self.data.general.currentMpNum
end

function BaseWorld:SetCurrentMpNum(currentMpNum)
    self.data.general.currentMpNum = currentMpNum
    self:Save()
end

function BaseWorld:SaveJournal(pid)
    stateHelper:SaveJournal(pid, self)
end

function BaseWorld:SaveFactionRanks(pid)
    stateHelper:SaveFactionRanks(pid, self)
end

function BaseWorld:SaveFactionExpulsion(pid)
    stateHelper:SaveFactionExpulsion(pid, self)
end

function BaseWorld:SaveFactionReputation(pid)
    stateHelper:SaveFactionReputation(pid, self)
end

function BaseWorld:SaveTopics(pid)
    stateHelper:SaveTopics(pid, self)
end

function BaseWorld:SaveKills(pid)

    for i = 0, tes3mp.GetKillChangesSize(pid) - 1 do

        local refId = tes3mp.GetKillRefId(pid, i)
        local number = tes3mp.GetKillNumber(pid, i)
        self.data.kills[refId] = number
    end

    self:Save()
end

function BaseWorld:LoadJournal(pid)
    stateHelper:LoadJournal(pid, self)
end

function BaseWorld:LoadFactionRanks(pid)
    stateHelper:LoadFactionRanks(pid, self)
end

function BaseWorld:LoadFactionExpulsion(pid)
    stateHelper:LoadFactionExpulsion(pid, self)
end

function BaseWorld:LoadFactionReputation(pid)
    stateHelper:LoadFactionReputation(pid, self)
end

function BaseWorld:LoadTopics(pid)
    stateHelper:LoadTopics(pid, self)
end

function BaseWorld:LoadKills(pid)

    tes3mp.InitializeKillChanges(pid)

    for refId, number in pairs(self.data.kills) do

        tes3mp.AddKill(pid, refId, number)
    end

    tes3mp.SendKillChanges(pid)
end

function BaseWorld:LoadDynamicRecords(pid)
    tes3mp.InitializeDynamicRecordChanges(pid)

    for index, record in pairs(dynamicRecords.data.records) do
        if record ~= nil then
            local recordIndex = tes3mp.AddDynamicRecord(pid, record.refId, record.type)

            if record.type == 0 and record.spell ~= nil then
                tes3mp.AddCustomSpell(pid, recordIndex, record.spell.name)
                tes3mp.AddCustomSpellData(pid, recordIndex, record.spell.data.type, record.spell.data.cost, record.spell.data.flags)
                for effectIndex, effect in pairs(record.spell.effects) do
                    tes3mp.AddCustomSpellEffect(pid, recordIndex, effect.effectId, effect.skill, effect.attribute, effect.range, effect.area, effect.duration, effect.magnMin, effect.magnMax)
                end
            end

            if record.type == 1 and record.potion ~= nil then
                tes3mp.AddCustomPotion(pid, recordIndex, record.potion.name, record.potion.model, record.potion.icon, record.potion.script)
                tes3mp.AddCustomPotionData(pid, recordIndex, record.potion.data.weight, record.potion.data.value, record.potion.data.autocalc)
                for effectIndex, effect in pairs(record.potion.effects) do
                    tes3mp.AddCustomPotionEffect(pid, recordIndex, effect.effectId, effect.skill, effect.attribute, effect.range, effect.area, effect.duration, effect.magnMin, effect.magnMax)
                end
            end

            if record.type == 2 and record.enchantment ~= nil then
                tes3mp.AddCustomEnchantment(pid, recordIndex)
                tes3mp.AddCustomEnchantmentContext(pid, recordIndex, record.enchantmentContext.itemType, record.enchantmentContext.gemCharge, record.enchantmentContext.oldItemRefId, record.enchantmentContext.newItemRefId, record.enchantmentContext.newItemName)
                tes3mp.AddCustomEnchantmentData(pid, recordIndex, record.enchantment.data.type, record.enchantment.data.charge, record.enchantment.data.autocalc, record.enchantment.data.cost)
                for effectIndex, effect in pairs(record.enchantment.effects) do
                    tes3mp.AddCustomEnchantmentEffect(pid, recordIndex, effect.effectId, effect.skill, effect.attribute, effect.range, effect.area, effect.duration, effect.magnMin, effect.magnMax)
                end
            end
        end
    end

    tes3mp.SendDynamicRecordChanges(pid)
end

function BaseWorld:SaveDynamicRecords(pid, playerData)
    local spellIdsToAdd = {}
    local potionIdsToAdd = {}
    local enchantedItemsToAdd = {}

    for i = 0, tes3mp.GetDynamicRecordChangesSize(pid) - 1 do
        local record = {}
        record.refId = "$mpdynamic" ..  self.data.general.currentDynamicRecordNum
        self.data.general.currentDynamicRecordNum = self.data.general.currentDynamicRecordNum + 1
        tes3mp.SetDynamicRecordRefId(pid, i, record.refId)

        local type = tes3mp.GetDynamicRecordType(pid, i)
        record.type = type

        --SPELL
        if type == 0 then
            table.insert(spellIdsToAdd, record.refId)
            record.spell = {}
            record.spell.name = tes3mp.GetSpellName(pid, i)
            record.spell.refId = record.refId

            record.spell.data = {}
            record.spell.data.type = tes3mp.GetSpellType(pid, i)
            record.spell.data.cost = tes3mp.GetSpellCost(pid, i)
            record.spell.data.flags = tes3mp.GetSpellFlags(pid, i)

            record.spell.effects = {}

            for j = 0, tes3mp.GetSpellEffectCount(pid, i) - 1 do
                local newEffect = {}

                newEffect.effectId = tes3mp.GetSpellEffectId(pid, i, j)
                newEffect.skill = tes3mp.GetSpellEffectSkill(pid, i, j)
                newEffect.attribute = tes3mp.GetSpellEffectAttribute(pid, i, j)
                newEffect.range = tes3mp.GetSpellEffectRange(pid, i, j)
                newEffect.area = tes3mp.GetSpellEffectArea(pid, i, j)
                newEffect.duration = tes3mp.GetSpellEffectDuration(pid, i, j)
                newEffect.magnMin = tes3mp.GetSpellEffectMagnMin(pid, i, j)
                newEffect.magnMax = tes3mp.GetSpellEffectMagnMax(pid, i, j)

                table.insert(record.spell.effects, newEffect)
            end
        end

        --POTION
        if type == 1 then
            table.insert(potionIdsToAdd, record.refId)
            record.potion = {}
            record.potion.name = tes3mp.GetPotionName(pid, i)
            record.potion.model = tes3mp.GetPotionModel(pid, i)
            record.potion.icon = tes3mp.GetPotionIcon(pid, i)
            record.potion.script = tes3mp.GetPotionScript(pid, i)
            record.potion.refId = record.refId

            record.potion.data = {}
            record.potion.data.weight = tes3mp.GetPotionWeight(pid, i)
            record.potion.data.value = tes3mp.GetPotionValue(pid, i)
            record.potion.data.autocalc = tes3mp.GetPotionAutoCalc(pid, i)
            record.potion.effects = {}

            for j = 0, tes3mp.GetPotionEffectCount(pid, i) - 1 do
                local newEffect = {}

                newEffect.effectId = tes3mp.GetPotionEffectId(pid, i, j)
                newEffect.skill = tes3mp.GetPotionEffectSkill(pid, i, j)
                newEffect.attribute = tes3mp.GetPotionEffectAttribute(pid, i, j)
                newEffect.range = tes3mp.GetPotionEffectRange(pid, i, j)
                newEffect.area = tes3mp.GetPotionEffectArea(pid, i, j)
                newEffect.duration = tes3mp.GetPotionEffectDuration(pid, i, j)
                newEffect.magnMin = tes3mp.GetPotionEffectMagnMin(pid, i, j)
                newEffect.magnMax = tes3mp.GetPotionEffectMagnMax(pid, i, j)

                table.insert(record.potion.effects, newEffect)
            end
        end

        --ENCHANTMENT
        if type == 2 then
            record.enchantment = {}

            record.enchantment.refId = record.refId

            record.enchantment.data = {}
            record.enchantment.data.charge = tes3mp.GetEnchantmentCharge(pid, i)
            record.enchantment.data.cost = tes3mp.GetEnchantmentCost(pid, i)
            record.enchantment.data.autocalc = tes3mp.GetEnchantmentAutoCalc(pid, i)
            record.enchantment.data.type = tes3mp.GetEnchantmentType(pid, i)

            record.enchantmentContext = {}
            record.enchantmentContext.itemType = tes3mp.GetEnchantmentContextItemType(pid, i)
            record.enchantmentContext.oldItemRefId = tes3mp.GetEnchantmentContextOldItemRefId(pid, i)
            record.enchantmentContext.newItemName = tes3mp.GetEnchantmentContextNewItemName(pid, i)
            record.enchantmentContext.newItemRefId = "$mpdynamic" .. self.data.general.currentDynamicRecordNum
            self.data.general.currentDynamicRecordNum = self.data.general.currentDynamicRecordNum + 1
            record.enchantmentContext.gemCharge = tes3mp.GetEnchantmentContextGemCharge(pid, i)
			
			tes3mp.SetEnchantmentContextNewItemRefId(pid, i, record.enchantmentContext.newItemRefId)

			table.insert(enchantedItemsToAdd, record.enchantmentContext.newItemRefId)

            record.enchantment.effects = {}

            for j = 0, tes3mp.GetEnchantmentEffectCount(pid, i) - 1 do
                local newEffect = {}

                newEffect.effectId = tes3mp.GetEnchantmentEffectId(pid, i, j)
                newEffect.skill = tes3mp.GetEnchantmentEffectSkill(pid, i, j)
                newEffect.attribute = tes3mp.GetEnchantmentEffectAttribute(pid, i, j)
                newEffect.range = tes3mp.GetEnchantmentEffectRange(pid, i, j)
                newEffect.area = tes3mp.GetEnchantmentEffectArea(pid, i, j)
                newEffect.duration = tes3mp.GetEnchantmentEffectDuration(pid, i, j)
                newEffect.magnMin = tes3mp.GetEnchantmentEffectMagnMin(pid, i, j)
                newEffect.magnMax = tes3mp.GetEnchantmentEffectMagnMax(pid, i, j)

                table.insert(record.enchantment.effects, newEffect)
            end
        end

        table.insert(dynamicRecords.data.records, record)
    end

			   

    --send out dynamic record addition to all players
    tes3mp.SendDynamicRecordChanges(pid, true)

    --add spell(s) to sender
    if(table.getn(spellIdsToAdd) > 0) then
        tes3mp.InitializeSpellbookChanges(pid)
        tes3mp.SetSpellbookChangesAction(pid, actionTypes.spellbook.ADD)
        for key, value in pairs(spellIdsToAdd) do
            tes3mp.AddSpell(pid, value)
			
			local newSpell = {}
            newSpell.spellId = value
            table.insert(playerData.spellbook, newSpell)
        end
        tes3mp.SendSpellbookChanges(pid)
    end

    --add potion(s) to sender
    if(table.getn(potionIdsToAdd) > 0) then
        tes3mp.InitializeInventoryChanges(pid)
        for key, value in pairs(potionIdsToAdd) do
            tes3mp.AddItem(pid, value, 1, -1, -1, -1)
        end
        tes3mp.SendInventoryChanges(pid)
    end

    --add enchanted item(s) to sender
    if(table.getn(enchantedItemsToAdd) > 0) then
        tes3mp.InitializeInventoryChanges(pid)
        for key, value in pairs(enchantedItemsToAdd) do
            tes3mp.AddItem(pid, value, 1, -1, -1, -1)
        end
        tes3mp.SendInventoryChanges(pid)
    end
end

return BaseWorld
