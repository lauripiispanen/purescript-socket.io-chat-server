module Control.SocketIO.Server where

import Prelude (Unit)

import Control.Monad.Eff (Eff)
import Data.Foreign.Class (class IsForeign)

foreign import data SocketIO :: !
foreign import data Server :: *
foreign import data Connection :: *

type Channel = String
type Port = Int

type ConnectionCallback eff = Connection -> Eff (socket :: SocketIO | eff) Unit
type EventCallback eff = String -> Eff (socket :: SocketIO | eff) Unit

foreign import listen :: forall eff. Port -> Eff (socket :: SocketIO | eff) Server

foreign import onConnection :: forall eff. Server -> ConnectionCallback eff -> Eff (socket :: SocketIO | eff) Unit

foreign import on :: forall eff. Connection -> String -> EventCallback eff -> Eff (socket :: SocketIO | eff) Unit

foreign import emit :: forall eff a. Connection -> String -> a -> Eff (socket :: SocketIO | eff) Unit
