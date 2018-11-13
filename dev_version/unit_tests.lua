-- Tester program used for making sure new versions work without bugs
-- Fake cc api's
fs        = require("fs")
turtle    = require("turtle")
textutils = require("textutils")

-- My api
local t       = require("val_api")

local LuaUnit = require("luaunit")
local os      = require("os")
local math    = require("math")

local startTime
t.debug_level = 3

-- Helper functions
function table.size(t)
  local retval = 0
  for k,v in pairs(t) do
    retval = retval + 1
  end

  return retval
end

local function trueorfalse()
  num = math.random(0, 1)
  if num == 0 then
    return false
  else
    return true
  end
end

local function checkResults(re)
  returnval = "OK"
  for k, v in pairs(re) do
    print("Test "..k..": "..v)
    returnval = "FAIL"
  end
  return returnval
end

-- results of tests will be stored in here
local results = {}
-- tests functions will be put inside here
local Test = {}

function Test:positions()
  -- There is a *VERY* small chance of this test failing from every movement returning false.
  local retval = nil
  local startingPos = {
    x = t.x,
    y = t.y,
    z = t.z,
    orientation = t.orientation,
  }

  t.saveCurrentPos("start")
  -- Move around some
  for i=1,10 do
    for i=1,10 do t.forward() end
    t.turnRight()

    for i=1,10 do t.forward() end
    t.turnLeft()

    if trueorfalse() then t.turnRight() end
    for i=1,10 do t.up() end
    for i=1,5 do t.down() end
  end

  -- Before you return to start make sure coordanites are not 0,0,0,0
  local middlePos = {
    x = t.x,
    y = t.y,
    z = t.z,
    orientation = t.orientation,
  }

  -- If the coordanites are still 0, 0, 0, 0 then fail
  if textutils.serialize(middlePos) == textutils.serialize(startingPos) then
    assertEquals(textutils.serialize(middlePos), textutils.serialize(startingPos))
  end
  --print(textutils.serialize(middlePos))

  t.gotoPos("start")
  local endingPos = {
    x = t.x,
    y = t.y,
    z = t.z,
    orientation = t.orientation,
  }

  if textutils.serialize(endingPos) ~= textutils.serialize(startingPos) then
    assertNotEquals(textutils.serialize(endingPos), textutils.serialize(startingPos))
  end

  return retval
end

LuaUnit:run()
