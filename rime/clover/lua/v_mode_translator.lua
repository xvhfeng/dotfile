-- 显示 V 临时半角模式中即将上屏的原始内容。

local function translator(input, segment)
    if not segment:has_tag("v_mode") or input:sub(1, 1) ~= "v" then
        return
    end

    local text = input:sub(2)
    if text ~= "" then
        yield(Candidate("v_mode", segment.start, segment._end, text, "〔半角〕"))
    end
end

return translator
