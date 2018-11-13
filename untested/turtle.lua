-- Fake cc library used by my automatic tests
-- Random is not working, i need a random seed
local math = require("math")
local os   = require("os")

-- Some items for one to randomly be picked by randitem
local items = {
  "minecraft:sand",
  "minecraft:iron_ingot",
  "minecraft:dirt",
  "minecraft:redstone",
  "minecraft:stone"
}

-- Helper functions
local function trueorfalse()
  math.randomseed(math.random(1, 2147483647) / os.clock())
  num = math.random(0, 1)

  if num == 0 then
    return false

  elseif num == 1 then
    return true

  else
    print(num)
    error("num != 1 or 0")
  end
end

-- Pick a random item from items table
local function randitem()
end

-- Fake turtle api
local turtle = {}

-- Moving functions will return true or false randomly
function turtle.forward()
  return trueorfalse()
end

function turtle.back()
  return trueorfalse()
end

function turtle.down()
  return trueorfalse()
end

function turtle.up()
  return trueorfalse()
end

-- Turning functions return nothing so i can leave them blank
function turtle.turnRight() end
function turtle.turnLeft() end

-- Digging functions
function turtle.dig()
  return true
end

function turtle.digUp()
  return true
end

function turtle.digDown()
  return true
end


return turtle
