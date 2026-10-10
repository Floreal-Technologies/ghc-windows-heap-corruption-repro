module Filler.A (RecordA (..), recordsA, summaryA) where

import Data.List (sortOn)

data ShapeA = CircleA Double | SquareA Double | PolygonA [Double]
  deriving stock (Eq, Ord, Show, Read)

data RecordA = RecordA
  { nameA :: String
  , weightA :: Int
  , shapeA :: ShapeA
  , tagsA :: [String]
  }
  deriving stock (Eq, Ord, Show, Read)

recordsA :: Int -> [RecordA]
recordsA n =
  [ RecordA ("item" <> show i) (i * 7 `mod` 13) (pick i) [show j | j <- [1 .. i `mod` 5]]
  | i <- [1 .. n]
  ]
  where
    pick i
      | even i = CircleA (fromIntegral i)
      | i `mod` 3 == 0 = SquareA (fromIntegral i / 2)
      | otherwise = PolygonA (map fromIntegral [1 .. i `mod` 7])

summaryA :: [RecordA] -> String
summaryA = unlines . map show . take 3 . sortOn weightA
