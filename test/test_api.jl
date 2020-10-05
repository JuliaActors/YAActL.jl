#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#
using YAActL, Test

t = Ref{Task}()                # this is for debugging
lp = LinkParams(taskref=t)

arg = YAActL.Args(1, 2, c=3, d=4)
@test arg.args == (1, 2)
@test arg.kwargs == pairs((c=3, d=4))

a = b = c = d = 1
e = f = 2

incx(x, by; y=0, z=0) = x+y+z + by
subx(x, y, sub; z=0) = x+y+z - sub

A = Actor(lp, incx, a, y=b, z=c)
sleep(0.1)
@test taskstate(A) == :runnable

# test diag and actor startup, become! (implicitly)
act = YAActL.diag!(A)
sleep(0.1)
@test act.dsp == full
@test act.sta == Tuple{}()
@test act.bhv.f == incx
@test act.bhv.args == (1,)
@test act.bhv.kwargs == pairs((y=1,z=1))

# test explicity become!
become!(A, subx, a, b, z=c)
sleep(0.1)
@test act.bhv.f == subx
@test act.bhv.args == (1,1) 
@test act.bhv.kwargs == pairs((z=1,))

# test set!
set!(A, state)
sleep(0.1)
@test act.dsp == state

# test update!
update!(A, 1, 2, 3)
sleep(0.1)
@test act.sta == (1,2,3)
update!(A, Args(2,3, x=1, y=2))
sleep(0.1)
@test act.bhv.args == (2,3)
@test act.bhv.kwargs == pairs((x=1,y=2,z=1))

# test get
@test get!(A) == (1,2,3)

# test call!
become!(A, incx, a, y=b, z=c)
set!(A, full)
@test call!(A, 1) == 4
set!(A, state)
update!(A, 1)
update!(A, Args(y=2,z=2))

# test cast!
