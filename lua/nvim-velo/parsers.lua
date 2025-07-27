local utils = require("nvim-velo.utils")

local M = {}

function M.parse_exec_params(args)
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

	return params
end

-- returns tuple of logs (all logs string), errors (all errors table)
function M.parse_velo_flow_logs(logs)
	local errored = {}
	local logs_str = ""
	for _, log in ipairs(logs) do
		if log.level == "ERROR" then
			table.insert(errored, log)
		end

		logs_str = logs_str .. string.format(
			"%-10s : %s\n",
			log.level,
			utils.trim(log.message):gsub("(\n)", "\\n")
		)
	end

	return logs_str, errored
end

return M
