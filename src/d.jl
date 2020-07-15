module D
export dfunc

include("b.jl")
using .B

include("c.jl")
using .C

include("a.jl")
using .A

function dfunc()
    a=Astruct()
    bfunc(a)
    cfunc(a)
end

end