-- Tester program used for making sure new versions work without bugs
fs        = require("fs")
turtle    = require("turtle")
textutils = require("textutils")

local t    = require("val_lib")
local os   = require("os")
local math = require("math")
local h    = require("helpers")

local startTime
local defaultReturnValue = "OK"
local testFailures = 0

local results = {}
local Test = {}

t.debug_level = 3

local function resetCoords()
  -- Reset the coordanites
	t.goto(0,0,0,0)
end

local function checkResults(re)
  for k, v in pairs(re) do
    local msg = "Test."..k.." - "..v

    if v ~= defaultReturnValue then
      testFailures = testFailures + 1
    end

    print(msg)
  end
end

function Test.inTable()
  local testTable = {
    "foo",
    "bar",
    2019,
    "potato",
  }

  if t.inTable("poo poo pee pee man", testTable) then
    return "t.inTable(\"poo poo pee pee man\") returned true expected false"
  end

  if t.inTable("foo", testTable) == false then
    return "t.inTable(\"foo\") returned false expected true"
  end

  if t.inTable(2019, testTable) == false then
    return "t.inTable(2019) returned false expected true"
  end

  return defaultReturnValue
end

function Test.positions()
  -- There is a *VERY* small chance of this test failing from every movement returning false.
  local startingPos = t.dumpCoords()

  t.saveCurrentPos("start")
  -- Move around some
  for i=1,10 do
    for i=1,10 do t.forward() end
    t.turnRight()

    for i=1,10 do t.forward() end
    t.turnLeft()

    if h.trueorfalse() then t.turnRight() end
    for i=1,10 do t.up() end
    for i=1,5 do t.down() end
  end

  -- Before you return to start make sure coordanites are not 0,0,0,0
  local middlePos = t.dumpCoords()

  -- If the coordanites are still 0, 0, 0, 0 then fail
  if textutils.serialize(middlePos) == textutils.serialize(startingPos) then
    return "Coordanites did not change."
  end
  --print(textutils.serialize(middlePos))

  t.gotoPos("start")
  local endingPos = t.dumpCoords()

  if textutils.serialize(endingPos) ~= textutils.serialize(startingPos) then
    return "Failed to return to start."
  end

  return defaultReturnValue
end

function Test.goto()
  local startingPos = t.dumpCoords()
  local expPos = {
    x = h.rand(-50, 50),
    y = h.rand(-50, 50),
    z = h.rand(-50, 50),
    orientation = h.rand(0, 3),
  }

  t.goto(expPos.x, expPos.y, expPos.z, expPos.orientation)

  local endingPos = t.dumpCoords()

  if h.isEqual(endingPos, expPos) == false then
    print(textutils.serialize(endingPos))
    return "Ending position is not equal to expected ending position"
  end

  return defaultReturnValue
end

function Test.calcFuelForPos()
  resetCoords()
  local fuelNeeded
  t.saveCurrentPos("start")

  fuelNeeded = t.calcFuelForPos("start")
  if fuelNeeded ~= 0 then
    return "fuelNeeded is "..tostring(fuelNeeded).." expected 0"
  end

  local x, y, z = 30, -19, 49
  local o = t.orientation

  -- Move around some
  t.goto(x,y,z,o)

  fuelNeeded = t.calcFuelForPos("start")
  if fuelNeeded ~= 98 then
    return "fuelNeeded is "..tostring(fuelNeeded).." expected 98"
  end

  -- Move some more
  t.goto(-10,20,-30,0)

  fuelNeeded = t.calcFuelForPos("start")
  if fuelNeeded ~= 60 then
    return "fuelNeeded is "..tostring(fuelNeeded).." expected 60"
  end

  return defaultReturnValue
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

  return defaultReturnValue
end

-- Run tests
for testname, testcase in pairs(Test) do
  startTime = os.clock()
  result = testcase()
  if result ~= nil then
    results[testname] = result
  end
end

checkResults(results)
print(string.format("\nRan "..table.size(Test).." Tests in %.5fs", os.clock() - startTime))
if testFailures > 0 then
  print(testFailures.." Test failures")
else
  print("OK")
end
-- cleanup
resetCoords()
