defmodule Bender.Modifier do
    defmacro __using__(_opts) do
        quote location: :keep do
            defmacro defbend name, opts \\ [], code do
                deps = Dict.get opts, :deps, []
                chain_type = Dict.get opts, :chain_type, :only
                quote do
                    defmodule unquote(name) do
                        alias Bender.State

                        defp break(args = %State{bends: {a,b}}), do: %{ args | bends: {[], b} }
                        defp break!(args = %State{bends: {a,b}}), do: %{ args | bends: {[], []} }

                        defp return(args = %State{response: resp}, result, status \\ :ok), do: %{ args | response: %{ resp | result: result, status: status } }
                        defp result(args, result, status \\ :ok), do: return(args, result, status)
                        defp error(args = %State{response: resp}, result), do: %{ args | response: %{ resp | result: result, status: :error } }
                        defp ok(args = %State{response: resp}), do: %{ args | response: %{ resp | status: :ok } }

                        defp patch(args = %State{context: context}, val) when is_map(val), do: %{args | context: Dict.merge(context, val)}
                        defp patch(args = %State{context: context}, key, val) when is_atom(key), do: %{args | context: Dict.put(context, key, val)}
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