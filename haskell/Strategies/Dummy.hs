-- | The dummy strategy always guesses the same code consisting of the buttons
-- T0,...,Tx where x is the length.

module Strategies.Dummy (dummy) where

import Strategies.Util

dummy = Strategy 
  { initialize   = initialize' 
  , extractGuess = extractGuess'
  , updateState  = updateState'
  }

-- | Memorize the code length.
initialize' :: Int -> Int
initialize' = id

-- | Always return the same guess.
extractGuess' :: Int -> Code
extractGuess' length = map (buttons !!) [0..length-1]

-- | Do not update any state.
updateState' :: Answer -> Int -> Int
updateState' = flip const 
