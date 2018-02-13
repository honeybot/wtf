local require = require
local lfs = require("lfs")
local tools = require("wtf.core.tools")
local table = require("table")
local Instance = require('wtf.core.classes.instance')
local Policy = require('wtf.core.classes.policy')

local loader = {}
loader.policies = {}

function loader:get_policy(name)
	return self.policies[name]
end

function loader:get_active_policies()
  local type = type
  local pairs = pairs
  local ngx = ngx
  local warn = tools.warn
  local err = tools.init_error

  local res = {}
  local pol = {}
  local policies = {}

  if ngx.var.wtf_policies ~= "" then
    policies = tools.split(ngx.var.wtf_policies, ",")
    if type(policies) == "table" then
      for _, policy_name in pairs(policies) do
        pol = self:get_policy(policy_name)
        if pol ~= nil then
          table.insert(res, pol)
        else
          err("Policy '" ..policy_name.."' isn't loaded")
        end
      end
    elseif type(policies) == "string" then
      table.insert(res, self:get_policy(policies))
    else
      warn( "Cannot initialize WTF because nginx variable wtf_policies (ngx.var.wtf_policies) type "..type(policies).." is unsupported. WTF is going to run in bypass mode")
    end
  else
    warn("Cannot initialize WTF because nginx variable 'wtf_policies' (ngx.var.wtf_policies) is empty. WTF is going to run in bypass mode")
  end
  return res
end

function loader:add_policy(...)
  local warn = tools.warn
  local select = select
  
  local policy_instance = select(1, ...)
  local policy_name = select(2, ...) or policy_instance:get_option('name')
  
  if policy_name ~= nil then 
    self.policies[policy_name] = Instance(policy_instance)
  else
    warn("Cannot get name for one from loading policies (Did you forget to define 'name' key in json?). This policy will be ignored.")
  end
	return self
end

function loader:load_policies_from_dir(policy_dir) 	
  for filename in lfs.dir(policy_dir) do
    if lfs.attributes(policy_dir..filename, "mode") == "file" and tools.string_ends(filename, '.json') then
      self:add_policy(Policy(policy_dir..filename, "file"))
    end
  end
  
  return self
end

return loader