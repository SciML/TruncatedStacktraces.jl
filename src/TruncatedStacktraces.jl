module TruncatedStacktraces

using InteractiveUtils
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

end