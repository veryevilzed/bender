defmodule Bender.Bend do
    defmacro __using__(_opts) do
        quote location: :keep do
            defmacro defbend name, opts \\ [], code do
                deps = Keyword.get opts, :deps, []
                chain_type = Keyword.get opts, :chain_type, :only
                quote do
                    defmodule unquote(name) do
                        alias Bender.State

                        defp break(args = %State{bends: {a,b}}), do: %{ args | bends: {[], b} }
                        defp break!(args = %State{bends: {a,b}}), do: %{ args | bends: {[], []} }

                        defp return(args = %State{response: resp}, result, status \\ :ok), do: %{ args | response: %{ resp | result: result, status: status } }
                        defp extra(args = %State{response: resp}, e), do: %{ args | response: %{ resp | extra: e } }
                        defp result(args, result, status \\ :ok), do: return(args, result, status)
                        defp error(args = %State{response: resp}, result), do: %{ args | response: %{ resp | result: result, status: :error } }
                        defp ok(args = %State{response: resp}), do: %{ args | response: %{ resp | status: :ok } }

                        defp retry(args=%State{slug: slug, bender: bender, __request__: re}) do
                            {status, response, extra} = apply(bender, :request, [slug, re])
                            args |> break |> return(response, status) |> extra(extra)
                        end

                        defp patch(args = %State{context: context}, val) when is_map(val), do: %{args | context: Map.merge(context, val)}
                        defp patch(args = %State{context: context}, key, val) when is_atom(key), do: %{args | context: Map.put(context, key, val)}
                        defp patch(args = %State{context: context}, key, val) when is_list(key), do: %{args | context: put_in(context, key, val)}

                        def deps, do: unquote(deps)
                        def chain_type, do: unquote(chain_type)

                        unquote(code)

                        def init(args), do: {unquote(name), args}
                        def init, do: unquote(name)

                        def process(_, state, _), do: state

                        defoverridable [init: 1]
                    end
                end
            end
         
        end
    end
end