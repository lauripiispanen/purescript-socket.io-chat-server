module ChatServer where

import Prelude (map, (==), not, ($))

import Control.SocketIO.Server (Server, Connection, Message, connections, on, disconnect)
import Rx.Observable (Observable, flatMap, scan, merge, take, fromArray)

import Data.Array ((:), filter)
import Data.Either (either)
import Data.Foreign (ForeignError, readString)

type User = { name :: String, connection :: Connection }

data ConnectionOutcome u = Connected User | Disconnected User

users :: Server -> Observable (Array User)
users server =
  let
    joinedUsers = joins (connections server)
    connects = map Connected joinedUsers
    disconnects = map Disconnected (flatMap joinedUsers userDisconnect)
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

toUserArray :: (ConnectionOutcome User) -> Array User -> Array User
toUserArray (Connected u) a = u : a
toUserArray (Disconnected u) a = filter (not (connectionEquals u)) a

connectionEquals :: User -> User -> Boolean
connectionEquals a b
  = (==) a.connection b.connection
