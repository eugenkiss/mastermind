-- A alternative to entropy.lua.
-- The base set for this alternative are not all possible guesses but instead
-- only the consistent guesses. Therefore it is much faster than entropy.lua
-- but, of course, it also needs more average guesses than entropy.lua. Still,
-- this might be a reasonable tradeoff.

local util = require 'strategies.util'
local createAllAnswers = util.createAllAnswers
local createAllCodes = util.createAllCodes
local getConsistentCodes = util.getConsistentCodes
local getShortestCode = util.getShortestCode
local min = math.min
local log = math.log

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
  local bestGuesses = {consistentCodes[1]}
  local maxEntropy = 0
  local totalSize = #consistentCodes
  for _,code in ipairs(consistentCodes) do
    local entropy = 0
    for _,answer in ipairs(allAnswers) do
      local partSize = #getConsistentCodes(consistentCodes, code, 
          answer.blacks, answer.whites)
      if partSize ~= 0 then
        local I = log(totalSize / partSize) / log(2)
        local P = partSize / totalSize
        entropy = entropy + I * P
      end
    end
    if entropy == maxEntropy and entropy > 0 then
      bestGuesses[#bestGuesses+1] = code 
    end
    if entropy > maxEntropy then
      maxEntropy = entropy
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
