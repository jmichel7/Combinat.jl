using Documenter, Combinat

DocMeta.setdocmeta!(Combinat, :DocTestSetup, :(using Combinat); recursive=true)

makedocs(;
    modules=[Combinat],
    authors="Jean Michel <jean.michel@imj-prg.fr> and contributors",
    sitename="Combinat.jl",
    format=Documenter.HTML(;
        canonical="https://jmichel7.github.io/Combinat.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
    warnonly=:missing_docs,
)

deploydocs(;
    repo="github.com/jmichel7/Combinat.jl",
    devbranch="main",
)
