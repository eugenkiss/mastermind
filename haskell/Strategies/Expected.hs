-- | The expected size strategy keeps a pool of possible secret codes around.
-- After each guess the inconsistent codes are removed from the pool.
--
-- From the pool of all codes a subpool of codes is determined. This subpool
-- contains the codes which would lead to a maximized expected payoff. If
-- possible this subpool is reduced to consistent guesses.
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

module Strategies.Expected (expected) where

import Data.List (minimumBy, maximumBy, sortBy, groupBy)
import Data.Ord (comparing)
import Data.Function (on)

import Strategies.Util

expected = Strategy 
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
  let pairs      = [[ (g, exps a g consistent) 
                      | a <- allAnswers ] 
                      | g <- allCodes   ]
      sumPairs   = map (foldr1 $ \(g, e1) (_, e2) -> (g, e1 + e2)) pairs
      sorted     = sortBy (comparing snd) sumPairs
      totalSize  = length consistent
      exps a g c = let partSize = length $ getConsistentCodes a g c
                   in fromIntegral (partSize^2) /. totalSize
  in map fst $ head $ groupBy ((==) `on` snd) sorted

-- | Helper function for division to reduce \'fromIntegral noise\'.
(/.) :: (Real a, Real b, Fractional c) => a -> b -> c
(/.) x y = fromRational $ if y == 0
                             then 0
                             else toRational x / toRational y
