CurseController = RegisterMod("Curse Controller", 1)
CurseController.version = 1.0

include("config")
CurseController.Config = CurseController:loadConfig()

function CurseController:IsDebugMode()
    return CurseController.Config["999"].enabled
end

function CurseController:SetDebugMode(b)
    CurseController.Config["999"].enabled = b
end

include("mcm")

CurseController.textRenders = {}
local minY = 50
local maxY = 200
local nextY = minY

local function getNextRenderY()
    if next(CurseController.textRenders, nil) == nil then
        nextY = minY
    end

    local currentY = nextY
    nextY = nextY + 10

    if nextY > maxY then
        nextY = minY
    end

    return currentY
end

local sendChallengeModeNotification = true

function CurseController:onPostPlayerInit(curses)
    Isaac.ConsoleOutput("[CurseController] onPostPlayerInit\n")
    sendChallengeModeNotification = true
end
CurseController:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, CurseController.onPostPlayerInit)

function CurseController:onPostCurseEval(curses)
    if Isaac:GetChallenge() ~= 0 then
        CurseController:renderText("Can't change curses while doing challenges")
        sendChallengeModeNotification = false
        return curses
    end
    Isaac.ConsoleOutput("[CurseController] onPostCurseEval\n")

    for k, curseConfig in pairs(CurseController.Config) do
        local curseId = tonumber(k)

        if curseConfig.forced and curseConfig.enabled and (curses & curseId) ~= curseId then
            curses = curses | curseId
            Isaac.ConsoleOutput("[CurseController] Added " .. curseConfig.name .. "\n")
            CurseController:renderText("Added " .. curseConfig.name)
        end

        if not curseConfig.enabled and (curses & curseId) == curseId then
            curses = curses & ~curseId
            Isaac.ConsoleOutput("[CurseController] Removed " .. curseConfig.name .. "\n")
            CurseController:renderText("Removed " .. curseConfig.name)
        end
    end

    return curses
end
CurseController:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, CurseController.onPostCurseEval)

local function printText(text, x, y)
    Isaac.RenderText(text, x, y, 1, 1, 1, 255)
end

function CurseController:renderText(text)
    if not CurseController:IsDebugMode() then
        return
    end
    table.insert(CurseController.textRenders, { text = text, time = 300, y = getNextRenderY() })
end

function CurseController:onRender(t)
    if not CurseController:IsDebugMode() then
        return
    end

    for index, toRender in pairs(CurseController.textRenders) do
        printText(toRender.text, 70, toRender.y)
        toRender.time = toRender.time - 1
        if toRender.time < 0 then
            table.remove(CurseController.textRenders, index)
        end
    end
end
CurseController:AddCallback(ModCallbacks.MC_POST_RENDER, CurseController.onRender)
