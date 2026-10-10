module Filler.D (RecordD (..), recordsD, summaryD) where

import Data.List (sortOn)

data ShapeD = CircleD Double | SquareD Double | PolygonD [Double]
  deriving stock (Eq, Ord, Show, Read)

data RecordD = RecordD
  { nameD :: String
  , weightD :: Int
  , shapeD :: ShapeD
  , tagsD :: [String]
  }
  deriving stock (Eq, Ord, Show, Read)

recordsD :: Int -> [RecordD]
recordsD n =
  [ RecordD ("item" <> show i) (i * 7 `mod` 13) (pick i) [show j | j <- [1 .. i `mod` 5]]
  | i <- [1 .. n]
  ]
  where
    pick i
      | even i = CircleD (fromIntegral i)
      | i `mod` 3 == 0 = SquareD (fromIntegral i / 2)
      | otherwise = PolygonD (map fromIntegral [1 .. i `mod` 7])

summaryD :: [RecordD] -> String
summaryD = unlines . map show . take 3 . sortOn weightD
