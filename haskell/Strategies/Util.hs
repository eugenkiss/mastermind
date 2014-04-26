-- | This module provides utility functions for strategies to reduce code
-- duplication since most strategies need this basic set of helper functions.

module Strategies.Util 
  ( StrategyState(..)
  , initializeStrategyState
  , getConsistentCodes
  , getShortestCode
  , getDefaultGuess
  , reset
    -- Reexport from Simulation.hs
  , Strategy(..) 
  , Code 
  , Codes 
  , Answer(..) 
  , Answers 
  , Button 
  , Position
  , buttons 
  , getPos
  , calcDrivingDistance 
  , compareCodes
  , isCorrect
  ) where

import Data.Ord (comparing)
import Data.List (sortBy)
import Control.Monad.State (State, put, get)
import Simulation 
  ( Strategy(..) 
  , Code 
  , Codes 
  , Answer(..) 
  , Answers 
  , Button 
  , Position 
  , buttons 
  , getPos 
  , calcDrivingDistance 
  , compareCodes
  , isCorrect
  )

-- | All needed state for a good strategy.
data StrategyState = StrategyState 
  { codeLength :: Int
  , allCodes   :: Codes
  , allAnswers :: Answers
  , consistent :: Codes
  , guess      :: Code
  }

-- | Initialize the state for a strategy depending on the code length.
initializeStrategyState :: Int -> StrategyState
initializeStrategyState length = StrategyState 
  { codeLength = length
  , allCodes   = createAllCodes length
  , allAnswers = createAllAnswers length
    -- TODO: How can I prevent this needless recomputation?
  , consistent = createAllCodes length
  , guess      = getDefaultGuess length
  }

-- TODO: Maybe use memozation for createAllAnswers and createAllCodes so that
-- less state is needed for the strategy.

-- | Create a list of all /possible/ blacks and whites combinations. This is
-- especially useful for the more sophisticated algorithms.
createAllAnswers :: Int -> Answers
createAllAnswers length = 
    [ Answer b w | b <- [0..length], w <- [0..length], 
                   b + w <= length, not $ b == length-1 && w == 1 ] 

-- | Create a list of all possible codes with a specific length.
createAllCodes :: Int -> Codes
createAllCodes 0 = [[]]
createAllCodes length = [ c:r | c <- buttons, r <- createAllCodes (length-1) ]

-- | Return a filtered list of all codes that might be the secret code. 
getConsistentCodes :: Answer -> Code -> Codes -> Codes
getConsistentCodes answer secretCode codes = filter isConsistent codes
    where isConsistent code = compareCodes secretCode code == answer

-- | Return a code that would result in the shortest travel distance.
getShortestCode :: Position -> Codes -> Code
getShortestCode lastPosition codes = head $ sortBy (comparing distance) codes
    where distance = calcDrivingDistance lastPosition
    
-- | Return the code consisting of the buttons T0,...,Tx where x is the length.
getDefaultGuess :: Int -> Code
getDefaultGuess length = map (buttons !!) [0..length-1] 

-- | Refill the codes with all possible codes and return the shortest one
-- relative to the robot's current position.
reset :: StrategyState -> StrategyState
reset st = let lastPos  = getPos $ last $ guess st
               shortest = getShortestCode lastPos $ allCodes st
           in st { guess = shortest, consistent = allCodes st }
