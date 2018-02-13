local require = require
local tools = require("wtf.core.tools")
local Plugin = require("wtf.core.classes.plugin")

local _M = Plugin:extend()
_M.name = "hello_world"

function _M:access(...)
  local select = select
	local instance = select(1, ...)
  local name = self:get_optional_parameter('name') or self.name
  
	if instance then
    instance:get_action('err_log'):act(name..' says: "Hello, world! This is direct action".')
    instance:get_action('err_log'):postpone('access', name..' says: "Hello, world! This action was postponed".')
    instance:note(name..' says: "Hello, world!')
    instance:note("This is")
    instance:note("a ")
    instance:note('solver".')
	end
  
	return self
end

return _M

