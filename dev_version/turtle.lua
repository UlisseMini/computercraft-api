-- Fake cc library used by my automatic tests
-- Random is not working, i need a random seed
-- TODO:
-- Add fuel system instead of randomly returning true / false
local math = require("math")
local os   = require("os")
local h    = require("helpers")

local slot = h.rand(1,16)
-- Some items for one to randomly be picked by randitem
local items = {
  "minecraft:sand",
  "minecraft:iron_ingot",
  "minecraft:dirt",
  "minecraft:redstone",
  "minecraft:stone"
}

-- Pick a random item from items table
local function randitem()
end

-- Fake turtle api
local turtle = {}

function turtle.getSelectedSlot()
  return slot
end
-- Moving functions will return true or false randomly
function turtle.forward()
  return h.trueorfalse()
end

function turtle.back()
  return h.trueorfalse()
end

function turtle.down()
  return h.trueorfalse()
end

function turtle.up()
  return h.trueorfalse()
end

-- Turning functions return nothing so i can leave them blank
function turtle.turnRight() end
function turtle.turnLeft() end

-- Digging functions
function turtle.dig()
  h.trueorfalse()
end

function turtle.digUp()
  h.trueorfalse()
end

function turtle.digDown()
  h.trueorfalse()
end


return turtle
