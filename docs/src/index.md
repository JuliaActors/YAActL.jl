# YAActL.jl

*Yet Another Actor Library* (but in Julia)

`YAActL` aims to be a tiny smart actor library for parallel and distributed computing. It is in early development and uses native Julia tasks and channels to implement actors.

## Documentation Overview

- A [quick introduction](intro.md) to `YAActL`,
- Manual, how to:
    - [setup](setup.md) `YAActL`,
    - [start and operate actors](actors.md),
    - understand [links to actors](links.md),
    - understand and define [actor behaviors](behavior.md),
- Examples:
    - a [stack](examples/stack.md),
    - a [recursive factorial](examples/factorial.md),
- Internals
    - [messages](messages.md) to actors,
    - actor [diagnosis](diagnosis.md)

## Rationale

1. Actors are exciting.
2. Actors are needed for parallel computing.
3. There is no mature [actor library](https://en.wikipedia.org/wiki/Actor_model#Actor_libraries_and_frameworks) in Julia. 
4. Building on Julia's existing strengths, it is possible to condense the actor-concept into a tiny smart and fast library for Julia.
5. A community effort is needed to do it.
6. This will enhance Julia's parallel computing capabilities.

If you agree with those points, please join `YAActL`'s development.

## References

- The [Actor model](https://en.wikipedia.org/wiki/Actor_model) on Wikipedia
- Gul Agha: Actors, A Model of Concurrent Computation in Distributed Systems.- 1986, MIT Press
- Vaughn Vernon: Reactive Messaging Patterns with the Actor Model, Applications and Integrations in Scala and Akka.- 2016, Pearson
- Joe Armstrong: Programming Erlang, 2nd ed., Software for a Concurrent World.- 2013 Pragmatic Programmers

## Author(s)

- [Paul Bayer](https://github.com/pbayer)

## License

`YAActL` is licensed under the [MIT License](https://github.com/pbayer/YAActL.jl/blob/master/LICENSE).
