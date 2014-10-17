defmodule Bender do
    use Bender.Core
    use Bender.Modifier
end

defmodule Bender.State do
    @derive [Access]
    defstruct [ 
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