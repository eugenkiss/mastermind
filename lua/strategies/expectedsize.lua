-- A strategy that seeks to maximize the expected payoff.
-- TODO: There seems to be a misunderstanding of this strategy on my side
-- since I needed to use an ugly fix to make it work.

local util = require 'strategies.util'
local createAllAnswers = util.createAllAnswers
local createAllCodes = util.createAllCodes
local getConsistentCodes = util.getConsistentCodes
local getShortestCode = util.getShortestCode
local min = math.min
local pow = math.pow

-- Main logic

local allCodes = createAllCodes(CODE_LENGTH)
local allAnswers = createAllAnswers(CODE_LENGTH)
local consistentCodes = {}
local lastGuess = nil
local lastButton = {x=0,y=0}
local lastSize -- Needed to fix strange behaviour

local function reset()
  for i,code in ipairs(allCodes) do
    consistentCodes[i] = code
  end
  lastGuess = getShortestCode(lastButton, consistentCodes)
  lastButton = lastGuess[CODE_LENGTH]
  return lastGuess
end

local function guess(blacks, whites)
  lastSize = #consistentCodes
  consistentCodes = getConsistentCodes(consistentCodes, lastGuess, 
      blacks, whites)
  -- Fix strange behaviour
  if lastSize == #consistentCodes then
    lastGuess = getShortestCode(lastButton, consistentCodes)
    lastButton = lastGuess[CODE_LENGTH]
    return lastGuess
  end
  local bestGuesses = {consistentCodes[1]}
  local totalSize = #consistentCodes
  local minExpectedSize = math.huge
  for _,code in ipairs(allCodes) do
    local expectedSize = 0
    for _,answer in ipairs(allAnswers) do
      local partSize = #getConsistentCodes(consistentCodes, code, 
          answer.blacks, answer.whites)
      expectedSize = expectedSize + pow(partSize, 2) / totalSize
    end
    if expectedSize == minExpectedSize then
      bestGuesses[#bestGuesses+1] = code
    end
    if expectedSize < minExpectedSize then
      minExpectedSize = expectedSize
      bestGuesses = {code}
    end
  end
  -- Use, if possible, consistent codes
  local consistentBestGuesses = getConsistentCodes(bestGuesses, lastGuess, 
      blacks, whites)
  if #consistentBestGuesses ~= 0 then bestGuesses = consistentBestGuesses end
  -- Use a code with the shortest travel distance
  lastGuess = getShortestCode(lastButton, bestGuesses)
  lastButton = lastGuess[CODE_LENGTH]
  return lastGuess
end

return {
  reset = reset,
  guess = guess
}
