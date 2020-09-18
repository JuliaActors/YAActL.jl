using Documenter, YAActL

makedocs(
    modules = [YAActL],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    sitename = "YAActL.jl",
    authors  = "Paul Bayer",
    pages = [
            "index.md",
            "setup.md",
            "actors.md",
            "links.md",
            "messages.md",
            "behavior.md",
            "examples.md",
            "diagnosis.md"
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
