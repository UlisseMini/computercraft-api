--[[
Valvates library for cordanite management and stuff.
If you have an idea for feature make an issue or
Create a pull request if you're a coder.
A lot of stuff here is unfinished so
Be careful and tell me how to make it better :DD

WARNING!
Since the turtle writes his coordanites to a file you should
run fs.delete(t.coordsfile) when your program finishes!
if you don't then his coords will get all screwed up if he moved without updating his coords

If you're using gps you can manually set coords and then update them
heres some untested example code

t = require("val_api")
t.x, t.y, t.z = gps.locate(0.5)
In this example orientation is still set to north by default,
if you want to find orientation you'll need code that compares coords
after you move, i might add this later but for now its up to you! ;)

TODO:
  Write saved positions to a file and read from it on startup.
  Add automatic gps support, maybe with a bool config variable to turn it on or off.

Here is an index that i think some programmers will find useful

function t.dumpCoords()
returns the current coordanaites in a table \w orientation

function t.inTable(value, table)
Checks if a value is in a table.

function t.cleanInventory()
Tries to clean the turtles inventory by-
throwing out unwanted items.
defined in the t.unWantedItems list.

function t.writeToFile(msg, file, mode)
valid modes are "a", append and "w", overwrite
simply writes to the file in args and cleanly closes it afterwards.

function t.log(msg, msg_debug_level)
logs messages, 5 levels starting at 0.
4: [DEBUG]
3: [INFO]
2: [WARNING]
1: [ERROR]
0: [FATAL] (Will terminate the program after logging)
Will not log the message if t.debug_level is less then msg_debug_level.

function t.savePositionsToFile()
Writes t.saved_positions to t.posfile

function t.init()
this function gets the correct coordanites from the t.coordsfile file.
if the file does not exist, it will create it and initalize the coordanites to 0,0,0,0

function t.calcFuelForPos(pos)
this function returns how much fuel it will take to go to a position.
it will fatal if the position does not exist.

function t.saveCoords()
Saves coordanites to t.coordsfile

--]]
local t = {}

t.debug_level = 4

t.logfile = "val_lib.log"
t.coordsfile = "coords"
t.posfile = "savedPositions"

local file -- Used for file management lower down
t.saved_positions = {}

t.selectedSlot = turtle.getSelectedSlot()
t.blocks_dug = 0

-- How to increment depending on the orientation
local zDiff = {
  [0] = -1,
  [1] = 0,
  [2] = 1,
  [3] = 0
}

local xDiff = {
  [0] = 0,
  [1] = 1,
  [2] = 0,
  [3] = -1
}

-- Needed for human readable input/output
t.orientations = {
  [0] = "north",
  [1] = "east",
  [2] = "south",
  [3] = "west"
}

-- Unwanted items for clean inventory function.
t.unWantedItems = {
  "minecraft:cobblestone",
  "minecraft:stone",
  "minecraft:flint",
  "minecraft:dirt",
  "minecraft:sandstone",
  "minecraft:gravel",
  "minecraft:sand"
}

function t.dumpCoords()
  return {
    x = t.x,
    y = t.y,
    z = t.z,
    orientation = t.orientation,
  }
end

function t.select(i)
  t.selectedSlot = i
  turtle.select(i)
end

function t.inTable(value, table)
  for key, keyValue in pairs(table) do
    if value == keyValue then
      return true
    end
  end
  return false
end

function t.cleanInventory()
  local item
  local prevSlot = turtle.getSelectedSlot()

  for i=1,16 do
    item = turtle.getItemDetail(i)
    -- Makes sure item exists to avoid nil errors.
    if item and t.inTable(item.name, t.unWantedItems) then
      turtle.select(i)
      turtle.dropDown(item.count) -- Drops all of the unwanted item
    end
  end
  turtle.select(prevSlot) -- Leave no trace!
end

function t.writeToFile(msg, fileName, mode)
  -- Function used by logging function.
  -- i felt it was cleaner this way.
  if mode == nil then
    mode = "a" -- By default append
  end

  if fileName == nil then
    t.log("[DEBUG] file to write to is nil, defaulting to "..t.logfile, 4)
    file = t.logfile -- default
  end

  if msg == nil then
    t.log("[ERROR] msg is nil in function t.writeToFile", 1)
    return
  end

  file = fs.open(fileName, mode)

  if not file then
    t.log("[ERROR] Failed to open "..fileName, 0)
    return
  end

  file.write(msg.."\n") -- Adds newline
  file.close()
end

function t.log(msg, msg_debug_level)
  -- Logging function

  if msg_debug_level == nil then
    t.writeToFile("[WARNING] msg_debug_level is nil, defaulting to level 3 message info.", t.logfile)
    -- As a param this is already local.
    msg_debug_level = 3
  end

  if msg_debug_level <= t.debug_level then
    t.writeToFile(msg, t.logfile)
  end
  -- Terminate the program if the message level is fatal.
  if msg_debug_level == 0 then
    print(msg)
    error()
  end
end

-- Get coords from file if file does not exist create one and set coords to 0,0,0,0
function t.init()
  local coords
  local contents
  if t.coordsfile == nil then
    t.log("[ERROR] t.coordsfile is nil", 1)
    t.log("[WARNING] Without a coords file persistance will fail", 2)
    return -- Breaks from this function
  end

  if not fs.exists(t.coordsfile) then
    t.log("[WARNING] t.coordsfile does not exist", 2)
    t.log("[INFO] Creating coordsfile...", 3)
    -- Creates coords file with 0,0,0,0 as values.
    t.writeToFile(textutils.serialize(
    {
      x = 0,
      y = 0,
      z = 0,
      orientation = 0
    }),
    t.coordsfile,
    "w")

    if not fs.exists(t.coordsfile) then
      t.log("[FATAL] Failed to create "..t.coordsfile, 0)
    end
  end

  file = fs.open(t.coordsfile, "r") -- Opens coordsfile for reading.
  if file == nil then
    t.log("[FATAL] Failed to open coordsfile, file is nil", 0)
  end

  contents = file.readAll()
  file.close()

  if contents == nil then
    t.log("[FATAL] Failed to read file contents", 0)
  end

  t.log("[DEBUG] Read file contents, trying to unserialize it", 4)
  coords = textutils.unserialize(contents)
  if type(coords) ~= "table" then
    t.log("[FATAL] failed to unserialize contents, coords is not a table, it is a "..type(coords), 0)
  end

  -- Sets coordanites
  t.log("[DEBUG] Got coordanites from file, they are\n"..textutils.serialize(coords), 4)
  t.x = coords.x
  t.y = coords.y
  t.z = coords.z

  -- Sets orientation
  t.orientation = coords.orientation

  -- Gets saved positions
  t.getSavedPositions()
  -- Not going to return a value since i'll just change the varables.
end

-- Saves coordanites to file
function t.saveCoords()
  local c = {
    x = t.x,
    y = t.y,
    z = t.z,
    orientation = t.orientation
  }
  c = textutils.serialize(c)

  t.log("[DEBUG] Updating "..t.coordsfile.."\n"..c, 4)
  t.writeToFile(c, t.coordsfile, "w")
end

local function orientationToNumber(orientationStr)
  -- Turns an orientation string into an Orientation number.
  for i=0,#t.orientations do
      if orientationStr == t.orientations[i] then
        return i
      end
  end
end

-- Turns an orientation number into an t.orientation string.
local function orientationToString(orientationInt)
  -- Checks to see if orientationInt is a number
  if type(orientationInt) ~= "number" then
    t.log("[FATAL] orientationInt is not a number", 0)
  end
  if orientations[orientationInt] then
    return t.orientations[orientationInt]
  else
    print("[FATAL] orientation is invalid", 0)
    print("orientationInt = "..orientationInt)
  end
end

-- Turning functions
function t.turnRight()
  turtle.turnRight()
  -- This "magic" math adds one to t.orientation unless t.orientation is 3, then it moves to 0.
  -- This could also be done with an if statement but this is cleaner imo
  t.orientation = (t.orientation + 1) % 4
  t.saveCoords()
end

function t.turnLeft()
  turtle.turnLeft()
  t.orientation = (t.orientation - 1) % 4
  t.saveCoords()
end

-- Looks to a direction, can be passed a string or a number
function t.look(direction)
  -- makes sure the value passed is valid.
  if type(direction) == "string" then
    direction = orientationToNumber(direction)
  elseif type(direction) ~= "number" then
      error("Direction is not a number")
  end

  -- Thanks to Incin for this bit of code :)
  if direction == t.orientation then return end

  if (direction - t.orientation) % 2 == 0 then
    t.turnLeft()
    t.turnLeft()
  elseif (direction - t.orientation) % 4 == 1 then
    t.turnRight()
  else
    t.turnLeft()
  end
end

function t.forward()
    t.log("[DEBUG] t.forward called", 4)

    if turtle.forward() then
      t.log("[DEBUG] turtle.forward() returned true, changing coords...", 4)
      -- Change t.x and t.z coords
      t.x = t.x + xDiff[t.orientation]
      t.z = t.z + zDiff[t.orientation]

      t.log("[DEBUG] Calling t.saveCoords from t.forward", 4)
      t.saveCoords()
      return true
    else
      -- If he failed to move return false and don't change the coords.
      t.log("[DEBUG] turtle.forward() returned false", 4)
      return false
    end
end

function t.up()
  t.log("[DEBUG] t.up function called", 4)
  if turtle.up() then
    t.y = t.y + 1
    t.log("[DEBUG] Trying to save coords to file after going up", 4)
    t.saveCoords()
    return true
  else
    return false
  end
end

function t.down()
  if turtle.down() then
    t.y = t.y - 1
    t.saveCoords()
    return true
  else
    return false
  end
end

function t.digDown()
  if turtle.digDown() then
    t.blocks_dug = t.blocks_dug + 1
    return true
  else
    return false
  end
end
function t.dig()
  if turtle.dig() then
    t.blocks_dug = t.blocks_dug + 1
    return true
  else
    return false
  end
end
function t.digUp()
  if turtle.digUp() then
    t.blocks_dug = t.blocks_dug + 1
    return true
  else
    return false
  end
end

-- This function saves the turtles position so it can be returned to later.
function t.saveCurrentPos(name)
  if type(name) ~= "string" then
    error("Position name must be a string.")
  end

  -- Creates a new table entry with "name" key
  t.saved_positions[name] = {
    x = t.x,
    y = t.y,
    z = t.z,
    orientation = t.orientation
  }
  t.savePositionsToFile()
end

function t.savePositionsToFile()
  t.writeToFile(textutils.serialize(t.saved_positions), t.posfile, "w")
end

function t.getSavedPositions()
  if fs.exists(t.posfile) then
    file = fs.open(t.posfile, "r")
    local data = file.readAll()
    file.close()

    local positions = textutils.unserialize(data)
    if type(positions) ~= "table" then
      t.log("[ERROR] Failed to unserialize positions", 1)
      return nil
    end

    return positions
  else
    -- Create one
    local positions = {}
    t.writeToFile(textutils.serialize(positions), t.posfile, "w")
    return positions
  end
end

function t.getPos()
  if fs.exists(t.posfile) then
    file = fs.open(t.posfile, "r")
    t.saved_positions = textutils.unserialize(file.readAll())
    file.close()
  else
    error("No file to get positions from.")
  end
end

function t.gotoPos(name)
  if t.saved_positions[name] == nil then error("[ERROR] t.saved_positions["..name.."] is nil") end
  for i,v in ipairs(t.saved_positions[name]) do print(i,v) end -- temp

  t.goto(t.saved_positions[name].x, t.saved_positions[name].y, t.saved_positions[name].z, t.saved_positions[name].orientation)
end

-- Careful this breaks blocks.
function t.goto(xTarget, yTarget, zTarget, orientationTarget)
  if not xTarget or not yTarget or not zTarget or not orientationTarget then
    t.log("[DEBUG] Here are all the params for the goto function:", 4)
    t.log("xTarget="..xTarget.."yTarget="..yTarget.."zTarget="..zTarget.."orientationTarget="..orientationTarget, 4)
    error("t.goto Can\"t travel to nil!, read logs for more info")
  end
  -- Moves to t.y
  while yTarget < t.y do
    t.digDown()
    t.down()
  end

  while yTarget > t.y do
    t.digUp()
    t.up()
  end

  -- Turns to correct t.orientation then moves forward until its at the right t.x cord
  if xTarget < t.x then
    t.look("west")
    while xTarget < t.x do
      t.dig()
      t.forward()
    end
  end

  if xTarget > t.x then
    t.look("east")
    while xTarget > t.x do
      t.dig()
      t.forward()
    end
  end

  -- Turns to correct t.orientation then moves forward until its at the right t.z cord
  if zTarget < t.z then
    t.look("north")
    while zTarget < t.z do
      t.dig()
      t.forward()
    end
  end
  if zTarget > t.z then
    t.look("south")
    while zTarget > t.z do
      t.dig()
      t.forward()
    end
  end
  -- Look to correct orientation
  t.look(orientationTarget)
end

function t.calcFuelForPos(posName)
  if posName == nil then
    t.log("[FATAL] pos is nil in t.calcFuelForPos", 0)
  elseif not t.saved_positions[posName] then
    t.log("[FATAL] t.saved_positions["..tostring(posName).."] Does not exist", 0)
  else
    local fuelNeeded = 0
    pos = t.saved_positions[posName]

    fuelNeeded = fuelNeeded + (math.abs(pos.x) - math.abs(t.x))
    fuelNeeded = fuelNeeded + (math.abs(pos.y) - math.abs(t.y))
    fuelNeeded = fuelNeeded + (math.abs(pos.z) - math.abs(t.z))

    t.log("[INFO] "..tostring(fuelNeeded).." Fuel needed to go to "..posName.." From "..textutils.serialize(t.dumpCoords()))
    return math.abs(fuelNeeded)
  end
end
t.init()
return t
