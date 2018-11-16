-- Fake fs api, so i can test outside of cc
local math = require("math")
local os   = require("os")

local fs = {}

-- Helper functions
local function trueorfalse()
  num = math.random(0, 1)

  if num == 0 then
    return false

  elseif num == 1 then
    return true

  else
    -- This should never be reached
    print(num)
    error("num != 1 or 0")
    return false
  end
end

local function exists(name)
  if type(name)~="string" then return false end
  return os.rename(name,name) and true or false
end

local function isFile(name)
  if type(name)~="string" then return false end
  if not exists(name) then return false end
  local f = io.open(name)
  local data = f:read("*a")
  if data then
    f:close()
    return true
  else
    f:close()
    return false
  end
end

local function isDir(name)
  return (exists(name) and not isFile(name))
end

function fs.exists(file)
  return isFile(file)
end

function fs.ReadAll(file)
  return file:read("*a")
end

-- It's called closure. Stuff defined in something gets access to locals from that thing.
-- gollark

function fs.open(file, mode)
  local f = {} -- Store fs files in here
  local handle = io.open(file, mode)

  function f.readAll()
    return handle:read("*a")
  end

  function f.close()
    handle:close()
  end

  function f.write(data)
    handle:write(data)
  end

  return f
end
return fs
