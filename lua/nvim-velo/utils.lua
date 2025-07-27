local M = {}

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

function M.to_base64(data)
  local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  return ((data:gsub('.', function(x)
    local r,b='',x:byte()
    for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
    return r;
  end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
    if (#x < 6) then return '' end
    local c=0
    for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
    return b:sub(c+1,c+1)
  end)..({ '', '==', '=' })[#data%3+1])
end

return M
