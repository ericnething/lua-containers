local Map = {}

local Common = require "internal.common"

local mt = {
   __newindex = function(t, key, v)
      error("Use 'Map:set' instead of direct indexing.")
      -- Map.set(t, key, v)
      -- return t
   end,
   
   __index = function(t, key)
      local method = Map[key]
      if method then
         return method
      else
         error("Use 'Map:get' instead of direct indexing.")
      end
   end,
   
   __len = function(t)
      return Map.size(t)
   end,
   
   __tostring = function(t)
      local result = {"map("}
      local count = 0
      local last = t:size()
      for k, v in pairs(t._data) do
         result[#result+1] = tostring(k).." = "..tostring(v)
         count = count + 1
         if count ~= last then
            result[#result+1] = ", "
         end
      end
      result[#result+1] = ")"
      return table.concat(result)
   end,
   
   __ipairs = function()
      error("Use 'pairs' to iterate over a Map.")
   end,
   
   __pairs = function(t)
      local iter = function(t, key)
         local v
         key, v = next(t, key)
         if v then return key, v end
      end
      return iter, t, nil
   end,
   
   __eq = function(a, b)
      return Map.isequal(a, b)
   end
}

function Map.new(xs)
   local size = 0
   if xs then
      assert(type(xs) == "table", "bad argument #1 to 'Map.new' (table expected)")
      for _ in pairs(xs) do
         size = size + 1
      end
   end
   
   local new = {
      _tag = "map",
      _data = xs or {},
      _size = size
   }
   setmetatable(new, mt)
   return new
end

function Map:size()
   return self._size
end

function Map:union(m)
   local is_map = m._tag == "map"
   assert(is_map, "bad argument #1 to 'Map:union' (map expected)")
   local result = self:copy()
   for k, v in pairs(m) do
      result:set(k, v)
   end
   return result
end

function Map:intersection(m)
   local is_map = m._tag == "map"
   assert(is_map, "bad argument #1 to 'Map:intersection' (map expected)")
   local result = Map.new()
   for k, v in pairs(m) do
      if self:get(k) then
         result:set(k, v)
      end
   end
   return result
end

function Map:difference(m)
   local is_map = m._tag == "map"
   assert(is_map, "bad argument #1 to 'Map:difference' (map expected)")
   local result = Map.new()
   for k, v in pairs(self) do
      if not m:get(k) then
         result:set(k, v)
      end
   end
   return result
end

function Map:remove(key)
   rawset(self._data, key, nil)
   self._size = self._size - 1
   return self
end

function Map:copy()
   return Common.deepcopy(self)
end

function Map:map(f)
   assert(type(f) == "function", "bad argument #1 to 'Map:map' (expected function)")
   local result = Map.new()
   for k,v in pairs(self._data) do
      result:set(k, f(v))
   end
   return result
end

function Map:map_with_key(f)
   assert(type(f) == "function", "bad argument #1 to 'Map:map_with_key' (expected function)")
   local result = Map.new()
   for k,v in pairs(self._data) do
      result:set(k, f(k, v))
   end
   return result
end

function Map:foreach(f)
   assert(type(f) == "function", "bad argument #1 to 'Map:foreach' (expected function)")
   for _,v in pairs(self._data) do f(v) end
end

function Map:foreach_with_key(f)
   assert(type(f) == "function", "bad argument #1 to 'Map:foreach_with_key' (expected function)")
   for k,v in pairs(self._data) do f(k, v) end
end

function Map:filter(predicate)
   assert(type(predicate) == "function", "bad argument #1 to 'Map:filter' (expected function)")
   local result = Map.new()
   for k,v in ipairs(self) do
      if predicate(v) then
         result:set(k, v)
      end
   end
   return result
end

function Map:fold(f, acc)
   assert(type(f) == "function", "bad argument #1 to 'Map:fold' (expected function)")
   for _,v in pairs(self._data) do
      acc = f(v, acc)
   end
   return acc
end

function Map:fold_with_key(f, acc)
   assert(type(f) == "function", "bad argument #1 to 'Map:fold_with_key' (expected function)")
   for _,v in pairs(self._data) do
      acc = f(k, v, acc)
   end
   return acc
end

function Map:isempty()
   return self:size() == 0
end

function Map:get(key)
   return rawget(self._data, key)
end

function Map:set(key, value)
   rawset(self._data, key, value)
   self._size = self._size + 1
   return self
end

function Map:isequal(m)
   assert(m._tag == "map", "bad argument #1 to 'Map:isequal' (expected map)")
   return Common.unordered_isequal(self._data, m._data)
end

function Map:totable()
   return self._data
end

Map.__index = Map
setmetatable(
   Map,
   {
      __call = function(_, xs) return Map.new(xs) end
   }
)

return Map
