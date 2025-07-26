local utils = require("nvim-velo.utils")
local vql = require("nvim-velo.vql")

local M = {}

function M.exec_vql()
	local current_buffer = vim.api.nvim_get_current_buf()
	local current_window = vim.api.nvim_get_current_win()

	if vim.o.filetype ~= "vql" then
		utils.err("Can't execute non '*.vql' file.")
		return
	end

	local obj = vim.system({
		"velociraptor",
		"--api_config",
		NvimVeloConfig.api_config_path,
		"query",
		utils.buffer_to_string(current_buffer),
		"--format",
		"jsonl",
		"-v",
		"--nobanner",
	})
	local result = obj:wait()

	utils.destroy_last_result_windows()

	local o_w, _ = utils.open_result_window(result.stdout, { direction = "horizontal", hl = "json"})
	local e_w, _ = utils.open_result_window(result.stderr, { direction = "horizontal", hl = "text"})

	NvimVeloState.last_stdout_window = o_w
	NvimVeloState.last_stderr_window = e_w

	vim.api.nvim_set_current_win(current_window)
end

function M.exec_client_vql(args)
	local allowed_params = { "fqdn", "flow_delete" }
	local params = utils.parse_kv_params(args.fargs, allowed_params)

	if not NvimVeloConfig.default_client_fqdn and not params.fqdn then
		utils.err("Client FQDN not found (use config or pass via. commandline).")
		return
	end

	if not params.fqdn then
		params.fqdn = NvimVeloConfig.default_client_fqdn
	end

	-- Note: if not specified in config or commandline defaults to true (on init) 
	if params.flow_delete then
		if params.flow_delete == "false" then
			params.flow_delete = false
		elseif params.flow_delete == "true" then
			params.flow_delete = true
		else
			params.flow_delete = NvimVeloConfig.delete_flow_after_exec
		end
	else
		params.flow_delete = NvimVeloConfig.delete_flow_after_exec
	end

	if vim.o.filetype ~= "vql" then
		utils.err("Can't execute non '*.vql' file.")
		return
	end

	local current_buffer = vim.api.nvim_get_current_buf()
	local current_window = vim.api.nvim_get_current_win()

	utils.destroy_last_result_windows()

	local client_id = vql.get_client_id(params.fqdn)
	if not client_id then
		utils.err("Client w/ hostname '" .. params.fqdn .."' not found.")
		return
	end

	local flow = vql.start_flow(
		utils.buffer_to_string(current_buffer),
		client_id
	)

	if not flow or not flow.collection.flow_id then
		utils.err("Failed to start flow, unknown error.")
		return
	end

	local flow_logs = vql.fetch_flow_logs(
		flow.collection.request.client_id,
		flow.collection.flow_id
	)

	local flow_results = vql.fetch_flow_results(
		flow.collection.request.client_id,
		flow.collection.flow_id
	)

	if params.flow_delete then
		vql.delete_flow(
			flow.collection.request.client_id,
			flow.collection.flow_id
		)
	end

	local errored = {}
	local logs_str = ""
	for _, log in ipairs(flow_logs) do
		if log.level == "ERROR" then
			table.insert(errored, log)
		end

		logs_str = logs_str .. string.format(
			"[%s]: %s\n",
			log.level,
			utils.trim(log.message)
		)
	end

	if #errored > 0 then
		local e_w, _ = utils.open_result_window(logs_str, { direction = "horizontal", hl = "text"})
		NvimVeloState.last_stderr_window = e_w
		vim.api.nvim_set_current_win(current_window)
		utils.err("VQL errored.")
		return
	end

	local o_w, _ = utils.open_result_window(flow_results, { direction = "horizontal", hl = "json"})
	local e_w, _ = utils.open_result_window(logs_str, { direction = "horizontal", hl = "text"})

	NvimVeloState.last_stdout_window = o_w
	NvimVeloState.last_stderr_window = e_w

	vim.api.nvim_set_current_win(current_window)
end

return M
