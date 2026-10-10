module Filler.F (RecordF (..), recordsF, summaryF) where

import Data.List (sortOn)

data ShapeF = CircleF Double | SquareF Double | PolygonF [Double]
  deriving stock (Eq, Ord, Show, Read)

data RecordF = RecordF
  { nameF :: String
  , weightF :: Int
  , shapeF :: ShapeF
  , tagsF :: [String]
  }
  deriving stock (Eq, Ord, Show, Read)

recordsF :: Int -> [RecordF]
recordsF n =
  [ RecordF ("item" <> show i) (i * 7 `mod` 13) (pick i) [show j | j <- [1 .. i `mod` 5]]
  | i <- [1 .. n]
  ]
  where
    pick i
      | even i = CircleF (fromIntegral i)
      | i `mod` 3 == 0 = SquareF (fromIntegral i / 2)
      | otherwise = PolygonF (map fromIntegral [1 .. i `mod` 7])

summaryF :: [RecordF] -> String
summaryF = unlines . map show . take 3 . sortOn weightF
