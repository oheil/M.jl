#copy&paste into REPL:

using BenchmarkTools

module M

mutable struct Ef
    e::Expr
    f1::Function
    f2::Function
    f3::Function
    function Ef()
        e = :(a + b)
        f1 = Base.eval( :( (a::Int,b::Int)->$e ) )
        f2 = Core.eval( M , :( (a::Int,b::Int)->$e ) )
        f3 = (a,b)->a+b
        new(e,f1,f2,f3)
    end
end

function eval_global(a_ef::Array{Ef,1})
    r=0
    for ef in a_ef
        global a=3
        global b=5
        try
            r += Core.eval(M, ef.e)
        catch e
        end
    end
    return r
end

function eval_let(a_ef::Array{Ef,1})
    r=0
    for ef in a_ef
        val1=3
        val2=5
        ex=ef.e
        try
            r += @eval begin
                    let
                        a=$val1
                        b=$val2
                        $ex
                    end
                end
        catch e
        end
    end
    return r
end

interpolate_from_dict(ex::Expr, dict) = Expr(ex.head, interpolate_from_dict.(ex.args, Ref(dict))...)
interpolate_from_dict(ex::Symbol, dict) = get(dict, ex, ex)
interpolate_from_dict(ex::Any, dict) = ex
function eval_interpolate(a_ef::Array{Ef,1})
    r=0
    for ef in a_ef
        try
            r += Base.eval(interpolate_from_dict(ef.e,Dict( :a => 3, :b => 5 )))
        catch e
        end
    end
    return r
end

function eval_invokelatest(@nospecialize(a_ef::Array{Ef,1}))
    r=0
    for ef in a_ef
        r += Base.invokelatest(ef.f1,3,5)
    end
    return r
end

function eval_applylatest(@nospecialize(a_ef::Array{Ef,1}))
    r=0
    for ef in a_ef
        r += Core._apply_latest(ef.f1,3,5)
    end
    return r
end

function eval_f1(a_ef::Array{Ef,1})
    r=0
    for ef in a_ef
        try
            r += ef.f1(3,5)
        catch e
        end
    end
    return r
end

function eval_f2(a_ef::Array{Ef,1})
    r=0
    for ef in a_ef
        try
            r += ef.f2(3,5)
        catch e
        end
    end
    return r
end

function eval_f3(a_ef::Array{Ef,1})
    r=0
    for ef in a_ef
        try
            r += ef.f3(3,5)
        catch e
        end
    end
    return r
end

function f(a,b)
    try
        a+b
    catch e
       0
    end
end

end

a_ef=[ M.Ef() for i in 1:1000 ]

#1
@btime M.eval_global($a_ef)

#2
@btime M.eval_let($a_ef)

#3
@btime M.eval_interpolate($a_ef)

#4
@btime M.eval_f1($a_ef)

#5
@btime M.eval_f2($a_ef)

#6
@btime M.eval_f3($a_ef)

#7
@btime sum( [ M.f(3,5) for i in 1:1000 ] )

#8
@btime M.eval_invokelatest($a_ef)

#8
@btime M.eval_applylatest($a_ef)
