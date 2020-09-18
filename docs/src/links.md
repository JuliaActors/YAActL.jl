# Links

We send messages to actors and they can send them to others over links. In fact, an actor is only represented by its link which it returns upon creation:

```@docs
Link
RLink
LINK
send!
```

Actors correspond with other actors over links. If we want a response from an actor, we must send it our own link together with a request message.

```@docs
self()
USR
```

For setting up links explicitly we have the following functions.

```@docs
newLink
LinkParams
parallel
```
