defmodule Bender.Core do
    defmacro __using__(_opts) do
        quote location: :keep do
            alias Bender.State
            defmacro defbender name, opts \\ [], code do
                g_extra = Dict.get opts, :extra, %{}
                bends = Dict.get opts, :bends, []
                quote do
                    defmodule unquote(name) do
                        use Bender.Tools

                        unquote(code)

                        defp _request(_, state), do: state

                        def request(slug, request \\ []) do
                            state =  %State{slug: slug, request: Dict.merge(%{extra: unquote(g_extra)}, request)}                
                            %{response: %{result: result, status: status, extra: extra}} = _request(slug, state)
                            {status, result, extra}
                        end

                        def request!(slug, request \\ []) do
                            case request(slug, request) do
                                {:ok, result, _} -> result
                                {_, error, _} -> raise error
                            end
                        end
                    end
                end
            end

            defmacro defpipe slug, opts \\ [] do
                g_extra = Dict.get(opts, :extra, %{})
                IO.puts "1"
                bends = Dict.get(opts, :bends, []) 
                IO.puts "2"
                bends = Enum.map(bends, fn(x)-> 
                            {_, [name]} = Macro.decompose_call(x)
                            Bender.Utils.required_middlewares :"Elixir.#{name}"
                        end) 
                    |> List.flatten 
                    |> Bender.Utils.filter_middlewares []
                IO.puts "3"
                quote do
                    defp _request(unquote(slug), state = %State{ extra: extra, bends: {a, b} }) do
                        %{ state | bends: { a ++ unquote(bends), b }, extra: Map.merge(extra, unquote(g_extra))  } |> process_in
                    end
                end
            end
        end
    end
end