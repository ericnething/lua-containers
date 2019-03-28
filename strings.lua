local String = {}

function String.foreach(f, s)
   s:gsub(".", f)
end

function String.iter(s)
   return s:gmatch(".")
end

function String.toarray(s)
   local result = {}
   s:gsub(".", function(c)
             result[#result+1] = c
   end)
   return result
end

return String
