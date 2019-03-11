local Stack = {}

function Stack.new(xs)
   if xs then
      assert(type(xs) == "table", "expected a table in position 1")
   end

   local new = {
      _tag = "stack",
      _data = xs or {},
      push = function(self, elem)
         rawset(self._data, #self._data + 1, elem)
         return self
      end,
      pop = function(self)
         local elem = rawget(self._data, #self._data)
         table.remove(self._data)
         return elem
      end,
      peek = function(self)
         local elem = rawget(self._data, #self._data)
         return elem
      end
   }

   local mt = {
      __newindex = function()
         error("Cannot directly set a list index. Use list:cons(elem) to add new elements.")
      end,
      __index = function(t, k)
         error("Cannot directly index a stack. Use stack:peek() to see the top-most element.")
      end,
      __len = function(t, k)
         return #t._data
      end,
      __tostring = function(t)
         local result = {"stack("}
         local last = #t._data
         for k, v in ipairs(t._data) do
            result[#result+1] = tostring(v)
            if k ~= last then
               result[#result+1] = ", "
            end
         end
         result[#result+1] = ")"
         return table.concat(result)
      end
   }
   setmetatable(new, mt)

   return new
end

return Stack
