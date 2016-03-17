module Main where

import Prelude (Unit, bind, (++), show, ($), map, (==), not)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, print)

import Data.Array ((:), filter, length)

import Control.SocketIO.Server (SocketIO, Connection, listen, connections, messages, disconnect)
import Rx.Observable (subscribe, flatMap, scan, merge)

type ConnectionState = Array Connection

initialState :: ConnectionState
initialState = []


main :: forall eff. Eff (socket :: SocketIO, console :: CONSOLE | eff) Unit
main = do
  server <- listen 8080
  log "Listening in port 8080"
  let conn = connections server
  let msg = flatMap conn messages
  let connects = map (toAction Connected) conn
  let disconnects = map (toAction Disconnected) (flatMap conn disconnect)
  let connectedClients = scan toConnectionState [] (merge connects disconnects)

  subscribe connectedClients $ printConnectionState

printConnectionState :: forall eff. (Array Connection) -> Eff (console :: CONSOLE | eff) Unit
printConnectionState s =
  print ("connected clients: " ++ (show (length s)))

data ConnectionOutcome = Connected | Disconnected
type ConnectionAction = { outcome :: ConnectionOutcome, connection :: Connection }

toAction :: ConnectionOutcome -> Connection -> ConnectionAction
toAction o c =
  { outcome : o, connection : c }

toConnectionState :: ConnectionAction -> ConnectionState -> ConnectionState
toConnectionState a s =
  let
    nextState { outcome = Connected, connection = c } = c : s
    nextState { outcome = Disconnected, connection = c } = filter (not (== c)) s
  in
    nextState a
