package.path = 'src/?.lua;../src/?.lua;' .. package.path

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
