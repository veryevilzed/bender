defmodule Bender.Tools do
    defmacro __using__(_opts) do
        quote location: :keep do
            alias Bender.State
            # Перекладывание мидлваря
            defp take_request_middleware(args=%State{ bends: {[],_} }), do: {:empty, args}
            defp take_request_middleware(args=%State{ bends: {[head|tail], m} }), do: {:ok, head, %{args | bends: {tail, [head|m]}}}

            defp process_out(args=%State{ bends: {_, []} }), do: args
            defp process_out(args=%State{ bends: {inm, [middleware|tail]} }) do
                args = %{ args | bends: {inm, tail} }
                args = case middleware do
                    {middleware, opts} -> apply(middleware, :process, [:out, args, opts])
                    middleware -> apply(middleware, :process, [:out, args, []])
                end
                process_out(args)
            end
            defp process_in(args) do
                case take_request_middleware(args) do
                    {:ok, middleware, args} -> 
                        args = case middleware do
                            {middleware, opts} -> process_in(apply(middleware, :process, [:in, args, opts]))
                            middleware ->         process_in(apply(middleware, :process, [:in, args, []]  ))
                        end
                    {:empty, args} ->
                      process_out(args)
                end                       
            end

        end
    end
end



defmodule Bender.Utils do
    defp deps(middleware) do
        case middleware do
            {middle, _} -> middle.deps
            middle -> middle.deps
        end
    end

    defp chain_type(middleware) do
        case middleware do
            {middle, _} -> middle.chain_type
            middle -> middle.chain_type
        end
    end

    defp in_middles(_middle, []), do: false
    defp in_middles(middle, [head|tail]) do
        case head do
            {^middle, _} -> true
            ^middle -> true
            _ -> in_middles(middle, tail)
        end
    end

    def filter_middlewares([], res), do: res |> Enum.reverse
    def filter_middlewares([m={middleware, _args}|middlewares], res) do
        case {in_middles(middleware, res), chain_type(middleware)}   do
            {true, :only}    ->   filter_middlewares(middlewares, res)
            {true, :only_args} ->   
                case in_middles(m, res) do
                    true  ->     filter_middlewares(middlewares, res)
                    false ->     filter_middlewares(middlewares, [m | res])
                end
            {_, :all}  ->      filter_middlewares(middlewares, [m | res])
            {false, _} ->      filter_middlewares(middlewares, [m | res])
        end
    end
    def filter_middlewares([middleware|middlewares], res) do
        case {in_middles(middleware, res), chain_type(middleware)}   do
            {true, :only} ->   filter_middlewares(middlewares, res)                                
            {true, _} ->       filter_middlewares(middlewares, res)
            {_, :all} ->       filter_middlewares(middlewares, [middleware | res])
            {false, _} ->      filter_middlewares(middlewares, [middleware | res])
        end
    end


    def required_middlewares(middlewares) when is_list(middlewares) do
        Enum.map(middlewares, fn(x) -> required_middlewares x end)
    end

    def required_middlewares(middleware) do

        req = deps middleware
        case req do
            [] -> [middleware]
            req -> Enum.map(req, fn(x) -> required_middlewares x end) ++ [middleware]
        end
    end

end