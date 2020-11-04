# State Machines

There are various ways to implement state machines with actors. The following examples illustrate how actors operate as state machines and are not to propose actual implementations.

## DFAs, behavior-switch

Behavior-switch is the most elegant way to implement a finite state machine with an actor.

Take a [deterministic finite automaton](https://en.wikipedia.org/wiki/Deterministic_finite_automaton) with four states ``\{s,q,p,r\}``, three inputs ``\{a,b,c\}`` and the transition function ``δ`` represented in a table:

| ``\;``          |  ``\;``  |  a  |  b  |  c  |
|----------------:|---------:|:---:|:---:|:---:|
|   initial state | -> **s** |  s  |  q  |  s  |
|                 |    **p** |  p  |  q  |  p  |
|                 |    **q** |  p  |  r  |  r  |
| accepting state |  * **r** |  r  |  r  |  r  |

The state-transition table can be implemented directly:

```julia
using YAActL

s(::Val{'b'}) = become(q)  # implement behaviors
s(x) = nothing             # default transition
p(::Val{'b'}) = become(q)
p(x) = nothing
q(::Val{'a'}) = become(p)
q(::Val{'b'}) = become(r)
q(::Val{'c'}) = become(r)
q(x) = nothing
r(x) = nothing
```

DFA-states are directly represented by behavior functions. Those switch behavior/state on certain input values or otherwise do nothing.

The actor ist started with the initial behavior. A `check` function parses input strings:

```julia
mydfa = Actor(s)

function check(lk::Link, str::String)
    become!(lk, s)         # switch to initial state
    foreach(str) do c
        cast!(lk, Val(c))  # send all chars to the actor
    end
    query!(lk, :bhv) == r  # check the final state
end
```

It checks which strings get accepted:

```julia
julia> check(mydfa, "baab")
false

julia> check(mydfa, "baabc")
true

julia> check(mydfa, "babaccabb")
true
```

## NFAs, state-dispatch

Non-deterministic finite automata can have more complex states, and more than one transition can happen at an input event.

|  ``\;``         |  ``\;``  |    a    |   b   |   c   |
|----------------:|---------:|:-------:|:-----:|:-----:|
|   initial state | -> **s** | {t,v,w} |   ∅   |   ∅   |
|                 |    **t** |  {u,v}  | {u,v} |   ∅   |
| accepting state |  * **u** |  {s,w}  | {s,w} |   ∅   |
| accepting state |  * **v** |    ∅    | {t,v} | {t,v} |
|                 |    **w** |    ∅    | {t,v} |   ∅   |

Now a simple state cannot represent directly this NFA. A transition function ``\delta`` is used to return and to dispatch on a `Tuple` of states:

```julia
using YAActL, .Iterators

@enum Q s t u v w   # describe states

# implement the transition function/methods
δ(::Val{s}, ::Val{'a'}) = (t,v,w)
δ(::Val{s}, ::Any)      = (s,)        # default transition
δ(::Val{t}, ::Val{'a'}) = (u,v)
δ(::Val{t}, ::Val{'b'}) = (u,v)
δ(::Val{t}, ::Any)      = (t,)
δ(::Val{u}, ::Val{'a'}) = (s,w)
δ(::Val{u}, ::Val{'b'}) = (s,w)
δ(::Val{u}, ::Any)      = (u,)
δ(::Val{v}, ::Val{'b'}) = (t,v)
δ(::Val{v}, ::Val{'c'}) = (t,v)
δ(::Val{v}, ::Any)      = (v,)
δ(::Val{w}, ::Val{'b'}) = (t,v)
δ(::Val{w}, ::Any)      = (w,)
δ(q::Q, c::Char) = δ(Val(q), Val(c))  # function barrier
δ(qs::Tuple, c::Char) = [δ(q,c) for q in qs] |> flatten |> Set |> Tuple
```

To illustrate how an actor works in `state` dispatch mode,
 we implement a simple iteration function to parse an input string and an actor method:

```julia
# do a simple iteration with a local state variable
function check(str::String)
    qs = s             # set the initial state 's'
    for c in str
        qs = δ(qs, c)  # update state
    end
    intersect(qs, (u,v)) |> !isempty
end

# work with the actor in state dispatch
function check(lk::Link, str::String)
    update!(mynfa, s)              # set initial state
    foreach(c->cast!(lk,c), str)   # cast each character
    intersect(query!(lk), (u,v)) |> !isempty  # check state
end
```

Both implementations follow exactly the same logic. But in the second case the actor maintains state. This enables asynchronous operation: we can send single characters and  query the state anytime.

An actor is setup in `state` dispatch mode and checks strings:

```julia
mynfa = Actor(δ)    # an actor with a δ behavior
set!(mynfa, state)  # is set to state dispatch
...

julia> check(mynfa, "aabc")
true

julia> check(mynfa, "bbb")
false
```

## Fibonacci Server

Servers often store data and provide it to clients with some additional computation. One classic example of that is a Fibonacci server. It stores calculated fibonacci numbers in a `Dict` in order to be able to serve future calls faster:

```julia
using YAActL

function fib(D::Dict{Int,BigInt}, n::Int)
    get!(D, n) do
        n == 0 && return big(0)
        n == 1 && return big(1)
        return fib(D, n-1) + fib(D, n-2)
    end
end
```

Since `D` is a mutable variable and `fib` returns the result, we use the actor's `full` dispatch mode. We start it with a new empty `Dict` and can `call!` it with the desired number `n`. The actor then updates `D` as necessary:

```julia
myfib = Actor(fib, Dict{Int,BigInt}())

julia> call!(myfib, 1000)
43466557686937456435688527675040625802564660517371780402481729089536555417949051890403879840079255169295922593080322634775209689623239873322471161642996440906533187938298969649928516003704476137795166849228875
```

The dictionary `D` is private to the actor.

## Generic Function Servers

`YAActL` actors support directives like:

- [`become!`](@ref): cause an actor to switch its behavior,
- [`call!`](@ref) an actor to execute its behavior function and to send the result,
- [`cast!`](@ref): cause an actor to execute its behavior function,
- [`exec!`](@ref): tell an actor to execute a function and to send the result.

They operate as state machines for executing functions. This makes them generic function servers. As shown above the behavior functions may implement state machines as well. They can start other child or siblings actors for doing things. Thus they can represent a hierarchy of state machines.
