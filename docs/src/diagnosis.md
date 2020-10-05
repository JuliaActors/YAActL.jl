# Diagnosis

```@meta
CurrentModule = YAActL
```

In order to develop actor programs, it is useful to have access to the actor tasks and eventually to their stack traces. You can `register!` an actor channel to a `Vector{Link}` in order to get access to the tasks.

```@docs
register!
istaskfailed(::Link)
istaskfailed(::Vector{Link})
taskstate
```

For diagnostic purposes it is possible to get access to the actor's [`ACT`](@ref _ACT) variable:

```@docs
diag!
```
