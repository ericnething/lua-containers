local ArrayList = {}

local is_number = function(k)
   return type(k) == "number"
end

local is_integer = function(k)
   return is_number(k) and math.floor(k) == k
end

local is_positive_integer = function(k)
   return is_integer(k) and k > 0
end

local is_within_bounds = function(k, length)
   return is_integer(k) and k > 0 and k <= length
end

function ArrayList.new(xs)
   if xs then
      assert(type(xs) == "table", "bad argument #1 to 'new' (table expected)")
   end

   local new = {
      _tag = "arraylist",
      _data = xs or {}
   }

   local methods = {
      push = function(self, ...)
         assert(type(...) ~= nil, "missing argument #2 to ':push' (value expected)")
         for _, elem in ipairs({...}) do
            rawset(self._data, #self._data + 1, elem)
         end
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
      reverse = function(self)
         local swap = function(array, k1, k2)
            local v1 = rawget(self._data, k1)
            local v2 = rawget(self._data, k2)
            rawset(self._data, k1, v2)
            rawset(self._data, k2, v1)
         end
         
         local length = #self._data
         local middle = math.floor(length/2)
         
         for left_index = 1, middle do
            local right_index = length + 1 - left_index
            swap(self._data, left_index, right_index)
         end
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
         assert(is_positive_integer(k), "Index must be a positive integer.")
         assert(v ~= nil, "Value cannot be nil.")
         assert(k <= #t._data, "Index "..tostring(k).." is out of bounds. Use :push() to add a new element.")
         
         rawset(t._data, k, v)
         return t
      end,
      __index = function(t, k)
         if is_number(k) then
            if is_within_bounds(k, #t._data) then
               return rawget(t._data, k)
            else
               error("Index "..tostring(k).." is out of bounds.")
            end
         end
         
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
         local result = {"arraylist("}
         local last = #t._data
         for k, v in ipairs(t._data) do
            result[#result+1] = tostring(v)
            if k ~= last then
               result[#result+1] = ", "
            end
         end
         result[#result+1] = ")"
         return table.concat(result)
      end,
      __ipairs = function(t)
         local iter = function(t, index)
            index = index + 1
            local value = rawget(t._data, index)
            if value then return index, value end
         end
         return iter, t, 0
      end,
      __pairs = function()
         error("Use 'ipairs' to iterate over this sequence.")
      end
   }
   setmetatable(new, mt)

   return new
end

setmetatable(
   ArrayList,
   {
      __call = function(_, xs) return ArrayList.new(xs) end
   }
)

return ArrayList
