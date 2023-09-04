import Bender


defbend A.Out3, deps: [] do
    def process(:in, state, _opts) do
        IO.puts "IS 3"
        state
    end
end

defbend Out2, deps: [] do
    def process(:in, state, _opts) do
        state
    end
end

defbend Out, deps: [Out2] do
    def process(:out, state = %{extra: extra}, opts) do
        state |> return("YES! : #{inspect extra} #{inspect opts}", :hex)
    end
end

defbender Test, extra: %{aaa: 5}, bends: [A.Out3] do
    defpipe 1, bends: [{Out, [5]}, Out.init(5)], extra: %{ code: "IsTest" }
    defpipe 2, bends: [Out] 
end

