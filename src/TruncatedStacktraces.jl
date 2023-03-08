module TruncatedStacktraces

using InteractiveUtils, MacroTools
const VERBOSE = Ref(false)

VERBOSE_MSG = """


Some of the types have been truncated in the stacktrace for improved reading. To emit complete information
in the stack trace, evaluate `TruncatedStacktraces.VERBOSE[] = true` and re-run the code."""

function __init__()
    for type in InteractiveUtils.subtypes(Exception)
        if type == MethodError
            Base.Experimental.register_error_hint(type) do io, e, args, kwargs
                !VERBOSE[] && println(io, VERBOSE_MSG)
            end
        else
            Base.Experimental.register_error_hint(type) do io, e
                !VERBOSE[] && println(io, VERBOSE_MSG)
            end
        end
    end
end

"""
    @truncate_stacktrace MyCustomType short_display_ordering...

Convenience Macro to generate `Base.show` for `::Type{MyCustomType{...}}`. For example, lets
say you have the following struct.

```julia
struct MyCustomType{A, B, C}
    a::A
    b::B
    c::C
end
```

Invoking `@truncate_stacktrace MyCustomType 3 1` generates the following code block
automatically:

```julia
function Base.show(io::IO, t::Type{(MyCustomType){var"##301", var"##302", var"##303"}}; ) where {var"##301", var"##302", var"##303"}
    if TruncatedStacktraces.VERBOSE[]
        print(io, string(MyCustomType) * "{" * join([var"##301", var"##302", var"##303"], ", ") * "}")
    else
        print(io, string(MyCustomType) * "{" * join([var"##303", var"##301"], ", ") * ", " * "...}")
    end
end
```
"""
macro truncate_stacktrace(l::Symbol, short_display...)
    l = getproperty(__module__, l)

    pcount = __get_parameter_count(l)
    @assert __maximum(short_display, pcount) <= pcount && __minimum(short_display, 1) >= 1

    name = :(Base.show)
    whereparams = ntuple(_ -> gensym(), pcount)
    args = Any[:(io::IO), :(t::Type{$l{$(whereparams...)}})]
    kwargs = []

    body = quote
        if TruncatedStacktraces.VERBOSE[]
            print(io, string($l) * "{" * join([$(whereparams...)], ", ") * "}")
        else
            print(io,
                  string($l) * "{" * join([$(whereparams[[short_display...]]...)], ", ") *
                  $(length(short_display) == 0 ? "" : ",") * "…}")
        end
    end

    fdef = Dict(:name => name, :args => args, :kwargs => kwargs, :body => body,
                :whereparams => whereparams)

    return MacroTools.combinedef(fdef)
end

__maximum(x, ::Int) = maximum(x)
__maximum(::Tuple{}, t::Int) = t
__minimum(x, ::Int) = minimum(x)
__minimum(::Tuple{}, ::Int) = 1

function __get_parameter_count(T::Union{DataType, UnionAll})
    length(Base.unwrap_unionall(T).parameters)
end

end
