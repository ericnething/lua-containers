local Queue = {}

local ArrayList = require "arraylist"

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

function Queue.new(xs)
   local new = {
      _tag = "queue",
      _head = ArrayList(),
      _tail = ArrayList(xs)
   }

   local methods = {
      push = function(self, ...)
         self._tail:push(...)
         return self
      end,
      pushfirst = function(self, ...)
         self._head:push(...)
         return self
      end,
      pop = function(self)
         if #self._head == 0 then
            self._head = self._tail:reverse()
            self._tail = ArrayList()
         end
         local elem = self._head:pop()
         return elem
      end,
      poplast = function(self)
         if #self._tail == 0 then
            local elem = self._head[1]
            self._head:delete(1)
            return elem
         else
            local elem = self._tail:pop()
            return elem
         end
      end,
      peek = function(self)
         if #self == 0 then
            return nil
         elseif #self._head == 0 then
            return self._tail[1]
         else
            return self._head:peek()
         end
      end
   }

   local mt = {
      __newindex = function(t, key, v)
         assert(is_positive_integer(key), "Index must be a positive integer.")
         assert(v ~= nil, "Value cannot be nil.")
         assert(key <= #t, "Index "..tostring(key).." is out of bounds. Use :push() to add a new element.")

         local head_len = #t._head
         if key <= head_len then
            t._head[head_len - key] = v
         else
            t._tail[key - head_len] = v
         end
         return t
      end,
      __index = function(t, key)

         if is_number(key) then
            if is_within_bounds(key, #t) then
               return t[key]
            else
               error("Index "..tostring(key).." is out of bounds.")
            end
         end
         
         local method = rawget(methods, key)
         if method then
            return method
         else
            error("Method not found.")
         end
      end,
      __len = function(t, k)
         return #t._head + #t._tail
      end,
      __tostring = function(t)
         local result = {"queue("}
         for k=#t._head,1,-1 do
            result[#result+1] = tostring(t._head._data[k])
            resukt[#result+1] = ", "
         end
         for _, v in ipairs(t._tail) do
            result[#result+1] = tostring(v)
            result[#result+1] = ", "
         end
         result[#result] = ")"
         return table.concat(result)
      end,
      __ipairs = function(t)
         local head_len, tail_len = #t._head, #t._tail
         local size = head_len + tail_len
         local iter = function(t, index)
            index = index + 1
            if index > size then return nil end

            if index <= head_len then
               local value = t._head[head_len - index]
               return index, value
            else
               local value = t._tail[index - head_len]
               return index, value
            end
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
   Queue,
   {
      __call = function(_, xs) return Queue.new(xs) end
   }
)

return Queue
