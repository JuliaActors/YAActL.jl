# YAActL.jl

*Yet another Actor Library* (built in Julia)

`YAActL` is a library for concurrent computing in Julia based on the [Actor model](https://en.wikipedia.org/wiki/Actor_model).

## Overview

- A [quick introduction](intro.md) to `YAActL`,
- Manual, how to:
    - [setup](setup.md) `YAActL`,
    - understand and use [actors](actors.md),
    - understand [links](links.md) to actors,
    - control actor [behavior](behavior.md).
- Actor API: [detailed documentation](api.md).
- Examples:
    - a [stack](examples/stack.md),
    - a [recursive factorial](examples/factorial.md),
- Internals
    - [messages](messages.md) to actors,
    - actor [diagnosis](diagnosis.md)

## Rationale

1. Actors are an important concept for concurrent computing.
2. There is no [actor library](https://en.wikipedia.org/wiki/Actor_model#Actor_libraries_and_frameworks) in Julia.
3. Julia allows to condense the actor-concept into a  smart and fast library.
4. A community effort is needed to do it.

If you agree with those points, please help with  `YAActL`'s development.

## Author(s)

- [Paul Bayer](https://github.com/pbayer)

## License

`YAActL` is licensed under the [MIT License](https://github.com/pbayer/YAActL.jl/blob/master/LICENSE).
