-- | The knuth strategy keeps a pool of possible secret codes around. After
-- each guess the inconsistent codes are removed from the pool.
--
-- From the pool of all codes a subpool of codes is determined. This subpool
-- contains the codes which would lead to a maximum shrinkage of the pool in
-- the next round for the worst possible answer. If possible this subpool
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
--
-- If you remove the special case and put a trace that shows the number of 
-- consistent codes like this:
--
-- > in trace (show (length consistent') ) st { guess = shortest, consistent = consistent' }
--
-- then when running the simulation with these parameters:
--
-- > $ mastermind-sim -a knuth -l 2 -t 100 -x 1 -c 0 -s -3
--
-- you'll see that the number of consistent codes stays at 1. If you add a
-- special case that just uses one of the consistent guesses when the size
-- of consistent guesses is 1 then everything works fine. However, when
-- running the simulation with these parameters:
--
-- > $ mastermind-sim -a knuth -l 3 -t 100 -x 1 -c 0 -s -3
--
-- you'll see that quite often the number of consistent codes stays at 6

module Strategies.Knuth (knuth) where

import Data.List (minimumBy, maximumBy, sortBy, groupBy)
import Data.Ord (comparing)
import Data.Function (on)

import Strategies.Util

knuth = Strategy 
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
  let pairs      = [[ (g, rems a g consistent) 
                      | a <- allAnswers ] 
                      | g <- allCodes   ]
      minPairs   = map (minimumBy (comparing snd)) pairs
      sorted     = reverse $ sortBy (comparing snd) minPairs
      rems a g c = length consistent - length (getConsistentCodes a g c)
  in map fst $ head $ groupBy ((==) `on` snd) sorted
