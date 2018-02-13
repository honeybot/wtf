local require = require
local tools = require("wtf.core.tools")
local Configurable_Object = require("wtf.core.classes.configurable_object")

local plugin = Configurable_Object:extend()
plugin.name = "Plugin class"

function plugin:init(...)
  local notice = tools.notice
  local name = self:get_optional_parameter('name') or self.name
  
  notice("Initializing plugin "..name.."("..self.name..")")
  return self
end

--[[--
May be implemented:
  function plugin:access(...)
  end
  
  function plugin:ssl_certificate(...)
  end
  
  function plugin:rewrite(...)
  end
  
  function plugin:content(...)
  end
  
  function plugin:header_filter(...)
  end
  
  function plugin:body_filter(...)
  end
  
  function plugin:log(...)
  end
--]]--
return plugin