local require = require
local Solver = require("wtf.core.classes.solver")

local _M = Solver:extend()
_M.name = "demo solver"

function _M:access(...)
  local select = select
  
	local caller = select(1, ...)
	local res = ""
  
  for _, note in self:get_notes() do
    if res ~= "" then res = res.." " end
    res = res..note
  end
  
  caller:get_action('err_log'):act(res)
  
	return self
end

return _M