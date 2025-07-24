local M = {}

function M.buffer_to_string(buffer)
	local content = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
	return table.concat(content, "\n")
end

function M.trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function M.err(msg)
	vim.notify(
		"[ERROR] " .. msg,
		vim.log.levels.ERROR
	)
end

function M.file_exists(path)
	local f = io.open(path, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

-- @param fargs array
-- @param allowed_params array
--
-- Used to parse user command arguments
-- Checks for allowed stuff
-- Example:
--	fargs: {'fqdn=localhost','flow_delete=false','fake_param=james'}
--	allowed_params: {'fqdn', 'flow_delete'}
--	return: {'fqdn': 'localhost', 'flow_delete':'false'}
function M.parse_kv_params(fargs, allowed_params)
	local params = {}

	local k, v
	for _, value in ipairs(fargs) do
		-- split at first `=`
		k, v = value:match("^([^=]+)=(.*)")

		for _, allowed in ipairs(allowed_params) do
			if allowed == k then
				params[allowed] = v
			end
		end
	end

	return params
end

function M.destroy_last_result_windows()
	if not NvimVeloState.last_stdout_window or not NvimVeloState.last_stderr_window then
		return
	end

	if vim.api.nvim_win_is_valid(NvimVeloState.last_stdout_window) then
		vim.api.nvim_win_close(NvimVeloState.last_stdout_window, true) -- force=true
	end

	if vim.api.nvim_win_is_valid(NvimVeloState.last_stderr_window) then
		vim.api.nvim_win_close(NvimVeloState.last_stderr_window, true) -- force=true
	end
end

function M.open_result_window(text, options)
	options = options or {}

	if not options.hl then
		options.hl = "text"
	end

	local buffer = vim.api.nvim_create_buf(false, true) -- listed=false, scratch=true

	local window
	local split
	if options.direction == "vertical" then
		split = 'left'
	else
		split = 'below'
	end

	window = vim.api.nvim_open_win(buffer, true, {
		split = split,
		win = 0
	})

	vim.api.nvim_paste(M.trim(text) or "", false, -1)
	vim.cmd("set syntax=" .. options.hl)

	return window, buffer
end

return M
