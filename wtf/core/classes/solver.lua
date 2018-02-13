local require = require
local tools = require("wtf.core.tools")
local ConfigurableObject = require("wtf.core.classes.configurable_object")

local solver = ConfigurableObject:extend()
solver.name = "Solver class"

function solver:init(...)
  local notice = tools.notice
  local name = self:get_optional_parameter('name') or self.name
  
  notice("Initializing solver "..name.."("..self.name..")")
  return self
end

--[[--
May be implemented:
  function solver:access(...)
  end
  
  function solver:ssl_certificate(...)
  end
  
  function solver:rewrite(...)
  end
  
  function solver:content(...)
  end
  
  function solver:header_filter(...)
  end
  
  function solver:body_filter(...)
  end
  
  function solver:log(...)
  end
--]]--

function solver:get_notes()
  local ngx = ngx
  local ipairs = ipairs
  
  if ngx.ctx and ngx.ctx["notes"] then
		return ipairs(ngx.ctx["notes"])
  else
    return {}
  end
end 

return solver
