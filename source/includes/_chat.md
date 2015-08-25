---

---
# Chat

## Introduction

The Chat APIs allow you to integrate and build applications to extend Ryver's
functionality in ways we never imagined.

## Messages

Messages are sent and received over the real-time messaging API. All messages
must have a `type` property that indicates the type of message and how a
consumer should interpret the remaining structure. The following table lists
the standard messages types.

### `id` property

When sending a message to the server, a client can include an `id` property of
type `string`. In turn, the server will respond with an [ack](#ack-message)
message once it has been successfully processed.

The `id` property also provides traceability. Should an `error` message occur in
response to a client request, the server will include the original `id` with the
`error` message.

### `to` property

For an incoming message (such as `presence_change` or `chat`), the `to` property
will contain the JID to which this message was delivered. If the target of the
message is the current user, it will be the user's JID; if the target was a team
room, it will be the JID of the team

### `from` property

For an incoming message, the `from` property will contain the JID of the
originating user.

### `JID`

A JID is a unique identifier for a user or team in Ryver and is used to route
messages. In general a JID takes the form `localpart@domainpart`, and is known
as a _bare JID_. A particular connected application that is currently authorized
to send and receive messages is of the form `localpart@domainpart/resource` and
is known as a _full JID_.

### message type list

Type                                        | Description
--------------------------------------------|------------
[ack](#ack-message)                         | response from the server to acknowledge a message sent by a client
[auth](#auth-message)                       | authenticate a new websocket connection
[chat](#chat-message)                       | represents a chat sent to a user or team
[error](#error-message)                     | sent by the server in response to an invalid message
[ping](#ping-message)                       | send a ping to the server
[presence_change](#presence_change-message) | indicates a change in presence
[team_join](#team_join-message)             | cause the current session to join the specified team chat room
[team_leave](#team_leave-message)           | cause the current session to leave the specified team chat room
[user_typing](#user_typing-message)         | indicates a user is typing

## Real-time Message API

### `ack` message

> Client:

```json
{
  "type": "message",
  "to":   "acme+27053427bb9f4c448d79ef5fcb4da78c@xmpp.ryver.com",
  "text": "hello world",
  "id":   "23TplPdS"
}
```

> Server: in response to the previous message

```json
{
  "type":       "ack",
  "reply_type": "message",
  "reply_to":   "23TplPdS"
}
```

The `ack` message is sent by the server to acknowledge a previous message sent
by a client. A client requests interest in receiving an `ack` by including an
`id` property in an outgoing message. `id` should be a unique string or
incrementing number; any other value is considered an error.

On success, certain messages will include a `response` property, that contains
additional data after processing. As an example, sending a `chat` message will
include the original chat with a `key` to uniquely identify the message for
editing or deleting. See each message to determine if a response is returned.

On failure, the message will include an `error` property that contains
information about the cause of the failure.

<aside class="notice">
Not all messages require an <code>ack</code>. An ack should be requested for
messages that would result in data loss should they fail to be processed
correctly
</aside>

#### Properties

Name             | Req | Type    | Description
-----------------|:---:|---------|------------
`reply_type`     | ✓   |string   |The message type of the original message
`reply_id`       | ✓   |string   |The id of the original message
`response`       |     |object   |An optional response message
`error`          |     |object   |See [error](#error-message) for more info

### `auth` message

> Client: authenticating with server

```json
{
  "type": "auth",
  "id": "71TplPdS",
  "authorization": "Session <session id>"
}
```

The `auth` message is sent by the client to establish an authenticated
connection with the server. The `<session id>` is obtained when calling
`Session.Login()`

#### Properties

Name             | Req | Type    | Description
-----------------|:---:|---------|------------
`authorization`  | ✓   |string   |`"Session" SP session-id`
`agent`          |     |string   |Name of application or client
`resource`       |     |string   |Unique value to identify the connection, appended to the JID

Note that the `resource`

#### `response` properties

Name             | Req | Type    | Description
-----------------|:---:|---------|------------
`jid`            | ✓   |string   |The full JID for the session

### `chat` message

> Server: a typical chat message sent to a client

```json
{
  "type": "chat",
  "from": "acme+edc02251076b4190830f30f48eff8266@xmpp.ryver.com",
  "to":   "acme+27053427bb9f4c448d79ef5fcb4da78c@xmpp.ryver.com",
  "text": "hello world",
  "key":  "00093971650512420864"
}
```

The `chat` message is sent by a client and delivered to the the appropriate user
or team. The `to` property identifies the destination of the message. If `to` is
the current user's JID, it was a 1:1 message, if the JID is a team, it  was
delivered to a team chat room.

#### Properties

Name             | Req | Type    | Description
-----------------|:---:|---------|------------
`text`           | ✓   |string   |The text of the message
`to`             | ✓   |string   |The destination `JID` of this message
`key`            | ✓   |string   |The unique identifier of this message for editing or deletion
`extras`         |     |object   |Optional extras, that can be used by integrations

#### `response` Properties

Name             | Req | Type    | Description
-----------------|:---:|---------|------------
`key`            | ✓   |string   |Unique identifier for this message

### `presence_change` message

> Client: notifying other users of an away presence

```json
{
  "type":     "presence_change",
  "presence": "away"
}
```

> Server: notify clients of presence change

```json
{
  "type":     "presence_change",
  "from":     "acme+edc02251076b4190830f30f48eff8266@xmpp.ryver.com/<resource>",
  "to":       "acme+27053427bb9f4c448d79ef5fcb4da78c@xmpp.ryver.com",
  "presence": "away"
}
```

The `presence_change` message is sent by the client to indicate a user's change
of availability.

<aside class="notice">
A client must send an initial presence after the <code>auth</code> message to
announce a user's availability or they will not be seen as online to other users
</aside>

Clients which receive this message can update the status in their local list of
users. The `to` property is either directed to the user or to a team JID,
depending on whether this was a global or team-specific presence change.

When a client sends out an initial presence after connecting, it will receive a
number of `presence_change` messages from the server to indicate the online
status of all the user's contacts. These initial `presence_change` messages will
include a `received` property, to indicate when the originating user last
updated their presence. If a user is online, the `from` will contain a full JID.

<aside class="notice">
Whilst connected, a client will receive a number of <code>presence_change</code>
messages that it can use to update the online status of their user list. In this
case, <code>received</code> will be absent, as it is implied to be <em>now</em>.
</aside>

#### Properties

Name             | Req | Type    | Description
-----------------|:---:|---------|------------
`presence`       | ✓   | string  | valid presence_type
`received`       |     | string  | ISO 8601 formatted date

#### Presence types

presence_type | Meaning
--------------|------------
`available`   | The user is available for chat
`dnd`         | The user is busy, do not disturb
`away`        | The user is temporarily away
`xa`          | The user is away for an extended period
`unavailable` | The user is not online


### `team_join` message

> Client: join the room

```json
{
  "type": "team_join",
  "to":   "acme+27053427bb9f4c448d79ef5fcb4da78c@xmpp.ryver.com"
}
```

The `team_join` message is sent by the client when a user wishes to participate
in the chat room. 1 or more `presence_change` messages will be sent to the user,
indicating who is currently in the room. Note that the value of the `to`
property for these `presence_change` messages will be the team's JID. Whilst
joined to a room, the current session will receive any group chat messages
directed to the room.

### `team_leave` message

> Client: leave the room

```json
{
  "type": "team_leave",
  "to":   "acme+27053427bb9f4c448d79ef5fcb4da78c@xmpp.ryver.com"
}
```

The `team_leave` message is sent by the client when a user no longer wishes to
participate in the chat room. All other clients will be sent a `presence_change`
message with a `presence` of `unavailable`. After leaving, the current session
will no longer receive any group chat messages directed to the room.


### `user_typing` message

> Client: indicating the user is typing

```json
{
  "type": "user_typing",
  "to":   "acme+27053427bb9f4c448d79ef5fcb4da78c@xmpp.ryver.com"
}
```

> Server: indicating user is typing to a specific JID

```json
{
  "type": "user_typing",
  "from": "acme+edc02251076b4190830f30f48eff8266@xmpp.ryver.com",
  "to":   "acme+27053427bb9f4c448d79ef5fcb4da78c@xmpp.ryver.com"
}
```

The `user_typing` message is sent by the client when a user starts typing. A
client can send this message multiple times. The `to` JID indicates to which
user or team the users is typing

Clients receiving this message can show an indicator that the user is typing.
The client would remove this indicator after a short delay or when a message is
received.

### `ping` message

> Client:

```json
{
  "type": "ping",
  "id":   "23TplPdS"
}
```

> Server:

```json
{
  "type":       "ack",
  "reply_type": "ping",
  "reply_to":   "23TplPdS"
}
```

The `ping` message is sent by the client to check the health of the connection
and server.

<aside class="notice">
The <code>id</code> property should be included to receive an <code>ack</code>
from the server.
</aside>

### `error` message

> Example error message in response to a failed auth message

```json
{
  "type": "error",
  "code": "auth_failed",
  "text": "authentication failed; invalid session"
}
```

Error messages are sent in response to a failed request or invalid message
payload.

#### Properties: `error`

Name             | Req | Type    | Description
-----------------|:---:|---------|------------
`code`           | ✓   | string  | a code identify the error
`text`           | ✓   | string  | a descriptive message of the error in English
`data`           |     | object  | additional information for a specific error code

#### Error codes

Code                    | Description
------------------------|-------------
`invalid_arg`           | the specified argument was missing or invalid
`auth_failed`           | the attempted `auth` message failed
`server_error`          | a server error occurred
`invalid_message_type`  | the specified message `type` was invalid
`not_authenticated`     | in an unauthenticated state, only the `auth` message is expected
`xmpp_error`            | an XMPP-specific error has occurred, see [data object](#properties-xmpp_error)

#### Properties: `xmpp_error`

When the `error.code` is `xmpp_error`, the `data` property will include extra
data describing the XMPP specific error per RFC-6120.

<aside class="notice">
The <code>xmpp</code> object is intended to be a temporary solution until MUC is
replaced
</aside>

Name               | Req | Type    | Description
-------------------|:---:|---------|------------
`type`             | ✓   | string  | `type` attribute of `error` element per [RFC-6120 Section 8.3.2](http://tools.ietf.org/html/rfc6120#section-8.3.2)
`cond`             | ✓   | string  | defined condition per [RFC-6120 Section 8.3.3](http://tools.ietf.org/html/rfc6120#section-8.3.3)
`text`             |     | string  | `text` element per [RFC-6120 Section 8.3.2](http://tools.ietf.org/html/rfc6120#section-8.3.2)
