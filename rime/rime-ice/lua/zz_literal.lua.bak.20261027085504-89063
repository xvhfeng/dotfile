-- 用 zz…zz 包裹 ASCII 字串，结束时生成一个原样候选。
local processor = {}
local translator = {}

local key_to_literal = {
  space = ' ', exclam = '!', quotedbl = '"', numbersign = '#', dollar = '$',
  percent = '%', ampersand = '&', apostrophe = "'", parenleft = '(', parenright = ')',
  asterisk = '*', plus = '+', comma = ',', minus = '-', period = '.', slash = '/',
  colon = ':', semicolon = ';', less = '<', equal = '=', greater = '>', question = '?',
  at = '@', bracketleft = '[', backslash = '\\', bracketright = ']', asciicircum = '^',
  underscore = '_', grave = '`', braceleft = '{', bar = '|', braceright = '}', asciitilde = '~',
}

local function encode(text)
  return (text:gsub('.', function(char)
    return string.format('%02X', string.byte(char))
  end))
end

local function decode(hex)
  return (hex:gsub('(%x%x)', function(byte)
    return string.char(tonumber(byte, 16))
  end))
end

local function refresh_candidate(context, state, text)
  context:clear()
  context:push_input('zZ' .. state .. encode(text))
end

local function append_key(buffer, key_name)
  local literal = key_to_literal[key_name] or key_name:match('^[A-Za-z0-9]$')
  if literal then
    return buffer .. literal
  end
  return nil
end

local function parse_state(input)
  local state, encoded = input:match('^zZ([0-4])([0-9A-F]*)$')
  if not state then
    return nil, nil
  end
  if #encoded % 2 ~= 0 then
    return nil, nil
  end
  return state, decode(encoded)
end

function processor.func(key, env)
  if key:release() or key:ctrl() or key:alt() or key:super() then
    return 2 -- kNoop
  end

  local context = env.engine.context
  local key_name = key:repr()
  local state, buffer = parse_state(context.input)

  if not state then
    if context.input == '' and key_name == 'z' then
      refresh_candidate(context, '0', '')
      return 1 -- kAccepted
    end
    return 2 -- kNoop
  end

  if key_name == 'Escape' then
    context:clear()
    return 1 -- kAccepted
  end

  if key_name == 'BackSpace' then
    if state == '0' then
      context:clear()
    elseif state == '1' then
      refresh_candidate(context, '0', '')
    elseif state == '2' then
      if buffer == '' then
        refresh_candidate(context, '1', '')
      else
        refresh_candidate(context, '2', buffer:sub(1, -2))
      end
    elseif state == '3' then
      refresh_candidate(context, '2', buffer)
    elseif state == '4' then
      refresh_candidate(context, '3', buffer)
    else
      context:clear()
    end
    return 1 -- kAccepted
  end

  if state == '0' then
    if key_name == 'z' then
      refresh_candidate(context, '1', '')
      return 1 -- kAccepted
    end
    -- 单独的 z 不是字串模式，把它交还给拼音输入。
    context:clear()
    context:push_input('z')
    return 2 -- kNoop
  end

  if state == '1' or state == '2' then
    if key_name == 'z' then
      refresh_candidate(context, '3', buffer)
      return 1 -- kAccepted
    end
    local updated = append_key(buffer, key_name)
    if updated then
      refresh_candidate(context, '2', updated)
      return 1 -- kAccepted
    end
    return 1 -- kAccepted
  end

  if state == '3' then
    if key_name == 'z' then
      refresh_candidate(context, '4', buffer)
      return 1 -- kAccepted
    end
    local updated = append_key(buffer .. 'z', key_name)
    if updated then
      refresh_candidate(context, '2', updated)
      return 1 -- kAccepted
    end
    return 1 -- kAccepted
  end

  -- 状态 4 是最终候选，交由 selector/editor 处理。
  return 2 -- kNoop
end

function translator.func(input, seg, _)
  local payload = input:match('^zZ([0-9A-F]+)$')
  if not payload then
    return
  end
  local state = payload:sub(1, 1)
  local encoded = payload:sub(2)
  if #encoded % 2 ~= 0 then
    return
  end
  if state == '0' then
    yield(Candidate('zz_literal', seg.start, seg._end, 'z', ' 〔字串〕'))
  elseif state == '1' then
    yield(Candidate('zz_literal', seg.start, seg._end, 'zz', ' 〔字串〕'))
  elseif state == '2' then
    yield(Candidate('zz_literal', seg.start, seg._end, 'zz' .. decode(encoded), ' 〔字串〕'))
  elseif state == '3' then
    yield(Candidate('zz_literal', seg.start, seg._end, 'zz' .. decode(encoded) .. 'z', ' 〔字串〕'))
  elseif state == '4' then
    yield(Candidate('zz_literal', seg.start, seg._end, decode(encoded), ' 〔字串〕'))
  end
end

return { processor = processor, translator = translator }
