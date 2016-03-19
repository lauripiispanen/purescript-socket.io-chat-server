module Main where

import ChatServer (User, users)

import Prelude (Unit, bind, (++), show, ($), map)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)

import Control.SocketIO.Server (SocketIO, Connection, listen)
import Rx.Observable (subscribe)

type ConnectionState = Array Connection

initialState :: ConnectionState
initialState = []


main :: forall eff. Eff (socket :: SocketIO, console :: CONSOLE | eff) Unit
main = do
  server <- listen 8080
  log "Listening in port 8080"
  let userList = users server

  subscribe userList $ printUserList

printUserList :: forall eff. (Array User) -> Eff (console :: CONSOLE | eff) Unit
printUserList u =
  log ("Users: " ++ (show (map userName u)))

userName :: User -> String
userName u =
  u.name
