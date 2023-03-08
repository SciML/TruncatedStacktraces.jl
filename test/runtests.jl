using Test, TruncatedStacktraces

@testset "Test that VERBOSE can remove the notice message" begin
    TruncatedStacktraces.VERBOSE[] = false
    error_msg = Ref{String}()
    try
        x
    catch e
        io = IOBuffer()
        showerror(io, e)
        error_msg[] = String(take!(io))
    end
    @test error_msg[] ==
          "UndefVarError: `x` not defined" *
          "\n\nSome of the types have been truncated in the" *
          " stacktrace for improved reading. To emit complete " *
          "information\nin the stack trace, evaluate " *
          "`TruncatedStacktraces.VERBOSE[] = true` and re-run the code.\n"
    TruncatedStacktraces.VERBOSE[] = true
    try
        x
    catch e
        io = IOBuffer()
        showerror(io, e)
        error_msg[] = String(take!(io))
    end
    @test error_msg[] ==
          "UndefVarError: `x` not defined"
end