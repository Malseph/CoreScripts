require("patterns")
jsonInterface = require("jsonInterface")
tableHelper = require("tableHelper")
local BaseCell = require("cell.base")

local Cell = class("Cell", BaseCell)

function Cell:__init(cellDescription)
    BaseCell.__init(self, cellDescription)

    -- Replace characters not allowed in filenames
    self.cellFile = cellDescription
    self.cellFile = string.gsub(self.cellFile, ":", ";")
    self.cellFile = string.gsub(self.cellFile, patterns.invalidFileCharacters, "_")
    self.cellFile = tes3mp.GetCaseInsensitiveFilename(os.getenv("MOD_DIR").."/cell/", self.cellFile .. ".json")

    if self.cellFile == "invalid" then
        self.hasEntry = false
    else
        self.hasEntry = true
    end
end

function Cell:CreateEntry()
    jsonInterface.save("cell/" .. self.cellFile, self.data)
    self.hasEntry = true
end

function Cell:Save()
    if self.hasEntry then
        tableHelper.cleanNils(self.data.packets)
        jsonInterface.save("cell/" .. self.cellFile, self.data)
    end
end

function Cell:Load()
    self.data = jsonInterface.load("cell/" .. self.cellFile)

    -- JSON doesn't allow numerical keys, but we use them, so convert
    -- all string number keys into numerical keys
    tableHelper.fixNumericalKeys(self.data)
end

return Cell
