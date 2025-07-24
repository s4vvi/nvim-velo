local utils = require("nvim-velo.utils")

local M = {}

function M.exec_vql()
	local current_buffer = vim.api.nvim_get_current_buf()
	local current_window = vim.api.nvim_get_current_win()

	if vim.o.filetype ~= "vql" then
		utils.err("Can't execute non '*.vql' file.")
		return
	end

	local vql = utils.buffer_to_string(current_buffer)
	local obj = vim.system({
		"velociraptor",
		"--api_config",
		NvimVeloConfig.api_config_path,
		"query",
		vql,
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
		if params.flow_delete:lower() == "false" then
			params.flow_delete = false
		elseif params.flow_delete:lower() == "true" then
			params.flow_delete = true 
		else
			params.flow_delete = NvimVeloConfig.delete_flow_after_exec
		end
	else
		params.flow_delete = NvimVeloConfig.delete_flow_after_exec
	end

	-- TODO: VQL factory 
	--[[
LET command = '''
SELECT *, sleep(time=4) FROM info()
'''
LET client_id <= SELECT client_id FROM clients() WHERE os_info.fqdn = 'localhost'
LET collection <= SELECT collect_client(
    client_id=client_id[0]["client_id"],
    artifacts='Generic.Client.VQL',
    env=dict(Command = command)
) as collection FROM scope()

LET _ <= SELECT * FROM watch_monitoring(artifact='System.Flow.Completion')
WHERE FlowId = collection[0]["collection"]["flow_id"]
LIMIT 1

--SELECT collection from scope()

SELECT * FROM flow_results(client_id=client_id[0]["client_id"], flow_id=collection[0]["collection"]["flow_id"])

LET _ <= SELECT * FROM delete_flow(
    flow_id=collection[0]["collection"]["flow_id"],
    client_id=client_id[0]["client_id"],
    really_do_it=true,
    sync=true
)
	--]]
end

return M
