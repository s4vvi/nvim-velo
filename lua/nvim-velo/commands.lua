local utils = require("nvim-velo.utils")
local nvim = require("nvim-velo.nvim")
local vql = require("nvim-velo.vql")
local parsers = require("nvim-velo.parsers")

local M = {}

function M.exec_vql(args)
	local params = parsers.parse_exec_params(args)
	if not params then return end

	if not nvim.assert_vql_ext() then return end

	nvim.destroy_last_result_windows()

	local current_buffer = vim.api.nvim_get_current_buf()
	local current_window = vim.api.nvim_get_current_win()

	local client_id = vql.get_client_id(params.fqdn)
	if not client_id then
		utils.err("Client w/ hostname '" .. params.fqdn .."' not found.")
		return
	end

	local flow = vql.start_flow(
		nvim.buffer_to_string(current_buffer),
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

	logs_string, errors_table = parsers.parse_velo_flow_logs(flow_logs)

	if #errors_table == 0 then
		nvim.open_results_success(flow_results, logs_string)
	else
		nvim.open_results_error(logs_string)
		utils.err("VQL errored.")
	end

	vim.api.nvim_set_current_win(current_window)
end

return M
