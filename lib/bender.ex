defmodule Bender do
    use Bender.Core
    use Bender.Bend
end

defmodule Bender.State do
    @derive [Access]
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
end