local Cluster = {
    new = function (id, status)
        if(status == nil) then
            status = 0
        end

        return {
            id = id,
            status = status,
            next = 0,

            write = function (self, next)
                if(status == -1) then
                    print([[Cluster defected. Can't write. Trying next available cluster...]])
                else
                    self.status = 1
                    self.next = next
                end
            end,

            clear = function (self)
                self.status = 0
                self.next = 0
            end
        }
    end
}

local Fat16 = {
    new = function (size, defected)
        math.randomseed(os.time())
        local array = {}
        local max = defected
        local prob

        for i=1,size do
             if(math.random() < 0.3 and max > 0) then prob = -1 else prob = 0 end
            if prob == -1 then max = max - 1 end

            local cluster = Cluster.new(i, prob)
            table.insert(array, cluster)
        end

        return {
            size = size,
            free = size - defected,
            table = array,
            defected = defected,
            files = {},

            memory_map = function (self)
                for _,v in pairs(self.table) do
                    print('Cluster',v.id,v.status,v.next)
                end
            end,

            list_files = function (self)
                for _,v in pairs(self.files) do
                    print('File',v.name ..'.'.. v.extension)
                end
            end,

            find_cluster = function(self)
                local available = {}

                for _,cluster in pairs(self.table) do
                    if(cluster.status == 0) then
                        table.insert(available, cluster)
                    end
                end

                if #available ~= 0 then return available else return -1 end
            end,
            -- find file by identifier
            find_file = function (self, file)
                for _, v in pairs(self.files) do
                    if(v.name ..'.'.. v.extension == file) then
                        return v
                    end
                end
                return nil
            end,

            traverse_file = function(self, file)
                local found = self:find_file(file.name .. '.' .. file.extension)

                if(found == nil) then return {} end

                local addr = found.start
                local listing = {}

                repeat
                    table.insert(listing, addr)
                    addr = self.table[addr].next
                until addr == 'FF'

                return listing
            end,

            write_file = function (self, file)
                if(self:find_file(file.name .. '.' .. file.extension) ~= nil) then print('File with such name is already created') return end
                if(self.free < file.size) then print('Insufficient free space') return end
                self.free = self.free - file.size

                local pool = self:find_cluster()
                file.start = pool[1].id
                self.files[file.name .. file.extension] = file
                for i=1, file.size - 1 do
                    pool[1]:write(pool[2].id)
                    table.remove(pool, 1)
                end

                pool[1]:write('FF')
            end,

            expand_file = function (self, file, delta)
                delta = tonumber(delta)
                if(delta == 0 or delta == nil) then return end
                if(self.free < delta) then print('Insufficient free space') return end
                self.free = self.free - delta

                local list = self:traverse_file(file)
                local pool = self:find_cluster()
                local addr = list[#list]
                self.table[addr]:write(pool[1].id)

                for i=1, delta - 1 do
                    pool[1]:write(pool[2].id) 

                    table.remove(pool, 1)
                end

                pool[1]:write('FF')
            end,

            shrink_file = function (self, file, delta)
                delta = tonumber(delta)
                if(delta == 0 or delta == nil) then return end
                if(file.size < delta) then print('You cannot delete file') return end
                if(self.free < delta) then print('Insufficient free space') return end
                self.free = self.free + delta

                local list = self:traverse_file(file)
                local addr = list[#list-delta]
                self.table[addr]:write('FF')

                for i=#list-delta+1, #list do
                    addr = list[i]
                    self.table[addr]:clear()
                end
            end
        }
    end
}

return Fat16