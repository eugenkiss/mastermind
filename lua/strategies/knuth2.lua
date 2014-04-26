-- In contrast to knuth this strategy does *not* try to minimize the travel
-- distance.

local util = require 'strategies.util'
local createAllAnswers = util.createAllAnswers
local createAllCodes = util.createAllCodes
local getConsistentCodes = util.getConsistentCodes
local getShortestCode = util.getShortestCode
local min = math.min

-- Main logic

local allCodes = createAllCodes(CODE_LENGTH)
local allAnswers = createAllAnswers(CODE_LENGTH)
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
  lastGuess = consistentCodes[1]
  local totalSize = #consistentCodes
  local maxScore = 1
  for _,code in ipairs(allCodes) do
    local score = math.huge
    for _,answer in ipairs(allAnswers) do
      local removals = totalSize - #getConsistentCodes(consistentCodes, code,
          answer.blacks, answer.whites)
      score = min(removals, score)
    end
    if score > maxScore then
      maxScore = score
      lastGuess = code
    end
  end
  lastButton = lastGuess[CODE_LENGTH]
  return lastGuess
end

return {
  reset = reset,
  guess = guess
}
