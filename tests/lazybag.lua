package.path = '../lib/?.lua;lib/?.lua;' .. package.path

pcall(require, 'luarocks.require')

local lazybag = require 'lazybag'

context('Lazybag', function()
    test('initializes new table objects', function()
        local container1 = lazybag.new()
        local container2 = lazybag.new()

        assert_type(container1, 'table')
        assert_type(container2, 'table')
        assert_not_equal(container1, container2)
    end)

    test('initializes new table objects from an existing table', function()
        local tbl = { one = 1, two = 2 }
        local container = lazybag.new(tbl)

        assert_equal(container.one, 1)
        assert_equal(container.two, 2)

        assert_error(function()
            -- cannot initialize a container with the module table
            lazybag.new(lazybag)
        end)
    end)

    test('accepts only functions for lazy fields generators', function()
        local container = lazybag.new()

        assert_error(function()
            container:lazy('lazy_field', true)
        end)
    end)

    test('initializes lazy fields only once', function()
        local container, count = lazybag.new(), 0

        container.field = container
        container:lazy('lazy_field', function(self)
            count = count + 1
            return self
        end)

        assert_false(container:islazy('field'))
        assert_true(container:islazy('lazy_field'))

        assert_type(container.lazy_field, 'table')
        assert_equal(container.field, container.lazy_field)
        assert_equal(count, 1)
        assert_false(container:islazy('lazy_field'))
    end)

    test('can rename lazy fields skipping their initialization', function()
        local container = lazybag.new()

        container:lazy('lazy_field', function(self) return self end)
        container:rename('lazy_field', 'renamed_lazy_field')

        assert_nil(container.lazy_field)
        assert_equal(container.renamed_lazy_field, container)

        container:rename('renamed_lazy_field', 'renamed_lazy_field_again')
        assert_nil(container.lazy_field)
        assert_nil(container.renamed_lazy_field)
        assert_equal(container.renamed_lazy_field_again, container)
    end)

    test('can rename normal fields', function()
        local container = lazybag.new()

        container.field = container
        container:rename('field', 'renamed_field')

        assert_nil(container.field)
        assert_equal(container.renamed_field, container)
    end)

    test('can rename lazybag functions', function()
        local container = lazybag.new()

        container:rename('lazy', 'renamed_lazy')
        assert_nil(container.lazy)
        assert_type(container.renamed_lazy, 'function')

        container:renamed_lazy('lazy_field', function(self) return self end)
        assert_equal(container.lazy_field, container)
    end)

    test('does not raise errors when renaming unset fields', function()
        local container = lazybag.new()

        container:rename('lazy_unknown', 'renamed_lazy_field')

        assert_nil(container.lazy_unknown)
        assert_nil(container.renamed_lazy_field)
    end)

    test('can replace lazy fields', function()
        local container = lazybag.new()

        container:lazy('lazy_field1', function(self) return self end)
        container:lazy('lazy_field2', function(self) return self end)

        container.lazy_field1 = false
        assert_false(container.lazy_field1)

        assert_equal(container.lazy_field2, container)
        container.lazy_field2 = false
        assert_false(container.lazy_field2)
    end)

    test('can retrieve lazy fields generators before first access', function()
        local container = lazybag.new()
        local generator = function(self) return self end

        container:lazy('lazy_field', generator)
        local retrieved = container:getraw('lazy_field')
        assert_equal(retrieved, generator)

        local value = container.lazy_field
        local retrieved = container:getraw('lazy_field')
        assert_equal(retrieved, value)
    end)
end)
