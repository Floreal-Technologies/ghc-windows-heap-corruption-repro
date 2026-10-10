module Filler.C (RecordC (..), recordsC, summaryC) where

import Data.List (sortOn)

data ShapeC = CircleC Double | SquareC Double | PolygonC [Double]
  deriving stock (Eq, Ord, Show, Read)

data RecordC = RecordC
  { nameC :: String
  , weightC :: Int
  , shapeC :: ShapeC
  , tagsC :: [String]
  }
  deriving stock (Eq, Ord, Show, Read)

recordsC :: Int -> [RecordC]
recordsC n =
  [ RecordC ("item" <> show i) (i * 7 `mod` 13) (pick i) [show j | j <- [1 .. i `mod` 5]]
  | i <- [1 .. n]
  ]
  where
    pick i
      | even i = CircleC (fromIntegral i)
      | i `mod` 3 == 0 = SquareC (fromIntegral i / 2)
      | otherwise = PolygonC (map fromIntegral [1 .. i `mod` 7])

summaryC :: [RecordC] -> String
summaryC = unlines . map show . take 3 . sortOn weightC
