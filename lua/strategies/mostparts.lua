-- A strategy that seeks to maximize the parts of a partition.

local util = require 'strategies.util'
local createAllAnswers = util.createAllAnswers
local createAllCodes = util.createAllCodes
local getConsistentCodes = util.getConsistentCodes
local getShortestCode = util.getShortestCode
local pow = math.pow

-- Associate a number with each button.
local buttonValue = {
  [T[0]] = 0,
  [T[1]] = 1,
  [T[2]] = 2,
  [T[3]] = 3,
  [T[4]] = 4,
  [T[5]] = 5,
  [T[6]] = 6,
  [T[7]] = 7,
}

--- Represent a guess with a unique number.
-- E.g. if guess = (T[0],T[2],T[5],T[7]) return 7520.
local function hashGuess(guess)
  local hash = 0
  for i,button in ipairs(guess) do
    hash = hash + pow(10, i) * buttonValue[button]
  end
  return hash
end

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
  -- This part is essential for this strategy
  if #consistentCodes == 1 then 
    lastGuess = consistentCodes[1]
    lastButton = lastGuess[CODE_LENGTH]
    return lastGuess
  end
  local bestGuesses = {consistentCodes[1]}
  local mostParts = 0
  for _,code in ipairs(allCodes) do
    local parts = 0
    local partSizes = {}
    local partHashes = {}
    local new = true
    for i,answer in ipairs(allAnswers) do
      local partition = getConsistentCodes(consistentCodes, code,
          answer.blacks, answer.whites)
      local size = #partition
      local hash = size > 0 and hashGuess(partition[1]) or 0
      -- A partition is new if its cardinality was not encountered before
      -- and the hash of its first element was not encountered either. This 
      -- distinction is sufficient to distinguish partitions because the 
      -- getConsistentCodes function does not alter the order of the elements 
      -- in the list it returns.
      new = true
      for i=1,#partSizes do
        if size == partSizes[i] and hash == partHashes[i] then
          new = false
          break
        end
      end
      if new then
        partHashes[#partHashes+1] = hash
        partSizes[#partSizes+1] = size
        parts = parts + 1
      end        
    end
    if parts == mostParts and parts > 1 then
      bestGuesses[#bestGuesses+1] = code 
    end
    if parts > mostParts then
      mostParts = parts
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
