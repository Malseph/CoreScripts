io2 = require("io2")
local json = require ("dkjson");

local jsonInterface = {};

function jsonInterface.load(fileName)
    local home = os.getenv("MOD_DIR") .. "/"
    local file = assert(io2.open(home .. fileName, 'r'), 'Error loading file: ' .. fileName);
    local content = file:read("*a");
    file:close();
    return json.decode(content, 1, nil);
end

function jsonInterface.save(fileName, data, keyOrderArray)
    local home = os.getenv("MOD_DIR") .. "/"
    local content = json.encode(data, { indent = true, keyorder = keyOrderArray });

    if content == nil then
        return
    end
    local file = io2.open(home .. fileName, 'w+b');

    if file ~= nil then
        file:write(content);
        file:close();
        return true
    else
        return false
    end
end

return jsonInterface;
