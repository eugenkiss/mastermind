-- A simple strategy that removes inconsistent codes from all possible 
-- codes until the secret code is narrowed down. In addition this strategy 
-- tries to minimize the travel distance for the robot.

local util = require 'strategies.util'
local createAllCodes = util.createAllCodes
local getConsistentCodes = util.getConsistentCodes
local getShortestCode = util.getShortestCode

-- Main logic

local allCodes = createAllCodes(CODE_LENGTH)
local consistentCodes = {}
local lastGuess = nil
local lastButton = {x=0,y=0}

local function reset()
  for i,code in ipairs(allCodes) do
    consistentCodes[i] = code
  end
  lastGuess = getShortestCode(lastButton, consistentCodes)
  lastButton = lastGuess[CODE_LENGTH]
  return lastGuess
end

local function guess(blacks, whites)
  consistentCodes = getConsistentCodes(consistentCodes, lastGuess, 
      blacks, whites)
  lastGuess = getShortestCode(lastButton, consistentCodes)
  lastButton = lastGuess[CODE_LENGTH]
  return lastGuess
end

return {
  reset = reset,
  guess = guess
}
