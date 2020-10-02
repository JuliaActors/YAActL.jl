using Documenter, YAActL

makedocs(
    modules = [YAActL],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    sitename = "YAActL.jl",
    authors  = "Paul Bayer",
    pages = [
        "Home" => "index.md",
        "Introduction" => "intro.md",
        "Manual" => [
            "setup.md",
            "actors.md",
            "links.md",
            "behavior.md",
            "patterns.md"],
        "Examples" => [
            "examples/stack.md",
            "examples/factorial.md"],
        "Internals" => [
            "messages.md",
            "internals.md",
            "diagnosis.md"]
    ]
)

deploydocs(
    repo   = "github.com/pbayer/YAActL.jl.git",
    target = "build",
    deps   = nothing,
    make   = nothing,
    devbranch = "master",
    devurl = "dev",
    versions = ["stable" => "v^", "v#.#", "dev" => "dev"]
)
