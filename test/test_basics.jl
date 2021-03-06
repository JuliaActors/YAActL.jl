#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

using YAActL, Test

struct Incr <: Message
    x::Int
end
struct Decr <: Message
    x::Int
end

t = Ref{Task}()
lp = LinkParams(taskref=t)

a = [0]
inca(msg::Incr) = a[1] += msg.x
inca(msg::Decr) = ( become(deca); send!(self(), msg) )
deca(msg::Decr) = a[1] -= msg.x
deca(msg::Incr) = ( become(inca); send!(self(), msg))
fail(msg::Incr) = undefined

A = Actor(lp, inca)
@test A isa Link
@test t[].state == :runnable
act = YAActL.diag!(A)
@test act.self == A
@test act.bhv.f == inca

send!(A, Incr(10))
sleep(0.1)
@test act.res == 10
@test a[1] == 10

send!(A, Decr(5))
send!(A, Decr(5))
sleep(0.2)
@test a[1] == 0

@test !istaskfailed(A)
@test info(A) == :runnable

exit!(A)
sleep(0.1)
@test !isopen(A.chn)

B = Actor(fail)
send!(B, Incr(0))
sleep(0.1)
@test istaskfailed(B)
s = info(B)
@test s.exception isa UndefVarError
