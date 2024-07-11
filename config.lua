CurseController.DefaultConfig = {
    [1] = { name = "Curse of Darkness", enabled = true, forced = false },
    [2] = { name = "Curse of the Labyrinth", enabled = true, forced = false },
    [4] = { name = "Curse of the Lost", enabled = true, forced = false },
    [8] = { name = "Curse of the Unknown", enabled = true, forced = false },
    [16] = { name = "Curse of the Cursed", enabled = true, forced = false },
    [32] = { name = "Curse of the Maze", enabled = true, forced = false },
    [64] = { name = "Curse of the Blind", enabled = true, forced = false },
    [128] = { name = "Curse of the Giant", enabled = true, forced = false },
    [999] = {name = "Show curse add / remove messages", enabled = false, forced = false}
}

local function encode(config)
    local str = 'curseId,name,enabled,forced\n'
    for curseId, curseConfig in pairs(config) do
        str = str .. curseId .. ',' .. curseConfig.name .. ',' .. tostring(curseConfig.enabled) .. "," .. tostring(curseConfig.forced) .. '\n'
    end
    return str
end

local function decode(str)
    local function toboolean(str)
        local map = { ["true"] = true, ["false"] = false }
        return map[str]
    end
    local first = true
    local config = {}
    for line in str:gmatch("([^\n]*)\n?") do
        if not first then
            words = {}
            for word in string.gmatch(line, '([^,]+)') do
                table.insert(words, word)
            end
            config[words[1]] = { name = words[2], enabled = toboolean(words[3]), forced = toboolean(words[4]) }
        else
            first = false
        end
    end
    return config
end

function CurseController:loadConfig()
    if CurseController:HasData() then
        Isaac.ConsoleOutput("[CurseController] Load config from file\n")
        return decode(CurseController:LoadData())
    else
        Isaac.ConsoleOutput("[CurseController] Load from default\n")
        return CurseController:loadDefaultConfig()
    end
end

function CurseController:loadDefaultConfig()
    data = encode(CurseController.DefaultConfig)
    config = decode(data)
    return config
end

function CurseController:saveConfig()
    data = encode(CurseController.Config)
    CurseController:SaveData(data)
end
