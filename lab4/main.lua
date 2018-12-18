local function split(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

function print_commands()
    print([[Commands:
1. init [size] [defect]
2. create [name] [size]
3. show [name]
4. expand [name] [size]
5. shrink [name] [size]
6. help]])
end

Fat16 = require('fat')
File = require('file')
yaml = require('yaml')

local command
local memory = nil
print_commands()
repeat
    command = io.read()
    local array = split(command, ' ')

    if(array[1] == 'exit') then
        break
    elseif(array[1] ~= 'init' and memory == nil) then
        print('Error. Memory is not initialized.')
        print_commands()
        goto continue
    elseif(#array == 3) then
        array[3] = tonumber(array[3])

        if(array[1] == 'init') then
            array[2] = tonumber(array[2])
            if(array[2] == nil or array[3] == nil) then print('Parameters must be numbers') goto continue end
            if(array[2] < array[3]) then print('Defect sector amount should be less than total nubmer of sectors') goto continue end
            memory = Fat16.new(array[2], array[3])
        elseif(array[1] == 'create') then
            local name = split(array[2], '.')
            local file = File.new(name[1], name[2], array[3])
            memory:write_file(file)
        elseif(array[1] == 'expand') then
            local file = memory:find_file(array[2])
            if(file == nil) then print('No such file found.') goto continue end
            memory:expand_file(file, array[3])
        elseif(array[1] == 'shrink') then
            local file = memory:find_file(array[2])
            if(file == nil) then print('No such file found.') goto continue end
            memory:shrink_file(file, array[3])
        end
    elseif(array[1] == 'show') then
        if(array[2] ~= nil) then
            local file = memory:find_file(array[2])
            if(file == nil) then print('No such file found.') goto continue end
            file:print()
            print('\n', yaml.encode(memory:traverse_file(file)))
        else
            memory:list_files()
        end
    elseif(array[1] == 'help') then
        print_commands()
        memory:memory_map()
    end

    ::continue::
until command == 'exit'