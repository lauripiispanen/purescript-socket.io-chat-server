module ChatServer where

import Prelude (map, (==), not, ($))

import Control.SocketIO.Server (Server, Connection, Message, connections, on, disconnect)
import Rx.Observable (Observable, flatMap, scan, merge, take, fromArray)

import Data.Array ((:), filter)
import Data.Either (either)
import Data.Foreign (ForeignError, readString)

type User = { name :: String, connection :: Connection }

data ConnectionOutcome = Connected | Disconnected
type ConnectionAction = { outcome :: ConnectionOutcome, user :: User }

users :: Server -> Observable (Array User)
users server =
  let
    joinedUsers = joins (connections server)
    connects = map (toAction Connected) joinedUsers
    disconnects = map (toAction Disconnected) (flatMap joinedUsers userDisconnect)
  in
    scan toUserArray [] (merge connects disconnects)

userDisconnect :: User -> Observable User
userDisconnect u = map (constant u) (disconnect u.connection)

constant :: User -> Connection -> User
constant u c = u

joins :: Observable Connection -> Observable User
joins conn = flatMap conn firstJoinMessage

firstJoinMessage :: Connection -> Observable User
firstJoinMessage conn = take 1 (flatMap (on "join" conn) parseUser)

parseUser :: Message -> Observable User
parseUser m =
  (either noUser (toUser m.connection)) $ readString m.payload

noUser :: ForeignError -> Observable User
noUser e =
  fromArray []

toUser :: Connection -> String -> Observable User
toUser c s =
  fromArray [{ name : s, connection: c }]

toAction :: ConnectionOutcome -> User -> ConnectionAction
toAction o u =
  { outcome : o, user : u }

toUserArray :: ConnectionAction -> Array User -> Array User
toUserArray a s =
  let
    nextState { outcome = Connected, user = u } = u : s
    nextState { outcome = Disconnected, user = u } = filter (not (connectionEquals u)) s
  in
    nextState a

connectionEquals :: User -> User -> Boolean
connectionEquals a b
  = (==) a.connection b.connection
