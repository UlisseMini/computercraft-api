-- Tester program used for making sure new versions work without bugs
fs        = require("fs")
turtle    = require("turtle")
textutils = require("textutils")

local t    = require("val_lib")
local os   = require("os")
local math = require("math")

local startTime
local defaultRetVal = "OK"

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
  for k, v in pairs(re) do
    print("Test."..k.." "..v)
  end
end

local results = {}
local Test = {}

function Test.positions()
  -- There is a *VERY* small chance of this test failing from every movement returning false.
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
    return "Coordanites did not change."
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
    return "Failed to return to start."
  end

  return defaultRetVal
end

function Test.textutils()
  local foo = {
    x = 32,
    y = 28,
  }
  local expected = "{\n  y = 28,\n  x = 32,\n}"

  -- serialize then unserialize
  local text = textutils.serialize(foo)

  if text ~= expected then
    return "textutils.serialize() did not return expected"
  end

  local bar = textutils.unserialize(text)

  if bar.x ~= foo.x or bar.y ~= foo.y then
    return "textutils.unserialize() failed"
  end

  return defaultRetVal
end

-- Run tests
for testname, testcase in pairs(Test) do
  startTime = os.clock()
  result = testcase()
  if result ~= nil then
    results[testname] = result
  end
end

print(string.format("Ran "..table.size(Test).." Tests in %.5fs\n", os.clock() - startTime))

checkResults(results)
