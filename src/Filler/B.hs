module Filler.B (RecordB (..), recordsB, summaryB) where

import Data.List (sortOn)

data ShapeB = CircleB Double | SquareB Double | PolygonB [Double]
  deriving stock (Eq, Ord, Show, Read)

data RecordB = RecordB
  { nameB :: String
  , weightB :: Int
  , shapeB :: ShapeB
  , tagsB :: [String]
  }
  deriving stock (Eq, Ord, Show, Read)

recordsB :: Int -> [RecordB]
recordsB n =
  [ RecordB ("item" <> show i) (i * 7 `mod` 13) (pick i) [show j | j <- [1 .. i `mod` 5]]
  | i <- [1 .. n]
  ]
  where
    pick i
      | even i = CircleB (fromIntegral i)
      | i `mod` 3 == 0 = SquareB (fromIntegral i / 2)
      | otherwise = PolygonB (map fromIntegral [1 .. i `mod` 7])

summaryB :: [RecordB] -> String
summaryB = unlines . map show . take 3 . sortOn weightB
