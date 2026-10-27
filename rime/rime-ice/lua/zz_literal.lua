-- 用 zv…zv 包裹 ASCII 字串，结束时生成一个原样候选。
local processor = {}
local translator = {}

local key_to_literal = {
  space = ' ', exclam = '!', quotedbl = '"', numbersign = '#', dollar = '$',
  percent = '%', ampersand = '&', apostrophe = "'", parenleft = '(', parenright = ')',
  asterisk = '*', plus = '+', comma = ',', minus = '-', period = '.', slash = '/',
  colon = ':', semicolon = ';', less = '<', equal = '=', greater = '>', question = '?',
  at = '@', bracketleft = '[', backslash = string.char(92), bracketright = ']', asciicircum = '^',
  underscore = '_', grave = '`', quoteleft = '`', quoteright = "'",
  braceleft = '{', bar = '|', braceright = '}', asciitilde = '~',
  KP_Decimal = '.', KP_Add = '+', KP_Subtract = '-', KP_Multiply = '*',
  KP_Divide = '/', KP_Equal = '=',
}

local shifted_literal = {
  ['1'] = '!', ['2'] = '@', ['3'] = '#', ['4'] = '$', ['5'] = '%',
  ['6'] = '^', ['7'] = '&', ['8'] = '*', ['9'] = '(', ['0'] = ')',
  minus = '_', equal = '+', bracketleft = '{', bracketright = '}',
  backslash = '|', semicolon = ':', apostrophe = '"', quoteright = '"',
  comma = '<', period = '>', slash = '?', grave = '~', quoteleft = '~',
}

local function encode(text)
  return (text:gsub('.', function(char) return string.format('%02X', string.byte(char)) end))
end

local function decode(hex)
  return (hex:gsub('(%x%x)', function(byte) return string.char(tonumber(byte, 16)) end))
end

local function refresh_candidate(context, state, text)
  context:clear()
  context:push_input('zZ' .. state .. encode(text))
end

local function append_key(buffer, key_name)
  local shifted = key_name:match('^Shift%+(.+)$')
  if shifted then key_name = shifted end
  local literal = (shifted and shifted_literal[key_name]) or key_to_literal[key_name]
    or key_name:match('^[A-Za-z0-9]$') or key_name:match('^KP_([0-9])$')
  if shifted and literal and literal:match('^[a-z]$') then literal = literal:upper() end
  return literal and buffer .. literal or nil
end

local function parse_state(input)
  local state, encoded = input:match('^zZ([0-4])([0-9A-F]*)$')
  if not state or #encoded % 2 ~= 0 then return nil, nil end
  return state, decode(encoded)
end

function processor.func(key, env)
  if key:release() or key:ctrl() or key:alt() or key:super() then return 2 end
  local context = env.engine.context
  local key_name = key:repr()
  local state, buffer = parse_state(context.input)

  if not state then
    if context.input == 'z' and key_name == 'v' then
      context:clear()
      refresh_candidate(context, '1', '')
      return 1
    end
    return 2
  end
  if key_name == 'Escape' then context:clear(); return 1 end
  if state ~= '4' and (key_name == 'Return' or key_name == 'KP_Enter') then
    local text = state == '3' and 'zv' .. buffer .. 'z' or 'zv' .. buffer
    env.engine:commit_text(text)
    context:clear()
    return 1
  end

  if key_name == 'BackSpace' then
    if state == '1' then
      context:clear(); context:push_input('z')
    elseif state == '2' then
      if #buffer <= 1 then refresh_candidate(context, '1', '')
      else refresh_candidate(context, '2', buffer:sub(1, -2)) end
    elseif state == '3' then refresh_candidate(context, '2', buffer)
    elseif state == '4' then refresh_candidate(context, '3', buffer)
    end
    return 1
  end

  if state == '1' or state == '2' then
    if key_name == 'z' then refresh_candidate(context, '3', buffer); return 1 end
    local updated = append_key(buffer, key_name)
    if updated then refresh_candidate(context, '2', updated) end
    return 1
  end

  if state == '3' then
    if key_name == 'v' then refresh_candidate(context, '4', buffer); return 1 end
    local updated = append_key(buffer .. 'z', key_name)
    if updated then refresh_candidate(context, '2', updated) end
    return 1
  end

  return 2 -- 状态 4 是最终候选，交由 selector/editor 处理。
end

function translator.func(input, seg, _)
  local payload = input:match('^zZ([0-9A-F]+)$')
  if not payload then return end
  local state, encoded = payload:sub(1, 1), payload:sub(2)
  if #encoded % 2 ~= 0 then return end
  local text
  if state == '1' then text = 'zv'
  elseif state == '2' then text = 'zv' .. decode(encoded)
  elseif state == '3' then text = 'zv' .. decode(encoded) .. 'z'
  elseif state == '4' then text = decode(encoded)
  end
  if text then yield(Candidate('zz_literal', seg.start, seg._end, text, ' 〔字串〕')) end
end

return { processor = processor, translator = translator }
