defmodule Bender.Core do
    defmacro __using__(_opts) do
        quote location: :keep do
            alias Bender.State
            defmacro defbender name, opts \\ [], code do
                bends = Dict.get opts, :bends, []
                quote do
                    defmodule unquote(name) do
                        use Bender.Tools

                        unquote(code)

                        defp _request(_, state), do: state

                        def request(slug, request \\ []) do
                            state =  %State{bends: { [] ++ unquote(bends), [] }, slug: slug, extra: Dict.get(unquote(opts), :extra, %{}), request: Dict.merge(%{extra: %{}}, request)}         
                            %{response: %{result: result, status: status, extra: extra}} = _request(slug, state)
                            {status, result, extra}
                        end

                        def request!(slug, request \\ []) do
                            case request(slug, request) do
                                {:error, error, _} -> raise error
                                {_, result, _} -> result
                            end
                        end
                    end
                end
            end

            defmacro defpipe slug, opts \\ [] do
                bends = Dict.get(opts, :bends, []) 
                bends = Enum.map(bends, 
                    fn({{_, _, [x, :init]}, _, mopts}) -> 
                        {_, _, [name]} = x
                        {:"Elixir.#{name}", mopts}
                    ({x, mopts}) -> 
                        {_, _, [name]} = x
                        {:"Elixir.#{name}", mopts}
                    (x) -> 
                        {_, _, [name]} = x
                        :"Elixir.#{name}"
                    end)
                bends = Enum.map(bends, fn(x)-> Bender.Utils.required_middlewares x end) 
                    |> List.flatten 
                    |> Bender.Utils.filter_middlewares []


                quote do
                    defp _request(unquote(slug), state = %State{ extra: extra, bends: {a, b} }) do
                        %{ state | bends: { a ++ unquote(bends), b }, extra: Map.merge(extra, Dict.get(unquote(opts), :extra, %{}))  } |> process_in
                    end
                end
            end
        end
    end
end