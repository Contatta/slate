---

---
# Real-Time Events

Event messages are sent over the real-time messaging API. These provide an
additional mechanism to push messages to a client that are not related to chat.
Events can occur for many reasons such as notifications or data-changes. Event
messages are identifiable when the incoming message `type` is `event`.

<aside class="notice">
Given a client using the XMPP protocol has no use for <code>event</code>
messages, they are only sent to clients using the JSON / ratatoskr protocol.
</aside>

Events can be sent to a specific set of users or broadcast to all the users of
an instance.

## Properties

Name             | Req | Type    | Description
-----------------|:---:|---------|------------
`topic`          | ✓   |string   |name of topic as a path, such as `/api/notify`
`data`           | ✓   |any      |payload, specific to the topic

## Topics

**TBA**
