module Filler.E (RecordE (..), recordsE, summaryE) where

import Data.List (sortOn)

data ShapeE = CircleE Double | SquareE Double | PolygonE [Double]
  deriving stock (Eq, Ord, Show, Read)

data RecordE = RecordE
  { nameE :: String
  , weightE :: Int
  , shapeE :: ShapeE
  , tagsE :: [String]
  }
  deriving stock (Eq, Ord, Show, Read)

recordsE :: Int -> [RecordE]
recordsE n =
  [ RecordE ("item" <> show i) (i * 7 `mod` 13) (pick i) [show j | j <- [1 .. i `mod` 5]]
  | i <- [1 .. n]
  ]
  where
    pick i
      | even i = CircleE (fromIntegral i)
      | i `mod` 3 == 0 = SquareE (fromIntegral i / 2)
      | otherwise = PolygonE (map fromIntegral [1 .. i `mod` 7])

summaryE :: [RecordE] -> String
summaryE = unlines . map show . take 3 . sortOn weightE
