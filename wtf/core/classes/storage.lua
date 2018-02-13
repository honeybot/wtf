local require = require
local tools = require("wtf.core.tools")
local Configurable_Object = require("wtf.core.classes.configurable_object")

local storage = Configurable_Object:extend()
storage.name = "Storage class"

function storage:init(...)
  local notice = tools.notice
  local name = self:get_optional_parameter('name') or self.name
  
  notice("Initializing storage "..name.."("..self.name..")")
  return self
end

--[[--
May be implemented:
  function storage:init(...)
  end

Should be implemented:
  function storage:get(key)
  end
  
  function storage:set(key, value)
  end
  
  function storage:del(key)
  end
  
--]]--
return storage