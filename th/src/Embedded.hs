{-# LANGUAGE CPP #-}
{-# LANGUAGE TemplateHaskell #-}

module Embedded (bundle) where

import Data.ByteString (ByteString)

import Splice (compiledBundle)

bundle :: ByteString
#if defined(GLIB)
bundle = $(compiledBundle "data/gresource/repro.gresource.xml")
#else
bundle = $(compiledBundle "data/manifest.txt")
#endif
