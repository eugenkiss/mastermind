-- | Module that provides the fundamental data, types and (helper) functions
-- for the simulation.

module Simulation 
  ( -- * General Mastermind Functions/Data
    Button
  , Code
  , Codes
  , Answer(..)
  , Answers
  , Position
  , buttons
  , getPos
  , calcDrivingDistance
  , compareCodes
  , isCorrect
    -- * Simulation Functions/Data
  , Strategy(..)
  , Statistic(..)
  , SimConfig(..)
  , PackedStrategy
  , packStrategy
  , mergeStats
  ) where

import System.Random
import System.CPUTime
import Control.Monad
import Control.Monad.RWS
import Control.Monad.Trans (liftIO)
import Data.Map (Map, fromList, empty, unionWith)
import Data.Function (on)
import Data.List (sortBy)


-- * General Mastermind Functions/Data

type Code     = [Button]
type Codes    = [Code]
type Answers  = [Answer]
type Position = (Double, Double)

data Button = Button { getPos :: Position }
              deriving (Eq, Show)

-- | The Buttons as given in the task.
buttons = [ Button (-460,  982)
          , Button ( 460,  982)
          , Button ( 982,  460)
          , Button ( 982, -460)
          , Button ( 460, -982)
          , Button (-460, -982)
          , Button (-982, -460)
          , Button (-982,  460)
          ]

-- | Common Mastermind answer. Consists of the correct buttons on correct
-- positions and the correct buttons on incorrect positions.
data Answer = Answer { blacks :: Int, whites :: Int } deriving (Eq, Show)

-- | Calculate the distance between two 2D points.
calcDistance :: Position -> Position -> Double
calcDistance (x1, y1) (x2, y2) = sqrt ((x1 - x2)^2 + (y1 - y2)^2)

-- | Calculate the driving distance for an entered guess.
calcDrivingDistance :: Position -> Code -> Double
calcDrivingDistance lastPosition code = foldl f 0 positionChain
    where f distance (p1, p2) = distance + calcDistance p1 p2
          positionChain = zip (lastPosition : positions) positions
          positions = map getPos code

-- | Calculate the time in ms for a distance in mm and a speed in mm/s.
calcDrivingTime :: Double -> Double -> Integer
calcDrivingTime distance speed = round $ (distance / speed) * 1000

-- | Create a random code of a given length.
createRandomCode :: Int -> StdGen -> [Button]
createRandomCode n gen = take n . map (buttons !!) . randomRs range $ gen 
    where range = (0, length buttons - 1)
    
-- | Return a mastermind answer.
compareCodes :: Code -> Code -> Answer
compareCodes guess secretCode = foldl f (Answer 0 0) (zip guess secretCode)
    where f answer (b1, b2)  
              | b1 == b2        = answer { blacks = blacks answer + 1 }
              | b2 `elem` guess = answer { whites = whites answer + 1 }
              | otherwise       = answer

-- | Return true if the answer represents a correctly guessed secret code. 
isCorrect :: Answer -> Int -> Bool
isCorrect (Answer b w) codeLength = b == codeLength


-- * Simulation Functions/Data

-- TODO: I'd rather avoid IO here since I don't really need it. But if I remove
-- it the evaluation of the strategy's guess (in stepState) is not strict thus 
-- I can't time the thinking time of a strategy. A better way would be to learn 
-- how to force strictness so that I could avoid IO.
type App = RWST SimConfig Statistic SimState IO

-- | This is the interface for a strategy.
data Strategy s = Strategy 
  { initialize   :: Int -> s -- ^ initialize the state with the code length.
  , extractGuess :: s -> Code
  , updateState  :: Answer -> s -> s
  }

-- TODO: A cleaner way is to log the answers and guesses and the driving +
--       thinking time and then process this log to get the summed 
--       successesPerRound and the summed driving and thinkingTime
-- | Several values that are recorded while the strategy plays the mastermind
-- game in order to be able to provide a statistic about its fitness.
data Statistic = Statistic 
  { successesPerRound :: Map Int Int
  , thinkingTime      :: Integer     -- ^ in ms
  , drivingTime       :: Integer     -- ^ in ms
  } 

defaultStat = Statistic 
  { successesPerRound = empty
  , thinkingTime      = 0
  , drivingTime       = 0
  }

instance Monoid Statistic where
    mempty  = defaultStat
    mappend = mergeStats

-- | All needed state for the simulation.
data SimState = SimState 
  { -- | Needed to keep track of how many tries the robot used to crack the 
    -- secret code. Reset to 1 after each correct guess.
    roundCounter :: Int 
    -- | Last button of an entered sequence. Needed to calculate the driving
    -- distance.
  , lastPosition :: Position   
    -- | Code to be guessed by the strategy. Updated after each correct guess.
  , secretCode :: Code
    -- It is not sufficient to keep the generator in the configuration
    -- environment as after a succesful guess a new random code must be created
    -- with a new generator and therefore the generator must be switched which
    -- is only possible if the generator belongs to the state.
  , rndGen :: StdGen
  } deriving (Show)

defaultState = SimState 
  { roundCounter = 1 
  , lastPosition = (0, 0)     -- Start in the center of the arena
  , secretCode   = []         -- Will be overwritten at the start
  , rndGen       = mkStdGen 1 -- Will be overwritten at the start
  }

-- | Various configuration information for the simulation.
data SimConfig = SimConfig 
  { stdGen     :: StdGen
  , timeLimit  :: Integer -- ^ in s
  , cpuFactor  :: Double
  , robotSpeed :: Double  -- ^ in mm/s
  , codeLength :: Int
  }

defaultConf = SimConfig 
  { stdGen     = mkStdGen 1
  , timeLimit  = 180
  , cpuFactor  = 1
  , robotSpeed = 920
  , codeLength = 1
  }

type Oracle = Code -> App Answer

-- | Receive a guess and return an answer. At the same time perform the
-- necessary state updates and log the driving time.
oracle :: Oracle 
oracle guess = do
    cfg <- ask
    st  <- get
    logDrivingTime guess
    let answer = compareCodes guess (secretCode st)
    if isCorrect answer (codeLength cfg)
       then addSuccess >> resetRoundCounter >> updateSecretCode (codeLength cfg) 
       else incRoundCounter
    updateLastPosition guess
    return answer

-- | Create one step of the simulation.
stepState :: SimConfig -> Oracle -> Strategy s -> IO (Statistic, SimState, s) -> IO (Statistic, SimState, s)
stepState cfg oracle strategy tuple = do 
    (stat, simState, strState) <- tuple
    -- Actually, a little more is timed than the mere strategy. But I am not 
    -- yet able to strictly evaluate updateState so this is a compromise.
    t0 <- getCPUTime
    let guess = extractGuess strategy strState
    (answer, simState', stat') <- runRWST (oracle guess) cfg simState
    let strState' = updateState strategy answer strState
    t1 <- getCPUTime
    let diff   = round $ fromIntegral (t1-t0) * cpuFactor cfg / (10^9) 
        stat'' = addThinkingTime stat' diff
    return (stat `mappend` stat'', simState', strState')

-- | Create an infinite stream of simulation steps.
stepMany :: SimConfig -> Strategy s -> Oracle -> [IO (Statistic, SimState, s)]
stepMany cfg str oracle = go $ return 
    (defaultStat, simState, initialize str (codeLength cfg)) 
    where go tuple = let tuple' = stepState cfg oracle str tuple
                     in tuple : go tuple'
          simState = defaultState 
                     { rndGen     = stdGen cfg
                     , secretCode = createRandomCode (codeLength cfg) (stdGen cfg) }

-- | A packed strategy is a strategy that is packed with the simulation and
-- whose stats can be obtained by providing a configuration.
type PackedStrategy = SimConfig -> IO Statistic

-- | Pack a strategy so the simulation's result can be obtained by providing
-- only a configuartion.
packStrategy :: Strategy state -> PackedStrategy
packStrategy str cfg =
    liftM getStat $ helper $ stepMany cfg str oracle
    where underLimit (stat, simState, strState) = getElapsedTime stat <= timeLimit cfg
          getStat    (stat, simState, strState) = stat 
          -- TODO: Try to replace this with takeWhileM
          helper (x1:x2:xs) = do
              bool <- liftM underLimit x2
              if bool then helper xs else x1

              -- TODO: Is it possible to write such a function?
              --takeWhileM :: (Monad m) => (a -> Bool) -> [m a] -> [m a]


-- ** RWS accessor/modifier helper functions

mergeStats :: Statistic -> Statistic -> Statistic
mergeStats (Statistic m1 dt1 tt1) (Statistic m2 dt2 tt2) = 
    Statistic (unionWith (+) m1 m2) (dt1 + dt2) (tt1 + tt2)

logDrivingTime :: Code -> App ()
logDrivingTime guess = do
    cfg <- ask
    st  <- get
    let distance = calcDrivingDistance (lastPosition st) guess
        duration = calcDrivingTime distance (robotSpeed cfg)
    tell $ mempty { drivingTime = duration }

addThinkingTime :: Statistic -> Integer -> Statistic
addThinkingTime stat n = stat `mappend` mempty { thinkingTime = n }

addSuccess :: App ()
addSuccess = do
    st <- get
    let round = roundCounter st
    tell mempty { successesPerRound = fromList [(round, 1)] }

onRoundCounter :: (Int -> Int) -> App ()
onRoundCounter f  = modify $ \s -> s { roundCounter = f (roundCounter s) }
incRoundCounter   = onRoundCounter (+1)
resetRoundCounter = onRoundCounter (const 1)

updateLastPosition :: Code -> App ()
updateLastPosition guess = do
    st <- get
    put st { lastPosition = getPos $ last guess }

updateSecretCode :: Int -> App ()
updateSecretCode codeLength = do 
    updateRndGen 
    modify $ \s -> s { secretCode = createRandomCode codeLength (rndGen s) }

updateRndGen :: App ()
updateRndGen = modify $ \s -> s { rndGen = fst $ split $ rndGen s }

getElapsedTime :: Statistic -> Integer
getElapsedTime stat = (drivingTime stat + thinkingTime stat) `div` 1000 -- in s
