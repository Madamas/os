local Process = {
    new = function (id)
        return {
            id = id,
            curr_seg = 0,
            size = math.random(50, 100),
            read = function (self, mem, addr)
                addr = tonumber(addr)
    
                if(addr == nil) then
                    return -1
                end

                if(addr > self.size - 1) then
                    return -1
                else 
                    if(self.curr_seg == 0) then
                        local code = mem:upload(self, self.size, self.id)
                        if(code == -1) then
                            return -2
                        end
                    end

                    return mem.seglist[self.curr_seg].addr + addr
                end
            end,

            print = function (self)
                print('--------------Process ' .. self.id .. ' ----------------\n')
                print('Segment in use ', self.curr_seg)
                print('Address start ', 0)
                print('Size', self.size)
                print('----------------------------------------')
            end
        }
    end
}

local Memory = {
    new = function (num)
        local seglist = {}
        math.randomseed(os.time())

        if(num  == nil) then
            num = 1
        end

        table.insert(seglist, {
            id = 1,
            addr = 0,
            size = math.random(30, 150) - 1,
            last_use = 0,
            pid = 0 
        })
        for i=2, num  do
            local size = math.random(30, 150)
            table.insert(seglist, {
                id = i,
                size = size,
                addr = seglist[i - 1].addr + seglist[i - 1].size,
                last_use = 0,
                pid = 0
            })
        end

        return {
            seglist = seglist,

            count_access = function (self, proc)
                if(proc.curr_seg ~= 0) then
                    self.seglist[proc.curr_seg].last_use = 0
                end

                for _,v in pairs(self.seglist) do
                    if(v.id ~= proc.curr_seg) then
                        v.last_use = v.last_use + 1
                    end
                end
            end,

            unload = function (self, segment)
                self.seglist[segment].pid = 0
                self.seglist[segment].last_use = 0
            end,

            upload = function (self, proc, size, pid)
                if(proc.curr_seg ~= 0) then
                    print('Selected process is already uploaded')
                    return
                end

                local segfree = {}
                local allowed = {}

                for _,v in pairs(self.seglist) do
                    if(v.pid == 0) then
                        table.insert(segfree, v.id)
                    end
                end

                for _,v in pairs(segfree) do
                    local segment = self.seglist[v]
                    if(segment.size >= size) then
                        table.insert(allowed, v)
                    end
                end

                if(#allowed == 0) then
                    local last_use = self.seglist[1].last_use
                    local last_id = 1
                    local size_suited = {}

                    for _,v in pairs(self.seglist) do
                        if(v.size >= size) then
                            table.insert(size_suited, v.id)
                        end
                    end     

                    if(#size_suited == 0) then
                        print('There is no memory for selected process')
                        return -1
                    end         

                    for _,v in pairs(self.seglist) do
                        if(v.last_use > last_use) then
                            last_id = v.id
                        end
                    end

                    self.unload(self, last_id)

                    proc.curr_seg = last_id
                    self.seglist[last_id].pid = pid
                    self.seglist[last_id].last_use = 0

                    return
                else
                    proc.curr_seg = allowed[1]
                    self.seglist[allowed[1]].pid = pid
                    self.seglist[allowed[1]].last_use = 0

                    return
                end
            end,

            print = function(self)
                print('------------------------------Memory--------------------\n')
                for i,_ in ipairs(self.seglist) do
                    local seg = self.seglist[i]
                    print('Segment ', i)
                    print('Size', seg.size)
                    print('Address ', seg.addr .. '......' .. (seg.addr + seg.size - 1))
                    print('Process ', seg.pid)
                    print('Last access to segment by process', seg.last_use, 'call(s) ago\n')
                end
                print('----------------------------------------------------------\n')
            end
        }
    end
}

function split(inputstr, sep)
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
    print('Commands:\n\
1. upload [pid]\n\
2. unload [pid]\n\
3. show [pid]\n\
4. read [pid]\n\
5. show\n\
6. help\n\
7. exit\n')
end


local num = 5

local mem = Memory.new(num - 2)
mem:print()
local workers = {}

for i=1,num do
    table.insert(workers, Process.new(i))
    workers[i]:print()
end
print_commands()

local command

repeat
    command = io.read()

    local array = split(command, ' ')

    if(#array == 1) then
        if(array[1] == 'show') then
            mem:print()
        elseif(array[1] == 'exit') then
            os.exit()
        else
            print_commands()
        end
    elseif(#array == 2) then
        local pid = tonumber(array[2])

        if(pid == nil) then
            print_commands()
        end

        if(pid < 1 or pid > #workers) then
            print('Pid should be less than amount of workers (' .. #workers .. ') and be bigger than 0')
        elseif(array[1] == 'upload') then
            local proc = workers[pid]
            mem:upload(proc, proc.size, pid)
            mem:print()
            mem:count_access(proc)
        elseif(array[1] == 'unload') then
            local proc = workers[pid]
            mem:unload(proc.curr_seg)
            proc.curr_seg = 0
            mem:print()
            mem:count_access(proc)
        elseif(array[1] == 'show') then
            workers[pid]:print()
        elseif(array[1] == 'read') then
            local proc = workers[pid]
            proc:print()
            print('Choose address to read')
            address = io.read()
            addr = proc:read(mem, address)

            if(addr == -1) then
                print('Invalid address')
                goto continue
            elseif(addr == -2) then
                goto continue
            else
                phys = proc
                mem:count_access(proc)
                print('Virtual memory address', address)
                print('Physical memory address', addr, '\n')
            end
        else
            print_commands()
        end
        ::continue::
    end
until command == 'exit'