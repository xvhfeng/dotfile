-- V 开头的临时半角英文模式。
-- 输入 vhello@example.com，按回车上屏 hello@example.com。

local processor = {}

local kAccepted = 1
local kNoop = 2

local shifted = {
    ["1"] = "!", ["2"] = "@", ["3"] = "#", ["4"] = "$", ["5"] = "%",
    ["6"] = "^", ["7"] = "&", ["8"] = "*", ["9"] = "(", ["0"] = ")",
    ["-"] = "_", ["="] = "+", ["["] = "{", ["]"] = "}", ["\\"] = "|",
    [";"] = ":", ["'"] = '"', [","] = "<", ["."] = ">", ["/"] = "?",
    ["`"] = "~",
}

local function printable_ascii(key)
    if key:release() or key:ctrl() or key:alt() or key:super() then
        return nil
    end

    local code = key.keycode
    if code < 0x20 or code > 0x7e then
        return nil
    end

    local char = string.char(code)
    if not key:shift() then
        return char
    end
    if char:match("%l") then
        return char:upper()
    end
    return shifted[char] or char
end

function processor.func(key, env)
    local engine = env.engine
    local context = engine.context

    -- 英文模式保持鼠须管原本的行为。
    if context:get_option("ascii_mode") then
        return kNoop
    end

    local input = context.input
    local active = input:sub(1, 1) == "v"

    if not active then
        local char = printable_ascii(key)
        if input == "" and char == "v" then
            context:push_input("v")
            return kAccepted
        end
        return kNoop
    end

    local repr = key:repr()
    if repr == "Return" or repr == "KP_Enter" then
        local text = input:sub(2)
        if text ~= "" then
            engine:commit_text(text)
        end
        context:clear()
        return kAccepted
    elseif repr == "BackSpace" then
        if #input <= 1 then
            context:clear()
        else
            context:pop_input(1)
        end
        return kAccepted
    elseif repr == "Escape" then
        context:clear()
        return kAccepted
    end

    local char = printable_ascii(key)
    if char then
        context:push_input(char)
        return kAccepted
    end

    -- Command/Control/Option 快捷键继续交给系统和后续处理器。
    return kNoop
end

return processor
