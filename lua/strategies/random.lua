-- A strategy that always guesses randomly.

local createRandomCode = require 'simulation'.createRandomCode

local function reset()
  return createRandomCode(CODE_LENGTH)
end

local function guess(blacks, whites)
  return createRandomCode(CODE_LENGTH)
end

return {
  reset = reset,
  guess = guess
}
