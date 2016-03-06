module Main where

import Prelude (Unit, bind, (++), show)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)

import Control.SocketIO.Server (SocketIO, Connection, listen, onConnection, on, emit)

main :: forall eff. Eff (socket :: SocketIO, console :: CONSOLE | eff) Unit
main = do
  server <- listen 8080
  log "Listening in port 8080"
  onConnection server handleConnection
  where
  handleConnection conn = do
    log "new connection"
    on conn "msg" handleMsg
    where
    handleMsg msg = do
      log (show msg)
      emit conn "msg" ("Foo" ++ (show msg))
