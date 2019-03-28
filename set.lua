local Set = {}

local Common = require "internal.common"

local mt = {
   __newindex = function(t, key, v)
      error("Cannot alter values directly in a Set.")
   end,
   
   __index = function(t, key)
      local method = Set[key]
      if method then
         return method
      else
         error("Use 'Set:get' instead of direct indexing.")
      end
   end,
   
   __len = function(t)
      return Set.size(t)
   end,
   
   __tostring = function(t)
      local result = {"set("}
      local count = 0
      local last = t:size()
      for k, v in pairs(t._data) do
         result[#result+1] = tostring(k)
         count = count + 1
         if count ~= last then
            result[#result+1] = ", "
         end
      end
      result[#result+1] = ")"
      return table.concat(result)
   end,
   
   __ipairs = function()
      error("Use 'pairs' to iterate over a Set.")
   end,
   
   __pairs = function(t)
      local iter = function(t, key)
         local v
         key, v = next(t, key)
         if v then return key end
      end
      return iter, t, nil
   end,
   
   __eq = function(a, b)
      return Set.isequal(a, b)
   end
}

function Set.new(xs)
   local size = 0
   if xs then
      assert(type(xs) == "table", "bad argument #1 to 'Set.new' (table expected)")
      for _ in pairs(xs) do
         size = size + 1
      end
   end
   
   local new = {
      _tag = "set",
      _data = xs or {},
      _size = size
   }
   setmetatable(new, mt)
   return new
end

function Set:size()
   return self._size
end

function Set:union(s)
   local is_set = s._tag == "set"
   assert(is_set, "bad argument #1 to 'Set:union' (set expected)")
   local result = self:copy()
   for k, v in pairs(s) do
      result:set(k, v)
   end
   return result
end

function Set:intersection(s)
   local is_set = s._tag == "map"
   assert(is_set, "bad argument #1 to 'Set:intersection' (set expected)")
   local result = Set.new()
   for k, v in pairs(s) do
      if self:get(k) then
         result:set(k, v)
      end
   end
   return result
end

function Set:difference(s)
   local is_set = s._tag == "set"
   assert(is_set, "bad argument #1 to 'Set:difference' (set expected)")
   local result = Set.new()
   for k, v in pairs(self) do
      if not s:get(k) then
         result:set(k, v)
      end
   end
   return result
end

function Set:issubset(s)
   local is_set = s._tag == "set"
   assert(is_set, "bad argument #1 to 'Set:issubset' (set expected)")
   for k in pairs(self) do
      if not s:get(k) then
         return false
      end
   end
   return true
end

function Set:issuperset(s)
   local is_set = s._tag == "set"
   assert(is_set, "bad argument #1 to 'Set:issuperset' (set expected)")
   return s:issubset(self)
end

function Set:remove(key)
   rawset(self._data, key, nil)
   self._size = self._size - 1
   return self
end

function Set:copy()
   return Common.deepcopy(self)
end

function Set:map(f)
   assert(type(f) == "function", "bad argument #1 to 'Set:map' (expected function)")
   local result = Set.new()
   for k in pairs(self._data) do
      result:add(f(k))
   end
   return result
end

function Set:foreach(f)
   assert(type(f) == "function", "bad argument #1 to 'Set:foreach' (expected function)")
   for k in pairs(self._data) do f(k) end
end

function Set:filter(predicate)
   assert(type(predicate) == "function", "bad argument #1 to 'Set:filter' (expected function)")
   local result = Set.new()
   for k in ipairs(self) do
      if predicate(k) then
         result:add(k)
      end
   end
   return result
end

function Set:fold(f, acc)
   assert(type(f) == "function", "bad argument #1 to 'Set:fold' (expected function)")
   for _,v in pairs(self._data) do
      acc = f(v, acc)
   end
   return acc
end

function Set:isempty()
   return self:size() == 0
end

function Set:contains(key)
   return rawget(self._data, key) or false
end

function Set:add(key)
   rawset(self._data, key, true)
   self._size = self._size + 1
   return self
end

function Set:isequal(m)
   assert(m._tag == "set", "bad argument #1 to 'Set:isequal' (expected set)")
   return Common.unordered_isequal(self._data, m._data)
end

function Set:totable()
   return self._data
end

Set.__index = Set
setmetatable(
   Set,
   {
      __call = function(_, xs) return Set.new(xs) end
   }
)

return Set
