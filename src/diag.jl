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
Base.istaskfailed(lk::Link) = !isnothing(lk.chn.excp)

"""
    istaskfailed(lks::Vector{Link})

Returns true if any task associated with a vector `lks` of links
has failed.
"""
Base.istaskfailed(lks::Vector{Link}) = any(lk->istaskfailed(lk), lks)

"""
	info(lk::Link)

Return the state (eventually the stacktrace) of a task associated 
with `lk`.
"""
function info(lk::Link)
	if istaskfailed(lk)
		return hasfield(typeof(lk.chn.excp), :task) ? lk.chn.excp.task : lk.chn.excp
	else
		return lk.chn.cond_take.waitq.head.donenotify.waitq.head.code.task.state
	end
end

"""
	diag!(lk::Link)

Return the internal `_ACT` variable of the `lk` actor.
This is only for diagnosis and testing.
"""
diag!(lk::Link) = request!(lk, Diag)
