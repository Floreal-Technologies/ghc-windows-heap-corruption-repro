{-# LANGUAGE CPP #-}
{-# LANGUAGE TemplateHaskell #-}

#if defined(WITH_GI)
module Embedded (bundle, registerResources) where
#else
module Embedded (bundle) where
#endif

import Data.ByteString (ByteString)
#if defined(WITH_GI)
import GI.GLib qualified as GLib
import GI.Gio qualified as Gio
#endif

import Splice (compiledBundle)

#if defined(WITH_GI)
registerResources :: IO ()
registerResources = GLib.bytesNew (Just bundle) >>= Gio.resourceNewFromData >>= Gio.resourcesRegister
#endif

bundle :: ByteString
#if defined(GLIB)
bundle = $(compiledBundle "data/gresource/repro.gresource.xml")
#else
bundle = $(compiledBundle "data/manifest.txt")
#endif
