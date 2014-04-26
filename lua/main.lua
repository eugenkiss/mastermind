require 'lib.getopt'
local util = require 'lib.util'
local printf = util.printf
local simulation = require 'simulation'

--- Load a strategy by injecting T and CODE_LENGTH into it.
local function dofile(filename, CODE_LENGTH)
  local f = assert(loadfile(filename))
  local env = getfenv(f)
  env.T = simulation.T
  env.CODE_LENGTH = CODE_LENGTH
  setfenv(f, env)
  return f()
end

-- Parse the command line arguments.
local opts = getopt(arg, 'trlfsc')
local TIME_LIMIT = tonumber(opts['t']) or 360
local CPU_SLOWNESS = tonumber(opts['c']) or 1
local ROBOT_SPEED = tonumber(opts['r']) or 920
local CODE_LENGTH = tonumber(opts['l']) or 4
local SIMULATIONS = tonumber(opts['s']) or 3
local STRATEGY = dofile(opts['f'], CODE_LENGTH)

-- Print the title.
printf('\n')
local title = "Testing '" .. opts['f'] .. "'"
printf(title .. '\n')
for i=1,#title do
  printf('=')
end
printf('\n\n')

-- Print the parameters and the progress bar.
printf('Time Limit:   ' .. TIME_LIMIT .. ' [s]\n')
printf('Robot Speed:  ' .. ROBOT_SPEED .. ' [mm/s]\n')
printf('Code Length:  ' .. CODE_LENGTH .. '\n')
printf('CPU Slowness: ' .. CPU_SLOWNESS .. '\n')
printf('Simulations:  ' .. SIMULATIONS .. '\n\n')
printf('[..........]\n')
printf(' ')

-- Start the simulation and keep statistics.
math.randomseed(util.gettime())
local stats = {} 
local progress = 0
for i=1,SIMULATIONS do
  stats[i] = simulation.run(TIME_LIMIT, CPU_SLOWNESS, ROBOT_SPEED, 
      CODE_LENGTH, STRATEGY)
  -- Print the progress
  local doneYet = i / SIMULATIONS
  for j=1,10 do
    if doneYet >= j / 10 and progress < j then
      printf('^')
      progress = progress + 1
    end
  end
end
printf('\n\n')

-- Calculate the values for successes and expected.
local successesSum = 0
local expectedSum = 0
for _,s in ipairs(stats) do
  for round,successes in pairs(s.successesPerRound) do
    successesSum = successesSum + successes
    expectedSum = expectedSum + (round * successes)
  end
end
local successesAverage = successesSum / SIMULATIONS
local expectedAverage = successesSum == 0 and math.huge or expectedSum / successesSum

-- Calculate percentages for the thinking and driving time.
local totalThinkingTime = 0
local totalDrivingTime = 0
for _,s in ipairs(stats) do
  totalThinkingTime = totalThinkingTime + s.thinkingTime
  totalDrivingTime = totalDrivingTime + s.drivingTime
end
local totalTime = totalThinkingTime + totalDrivingTime
local relativeThinkingTime = totalThinkingTime / totalTime * 100
local relativeDrivingTime = totalDrivingTime / totalTime * 100

-- Calculate the values for the result table.
local maxRound = 8
local tableEntries = {}
for i=1,8 do
  tableEntries[i] = 0
end
for _,s in ipairs(stats) do
  for j=1,maxRound-1 do
    local successes = s.successesPerRound[j] or 0
    tableEntries[j] = tableEntries[j] + successes
  end
end
-- Calculate rounds >= maxRound.
local sum = 0
for i=1,maxRound-1 do
  sum = sum + tableEntries[i]
end
tableEntries[maxRound] = successesSum - sum
-- Transform into relative values
for i=1,maxRound do
  tableEntries[i] = tableEntries[i] / successesSum * 100
end

-- Print the results.
printf('Results\n')
printf('-------\n\n')
printf('Successes: %.5f\n', successesAverage)
printf('Expected:  %.5f [Guesses/Success]\n\n', expectedAverage)
printf('Driving Time:  %.2f [%%]\n', relativeDrivingTime)
printf('Thinking Time: %.2f [%%]\n\n', relativeThinkingTime)
printf('|   1   |   2   |   3   |   4   |   5   |   6   |   7   |  >=8  | [Round]\n')
printf('|===============================================================|\n')
printf('| ')
for i=1,maxRound do
  local percent = tableEntries[i]
  local formatted = string.format('%.2f', percent)
  if #formatted == 4 then formatted = '0'..formatted end
  if formatted == '100.00' then formatted = '100.0' end
  printf('%s | ', formatted)
end
printf('[%%]\n\n')
