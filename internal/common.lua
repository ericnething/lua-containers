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

function sequence_isequal(a, b)
   if type(a) ~= type(b) then
      return false
   end
   local type_a = type(a)
   if type_a == "number" or
      type_a == "string" or
      type_a == "boolean" or
      type_a == "nil"
   then
      return a == b
   elseif type(a) == "table" then
      if #a ~= #b then
         return false
      else
         for k = 1, #a do
            if not sequence_isequal(a[k], b[k]) then
               return false
            end
         end
      end
      return true
   else
      return false
   end
end

function unordered_isequal(a, b)
   local keys = function(t)
      local result = {}
      for k in pairs(t) do
         result[#result + 1] = k
      end
      return result
   end
   
   if type(a) ~= type(b) then
      return false
   end
   local type_a = type(a)
   if type_a == "number" or
      type_a == "string" or
      type_a == "boolean" or
      type_a == "nil"
   then
      return a == b
   elseif type(a) == "table" then
      local a_keys, b_keys = keys(a), keys(b)
      if #a_keys ~= #b_keys then
         return false
      else
         for _, key in ipairs(a_keys) do
            if not unordered_isequal(a[key], b[key]) then
               return false
            end
         end
      end
      return true
   else
      return false
   end
end

function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            copies[orig] = copy
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return {
   is_number = is_number,
   is_integer = is_integer,
   is_positive_integer = is_positive_integer,
   is_within_bounds = is_within_bounds,
   sequence_isequal = sequence_isequal,
   unordered_isequal = unordered_isequal,
   deepcopy = deepcopy
}
