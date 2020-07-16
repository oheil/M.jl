#module C
#export cfunc

#include("a.jl")
#using ..A

function cfunc(::Astruct)
end

#end
