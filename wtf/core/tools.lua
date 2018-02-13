local tinsert = table.insert

local tools = {}

function tools.readfile(file)
  local assert = assert
  local io = io
  local content = ""

  local f = assert(io.open(file, "rb"))
  content = f:read("*all")
  f:close()
  
  return content
end

function tools.string_ends(str, ends)
  return ends=='' or str.sub(str,-str.len(ends))==ends
end

function tools.trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function tools.split(str,sep)
  local string = string
  local array = {}
  local reg = string.format("([^%s]+)",sep)
  local trim = tools.trim
  
  for mem in string.gmatch(str,reg) do
    tinsert(array, trim(mem)) 
  end
  
  if #array > 1 then
    return array
  elseif #array == 1 then
    return array[1]
  else
    return str
  end
end

function tools.info(str)
  local ngx = ngx
  if ngx.var.wtf_debug then ngx.log(ngx.INFO, str) end
end

function tools.warn(str)
  local ngx = ngx
  ngx.log(ngx.WARN, str)
end

function tools.notice(str)
  local ngx = ngx
  ngx.log(ngx.NOTICE, str)
end

function tools.error(str)
  local ngx = ngx
  local wtf_soft_error = ngx.var["wtf_soft_error"]
  ngx.log(ngx.ERR, str)
  if not wtf_soft_error then 
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.header["Content-Type"] = "text/plain"
    ngx.say("WTF error occured. Please see error log.")
    ngx.exit(ngx.status)
  end
end

function tools.init_error(str)
  local ngx = ngx
  ngx.log(ngx.ERR, str)
end

function tools.random_string(n)
  local require = require
  local math = require("math")
  local alphabet = {'q','w','e','r','t','y','u','i','o','p','a','s','d','f','g','h','j','k','l','z','x','c','v','b','n','m','1','2','3','4','5','6','7','8','9','0'}
  local res = ""
  local r
  
  for _ =1,n do
    r = math.random(#alphabet)
    res = res..alphabet[r]
  end
  
  return res
end

function tools.load_if_exists(module_name)
  local require = require
  local pcall = pcall
  local type = type
  local find = string.find
  
  local status, res = pcall(require, module_name..".".."handler")
  
  if status then
    return true, res
  else
    status, res = pcall(require, module_name)
    if status then
      return true, res
    elseif type(res) == "string" and find(res, "module '" .. module_name .. "' not found", nil, true) then
      return false, res
    else
      tools.init_error(res)
    end
  end
  
end

return tools