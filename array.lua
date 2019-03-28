local Array = {}

local Common = require "internal.common"
local is_number = Common.is_number
local is_integer = Common.is_integer
local is_positive_integer = Common.is_positive_integer
local is_within_bounds = Common.is_within_bounds

local mt = {
   __newindex = function(t, key, v)
      Array.set(t, key, v)
      return t
   end,
   
   __index = function(t, key)
      if is_number(key) then
         return Array.get(t, key)
      end
      
      local method = Array[key]
      if method then
         return method
      else
         error("Method not found.")
      end
   end,
   
   __len = function(t)
      return Array.size(t)
   end,
   
   __tostring = function(t)
      local result = {"array("}
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
   end,
   
   __eq = function(a, b)
      return Array.isequal(a, b)
   end
}

function Array.new(xs)
   if xs then
      assert(type(xs) == "table", "bad argument #1 to 'Array.new' (table expected)")
   end

   local new = {
      _tag = "array",
      _data = xs or {}
   }
   setmetatable(new, mt)
   return new
end

function Array:size()
   return #self._data
end

function Array:push(...)
   assert(type(...) ~= nil, "missing argument #1 to 'Array:push' (value expected)")
   for _, elem in ipairs({...}) do
      rawset(self._data, self:size() + 1, elem)
   end
   return self
end

function Array:pop()
   local elem = rawget(self._data, self:size())
   table.remove(self._data)
   return elem
end

function Array:peek()
   local elem = rawget(self._data, self:size())
   return elem
end

function Array:append(array)
   local is_table = type(array) == "table"
   local is_array = is_table and array._tag == "array"
   assert(is_table or is_array, "bad argument #1 to 'Array:append' (table or array expected)")
   
   if is_array then
      self:push(table.unpack(array._data))
   elseif is_table then
      self:push(table.unpack(array))
   end
   return self
end

function Array:remove(k)
   table.remove(self._data, k)
   return self
end

function Array:reverse()
   local swap = function(array, k1, k2)
      local v1 = rawget(self._data, k1)
      local v2 = rawget(self._data, k2)
      rawset(self._data, k1, v2)
      rawset(self._data, k2, v1)
   end
   
   local length = self:size()
   local middle = math.floor(length/2)
   
   for left_index = 1, middle do
      local right_index = length + 1 - left_index
      swap(self._data, left_index, right_index)
   end
   return self
end

function Array:copy()
   return Common.deepcopy(self)
end

function Array:map(f)
   assert(type(f) == "function", "bad argument #1 to 'Array:map' (expected function)")
   local result = {}
   for k,v in ipairs(self._data) do
      rawset(result, k, f(v))
   end
   return Array.new(result)
end

function Array:foreach(f)
   assert(type(f) == "function", "bad argument #1 to 'Array:foreach' (expected function)")
   for _,v in ipairs(self._data) do f(v) end
end

function Array:filter(predicate)
   assert(type(predicate) == "function", "bad argument #1 to 'Array:filter' (expected function)")
   local result = {}
   for k,v in ipairs(self._data) do
      if predicate(v) then
         rawset(result, #result+1, v)
      end
   end
   return Array.new(result)
end

function Array:foldl(f, acc)
   assert(type(f) == "function", "bad argument #1 to 'Array:foldl' (expected function)")
   for _,v in ipairs(self._data) do
      acc = f(v, acc)
   end
   return acc
end

function Array:foldr(f, acc)
   assert(type(f) == "function", "bad argument #1 to 'Array:foldr' (expected function)")
   for k = self:size(), 1, -1 do
      local v = rawget(self._data, k)
      acc = f(v, acc)
   end
   return acc
end

function Array:sort(f)
   if f then
      assert(type(f) == "function", "bad argument #1 to 'Array:sort' (expected function)")
      table.sort(self._data, f)
   else
      table.sort(self._data)
   end
   return self
end

function Array:stable_sort(f)
   if f then
      assert(type(f) == "function", "bad argument #1 to 'Array:sort' (expected function)")
      self._data = mergesort(self._data, f)
   else
      self._data = mergesort(self._data)
   end
   return self
end

function Array:isempty()
   return self:size() == 0
end

function Array:take(n)
   local result = Array.new()
   for k = 1, n do
      local element = self:get(k)
      result:push(element)
   end
   return result
end

function Array:drop(n)
   local result = Array.new()
   for k = n + 1, self:size() do
      local element = self:get(k)
      result:push(element)
   end
   return result
end

function Array:get(index)
   if is_within_bounds(index, self:size()) then
      return rawget(self._data, index)
   else
      error("Index "..tostring(index).." is out of bounds.")
   end
end

function Array:set(index, value)
   assert(is_positive_integer(index), "Index must be a positive integer.")
   assert(value ~= nil, "Value cannot be nil.")
   assert(index <= self:size(), "Index "..tostring(index).." is out of bounds. Use 'Array:push' to add a new element.")
   rawset(self._data, index, value)
   return self
end

function Array:isequal(array)
   assert(array._tag == "array", "bad argument #1 to 'Array:isequal' (expected array)")
   return Common.sequence_isequal(self._data, array._data)
end

function Array:totable()
   return self._data
end

Array.__index = Array
setmetatable(
   Array,
   {
      __call = function(_, xs) return Array.new(xs) end
   }
)

return Array
