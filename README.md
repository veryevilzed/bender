Bender
======

![bite my shiny metal ass](bender.png)


Cigarettes, alcohol and drugs make your code more slowly!

Bend your code
--------------

Include Bender in your project.

```
deps: [
	{:bender, github: "veryevilzed/bender"}
	...
]

```

Create your first Bender

```

import Bender

defbender MyTest.FirstBender do

end

```

Create you first Pipe

```

import Bender

defbender MyTest.FirstBender do
    defpipe "test", bends: [
        ...
    ] 
end

```

Create your first bend

```

defbend MyTest.HelloWorldBend do
    def process(:in, state=%{request: %{name: name}}, _) do 
        state |> return "Hello World #{name}"
    end
end

```

Setup your MyTest.HelloWorldBend into your pipe

All source:

```
import Bender

defbend MyTest.HelloWorldBend do
    def process(:in, state=%{request: %{name: name}}, _) do 
        state |> return "Hello World, #{name}!"
    end
end

defbender MyTest.FirstBender do
    defpipe "test", bends: [
        MyTest.HelloWorldBend
    ] 
end

```

Test your Bender

```
MyTest.FirstBender.request! "test", name: "dude"

=> "Hello World, dude!"

```

Enjoy!
