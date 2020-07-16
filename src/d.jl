module D
export dfunc

include("a.jl")
using .A

include("b.jl")
using .B

include("c.jl")
using .C

function dfunc()
    a=Astruct()
    bfunc(a)
    cfunc(a)
end

end