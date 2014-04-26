-- | The most parts strategy keeps a pool of possible secret codes around.
-- After each guess the inconsistent codes are removed from the pool.
--
-- From the pool of all codes a subpool of codes is determined. This subpool
-- contains the codes which would lead to a maximized number of partitions.
-- That means that the best guess would lead to a different (disjoint) set of
-- new consistent codes for each possible answer. If possible this subpool
-- is reduced to consistent guesses.
-- 
-- Additionally, the to-be-entered code which is chosen from the subpool is the
-- one that results in the minimal travel distance for the robot.
-- 
-- If there are less than a handful of codes left the one with the shortest
-- distance is chosen.

-- TODO: Explain the special case when there are only some codes left.
--
-- I can't explain why this special case is needed but without it the strategy
-- is really bad.

-- TODO: Explain why the subpool must be reduced to consistent guesses if
-- possible. Explain why it is not necessarily needed for the other strategies.
--
-- If I don't do this the strategy is bad.

module Strategies.MostParts (mostparts) where

import Data.List (minimumBy, maximumBy, sortBy, groupBy)
import Data.Ord (comparing)
import Data.Function (on)
import Control.Arrow

import Strategies.Util

mostparts = Strategy 
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
            consistent' = getConsistentCodes answer (guess st) (consistent st)
            subpool     = getSubPool (allAnswers st) (allCodes st) consistent'
            subpool'    = getConsistentCodes answer (guess st) subpool
            chosen
                | length consistent' <= codeLength st ^ 2      = consistent'
                | length consistent' == length (consistent st) = consistent'
                | not (null subpool')                          = subpool'
                | otherwise                                    = subpool
            shortest    = getShortestCode lastPos chosen 
        in st { guess = shortest, consistent = consistent' }

getSubPool :: Answers -> Codes -> Codes -> Codes
getSubPool allAnswers allCodes consistent =
  let pairs    = [[ (g, getConsistentCodes a g consistent) 
                    | a <- allAnswers ] 
                    | g <- allCodes   ]
      grouped  = map (groupBy ((==) `on` snd)) pairs        
      parts    = map (getGuess &&& length) grouped          
      sorted   = reverse $ sortBy (comparing snd) parts
      getGuess = fst . head . head
  in map fst $ head $ groupBy ((==) `on` snd) sorted
