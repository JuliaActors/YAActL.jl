#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

using YAActL, Test

struct MyMsg <: Message 
    x::Int
end

struct MySource <: Message
    x::Int
    from::LINK
end

function writeLk(lk::Link, src=true, slp=false)
    for i in 1:4
        put!(lk, MyMsg(i))
        yield()
        slp && sleep(rand()*0.1)
    end
    if src
        put!(lk, MySource(10, USR))
        yield()
        slp && sleep(rand()*0.1)
    end
    for i in 5:8
        put!(lk, MyMsg(i))
        yield()
        slp && sleep(rand()*0.1)
    end
end

function readLk(lk::Link)
    buf = Int[]
    while isready(lk)
        push!(buf, take!(lk).x)
    end
    buf
end

myLink = Link(10)

@test YAActL._match(MyMsg(1), nothing, nothing)
@test YAActL._match(MySource(1,USR), nothing, nothing)

@test YAActL._match(MyMsg(1), MyMsg, nothing)
@test !YAActL._match(MyMsg(1), Response, nothing)

@test !YAActL._match(MyMsg(1), nothing, USR)
@test YAActL._match(MySource(1,USR), nothing, USR)
@test !YAActL._match(MySource(1,USR), nothing, myLink)

@test !YAActL._match(MyMsg(1), MyMsg, USR)
@test !YAActL._match(MySource(1,USR), MyMsg, USR)
@test YAActL._match(MySource(1,USR), MySource, USR)
@test !YAActL._match(MySource(1,USR), MySource, myLink)

writeLk(myLink)
@test length(myLink.data) == 9
msg = receive!(myLink, MySource, USR)
@test msg == MySource(10, USR)
@test length(myLink.data) == 8
@test readLk(myLink) == collect(1:8)
@test length(myLink.data) == 0

msg = receive!(myLink, MySource, USR, timeout=1)
@test msg == Timeout()

writeLk(myLink, false)
@test length(myLink.data) == 8
msg = receive!(myLink, MySource, USR, timeout=0)
@test msg == Timeout()
@test length(myLink.data) == 8
@test readLk(myLink) == collect(1:8)
@test length(myLink.data) == 0

@async writeLk(myLink, true, true)
msg = receive!(myLink, MySource, USR)
@test msg == MySource(10, USR)
sleep(1)
@test length(myLink.data) == 8
@test readLk(myLink) == collect(1:8)
@test length(myLink.data) == 0

comtest(msg::MySource) = nothing
function comtest(msg::Request)
    res = (1, (2), (3,4,5), [6,7,8])
    if msg.x in 1:4
        send!(msg.from, Response(res[msg.x], self()))
    else
        send!(msg.from, Response("test", self()))
    end
    return nothing
end

A = Actor(comtest)
send!(A, MySource(1, USR))
msg = receive!(USR, timeout=1)
@test msg == Timeout()
send!(A, Request(10, USR))
msg = receive!(USR, timeout=1)
@test msg == Response("test", A)

res = request!(A, MySource(1, USR), timeout=1)
@test res == Timeout()
res = request!(A, Request(1, USR), full=true, timeout=1)
@test res == Response(1, A)
@test request!(A, Request(1, USR), timeout=1) == 1
@test request!(A, Request(2, USR), timeout=1) == 2
@test request!(A, Request(3, USR), timeout=1) == (3,4,5)
@test request!(A, Request(4, USR), timeout=1) == [6,7,8]
@test request!(A, Request(99, USR), timeout=1) == "test"
