local Queue = {}

local Array = require "array"

local Common = require "internal.common"
local is_number = Common.is_number
local is_integer = Common.is_integer
local is_positive_integer = Common.is_positive_integer
local is_within_bounds = Common.is_within_bounds

local mt = {
   __newindex = function(t, key, v)
      return t:set(key, v)
   end,

   __index = function(t, key)
      if is_number(key) then
         return t:get(key)
      end
      
      local method = Queue[key]
      if method then
         return method
      else
         error("Method not found.")
      end
   end,

   __len = function(t)
      return t:size()
   end,

   __tostring = function(t)
      local result = {"queue(", ""}
      for k = #t._front, 1, -1 do
         result[#result+1] = tostring(t._front._data[k])
         result[#result+1] = ", "
      end
      for _, v in ipairs(t._back) do
         result[#result+1] = tostring(v)
         result[#result+1] = ", "
      end
      result[#result] = ")"
      return table.concat(result)
   end,
   
   __ipairs = function(t)
      local front_len, back_len = #t._front, #t._back
      local size = front_len + back_len
      local iter = function(t, index)
         index = index + 1
         if index > size then return nil end

         if index <= front_len then
            local value = t._front:get(front_len - index)
            return index, value
         else
            local value = t._back:get(index - front_len)
            return index, value
         end
      end
      return iter, t, 0
   end,
   
   __pairs = function(_)
      error("Use 'ipairs' to iterate over this sequence.")
   end,

   __eq = function(a, b)
      return Queue.isequal(a, b)
   end
}

function Queue.new(xs)
   local new = {
      _tag = "queue",
      _front = Array.new(),
      _back = Array.new(xs)
   }
   setmetatable(new, mt)
   return new
end

function Queue:push(...)
   self._back:push(...)
   return self
end

function Queue:pushfirst(...)
   self._front:push(...)
   return self
end

function Queue:pop()
   if self._front:isempty() then
      self._front = self._back:reverse()
      self._back = Array.new()
   end
   local elem = self._front:pop()
   return elem
end

function Queue:poplast()
   if #self._back == 0 then
      local elem = self._front[1]
      self._front:remove(1)
      return elem
   else
      local elem = self._back:pop()
      return elem
   end
end

function Queue:peek()
   if self:isempty() then return nil
   elseif self._front:isempty() then return self._back:get(1)
   else return self._front:peek()
   end
end

function Queue:size()
   return self._front:size() + self._back:size()
end

function Queue:isempty()
   return self._front:isempty() and self._back:isempty()
end

function Queue:get(index)
   if is_within_bounds(index, self:size()) then
      local front_len = self._front:size()
      if index <= front_len then
         return self._front:get(front_len - index + 1)
      else
         return self._back:get(index - front_len)
      end
   else
      error("Index "..tostring(index).." is out of bounds.")
   end
end

function Queue:set(index, value)
   assert(is_positive_integer(index), "Index must be a positive integer.")
   assert(value ~= nil, "Value cannot be nil.")
   assert(index <= self:size(), "Index "..tostring(index).." is out of bounds. Use 'Queue:push' to add a new element.")
   local front_len = self._front:size()
   if index <= front_len then
      self._front:set(front_len - index + 1, value)
   else
      self._back:set(index - front_len, value)
   end
   return self
end

function Queue:isequal(q)
   assert(q._tag == "queue", "bad argument #1 to 'Queue:isequal' (expected queue)")
   if self:size() ~= q:size() then return false end
   for index = 1, self:size() do
      if not Common.sequence_isequal(self:get(index), q:get(index)) then
         return false
      end
   end
   return true
end

function Queue:append(q)
   local is_table = type(q) == "table"
   local is_queue = is_table and q._tag == "queue"
   assert(is_table or is_queue == "queue", "bad argument #1 to 'Queue:isequal' (expected table or queue)")
   if is_queue then
      self._back:append(q:toarray())
   elseif is_table then
      self._back:append(q)
   end
   return self
end

function Queue:toarray()
   return self._front:reverse():append(self._back)
end

function Queue:totable()
   return self:toarray:totable()
end

function Queue:remove(index)
   if is_within_bounds(index, self:size()) then
      local front_len = self._front:size()
      if index <= front_len then
         self._front:remove(front_len - index + 1)
      else
         self._back:remove(index - front_len)
      end
   else
      error("Index "..tostring(index).." is out of bounds.")
   end
   return self
end

function Queue:map(f)
   assert(type(f) == "function", "bad argument #1 to 'Queue:map' (expected function)")
   local result = Queue.new()
   for _, v in ipairs(self) do
      result:push(f(v))
   end
   return result
end

function Queue:foreach(f)
   assert(type(f) == "function", "bad argument #1 to 'Queue:foreach' (expected function)")
   for _, v in ipairs(self) do f(v) end
end

function Queue:filter(predicate)
   assert(type(f) == "function", "bad argument #1 to 'Queue:filter' (expected function)")
   local result = Queue.new()
   for _, v in ipairs(self) do
      if predicate(v) then
         result:push(v)
      end
   end
   return result
end

function Queue:foldl(f, acc)
   assert(type(f) == "function", "bad argument #1 to 'Queue:foldl' (expected function)")
   for _, v in ipairs(self) do
      acc = f(v, acc)
   end
   return acc
end

function Queue:foldr(f, acc)
   assert(type(f) == "function", "bad argument #1 to 'Queue:foldr' (expected function)")
   for k = self:size(), 1, -1 do
      local v = self:get(k)
      acc = f(v, acc)
   end
   return acc
end

Queue.__index = Queue
setmetatable(
   Queue,
   {
      __call = function(_, xs) return Queue.new(xs) end
   }
)

return Queue
