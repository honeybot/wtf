local require = require
local Action = require("wtf.core.classes.action")

local _M = Action:extend()
_M.name = "log"

function _M:act(...)
  local ngx = ngx
  local select = select
  
	local message = select(1, ...)
  local log_level = self:get_mandatory_parameter('log_level')
  
  ngx.log(log_level, message)
  
	return self
end

return _M

