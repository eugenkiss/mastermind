--- Utility functions.
require "socket"
local M = {}

--- Print a formatted string.
-- Use __tostring method on tables that provide the function.
local function printf(s, ...)
  local t = {}
  for i,v in ipairs{...} do
    if type(v) == 'table' and v.__tostring then
      t[i] = tostring(v)
    else
      t[i] = v
    end
  end
  io.write(s:format(unpack(t)))
  io.flush() 
end
M.printf = printf

--- Create a read only table.
-- Usage: t = readOnly{'a', 'b', 'c'}
local function readOnly(t)
  local proxy = {}
  local mt = {
    __index = t,
    __newindex = function (t,k,v)
      error("attempt to update a read-only table", 2)
    end
  }
  setmetatable(proxy, mt)
  return proxy
end
M.readOnly = readOnly

--- Sleep for n milliseconds without busy wait.
local function sleep(n)
  socket.select(nil, nil, n/1000)
end
M.sleep = sleep

--- Get a higher resolution time than os.time()
local function gettime()
  return socket.gettime()*1000
end
M.gettime = gettime

--- Round a number 'num' to 'idp' decimal places.
local function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
M.round = round

--- Return true if the element x is in Table t.
local function isin(t, x)
  for _,t_i in pairs(t) do
    if t_i == x then return true end
  end
  return false
end
M.isin = isin

--- Return the sublist from index u to o (inclusive) from t.
local function slice(t, u, o)
  local res = {}
  for i=u,o do
    res[#res+1] = t[i]
  end
  return res
end
M.slice = slice

return M
