-- Tester program used for making sure new versions work without bugs
local t = require("val_api")
local turtle = require("fakecc")

local Test = {}

-- Test functions
function Test.up()
  print("Tests failed")
end

-- Run tests
for i, v in ipairs(Test) do
  v()
end
print("All tests ran... OK")
