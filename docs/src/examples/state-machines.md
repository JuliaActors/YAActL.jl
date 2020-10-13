# State Machines

There are various ways to implement state machines with actors. The following examples show some approaches and don't propose actual implementations.

## A DFA

One of the simplest ways to implement a state machine behavior is to implement a behavior function with appropriate transition methods for each state-event combination.

We take a [deterministic finite automaton](https://en.wikipedia.org/wiki/Deterministic_finite_automaton), ``A = (\{s,q,p,r\},\{a,b,c\},δ,s,\{r\})`` with the following state-transition table:

| | inputs  | 'a' | 'b' | 'c' |
|--:|-------:|:-----:|:-----:|:-----:|
|**initial state**|   -> s  |  s  |  q  |  s |
| |      q  |  p  |  r  |  r |
| |      p  |  p  |  q  |  p |
|**accepting state**|    * r  |  r  |  r  |  r |

We can implement that directly: 

```julia
using YAActL

s(::Val{'b'}) = become(q)  # implement behaviors
s(x) = nothing
q(::Val{'a'}) = become(p)
q(::Val{'b'}) = become(r)
q(::Val{'c'}) = become(r)
q(x) = nothing
p(::Val{'b'}) = become(q)
p(x) = nothing
r(x) = nothing
```

We dispatch on values and use default transitions doing nothing. We start an actor and use a small `check` function to parse input strings:

```julia
mydfa = Actor(s)

function check(lk::Link, str::String)
    become!(lk, s)         # start behavior
    foreach(str) do c
        cast!(lk, Val(c))  # send all chars
    end
    get!(lk, :bhv) == r    # check the final behavior
end
```

Then we can check which strings get accepted:

```julia
julia> check(mydfa, "baab")
false

julia> check(mydfa, "baabc")
true

julia> check(mydfa, "babaccabb")
true
```

## A NFA

Non-deterministic finite automata can have more complex states, and more than one transition can happen at an input event.

## A Fibonacci Server

Servers often store data and provide it with some additional computation. One classic example of that is a Fibonacci server:

