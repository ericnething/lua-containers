local Set = {}

function Set.new(xs)
   if xs then
      assert(type(xs) == "table", "bad argument #1 to 'new' (table expected)")
   end

   local from_table = function(t)
      local result = {}
      for k in pairs(t) do
         result[k] = true
      end
      return result
   end
   
   local new = {
      _tag = "set",
      _data = xs and from_table(xs) or {}
   }

   local methods = {
      contains = function(self, k)
         return self._data[k]
      end,
      insert = function(self, ...)
         assert(type(...) ~= nil, "missing argument #2 to ':insert' (value expected)")
         for _, elem in ipairs({...}) do
            rawset(self._data, elem, true)
         end
         return self
      end,
      append = function(self, array)
         local is_table = type(array) == "table"
         local is_arraylist = is_table and array._tag == "arraylist"
         assert(is_table or is_arraylist, "bad argument #2 to ':append' (table or arraylist expected)")

         if is_table then
            self:push(table.unpack(array))
         elseif is_arraylist then
            self:push(table.unpack(array._data))
         end
         return self
      end,
      delete = function(self, k)
         table.remove(self._data, k)
         return self
      end,
      clone = function(self)
         
      end,
      map = function(self, f)
         assert(type(f) == "function", "bad argument #2 to ':map' (expected function)")
         local result = {}
         for k,v in ipairs(self._data) do
            rawset(result, k, f(v))
         end
         return ArrayList.new(result)
      end,
      foreach = function()
         assert(type(f) == "function", "bad argument #2 to ':foreach' (expected function)")
         for _,v in ipairs(self._data) do f(v) end
         return self
      end,
      filter = function(self, predicate)
         assert(type(predicate) == "function", "bad argument #2 to ':filter' (expected function)")
         local result = {}
         for k,v in ipairs(self._data) do
            if predicate(v) then
               rawset(result, #result+1, v)
            end
         end
         return ArrayList.new(result)
      end,
      foldl = function(self, f, acc)
         assert(type(f) == "function", "bad argument #2 to ':foldl' (expected function)")
         for _,v in ipairs(self._data) do
            acc = f(v, acc)
         end
         return acc
      end,
      foldr = function(self, f, acc)
         assert(type(f) == "function", "bad argument #2 to ':foldr' (expected function)")
         for k=#self._data,1,-1 do
            local v = rawget(self._data, k)
            acc = f(v, acc)
         end
         return acc
      end
   }
   
   local mt = {
      __newindex = function(t, k, v)
         error("Use ':insert' to add a new element to the set.")
      end,
      __index = function(t, k)
         local method = rawget(methods, k)
         if method then
            return method
         else
            error("Method not found.")
         end
      end,
      __len = function(t, k)
         return #t._data
      end,
      __tostring = function(t)
         local result = {"set("}
         for k in pairs(t._data) do
            result[#result+1] = tostring(k)
            result[#result+1] = ", "
         end
         result[#result] = ")"
         return table.concat(result)
      end,
      __ipairs = function(t)
         error("Use 'pairs' to iterate over this collection.")
      end,
      __pairs = function()
         local iter = function(t, key)
            key = next(t, key)
            return key
         end
         return iter, t, nil
      end
   }
   setmetatable(new, mt)

   return new
end

setmetatable(
   Set,
   {
      __call = function(_, xs) return Set.new(xs) end
   }
)

return Set
