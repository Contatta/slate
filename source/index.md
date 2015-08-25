---
title: Ryver API Reference

toc_footers:
  - <a href='#'>Sign Up for a Developer Key</a>

includes:
  - how_tos
  - chat
  - events

search: true
---

# Introduction

Welcome to the official Ryver API documentation. Our APIs allow 3rd parties
to integrate to Ryver with greater flexibility than what is supported by
services such Zapier. Ryver’s APIs are a subset of
[OData 2.0](http://www.odata.org/documentation/odata-version-2-0/) and will be
familiar to someone with experience using REST HTTP APIs.

## The Basics

The Ryver API is predominantly resource-oriented with a small number of
RPC-style end points to perform more complex actions. [Cross-origin resource
sharing](http://en.wikipedia.org/wiki/Cross-origin_resource_sharing) is supported
to provide access to our API from web clients. [JSON](http://www.json.org) is
returned for all resource requests.

<pre class="inline"><code>
http://host/path/odata.svc/users(1)?$top=2&$orderby=Name
\________________________/\_______/ \__________________/
             |                |               |
         base path      resource path    query options
</code></pre>

# Authentication

> To authenticate using curl:

```shell
curl -X POST -u user:pass "https://test.ryver.com/api/1/odata.svc/Session.Login()"
```

> Typical response

```json
{
  "username": "Stu",
  "id": 75,
  "sessionId": "develop:75:6b2e6516971b23910d75ef91b43fe7eaf3706675",
  "instanceId": "develop",
  "newUser": false,
  "__descriptor": "Stuart Carnie"
}
```

A consumer must first authenticate with the Ryver API using HTTP Basic
authentication over [HTTPS](http://en.wikipedia.org/wiki/HTTP_Secure), by
calling the `/api/1/odata.svc/Session.Login()` API.

<aside class="notice">
Upon successful verification of credentials, the server will respond with
information about the authenticated user, including a <code>sessionId</code>
that should be used in subsequent requests.
</aside>

The `sessionId` should be paired with a header named `Contatta-Session` as
follows

> Using the `Contatta-Session` header

```shell
curl "http://develop.contatta.vm/api/1/odata.svc/Session.GetCurrentUser()" \
     -H "Contatta-Session: develop:75:6b2e6516971b23910d75ef91b43fe7eaf3706675"
```
