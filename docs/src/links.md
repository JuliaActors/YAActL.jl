# Links

We send messages to actors and they can send them to others over links. In fact, an actor is only represented by its link which it returns upon creation:

```@docs
Link
RLink
LINK
```

Actors correspond with other actors over links. There is a default link for users to communicate with actors.

```@docs
USR
```

For setting up links explicitly we have the following functions.

```@docs
newLink
LinkParams
parallel
```
