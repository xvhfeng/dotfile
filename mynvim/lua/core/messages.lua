local M = {}

local buffer
local appending = false
local configured = false
local key_logging = false
local namespace = vim.api.nvim_create_namespace("mynvim.messages")
local originals = {}

local function message_buffer()
	if buffer and vim.api.nvim_buf_is_valid(buffer) then
		return buffer
	end

	for _, candidate in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(candidate) == "*Neovim-Messages*" then
			buffer = candidate
			return buffer
		end
	end

	buffer = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(buffer, "*Neovim-Messages*")
	vim.bo[buffer].buftype = "nofile"
	vim.bo[buffer].bufhidden = "hide"
	vim.bo[buffer].swapfile = false
	return buffer
end

local function append_log(kind, message)
	if appending or message == nil or message == "" then
		return
	end

	appending = true
	local ok, err = pcall(function()
		local stamp = os.date("%H:%M:%S")
		local lines = vim.split(tostring(message), "\n", { plain = true })
		for index, line in ipairs(lines) do
			local prefix = index == 1 and string.format("[%s] ", kind) or ""
			lines[index] = string.format("%s%s [%s]", prefix, line, stamp)
		end
		vim.api.nvim_buf_set_lines(message_buffer(), -1, -1, false, lines)
	end)
	appending = false

	if not ok then
		vim.schedule(function()
			vim.api.nvim_err_writeln("Neovim message recorder failed: " .. err)
		end)
	end
end

local function notify_kind(level)
	if level == vim.log.levels.ERROR then
		return "ERROR"
	end
	if level == vim.log.levels.WARN then
		return "WARN"
	end
	return "INFO"
end

local function echo_text(chunks)
	local text = {}
	for _, chunk in ipairs(chunks or {}) do
		table.insert(text, chunk[1] or "")
	end
	return table.concat(text)
end

function M.buffer()
	return message_buffer()
end

function M.setup()
	if configured then
		return
	end
	configured = true
	message_buffer()

	originals.notify = vim.notify
	vim.notify = function(message, level, opts)
		local result = originals.notify(message, level, opts)
		append_log(notify_kind(level), message)
		return result
	end

	originals.print = _G.print
	_G.print = function(...)
		local values = { ... }
		local result = originals.print(...)
		for index, value in ipairs(values) do
			values[index] = tostring(value)
		end
		append_log("PRINT", table.concat(values, "\t"))
		return result
	end

	originals.echo = vim.api.nvim_echo
	vim.api.nvim_echo = function(chunks, history, opts)
		local result = originals.echo(chunks, history, opts)
		append_log("ECHO", echo_text(chunks))
		return result
	end

	vim.api.nvim_create_user_command("OpenMessages", function()
		vim.cmd.sbuffer(message_buffer())
	end, { force = true })

	vim.api.nvim_create_user_command("ClearMessages", function()
		vim.api.nvim_buf_set_lines(message_buffer(), 0, -1, false, {})
	end, { force = true })

	vim.api.nvim_create_user_command("MessagesKeylogToggle", function()
		key_logging = not key_logging
		vim.notify("Message key logging " .. (key_logging and "enabled" or "disabled"))
	end, { force = true })

	vim.on_key(function(key)
		if key_logging then
			append_log("KEY", vim.fn.keytrans(key))
		end
	end, namespace)

	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = function()
			local history = vim.fn.execute("messages")
			if history ~= "" then
				append_log("HISTORY", history)
			end
		end,
	})
end

return M
