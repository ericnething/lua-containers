local Queue = {}

Queue.__index = Queue

function Queue.new(array)
   local result = array or {}
   result.last = #result
   result.first = 1
   setmetatable(result, Queue)
   return result
end

function Queue:push(...)
   for _, item in ipairs({...}) do
      self.last = self.last + 1
      self[self.last] = item
   end
   return self
end

function Queue:pop()
   local item = self[self.first]
   if item then
      self.first = self.first + 1
   end
   return item
end

function Queue:append(queue)
   assert(type(queue) == "table", "bad argument #2 to ':append' (expected table)")
   return self:push(table.unpack(queue))
end

function Queue:size()
   return self.last - self.first + 1
end

function Queue:isempty()
   return self:length() == 0
end

setmetatable(
   Queue,
   {
      __call = function(_, array)
         return Queue.new(array)
      end
   }
)

return Queue
