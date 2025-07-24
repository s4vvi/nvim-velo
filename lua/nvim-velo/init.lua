local velo = require("nvim-velo.velo")
local utils = require("nvim-velo.utils")

local M = {}

NvimVeloConfig = NvimVeloConfig or {}
NvimVeloState = {}

function M.setup(config)
	if vim.fn.executable("velociraptor") ~= 1 then
		utils.err("Velociraptor binary not found (nvim-velo).")
		return
	end

	if not config then
		utils.err("Configuration not specified (nvim-velo).")
		return
	end

	if not config["api_config_path"] then
		utils.err("API configuration path (api_config_path) not specified (nvim-velo).")
		return
	end

	if not utils.file_exists(config["api_config_path"]) then
		local full_path = os.getenv("PWD") .. "/" .. config["api_config_path"]
		utils.err("Failed to open API config file '" .. full_path .. "'")
		return
	end

	-- Probably will expand in the future
	local complete_config = {
		api_config_path = config["api_config_path"]
	}

	if config["default_client_fqdn"] then
		complete_config.default_client_fqdn = config["default_client_fqdn"]
	end

	if config["delete_flow_after_exec"] == false then
		complete_config.delete_flow_after_exec = false
	else
		complete_config.delete_flow_after_exec = true
	end

	NvimVeloConfig = complete_config
end

vim.api.nvim_create_user_command(
	'VQLServerExec',
	velo.exec_vql,
	{desc = 'run the file contents against Velociraptor server'}
)

vim.api.nvim_create_user_command(
	'VQLClientExec',
	function (args)
		velo.exec_client_vql(args)
	end,
	{
		nargs = '*',
		complete = function (arg_lead, cmdline, _)
			local args = { "fqdn=", "flow_delete=" }

			if arg_lead:find('^fqdn=') then
				return {}
			end

			if arg_lead:find('^flow_delete=') then
				return { "true", "false" }
			end

			if cmdline:find('fqdn=') then
				table.remove(args, 1)
			end

			if cmdline:find('flow_delete=') then
				table.remove(args, 2)
			end

			return args
		end,
		desc = 'run the file contents against Velociraptor client',
	}
)

return M
