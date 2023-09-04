defmodule Bender.Core do
    defmacro __using__(_opts) do
        quote location: :keep do
            alias Bender.State
            defmacro defbender(name, opts \\ [], code) do
                bends = Keyword.get(opts, :bends, [])
                quote do
                    defmodule unquote(name) do
                        use Bender.Tools
                        all_bends = []

                        unquote(code)

                        @all_bends all_bends
                        def all, do: @all_bends

                        defp _request(_, state), do: state

                        def request(slug, request \\ []) do
                            state =  %State{__request__: request, bends: { [] ++ unquote(bends), [] }, slug: slug, bender: unquote(name), extra: Keyword.get(unquote(opts), :extra, %{}), request: Map.merge(%{extra: %{}}, Enum.into(request, %{}))}
                            %{response: %{result: result, status: status, extra: extra}} = _request(slug, state)
                            {status, result, extra}
                        end

                        def request!(slug, request \\ []) do
                            case request(slug, request) do
                                {:error, error, _} -> raise %RuntimeError{message: "Error: #{error}"}
                                {_, result, _} -> result
                            end
                        end

                        def stream(slug, request \\ []), do: Stream.repeatedly fn()-> request(slug, request) end
                        def stream!(slug, request \\ []), do: Stream.repeatedly fn()-> request!(slug, request) end
                    end
                end
            end

            defmacro defpipe slug, opts \\ [] do
                dir = Keyword.get(opts, :direction, :both) 
                bends = Keyword.get(opts, :bends, []) 
                bends = Enum.map(bends, 
                    fn({{_, _, [x, :init]}, _, [mopts]}) -> 
                        {_, _, name} = x
                        name = name |> Enum.map(&Atom.to_string(&1)) |> Enum.join(".")
                        {:"Elixir.#{name}", mopts}
                    ({x, [mopts]}) -> 
                        {_, _, name} = x
                        name = name |> Enum.map(&Atom.to_string(&1)) |> Enum.join(".")
                        {:"Elixir.#{name}", mopts}
                    (x) -> 
                        {_, _, name} = x
                        name = name |> Enum.map(&Atom.to_string(&1)) |> Enum.join(".")
                        :"Elixir.#{name}"
                    end)
                bends = Enum.map(bends, fn(x)-> Bender.Utils.required_middlewares x end) 
                    |> List.flatten 
                    |> Bender.Utils.filter_middlewares([])


                quote do
                    all_bends = [unquote(slug) | all_bends]
                    defp _request(unquote(slug), state = %State{ extra: extra, bends: {a, b} }) do
                        %{ state | bends: { a ++ unquote(bends), b }, extra: extra} |> process_in(unquote(dir))
                    end
                end
            end
        end
    end
end