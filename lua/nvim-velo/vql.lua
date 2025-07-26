local utils = require("nvim-velo.utils")
local json = require("nvim-velo.json")

local M = {}

-- Execute a VQL flow to find a client ID for a hostname
-- Formats:
-- 1. %s - hostname
local VQL_GET_CLIENT_ID = [[
SELECT client_id FROM clients() WHERE os_info.fqdn = '%s'
]]

-- Execute a VQL flow on a defined host
-- Note: perfroms await, wierd hangs happen when awaiting in separate query
--			 maybe related to timing or smth. legacy funcs as comments
-- Formats: 
-- 1. %s - base64 encoded	VQL
-- 2. %s - client ID
local VQL_FLOW_START_EXEC = [[
LET command = base64decode(string='%s')
LET collection <= SELECT collect_client(
    client_id='%s',
    artifacts='Generic.Client.VQL',
    env=dict(Command = command)
) as collection FROM scope()

LET _ <= SELECT * FROM watch_monitoring(artifact='System.Flow.Completion')
WHERE FlowId = collection[0]["collection"]["flow_id"] 
LIMIT 1

SELECT * FROM collection
]]

--[[
-- Await a given flow
-- Formats:
-- 1. %s - flow ID 
local VQL_FLOW_AWAIT_EXEC = [[
LET monitor <= SELECT * FROM watch_monitoring(artifact='System.Flow.Completion')
WHERE FlowId = '%s' 
LIMIT 1

SELECT * FROM monitor
]]
--]]

-- Execute a VQL to fetch flow logs
-- Formats:
-- 1. %s - client ID 
-- 2. %s - flow ID 
local VQL_GET_FLOW_LOGS = [[
SELECT * FROM flow_logs(client_id='%s', flow_id='%s')
]]

-- Execute a VQL to fetch flow results 
-- Formats:
-- 1. %s - client ID 
-- 2. %s - flow ID 
local VQL_GET_FLOW_RESULTS = [[
SELECT * FROM flow_results(client_id='%s', flow_id='%s')
]]

-- Execute a VQL to delete a flow 
-- Formats:
-- 1. %s - flow ID 
-- 2. %s - client ID 
local VQL_DELETE_FLOW = [[
LET _ <= SELECT * FROM delete_flow(
    flow_id='%s',
    client_id='%s',
    really_do_it=true,
    sync=true
)
]]

function M.vql_exec(vql)
	if not vql then
		error("VQL not defined")
	end

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

	local res = obj:wait()
	--print(res.stdout)
	return res
end

local function build_vql_get_client_id(hostname)
	if not hostname then
		error('hostname not defined')
	end

	return string.format(VQL_GET_CLIENT_ID, hostname)
end

local function build_vql_flow_start(vql, client_id)
	if not vql then
		error('vql not defined')
	end

	if not client_id then
		error('client_id not defined')
	end

	return string.format(VQL_FLOW_START_EXEC, utils.to_base64(vql), client_id)
end

--[[
local function build_vql_flow_await(flow_id)
	if not flow_id then
		error('flow_id not defined')
	end

	return string.format(VQL_FLOW_AWAIT_EXEC, flow_id)
end
--]]

local function build_vql_get_flow_logs(client_id, flow_id)
	if not client_id then
		error('client_id not defined')
	end

	if not flow_id then
		error('flow_id not defined')
	end

	return string.format(VQL_GET_FLOW_LOGS, client_id, flow_id)
end

local function build_vql_get_flow_results(client_id, flow_id)
	if not client_id then
		error('client_id not defined')
	end

	if not flow_id then
		error('flow_id not defined')
	end

	return string.format(VQL_GET_FLOW_RESULTS, client_id, flow_id)
end

local function build_vql_delete_flow(client_id, flow_id)
	if not client_id then
		error('client_id not defined')
	end

	if not flow_id then
		error('flow_id not defined')
	end

	return string.format(VQL_DELETE_FLOW, flow_id, client_id)
end

function M.get_client_id(hostname)
	if not hostname then
		error('hostname not defined')
	end

	local result = M.vql_exec(
		build_vql_get_client_id(hostname)
	)

	if result.stdout == "" then
		return
	end

	return json.parse(result.stdout).client_id
end

function M.start_flow(vql, client_id)
	if not vql then
		error('vql not defined')
	end

	if not client_id then
		error('client_id not defined')
	end

	return json.parse(
		M.vql_exec(
			build_vql_flow_start(vql, client_id)
		).stdout
	)
end

--[[
function M.await_flow(flow_id)
	if not flow_id then
		error('flow_id not defined')
	end

	return json.parse(
		M.vql_exec(
			build_vql_flow_await(flow_id)
		).stdout
	)
end
--]]

function M.fetch_flow_logs(client_id, flow_id)
	if not client_id then
		error('client_id not defined')
	end

	if not flow_id then
		error('flow_id not defined')
	end

	local result = {}
	local logs = M.vql_exec(build_vql_get_flow_logs(client_id, flow_id)).stdout

	-- Parse returned json lines one by one
	for line in logs:gmatch("([^\r\n]+)") do
		result[#result+1] = json.parse(line)
	end

	return result
end

function M.fetch_flow_results(client_id, flow_id)
	if not client_id then
		error('client_id not defined')
	end

	if not flow_id then
		error('flow_id not defined')
	end

	return M.vql_exec(build_vql_get_flow_results(client_id, flow_id)).stdout
end

function M.delete_flow(client_id, flow_id)
	if not client_id then
		error('client_id not defined')
	end

	if not flow_id then
		error('flow_id not defined')
	end

	M.vql_exec(build_vql_delete_flow(client_id, flow_id))
end

return M
