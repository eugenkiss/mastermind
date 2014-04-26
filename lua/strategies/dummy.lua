-- A dummy mastermind miniproject strategy.
-- Only two functions must be provided by a strategy: reset and guess.
-- Additional utility/helper functions can be created of course. Two global
-- variables are injected: T, a table representing the buttons, and
-- CODE_LENGTH, the length of the claimed sequence.
-- T[0]...T[7] map to the respective buttons in the miniproject. Each button
-- has an x and y coordinate.
-- It would be wise to write your bot in a way that it can handle different
-- CODE_LENGTHs. That is, the bot can can be used for sequences of length 1 
-- but equally for sequences of length 7.

--- Reset the state of the strategy and return the first guess.
local function reset()
  -- This function is called once before the game and after each correct guess.
  -- res would be '{T[0],T[1],T[2],T[3]}' if CODE_LENGTH was 4.
  local res = {}
  for i=0,CODE_LENGTH-1 do
    res[#res+1] = T[i]
  end
  return res
end

--- Return a guess based on the information provided by blacks and whites.
-- blacks states how many buttons were in the correct position in the last
-- guess and whites states how many buttons were indeed in the sequence but in
-- the wrong position.
local function guess(blacks, whites)
  -- res would be '{T[0],T[1],T[2],T[3]}' if CODE_LENGTH was 4.
  local res = {}
  for i=0,CODE_LENGTH-1 do
    res[#res+1] = T[i]
  end
  return res
end

-- Don't remove! This is obligatory!
return {
  reset = reset,
  guess = guess
}
