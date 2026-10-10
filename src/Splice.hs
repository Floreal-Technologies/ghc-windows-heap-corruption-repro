{-# LANGUAGE CPP #-}
{-# LANGUAGE TemplateHaskellQuotes #-}

module Splice (compiledBundle) where

import Data.ByteString qualified as BS
import Data.ByteString.Internal (unsafePackLenLiteral)
import Language.Haskell.TH (Exp, Q, integerL, litE, stringPrimL)
import Language.Haskell.TH.Syntax (addDependentFile, makeRelativeToProject)
#if defined(GLIB)
import Control.Monad (forM_)
import Language.Haskell.TH.Syntax (runIO)
import System.Directory (getTemporaryDirectory, removeFile)
import System.FilePath (takeDirectory)
import System.IO (hClose, openBinaryTempFile)
import System.Process (callProcess, readProcess)
#elif defined(RUN_IO)
import Language.Haskell.TH.Syntax (runIO)
import System.Directory (getTemporaryDirectory, removeFile)
import System.IO (hClose, openBinaryTempFile)
#endif
#if !defined(GLIB) && defined(RUN_IO) && defined(SPAWN)
import System.FilePath (normalise)
import System.Info (os)
import System.Process (callProcess, readProcess)
#endif

compiledBundle :: FilePath -> Q Exp
compiledBundle relative = do
  manifest <- makeRelativeToProject relative
  addDependentFile manifest
  bundle <- produce manifest
  [|unsafePackLenLiteral $(litE (integerL (fromIntegral (BS.length bundle)))) $(litE (stringPrimL (BS.unpack bundle)))|]

produce :: FilePath -> Q BS.ByteString
#if defined(GLIB)
produce manifest = do
  let sourceDir = takeDirectory manifest
  listed <- runIO (readProcess "glib-compile-resources" ["--sourcedir", sourceDir, "--generate-dependencies", manifest] "")
  forM_ (lines listed) addDependentFile
  runIO $ do
    tmp <- getTemporaryDirectory
    (target, handle) <- openBinaryTempFile tmp "repro.gresource"
    hClose handle
    callProcess "glib-compile-resources" ["--sourcedir", sourceDir, "--target", target, manifest]
    BS.readFile target <* removeFile target
#elif defined(RUN_IO) && defined(SPAWN)
produce manifest = do
  _ <- runIO (uncurry readProcess (command ("Get-Content -Raw -LiteralPath " <> quoted manifest) "cat" [manifest]) "")
  runIO $ do
    tmp <- getTemporaryDirectory
    (target, handle) <- openBinaryTempFile tmp "repro.bundle"
    hClose handle
    uncurry callProcess (command ("Copy-Item -LiteralPath " <> quoted manifest <> " -Destination " <> quoted target) "cp" [manifest, target])
    BS.readFile target <* removeFile target

command :: String -> FilePath -> [String] -> (FilePath, [String])
command script unixProgram unixArguments
  | os == "mingw32" = ("powershell", ["-NoProfile", "-NonInteractive", "-Command", script])
  | otherwise = (unixProgram, unixArguments)

quoted :: FilePath -> String
quoted path = "'" <> normalise path <> "'"
#elif defined(RUN_IO)
produce manifest = runIO $ do
  tmp <- getTemporaryDirectory
  (target, handle) <- openBinaryTempFile tmp "repro.bundle"
  hClose handle
  BS.readFile manifest >>= BS.writeFile target
  BS.readFile target <* removeFile target
#else
produce _ = pure (BS.replicate 8757 0x2a)
#endif
