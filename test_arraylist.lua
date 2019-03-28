local ArrayList = require "arraylist"

function test1()
   local a = ArrayList({1,2,3,4,5})
   for k,v in ipairs(a) do
      print(k, v)
   end
end

function test2()
   local ArrayList = dofile("arraylist.lua")
   local a = ArrayList({1,2,3})
   local b = ArrayList({7,8,9})
   a:append(b)
   print(a)
   local new_a = a:filter(function(elem) return elem % 2 == 1 end)
   print(new_a)
end
