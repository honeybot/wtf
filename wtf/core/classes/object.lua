local Object = {}
Object.__index = Object


function Object:_init()
end


function Object:extend()
  local setmetatable = setmetatable
  local pairs = pairs
  
  local cls = {}
  
  for k, v in pairs(self) do
    if k:find("__") == 1 then
      cls[k] = v
    end
  end
  
  cls.__index = cls
  cls.super = self
  setmetatable(cls, self)
  
  return cls
end


function Object:implement(...)
  local type = type
  local pairs = pairs
  
  for _, cls in pairs({...}) do
    for k, v in pairs(cls) do
      if self[k] == nil and type(v) == "function" then
        self[k] = v
      end
    end
  end
end


function Object:is(T)
  local getmetatable = getmetatable
  
  local mt = getmetatable(self)
  
  while mt do
    if mt == T then
      return true
    end
    mt = getmetatable(mt)
  end
  
  return false
end


function Object:__tostring()
  return "Object"
end


function Object:__call(...)
  local obj = setmetatable({}, self)
  obj:_init(...)
  return obj
end


return Object