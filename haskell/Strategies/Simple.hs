-- | The simple strategy keeps a pool of possible secret codes around. After
-- each guess the inconsistent codes, i.e. the codes that can't possibly be the
-- secret code anymore, are removed from the pool so that the pool shrinks on
-- and on after each guess until it is so small that the secret code is
-- cracked.
-- 
-- Additionally, the to-be-entered code which is chosen from the pool is the
-- one that results in the minimal travel distance for the robot. This way time
-- is saved and more codes can be entered in the given time limit as opposed to
-- a strategy that would for example always pick the first code from the pool.

module Strategies.Simple (simple) where

import Strategies.Util

simple = Strategy 
  { initialize   = initializeStrategyState 
  , extractGuess = extractGuess'
  , updateState  = updateState'
  }

extractGuess' :: StrategyState -> Code
extractGuess' = guess

updateState' :: Answer -> StrategyState -> StrategyState
updateState' answer st 
    | isCorrect answer (codeLength st) = reset st 
    | otherwise =
        let lastPos     = getPos $ last $ guess st
            consistent' = getConsistentCodes answer (guess st) $ consistent st
            shortest    = getShortestCode lastPos consistent'
        in st { guess = shortest, consistent = consistent' }
