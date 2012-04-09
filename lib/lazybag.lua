local mt_newindex = function(t, key, value)
    getmetatable(t).storage[key] = value
end

local mt_index = function(t, key)
    local mt = getmetatable(t)
    local storage, generators = mt.storage, mt.generators
    if storage[key] == nil and generators[key] ~= nil then
        storage[key], generators[key] = generators[key](t, key), nil
    end
    return storage[key]
end

local fn_lazy = function(t, key, fn)
    if type(fn) ~= 'function' then
        error('Function expected')
    end
    getmetatable(t).generators[key] = fn
    return fn
end

local fn_islazy = function(t, key)
    return getmetatable(t).generators[key] ~= nil
end

local fn_rename = function(t, old, new)
    local generators = getmetatable(t).generators
    if generators[old] ~= nil then
        generators[new], generators[old] = generators[old], nil
    elseif t[old] ~= nil then
        t[new], t[old] = t[old], nil
    end
end

local fn_getraw = function(t, key)
    local mt = getmetatable(t)
    return mt.generators[key] or mt.storage[key]
end

local lazybag = {
    new = function()
        local t = {
            lazy = fn_lazy,
            islazy = fn_islazy,
            rename = fn_rename,
            getraw = fn_getraw,
        }
        local mt = {
            generators = {},
            storage = {},
            __index = mt_index,
            __newindex = mt_newindex,
        }
        return setmetatable(t, mt)
    end,
}

return lazybag
