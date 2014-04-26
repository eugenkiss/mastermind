-- | Module which is concerned with parsing and error handling of the command 
-- line arguments provided by the user.

module Opts (simOptions) where

import System.Random
import System.Environment
import System.Console.GetOpt
import System.Exit
import Unsafe.Coerce
import Data.Maybe (fromJust, isNothing, listToMaybe)
import Control.Monad (liftM)

import Simulation (SimConfig(..), Strategy, PackedStrategy, packStrategy)
import Strategies.Dummy
import Strategies.Simple
import Strategies.Simple2
import Strategies.Knuth
import Strategies.Entropy
import Strategies.Expected
import Strategies.MostParts


usageHeader = "Usage: mastermind-sim [OPTION...] -a STRATEGY"

availableStrategies = "These are the available strategies:\n" ++
                         "   dummy\n"     ++
                         "   simple\n"    ++
                         "   simple2\n"   ++
                         "   knuth\n"     ++
                         "   entropy\n"   ++
                         "   expected\n"  ++
                         "   mostparts\n"

nameToStrategy :: String -> Maybe PackedStrategy
nameToStrategy "dummy"     = Just $ packStrategy dummy
nameToStrategy "simple"    = Just $ packStrategy simple
nameToStrategy "simple2"   = Just $ packStrategy simple2
nameToStrategy "knuth"     = Just $ packStrategy knuth
nameToStrategy "entropy"   = Just $ packStrategy entropy
nameToStrategy "expected"  = Just $ packStrategy expected
nameToStrategy "mostparts" = Just $ packStrategy mostparts
nameToStrategy _           = Nothing

maybeRead :: Read a => String -> Maybe a
maybeRead = fmap fst . listToMaybe . reads

data Options = Options
 { optRepetitions :: Int
 , optSeed        :: Maybe Int
 , optTimeLimit   :: Integer 
 , optCPUFactor   :: Double 
 , optRobotSpeed  :: Double 
 , optCodeLength  :: Int 
 , optStrategy    :: String 
 } 

defaultOptions = Options
 { optRepetitions = 10 
 , optSeed        = Nothing
 , optTimeLimit   = 180
 , optCPUFactor   = 1
 , optRobotSpeed  = 920
 , optCodeLength  = 3
 , optStrategy    = ""
 }

options :: [ OptDescr (Options -> IO Options) ]
options =
    [ Option "s" ["seed"]
        (ReqArg
            (\arg opt -> do
                let arg' = maybeRead arg :: Maybe Int
                if isNothing arg'
                   then error "seed must be a number" 
                   else return opt { optSeed = arg' })
            "INTEGER")
        "Random seed (default: System seed)"
 
    , Option "l" ["length"]
        (ReqArg
            (\arg opt -> do
                let arg' = maybeRead arg
                if isNothing arg' || fromJust arg' < 1
                   then error "code length must be a number >= 1" 
                   else return opt { optCodeLength = fromJust arg' })
            "INTEGER >=1")
        "Code length (default: 3)"
 
    , Option "t" ["timelimit"]
        (ReqArg
            (\arg opt -> do
                let arg' = maybeRead arg
                if isNothing arg' || fromJust arg' < 0
                   then error "time limit must be a number >= 0" 
                   else return opt { optTimeLimit = fromJust arg' })
            "INTEGER >=0")
        "Time limit (default: 180s)"

    , Option "c" ["cpufactor"]
        (ReqArg
            (\arg opt -> do
                let arg' = maybeRead arg
                if isNothing arg' || fromJust arg' < 0
                   then error "cpu factor must be a number >= 0" 
                   else return opt { optCPUFactor = fromJust arg' })
            "DOUBLE >=0")
        "CPU slowness factor (default: 1)"

    , Option "r" ["robotspeed"]
        (ReqArg
            (\arg opt -> do
                let arg' = maybeRead arg
                if isNothing arg' || fromJust arg' <= 0
                   then error "robot speed must be a number > 0" 
                   else return opt { optRobotSpeed = fromJust arg' })
            "DOUBLE >=0")
        "Robot speed (default: 920mm/s)"

    , Option "x" ["repetitions"]
        (ReqArg
            (\arg opt -> do
                let arg' = maybeRead arg
                if isNothing arg' || fromJust arg' < 1
                   then error "repetitions must be a number >= 1" 
                   else return opt { optRepetitions = fromJust arg' })
            "INTEGER >0")
        "Repetitions (default: 10)"

    , Option "a" ["algorithm"]
        (ReqArg
            (\arg opt -> return opt { optStrategy = arg }) 
            "STRING")
        "Strategy"
 
    , Option "h" ["help"]
        (NoArg
            (\_ -> do
                prg <- getProgName
                putStr $ usageInfo usageHeader options
                putStr "\n"
                putStr availableStrategies
                exitWith ExitSuccess))
        "Show help"
    ]

simOptions :: IO (Int, SimConfig, PackedStrategy, String)
simOptions = do
    args <- getArgs
    case getOpt RequireOrder options args of
         (o, [], []) -> do
             gen  <- getStdGen
             opts <- foldl (>>=) (return defaultOptions) o
             if optStrategy opts == "" 
                then error "strategy must be provided" else do
             let strategyName = optStrategy opts
                 strategy = nameToStrategy strategyName
             if isNothing strategy
                then error $ "unrecognized strategy\n" ++ availableStrategies else do
             let reps = optRepetitions opts
                 cfg  = SimConfig
                   { stdGen     = maybe gen mkStdGen (optSeed opts)
                   , timeLimit  = optTimeLimit opts
                   , cpuFactor  = optCPUFactor opts
                   , robotSpeed = optRobotSpeed opts
                   , codeLength = optCodeLength opts
                   }
             return (reps, cfg, fromJust strategy, strategyName)
         (_, n, [])     -> error $ "unrecognized arguments: " ++ unwords n 
         (_, _, errors) -> error $ concat errors ++ 
                                   usageInfo usageHeader options
