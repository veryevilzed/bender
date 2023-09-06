defmodule Bender do
    use Bender.Core
    use Bender.Bend
end

defmodule Bender.State do
    @behaviour Access

    defstruct [ 
        __request__: %{},
        bends: {[],[]},
        slug: nil,
        bender: nil,
        request: %{ 
            extra: %{}
        }, 
        response: %{
            status: :error,
            result: nil,
            extra: nil
        }, 
        context: %{},
        extra: %{}
    ]

    def fetch(term, key) do
        term
        |> Map.from_struct()
        |> Map.fetch(key)
    end

    def pop(term, key) do
        term
        |> Map.from_struct()
        |> Map.pop(key)
    end

    def get(term, key, default) do
        term
        |> Map.from_struct()
        |> Map.get(key, default)
    end

    def get_and_update(data, key, function) do
        data
        |> Map.from_struct()
        |> Map.get_and_update(key, function)
    end
end