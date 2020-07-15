module B
export bfunc

include("a.jl")
using .A

function bfunc(::Astruct)
end

end
