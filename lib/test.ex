import Bender

defbend Out2, deps: [] do
    def process(:in, state, _opts) do
        IO.puts "NO?"
        state
    end
end

defbend Out, deps: [Out2] do
    def process(:in, state=%{extra: extra}, _opts) do
        state |> error "YES! : #{inspect extra}"
    end
end

defbender Test, extra: %{aaa: 5} do
    defpipe 1, bends: [Out], extra: %{ code: "IsTest" }
    defpipe 2, bends: [Out] 
end

