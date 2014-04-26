local util = require 'lib.util'
local isin = util.isin
local sqrt, pow = math.sqrt, math.pow

-- The buttons as given in the task.
local T = util.readOnly{
  [0] = {x=-460, y=982},
  [1] = {x=460, y=982},
  [2] = {x=982, y=460},
  [3] = {x=982, y=-460},
  [4] = {x=460, y=-982},
  [5] = {x=-460, y=-982},
  [6] = {x=-982, y=-460},
  [7] = {x=-982, y=460}
}

--- Return the euklidian distance of two points in the two dimensional space.
local function calcDistance(t1, t2)
  return sqrt(pow(t1.x - t2.x, 2) + pow(t1.y - t2.y, 2))
end

--- Calculate the driving distance in mm for a specific guess.
-- lastButton may be null. The robot's position is then interpreted to be
-- the center of the area.
local function calcDrivingDistance(lastButton, guess)
  --local lastButton = lastButton or {x=0,y=0}
  local distance = calcDistance(lastButton, guess[1])
  for i=1,#guess-1 do
    distance = distance + calcDistance(guess[i], guess[i+1])
  end
  return distance
end

--- Calculate the time in ms for a distance in mm and a robotSpeed in mm/s.
local function calcDrivingTime(distance, robotSpeed)
  return (distance / robotSpeed) * 1000 
end

--- Measure the elapsed time in ms for the execution of function f.
-- Return a tuple whith the elapsed time as the first result and f's result
-- as the second result. The arguments to f are the remaining arguments of
-- this function.
local function measureTime(f, ...)
  local startTime = util.gettime()
  local result = f(...)
  local elapsedTime = util.gettime() - startTime
  return elapsedTime, result
end

--- Return a permutation with repetitions of {T[0],...,T[7]} of length n.
local function createRandomCode(n)
  local sequence = {}
  for i=1,n do
    sequence[i] = T[math.random(0, 7)]
  end
  return sequence
end

--- Return a mastermind answer consisting of the number of blacks and whites
--- for a guess s1 and a secret code s2 (although s2 does not always has to
--- be the secret code).
local function compareCodes(s1, s2)
  local correctPositions = 0
  local correctButtons = 0
  for i=1,#s1 do
    if s2[i] == s1[i] then
      correctPositions = correctPositions + 1
    elseif isin(s1, s2[i]) then
      correctButtons = correctButtons + 1
    end
  end
  return {blacks=correctPositions, whites=correctButtons}
end

--- Run the simulation and return a statistics table.
local function run(timeLimit, CPUSlowness, robotSpeed, codeLength, strategy)
  -- Several statistics of a single simulation
  local stats = {
    -- Save how many correct guesses have been achieved in each round. The 
    -- key is the respective round and the value is the number of successes 
    -- in that round
    successesPerRound = {},
    -- Total time used for deciding for the next guess in ms
    thinkingTime = 0,
    -- Total time used for driving in ms
    drivingTime = 0,
  }
  -- Convert time limit into milliseconds
  local timeLimit = timeLimit * 1000 
  -- Decide for a secret code
  local secretCode = createRandomCode(codeLength)
  -- Keep track of the current round. Reset after a correct guess
  local roundCounter = 1
  -- Start in the center of the area
  local lastPosition = {x=0, y=0} 
  -- Get the strategy's first guess
  local guess, distance, elapsed, answer
  elapsed, guess = measureTime(strategy.reset)
  stats.thinkingTime = stats.thinkingTime + elapsed * CPUSlowness
  distance = calcDrivingDistance(lastPosition, guess)
  elapsed = calcDrivingTime(distance, robotSpeed)
  stats.drivingTime = stats.drivingTime + elapsed

  while stats.thinkingTime + stats.drivingTime < timeLimit do
    answer = compareCodes(guess, secretCode)
    if answer.blacks == codeLength then -- a correct guess
      secretCode = createRandomCode(codeLength)
      local old = stats.successesPerRound[roundCounter] or 0
      stats.successesPerRound[roundCounter] = old + 1
      elapsed, guess = measureTime(strategy.reset)
      stats.thinkingTime = stats.thinkingTime + elapsed * CPUSlowness
      roundCounter = 0
    else -- an incorrect guess
      elapsed, guess = measureTime(strategy.guess, answer.blacks, answer.whites)
      stats.thinkingTime = stats.thinkingTime + elapsed * CPUSlowness
      roundCounter = roundCounter + 1
    end
    distance = calcDrivingDistance(lastPosition, guess)
    elapsed = calcDrivingTime(distance, robotSpeed)
    stats.drivingTime = stats.drivingTime + elapsed
    lastPosition = guess[codeLength]
  end
  return stats
end

return {
  T = T,
  calcDistance = calcDistance,
  createRandomCode = createRandomCode,
  compareCodes = compareCodes,
  calcDrivingDistance = calcDrivingDistance,
  run = run
}
