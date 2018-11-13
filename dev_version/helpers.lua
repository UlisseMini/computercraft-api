-- Some helper functions i don't like rewriting

local M = {}

function M.isEqual(a,b)

   local function isEqualTable(t1,t2)

      if t1 == t2 then
         return true
      end

      for k,v in pairs(t1) do

         if type(t1[k]) ~= type(t2[k]) then
            return false
         end

         if type(t1[k]) == "table" then
            if not isEqualTable(t1[k], t2[k]) then
               return false
            end
         else
            if t1[k] ~= t2[k] then
               return false
            end
         end
      end

      for k,v in pairs(t2) do

         if type(t2[k]) ~= type(t1[k]) then
            return false
         end

         if type(t2[k]) == "table" then
            if not isEqualTable(t2[k], t1[k]) then
               return false
            end
         else
            if t2[k] ~= t1[k] then
               return false
            end
         end
      end

      return true
   end

   if type(a) ~= type(b) then
      return false
   end

   if type(a) == "table" then
      return isEqualTable(a,b)
   else
      return (a == b)
   end

end

function M.rand(n1, n2)
  math.randomseed(math.random(1, 2147483647) / os.clock())
  return math.random(n1, n2)
end

function M.trueorfalse()
  local num = M.rand(0, 1)
  if num == 0 then
    return false
  else
    return true
  end
end

function table.size(t)
  local retval = 0
  for k,v in pairs(t) do
    retval = retval + 1
  end

  return retval
end

return M
