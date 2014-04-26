--- Common functions that are needed by almost any good strategy.

local util = require 'lib.util'
local isin = util.isin
local slice = util.slice
local simulation = require 'simulation'
local T = simulation.T
local calcDrivingDistance = simulation.calcDrivingDistance
local compareCodes = simulation.compareCodes

local function _createAllCodes(codes, code, length)
  if length == 0 then
    codes[#codes+1] = {unpack(code)}
  else
    for i=0,7 do
      code[length] = T[i]
      _createAllCodes(codes, code, length-1)
    end
  end
end

--- Create a list of all possible codes with a length of 'length'.
local function createAllCodes(length)
  local codes = {}
  _createAllCodes(codes, {}, length)
  return codes
end

--- Return a list of all codes in 'set' that might be the secret code.
local function getConsistentCodes(codes, guess, blacks, whites)
  local res = {}
  for _,code in ipairs(codes) do
    local answer = compareCodes(guess, code)
    if answer.blacks == blacks and answer.whites == whites then
      res[#res+1] = code
    end
  end
  return res
end

--- Return the code from 'codes' that would result in the shortest travel
--- distance.
local function getShortestCode(lastPosition, codes)
  local minDistance = math.huge
  local shortestCode = nil
  for _,code in ipairs(codes) do
    local distance = calcDrivingDistance(lastPosition, code)
    if distance < minDistance then
      minDistance = distance
      shortestCode = code
    end
  end
  return shortestCode
end

--- List of all *possible* blacks and whites combinations.
-- Especially useful for the more sophisticated algorithms.
local function createAllAnswers(length)
  local res = {}
  for blacks=0,length do
    for whites=0,length do
      if blacks + whites <= length
         and not (blacks == length-1 and whites == 1) -- impossible
         then
        res[#res+1] = {blacks=blacks, whites=whites}
      end
    end
  end
  return res
end

return {
  createAllAnswers = createAllAnswers,
  createAllCodes = createAllCodes,
  getConsistentCodes = getConsistentCodes,
  getShortestCode = getShortestCode
}
