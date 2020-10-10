#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

"""
    register!(lks::Vector{Link}, lk::Link)

Register a link `lk` to a vector of links `lks`.
"""
register!(lks::Vector{Link}, lk::Link) = push!(lks, lk)
register!(lks::Vector{Channel}, lk::Link) = push!(lks, lk)

"""
	istaskfailed(lk::Link)

Returns true if a task associated with `lk` has failed.
"""
Base.istaskfailed(lk::Link) = !isnothing(lk.excp)

"""
    istaskfailed(lks::Vector{Link})

Returns true if any task associated with a vector `lks` of links
has failed.
"""
Base.istaskfailed(lks::Vector{Link}) = any(lk->istaskfailed(lk), lks)

"""
	taskstate(lk::Link)

Return the state (eventually the stacktrace) of a task associated 
with `lk`.
"""
function taskstate(lk::Link)
	if istaskfailed(lk)
		return hasfield(typeof(lk.excp), :task) ? lk.excp.task : lk.excp
	else
		return lk.cond_take.waitq.head.donenotify.waitq.head.code.task.state
	end
end

"""
	diag!(lk::LINK)

Return the internal `_ACT` variable of the `lk` actor.
This is only for diagnosis and testing.
"""
diag!(lk::LK) where LK<:LINK = request!(lk, Diag)
