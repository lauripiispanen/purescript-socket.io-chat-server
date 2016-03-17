module Control.SocketIO.Server where

import Prelude (Unit, class Eq, (==))

import Control.Monad.Eff (Eff)

import Rx.Observable (Observable)

foreign import data SocketIO :: !
foreign import data Server :: *
foreign import data Connection :: *

type Channel = String
type Port = Int
type Message = { conn :: Connection, msg :: String }

type ConnectionCallback eff = Connection -> Eff (socket :: SocketIO | eff) Unit
type EventCallback eff = String -> Eff (socket :: SocketIO | eff) Unit

foreign import listen :: forall eff. Port -> Eff (socket :: SocketIO | eff) Server

foreign import onConnection :: forall eff. Server -> ConnectionCallback eff -> Eff (socket :: SocketIO | eff) Unit

foreign import on :: forall eff. Connection -> String -> EventCallback eff -> Eff (socket :: SocketIO | eff) Unit

foreign import emit :: forall eff a. Connection -> String -> a -> Eff (socket :: SocketIO | eff) Unit

foreign import connections :: Server -> Observable Connection

foreign import disconnect :: Connection -> Observable Connection

foreign import messages :: Connection -> Observable Message

foreign import connectionId :: Connection -> String

instance eqConnection :: Eq Connection where
  eq a b = (==) (connectionId a) (connectionId b)
