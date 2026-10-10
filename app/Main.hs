module Main (main) where

import Data.ByteString qualified as BS

import Embedded (bundle)
import Filler.A (recordsA, summaryA)

main :: IO ()
main = do
  print (BS.length bundle)
  putStr (summaryA (recordsA 20))
