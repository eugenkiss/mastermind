-- Strategy that uses the worst case algorithm also known as the "Knuth
-- Algorithm" after its creator Donald Knuth. In addition this strategy tries 
-- to minimize the travel distance.

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
  local bestGuesses = {consistentCodes[1]}
  local totalSize = #consistentCodes
  local maxScore = 1
  for _,code in ipairs(allCodes) do
    local score = math.huge
    for _,answer in ipairs(allAnswers) do
      local removals = totalSize - #getConsistentCodes(consistentCodes, code,
          answer.blacks, answer.whites)
      score = min(removals, score)
    end
    if score == maxScore and score > 0 then
      bestGuesses[#bestGuesses+1] = code 
    end
    if score > maxScore then
      maxScore = score
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
