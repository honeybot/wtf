local require = require
local ConfigurableObject = require("wtf.core.classes.configurable_object")
local tools = require("wtf.core.tools")

local instance = ConfigurableObject:extend()

function instance:init_plugins()
  local pairs = pairs
  local next = next
  local warn = tools.warn
  
  local policy_instance = self:get_policy()
  local status
	local Plugin
  
  self.plugins = {}
    
  -- Load plugins
	if policy_instance:get_option('plugins') then
		for plugin_name, plugin_policies in pairs(policy_instance:get_option('plugins')) do
      status, Plugin = tools.load_if_exists("wtf.plugins."..plugin_name)
			if status then
				if next(plugin_policies) ~= nil  then
					for _, plugin_policy in pairs(plugin_policies) do
            self.plugins[#self.plugins+1] = Plugin(plugin_policy)
					end
				else
          self.plugins[#self.plugins+1] = Plugin({})
				end
			else
				warn("Cannot find plugin "..plugin_name)
			end
		end
  end
  
  return self
end

function instance:init_actions()
  local pairs = pairs
  local next = next
  local warn = tools.warn
  
  local policy_instance = self:get_policy()
  local status
  local action_obj
  local Action
  
  self.actions = {}
  
  -- Load actions
	if policy_instance:get_option('actions') then
		for action_type, action_instances in pairs(policy_instance:get_option('actions')) do
      status, Action = tools.load_if_exists("wtf.actions."..action_type)
			if status then
				if next(action_instances) ~= nil  then
					for _, action_instance in pairs(action_instances) do
            action_obj = Action(action_instance)
            if action_obj:get_policy() and action_obj:get_policy().name then
							self.actions[action_obj:get_policy().name] = action_obj
            else
							self.actions[action_type] = action_obj
						end
					end
				else
          action_obj = Action({})
					self.actions[action_type] = action_obj
				end
			else
				warn("Cannot load action "..action_type)
			end
		end
	end
  
  return self
end

function instance:init_solvers()
  local pairs = pairs
  local next = next
  local warn = tools.warn
  
  local policy_instance = self:get_policy()
  local status
  local solver_obj
  local Solver
  
  self.solvers = {}

  -- Load solvers
  if policy_instance:get_option('solvers') then
		for solver_type, solver_policies in pairs(policy_instance:get_option('solvers')) do
      status, Solver = tools.load_if_exists("wtf.solvers."..solver_type)
			if status then
				if next(solver_policies) ~= nil  then
					for _, solver_policy in pairs(solver_policies) do
            solver_obj = Solver(solver_policy)
						self.solvers[#self.solvers+1] = solver_obj
					end
				else
          solver_obj = Solver({})
					self.solvers[#self.solvers+1] = solver_obj
				end
			else
				warn("Cannot load solver "..solver_type)
			end
		end
	end
  
  return self
end

function instance:init_storages()
  local pairs = pairs
  local next = next
  local warn = tools.warn
  
  local policy_instance = self:get_policy()
  local status
  local storage_obj
  local Storage
  
  self.storages = {}
  
  -- Load storages
	if policy_instance:get_option('storages') then
		for storage_type, storage_instances in pairs(policy_instance:get_option('storages')) do
      status, Storage = tools.load_if_exists("wtf.storages."..storage_type)
			if status then
				if next(storage_instances) ~= nil  then
					for _, storage_instance in pairs(storage_instances) do
            storage_obj = Storage(storage_instance)
            if storage_obj:get_policy() and storage_obj:get_policy().name then
							self.storages[storage_obj:get_policy().name] = storage_obj
            else
							self.storages[storage_type] = storage_obj
						end
					end
				else
          storage_obj = Storage({})
					self.storages[storage_type] = storage_obj
				end
			else
				warn("Cannot load storage "..storage_type)
			end
		end
	end
  
  return self
end

function instance:set_policy(policy_instance)
  instance.super.set_policy(self, policy_instance)

  self:init_storages()
  self:init_actions()
	self:init_plugins()
  self:init_solvers()

	return self
end  

function instance:get_action(action_name)
	return self.actions[action_name]
end

function instance:get_solver(solver_name)
  return self.solvers[solver_name]
end

function instance:get_plugin(plugin_name)
  return self.plugins[plugin_name]
end

function instance:get_storage(storage_name)
  return self.storages[storage_name]
end

function instance:note(message)
  local ngx = ngx
  
	if not ngx.ctx["notes"] then ngx.ctx["notes"] = {} end
	
	local size = #ngx.ctx["notes"]
	ngx.ctx["notes"][size+1] = message
	
	return self
end

function instance:get_notes()
  local ngx = ngx
  
  return ngx.ctx['notes']
end

function instance:make_decision_on_noted(stage)
  local pairs = pairs
  
  local notes = self:get_notes()
  
  if notes ~= nil and #notes > 0 then
    for _, s in pairs(self.solvers) do
      if s[stage] then s[stage](s, self) end
    end
	end
  
  return self
end

function instance:init()
  local ipairs = ipairs
  local pairs = pairs
    
  for _,p in ipairs(self.plugins) do
		if p.init then p:init(self) end
	end
  
  for _,a in pairs(self.actions) do
		if a.init then a:init(self) end
	end
  
  for _,s in pairs(self.solvers) do
    if s.init then s:init(self) end
  end
  
  for _,st in pairs(self.storages) do
    if st.init then st:init(self) end
  end

	return self
end

function instance:init_worker()
  local ipairs = ipairs
  local pairs = pairs
  
  for _,p in ipairs(self.plugins) do
		if p.init_worker then p:init_worker(self) end
	end
  
  for _,a in pairs(self.actions) do
		if a.init_worker then a:init_worker(self) end
	end
  
  for _,s in pairs(self.solvers) do
    if s.init_worker then s:init_worker(self) end
  end
  
  for _,st in pairs(self.storages) do
    if st.init_worker then st:init_worker(self) end
  end
  
	return self
end

function instance:access()
  local ipairs = ipairs
  local pairs = pairs
  
  
  for _,p in ipairs(self.plugins) do
		if p.access then p:access(self) end
	end

  for _,a in pairs(self.actions) do
    if a.do_postponed then a:do_postponed("access") end
  end

  self:make_decision_on_noted("access")
  
	return self
end

function instance:ssl_certificate()
  local ipairs = ipairs
  local pairs = pairs
  
	for _,p in ipairs(self.plugins) do
		if p.ssl_certificate then p:ssl_certificate(self) end
	end
  
  for _,a in pairs(self.actions) do
    if a.do_postponed then a:do_postponed("ssl_certificate") end
  end
  
  self:make_decision_on_noted("ssl_certificate")
  
	return self
end

function instance:rewrite()
  local ipairs = ipairs
  local pairs = pairs

	for _,p in ipairs(self.plugins) do
		if p.rewrite then p:rewrite(self) end
	end
  
  for _,a in pairs(self.actions) do
    if a.do_postponed then a:do_postponed("rewrite") end
  end
  
  self:make_decision_on_noted("rewrite")
  
	return self
end

function instance:content()
  local ipairs = ipairs
  local pairs = pairs

	for _,p in ipairs(self.plugins) do
		if p.content then p:content(self) end
	end
  
  for _,a in pairs(self.actions) do
    if a.do_postponed then a:do_postponed("content") end
  end
  
  self:make_decision_on_noted("content")
  
	return self
end

function instance:header_filter()
  local ipairs = ipairs
  local pairs = pairs

	for _,p in ipairs(self.plugins) do
		if p.header_filter then p:header_filter(self) end
	end
  
  for _,a in pairs(self.actions) do
    if a.do_postponed then a:do_postponed("header_filter") end
  end
  
  self:make_decision_on_noted("header_filter")
  
	return self
end

function instance:body_filter()
  local ipairs = ipairs
  local pairs = pairs

	for _,p in ipairs(self.plugins) do
		if p.body_filter then p:body_filter(self) end
	end
  
  for _,a in pairs(self.actions) do
    if a.do_postponed then a:do_postponed("body_filter") end
  end
    
  self:make_decision_on_noted("body_filter")

	return self
end

function instance:log()
  local ipairs = ipairs
  local pairs = pairs
  
	for _,p in ipairs(self.plugins) do
		if p.log then p:log(self) end
	end
  
  for _,a in pairs(self.actions) do
    if a.do_postponed then a:do_postponed("log") end
  end
  
  self:make_decision_on_noted("log")
  
	return self
end

function instance:_init(...)
  local select = select
  
  local instance_policy = select(1, ...)
    
  if instance_policy == nil then
    self:set_policy({})
  else
    self:set_policy(instance_policy)
  end
end

return instance