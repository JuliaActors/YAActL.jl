#
# This example implements a DFA (deterministiv finite automaton)
#
#   A = ({s,q,p,r},{'a','b','c'},δ,s,{r})
# 
#   with the following transition table:

#         | input symbols
#  states | 'a' | 'b' | 'c'
#  -------+-----+-----+-----
#   -> s  |  s  |  q  |  s
#      q  |  p  |  r  |  r
#      p  |  p  |  q  |  p
#    * r  |  r  |  r  |  r
#
using YAActL

s(::Val{'b'}) = become(q)
s(x) = nothing
q(::Val{'a'}) = become(p)
q(::Val{'b'}) = become(r)
q(::Val{'c'}) = become(r)
q(x) = nothing
p(::Val{'b'}) = become(q)
p(x) = nothing
r(x) = nothing

mydfa = Actor(s)

function check(lk::Link, str::String)
    become!(lk, s)          # start behavior
    foreach(str) do c
        cast!(lk, Val(c))   # send all chars to the actor
    end
    query!(lk, :bhv) == r   # check the actors behavior
end

check(mydfa, "baab")        # false
check(mydfa, "baabc")       # true
check(mydfa, "babaccabb")   # true
