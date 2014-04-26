-- A bot which uses only part of the information of the answer and thus is not
-- very effective. Plus, it does not try to minimze the travel distance.

local util = require 'strategies.util'
local createAllCodes = util.createAllCodes

local function compareCodes(s1, s2)
  local correctPositions = 0
  for i=1,#s1 do
    if s2[i] == s1[i] then
      correctPositions = correctPositions + 1
    end
  end
  return correctPositions
end

local function getConsistentCodes(codes, guess, blacks, whites)
  local res = {}
  for _,code in ipairs(codes) do
    local b = compareCodes(guess, code)
    if b == blacks then
      res[#res+1] = code
    end
  end
  return res
end

-- Main logic

local allCodes = createAllCodes(CODE_LENGTH)
local consistentCodes = {}
local lastGuess = nil
local lastButton = {x=0,y=0}

local function reset()
  for i,code in ipairs(allCodes) do
    consistentCodes[i] = code
  end
  lastGuess = consistentCodes[1]
  lastButton = lastGuess[CODE_LENGTH]
  return lastGuess
end

local function guess(blacks, whites)
  consistentCodes = getConsistentCodes(consistentCodes, lastGuess, 
      blacks, whites)
  lastGuess = consistentCodes[1]
  lastButton = lastGuess[CODE_LENGTH]
  return lastGuess
end

return {
  reset = reset,
  guess = guess
}
