-- | The simple2 strategy keeps a pool of possible secret codes around. After
-- each guess the inconsistent codes, i.e. the codes that can't possibly be the
-- secret code anymore, are removed from the pool so that the pool shrinks on
-- and on after each guess until it is so small that the secret code is
-- cracked.
-- 
-- In contrast to the simple strategy simple2 does not optimize the travel 
-- distance for the robot.

module Strategies.Simple2 (simple2) where

import Strategies.Util

simple2 = Strategy 
  { initialize   = initializeStrategyState 
  , extractGuess = extractGuess'
  , updateState  = updateState'
  }

extractGuess' :: StrategyState -> Code
extractGuess' = guess

updateState' :: Answer -> StrategyState -> StrategyState
updateState' answer st 
    | isCorrect answer (codeLength st) =  
        st { guess = head $ allCodes st, consistent = allCodes st }
    | otherwise =
        let consistent' = getConsistentCodes answer (guess st) $ consistent st
            next        = head consistent'
        in st { guess = next, consistent = consistent' }
