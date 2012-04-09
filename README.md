Lazybag
=======

Lazybag is a tiny Lua library loosely inspired by [Pimple](http://github.com/fabpot/pimple) that
can be leveraged to create table objects with fields that are lazily initialized upon first access
using functions that act as value initializers.

## Compatibility ##

This library is tested and works with __Lua 5.1__, __Lua 5.2__ and __LuaJit 2.0__.

## Example ##

```lua
local container = require('lazybag').new()

-- plain field with a table value
container.metavars = { 'foo', 'bar' }

-- plain field with a function value
container.fn = function(t, foo, bar)
    return 'Foo is '..foo..' and bar is '..bar..'.'
end

-- defines a 'iamlazy' field whose value is initialized upon first access
container:lazy('iamlazy', function(t)
    print('You will see me only once!')
    return t:fn(unpack(t.metavars))
end)

print(container.iamlazy)
print(container.iamlazy)

--[[
You will see me only once!
Foo is foo and bar is bar.
Foo is foo and bar is bar.
]]
```

## Tests ##

Lazybag uses [Telescope](http://telescope.luaforge.net) for its tests. You can launch the whole test
suite from the root of the repository with `tsc -f tests/lazybag.lua`.

## Author ##

- [Daniele Alessandri](mailto:suppakilla@gmail.com) ([twitter](http://twitter.com/JoL1hAHN))

## License ##

The code for Lazybag is distributed under the terms of the MIT license (see LICENSE).
