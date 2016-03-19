module Control.SocketIO.Server where

import Prelude (Unit, class Eq, (==))

import Control.Monad.Eff (Eff)
import Data.Foreign (Foreign)

import Rx.Observable (Observable)

foreign import data SocketIO :: !
foreign import data Server :: *
foreign import data Connection :: *

type Channel = String
type Port = Int
type Message = { connection :: Connection, payload :: Foreign }

foreign import listen :: forall eff. Port -> Eff (socket :: SocketIO | eff) Server

foreign import on :: String -> Connection -> Observable Message

foreign import emit :: forall eff a. Connection -> String -> a -> Eff (socket :: SocketIO | eff) Unit

foreign import connections :: Server -> Observable Connection

foreign import disconnect :: Connection -> Observable Connection

foreign import connectionId :: Connection -> String

instance eqConnection :: Eq Connection where
  eq a b = (==) (connectionId a) (connectionId b)
