# Actor Patterns

Here we describe some things we can do with actors:

## State Machines

Actors can be used to store, search, filter, compose, calculate ... concurrently on a computer or in a network. All those different activities can be seen generally as state machines.

State machines *have state and react to events*. In that basic sense actors are state machines and are particularly suited to represent them. `YAActL` actors have been designed to [support various approaches](examples/state-machines.md) to implement state machines.

## Parallel Computation

> ... actors provide no direct support for parallelism. ... And because actors do not share state and can only communicate through message passing, they are not a suitable choice if you need fine-grained parallelism. [^1]

As with Julia's built-in functionality you can easily parallelize heavy computations with actors. This is shown in the [parallel map example](examples/pmap.md).

## Building Systems

Actors are easily composable into systems. ...

## Fault-tolerant Systems

The supervisory tree is not yet implemented.

[^1]: Paul Butcher, Seven Concurrency Models in Seven Weeks.- 2014, The Pragmatic Programmers, p. 152