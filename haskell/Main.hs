-- | Main module where everything comes together.

{-# LANGUAGE RecordWildCards #-}
module Main where

import System.IO
import System.Random
import System.Environment
import System.Console.GetOpt
import System.Exit
import Control.Monad (liftM, liftM2, foldM, forM_, replicateM_)
import Data.Maybe (fromMaybe)
import Text.Printf (printf)
import Data.Function (on)
import Data.IORef
import qualified Data.Map as M
import Data.Map 
  ( Map
  , fromList
  , elems
  , assocs
  , empty
  , insert
  , union
  , unionWith
  , fold
  , foldWithKey
  , filterWithKey
  , findWithDefault
  )

import Opts (simOptions)
import Simulation (SimConfig(..), Statistic(..), PackedStrategy, mergeStats)


main = do
    hSetBuffering stdout NoBuffering
    (reps, cfg, strategy, strategyName) <- simOptions 
    putStr $ showTitle strategyName
    putStr $ showConfig reps cfg
    let summedStats = sumStats reps cfg strategy
    report <- liftM (showReport reps) summedStats
    putStr report

-- | Format the strategy's name as a title.
showTitle :: String -> String
showTitle name = let title = "Testing " ++ name
                     line  = replicate (length title) '='
                 in "\n" ++ title ++ "\n" ++ line ++ "\n\n"

-- | Show the (partially) provided configuration parameters from the command
-- line in human readable form.
showConfig :: Int -> SimConfig -> String
showConfig reps (SimConfig{..}) = 
    "Time Limit:   " ++ show timeLimit  ++ " [s]\n"    ++
    "Robot Speed:  " ++ show robotSpeed ++ " [mm/s]\n" ++
    "Code Length:  " ++ show codeLength ++ "\n"        ++
    "CPU Slowness: " ++ show cpuFactor  ++ "\n"        ++
    "Simulations:  " ++ show reps       ++ "\n\n"      ++
    "[..........]\n " 

-- | Show the stats in human readable form.
showReport :: Int -> Statistic -> String
showReport reps (Statistic succsPerRound thinkingTime drivingTime) = 
    printf "Results\n" ++
    printf "-------\n\n" ++
    printf "Successes: %.5f\n" succsAvg ++
    printf "Expected:  %.5f [Guesses/Success]\n\n" expAvg ++
    printf "Driving Time:  %6.2f [%%]\n" drivingRel ++
    printf "Thinking Time: %6.2f [%%]\n\n" thinkingRel ++
    printf "|   1   |   2   |   3   |   4   |   5   |   6   |   7   |  >=8  | [Round]\n" ++
    printf "|===============================================================|\n" ++
    printf "| " ++ concatMap format (elems relSuccsPerRound) ++ printf "[%%]\n\n"

    where format n = printf (if n == 100 then "%05.1f | " else "%05.2f | ") n 
          
          succsSum = sum $ elems succsPerRound 
          expSum   = sum $ map (uncurry (*)) $ assocs succsPerRound
          succsAvg = succsSum /. reps        :: Double
          expAvg   = expSum /. succsSum :: Double

          totalTime   = thinkingTime + drivingTime 
          thinkingRel = thinkingTime /. totalTime * 100 :: Double
          drivingRel  = drivingTime /. totalTime * 100  :: Double

          maxRound         = 8
          succsOverEqMax   = sum . elems . filterWithKey (\k _ -> k >= maxRound)
                             $ succsPerRound 
          newSuccsPerRound = (`union` (fromList $ zip [1..maxRound] [0,0..]))
                             . insert maxRound succsOverEqMax  
                             . filterWithKey (\k _ -> k < maxRound) 
                             $ succsPerRound
          relSuccsPerRound = M.map (\s -> s /. succsSum * 100) 
                             newSuccsPerRound :: Map Int Double


-- TODO: Is it possible to write that more beautifully?
-- | Repeat a simulation /n/ times, output the progress as ASCII to stdout and
-- finally return the summation of the individual stats for each executed
-- simulation.
sumStats :: Int -> SimConfig -> PackedStrategy -> IO Statistic
sumStats n cfg packedStrategy = do
    let length = 10
    printed <- newIORef 0
    acc     <- newIORef $ Statistic empty 0 0
    forM_ [0..n-1] $ \i -> do
        let toPrint = floor $ i /. n * fromIntegral length :: Int
        diff <- liftM (toPrint -) (readIORef printed)
        replicateM_ diff $ putStr "^"
        modifyIORef printed (+diff)
        acc' <- liftM2 mergeStats (readIORef acc) (stats !! i)
        writeIORef acc acc'
    rest <- liftM (length -) (readIORef printed)
    replicateM_ rest $ putStr "^"
    putStr "\n\n"
    readIORef acc

    where stats = take n $ map packedStrategy args
          args  = iterate updateCfg cfg
          -- Update the generator so that successive simulations do not yield
          -- the same result which would rather diminish the purpose of
          -- repeated simulations.
          updateCfg cfg = cfg { stdGen = fst $ split $ stdGen cfg }


-- | Helper function for division to reduce \'fromIntegral noise\'.
(/.) :: (Real a, Real b, Fractional c) => a -> b -> c
(/.) x y = fromRational $ if y == 0
                             then 0
                             else toRational x / toRational y
