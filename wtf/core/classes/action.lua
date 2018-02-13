local require = require
local tools = require("wtf.core.tools")
local ConfigurableObject = require("wtf.core.classes.configurable_object")

local action = ConfigurableObject:extend()
action.name = "Action class"

--[[
Should be implemented:
  function action:act(...)
  end
]]--

function action:init(...)
  local notice = tools.notice
  local name = self:get_optional_parameter('name') or self.name
  
  notice("Initializing action "..name.."("..self.name..")")
  return self
end

function action:postpone(stage, message)
  local ngx = ngx
  
  local action_name = self:get_policy()['name'] or self.name
  
	if not ngx.ctx["postponed"] then ngx.ctx["postponed"] = {} end
	if not ngx.ctx["postponed"][stage] then ngx.ctx["postponed"][stage] = {} end
	if not ngx.ctx["postponed"][stage][action_name] then ngx.ctx["postponed"][stage][action_name] = {} end

	local size = #ngx.ctx["postponed"][stage][action_name]
	ngx.ctx["postponed"][stage][action_name][size+1] = message

	return self
end

function action:do_postponed(stage)
  local ngx = ngx
  local ipairs = ipairs

  local action_name = self:get_optional_parameter('name') or self.name

  if ngx.ctx and ngx.ctx["postponed"] and ngx.ctx["postponed"][stage] and ngx.ctx["postponed"][stage][action_name] then
		for _, message in ipairs(ngx.ctx["postponed"][stage][action_name]) do
      self:act(message)
    end
	end
  
  return self
end

return action