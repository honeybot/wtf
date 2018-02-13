local require = require
local cjson = require("cjson")
local tools = require("wtf.core.tools")
local Object = require("wtf.core.classes.object")

local configurable_object = Object:extend()

function configurable_object:set_policy(object_policy)
	self.policy = object_policy
	return self
end

function configurable_object:get_policy()
  return self.policy
end

function configurable_object:get_mandatory_parameter(option_name)
  local policy = self:get_policy()
  local caller_name = self.name or "unknown object"
  local err = tools.error
    
  if policy == nil then
    err("Cannot get mandatory option '"..option_name.."' for '"..caller_name.."' because policy is empty")
    return nil
  elseif policy[option_name] == nil then
    caller_name = policy['name'] or caller_name
    err("Cannot get mandatory option '"..option_name.."' for '"..caller_name.."' because attribute is empty")
    return nil
  else
    return policy[option_name]
  end
    
end

function configurable_object:get_optional_parameter(option_name)
  local policy = self:get_policy()
  local caller_name = self.name or "unknown object"
  local notice = tools.notice
    
  if policy == nil then
    notice("Cannot get optional parameter  '"..option_name.."' for '"..caller_name.."' because policy is empty")
    return nil
  elseif policy[option_name] == nil then
    caller_name = policy['name'] or caller_name
    notice("Cannot get optional parameter '"..option_name.."' for '"..caller_name.."' because attribute is empty")
    return nil
  else
    return policy[option_name]
  end
    
end

function configurable_object:__to_string()
  return cjson.encode(self.policy)
end

function configurable_object:_init(...)
  local select = select
  
  local object_policy = select(1, ...)
  if object_policy == nil then
    self:set_policy({})
  else
    self:set_policy(object_policy)
  end
end

return configurable_object