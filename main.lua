local CurseController = RegisterMod("Curse Controller", 1)

local msgTimerDuration = 300

local hadCurse = false
local msgTimer = msgTimerDuration

local function printText(text, x, y)
    Isaac.RenderText(text, x, y, 1, 1, 1, 255)
end

function CurseController:onPostCurseEval(curses)
    hadCurse = false
    msgTimer = msgTimerDuration

    if curses == LevelCurse.CURSE_NONE then
        return curses
    end

    if (curses | LevelCurse.CURSE_OF_BLIND) == LevelCurse.CURSE_OF_BLIND then
        hadCurse = true
        return curses & ~LevelCurse.CURSE_OF_BLIND
    end

    return curses
end
CurseController:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, CurseController.onPostCurseEval)

function CurseController:onRender(t)
    hadCurse = true
    if hadCurse and msgTimer > 0 then
        printText("Curse of the Blind was removed", 10, 250)
        msgTimer = msgTimer - 1
    end
end
CurseController:AddCallback(ModCallbacks.MC_POST_RENDER, CurseController.onRender)
