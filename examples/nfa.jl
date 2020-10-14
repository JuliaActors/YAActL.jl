using YAActL, .Iterators

@enum Q s t u v w   # describe states

# implement the transition function/methods
δ(::Val{s}, ::Val{'a'}) = (t,v,w)
δ(::Val{s}, ::Any)      = (s,)
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
δ(q::Q, c::Char) = δ(Val(q), Val(c))
δ(qs::Tuple, c::Char) = [δ(q,c) for q in qs]|>flatten|>Set|>Tuple

# this is a simple iteration over state
function check(str::String)
    qs = s
    for c in str
        qs = δ(qs, c)
    end
    intersect(qs,(u,v)) |> !isempty
end

# this works with the actor in state dispatch
function check(lk::Link, str::String)
    update!(mynfa, s)
    foreach(c->cast!(lk,c), str)
    intersect(query!(lk), (u,v)) |> !isempty
end

mynfa = Actor(δ)
set!(mynfa, state)

check(mynfa, "aabc")

check(mynfa, "bbb")
