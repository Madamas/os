local RR = {
    new = function(quantum, proclist)
        if proclist == nil then proclist = {} end

        return {
            quantum = quantum,
            proclist_len = #proclist,
            proclist = proclist,
            curr_proc = 1,
            curr_quant = 0,

            add_process = function(self, process)
                table.insert(self.proclist, process)
                self.proclist_len = self.proclist_len + 1
            end,

            remove_process = function(self)
                table.remove(self.proclist, self.curr_proc)
                self.proclist_len = self.proclist_len - 1
                self.curr_quant = 0
                if self.proclist_len ~= 0 then
                    self.curr_proc = self.curr_proc % self.proclist_len + 1
                end
            end,

            get_process = function(self)
                if self.curr_quant > self.quantum then
                    self.curr_proc = (self.curr_proc + 1) % self.proclist_len + 1
                    self.curr_quant = 1
                else
                    self.curr_quant = self.curr_quant + 1
                end
                return self.proclist[self.curr_proc]
            end,

            print = function (self)
                local res = ''
                for _, i in pairs(self.proclist) do
                    res = res .. '\n' .. i:print()
                end

                return res
            end

        }
    end
}

local SRTF = {
    new = function(proclist)
        if proclist == nil then proclist = {} end
        
        return {
            proclist = proclist,
            proclist_len = #proclist,
            fastest_id = 1,
            fastest_time = proclist[1].time,

            add_process = function(self, process)
                table.insert(self.proclist, process)
                self.proclist_len = self.proclist_len + 1
                if(self.fastest_time > process.time) then
                    self.fastest_id = self.proclist_len
                    self.fastest_time = process.time
                end
            end,

            remove_process = function(self)
                table.remove(self.proclist, self.fastest_id)
                self.proclist_len = #self.proclist
                if self.proclist_len == 0 then return end

                local minimum = self.proclist[1].time
                self.fastest_id = 1

                for id, process in pairs(self.proclist) do
                    if process.time < minimum and process.time > 0 then
                        self.fastest_time = process.time
                        self.fastest_id = id
                    end
                end
            end,

            get_process = function(self)
                return self.proclist[self.fastest_id]
            end,

            print = function (self)
                local res = ''
                for _, i in pairs(self.proclist) do
                    res = res .. '\n' .. i:print()
                end

                return res
            end

        }
    end
}

return {
    RR = RR,
    SRTF = SRTF
}