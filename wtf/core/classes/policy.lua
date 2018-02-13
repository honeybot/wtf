local require = require
local tools = require("wtf.core.tools")
local cjson = require("cjson")
local Object = require("wtf.core.classes.object")

local policy = Object:extend()

function policy:create_from_file(filename)
    local notice = tools.notice
    notice("Loading policy from file "..filename)
    self.content = cjson.decode(tools.readfile(filename))
    return self
end

function policy:create_from_json(json)
    self.content = cjson.decode(json)
    return self
end

function policy:create_from_table(obj)
    self.content = obj
    return self
end

function policy:get_option(key)
    return self.content[key]
end

function policy:_init(...)
  local select = select
  local type = type
  local warn = tools.warn
  
  local source = select(1, ...)
  local source_type = select(2, ...)

  -- use source type if it is explicitly defined
  if source_type ~= nil then
    if source_type:lower() == "file" and type(source) == "string" then
      self:create_from_file(source)
    elseif source_type:lower() == "table" and type(source) == "table" then
      self:create_from_table(source)
    elseif source_type:lower() == "json" and type(source) == "string" then
      self:create_from_json(source)
    else
      warn("Unknown policy source type: '"..source_type.."'. Supported types are 'table' and 'string'. Policy will be ignored.")
    end
  -- if source type isn't defined then try to guess
  else
    if type(source) == "table" then
      self:create_from_table(source)
    elseif type(source) == "string" then
      if tools.string_ends(source, ".json") then
        self:create_from_file(source)
      else
        self:create_from_json(source)
      end
    else
      warn("Unknown policy source type: '"..type(source).."'. Supported types are 'table' and 'string'. Policy will be ignored.")
    end
  end

end

return policy