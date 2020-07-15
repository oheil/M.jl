module M

#include("a.jl")
include("b.jl")
include("c.jl")

function d()
    a=A()
    b(a)
    c(a)
end

end
