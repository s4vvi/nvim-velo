local utils = require("nvim-velo.utils")

local M = {}

function M.assert_vql_ext()
	if vim.o.filetype ~= "vql" then
		utils.err("Can't execute non '*.vql' file.")
		return false
	end
	return true
end

function M.buffer_to_string(buffer)
	local content = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
	return table.concat(content, "\n")
end

function M.destroy_last_result_windows()
	if NvimVeloState.last_stdout_window ~= nil then
		if vim.api.nvim_win_is_valid(NvimVeloState.last_stdout_window) then
			vim.api.nvim_win_close(NvimVeloState.last_stdout_window, true) -- force=true
		end
	end

	if NvimVeloState.last_stderr_window ~= nil then
		if vim.api.nvim_win_is_valid(NvimVeloState.last_stderr_window) then
			vim.api.nvim_win_close(NvimVeloState.last_stderr_window, true) -- force=true
		end
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

	vim.api.nvim_paste(utils.trim(text) or "", false, -1)
	vim.cmd("set syntax=" .. options.hl)

	return window, buffer
end

function M.open_results_success(results, logs)
	local o_w, _ = M.open_result_window(results, { direction = "horizontal", hl = "json"})
	local e_w, _ = M.open_result_window(logs, { direction = "horizontal", hl = "text"})

	NvimVeloState.last_stdout_window = o_w
	NvimVeloState.last_stderr_window = e_w
end

function M.open_results_error(logs)
		local e_w, _ = M.open_result_window(logs, { direction = "horizontal", hl = "text"})

		NvimVeloState.last_stderr_window = e_w
end

return M
