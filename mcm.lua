if ModConfigMenu == nil then
    return
end

CurseController.ModConfigMenuLoaded = true

function CurseController:CreateModMenu()
    local modName = CurseController.Name
    ModConfigMenu.RemoveCategory(CurseController.Name)
    CurseController:CreateInfoPage(modName)
    CurseController:CreateenabledPage(modName)
    CurseController:CreateForcedPage(modName)
end

function CurseController:CreateInfoPage(category)
    local tab = "Info"
    ModConfigMenu.AddSpace(category, tab)
    ModConfigMenu.AddText(category, tab, function()
        return category
    end)
    ModConfigMenu.AddText(category, tab, function()
        return "Version " .. CurseController.version
    end)
    ModConfigMenu.AddSpace(category, tab)
    ModConfigMenu.AddText(category, tab, function()
        return "by 123456687548"
    end)
    ModConfigMenu.AddSpace(category, tab)
    ModConfigMenu.AddSetting(
            category,
            tab,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return CurseController:IsDebugMode()
                end,
                Display = function()
                    return "Show curse add / remove messages: " .. (CurseController:IsDebugMode() and "ENABLED" or "DISABLED")
                end,
                OnChange = function(b)
                    CurseController:SetDebugMode(b)
                    CurseController:saveConfig()
                end,
                Info = { "Press SPACE to reset to default settings" }
            }
    )
    ModConfigMenu.AddSetting(
            category,
            tab,
            {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return true
                end,
                Display = function()
                    return ">> RESET <<"
                end,
                OnChange = function(currentBool)
                    CurseController.Config = CurseController:loadDefaultConfig()
                    CurseController:saveConfig()
                    ModConfigMenu:CloseConfigMenu()
                    CurseController:CreateModMenu()
                end,
                Info = { "Press SPACE to reset to default settings" }
            }
    )
end

local function getSortedTableKeys(t)
    local keys = {}

    for k in pairs(t) do
        key = tonumber(k)
        if key < 129 then
            table.insert(keys, key)
        end
    end
    table.sort(keys)
    CurseController.SortedKeys = keys
    return keys
end

function CurseController:CreateenabledPage(category)
    local tab = "Enabled"

    keys = getSortedTableKeys(CurseController.Config)
    for _, curseId in ipairs(keys) do
        if curseId ~= LevelCurse.CURSE_OF_THE_CURSED and curseId ~= LevelCurse.CURSE_OF_GIANT then
            local curseConfig = CurseController.Config[tostring(curseId)]
            ModConfigMenu.AddSetting(
                    category,
                    tab,
                    {
                        Type = ModConfigMenu.OptionType.BOOLEAN,
                        CurrentSetting = function()
                            return curseConfig.enabled
                        end,
                        Display = function()
                            return curseConfig.name .. ": " .. (curseConfig.enabled and "ENABLED" or "DISABLED")
                        end,
                        OnChange = function(b)
                            curseConfig.enabled = b
                            CurseController:saveConfig()
                        end,
                        Info = {
                            "Enabled = Curse can appear on new floors",
                            "enabled = Curse can't appear on new floors",
                        }
                    }
            )
        end
    end
end

function CurseController:CreateForcedPage(category)
    local tab = "Forced"
    ModConfigMenu.AddText(category, tab, function()
        return "enabled curses have priority"
    end)
    ModConfigMenu.AddText(category, tab, function()
        return "over forced curses!"
    end)
    ModConfigMenu.AddSpace(category, tab)

    keys = getSortedTableKeys(CurseController.Config)
    for _, curseId in ipairs(keys) do
        local curseConfig = CurseController.Config[tostring(curseId)]
        ModConfigMenu.AddSetting(
                category,
                tab,
                {
                    Type = ModConfigMenu.OptionType.BOOLEAN,
                    CurrentSetting = function()
                        return curseConfig.forced
                    end,
                    Display = function()
                        return curseConfig.name .. ": " .. (curseConfig.forced and "ENABLED" or "DISABLED")
                    end,
                    OnChange = function(b)
                        curseConfig.forced = b
                        CurseController:saveConfig()
                    end,
                    Info = {
                        "Enabled = Curse always appear on new floors",
                        "enabled = Default behaviour",
                    }
                }
        )
    end
end

CurseController:CreateModMenu()
