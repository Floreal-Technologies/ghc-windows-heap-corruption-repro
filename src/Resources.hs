module Resources (registerResources) where

import GI.GLib qualified as GLib
import GI.Gio qualified as Gio

import Embedded (bundle)

registerResources :: IO ()
registerResources = GLib.bytesNew (Just bundle) >>= Gio.resourceNewFromData >>= Gio.resourcesRegister
