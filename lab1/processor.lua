local Process = {
    new = function(id, time) 
        self = {
            id = id,
            time = time
        }

        return { 
            run = function(self)
                self.time = self.time - 1;
                if self.time == 0 then return true else return false end
            end,
            left = function(self)
                return self
            end,
            print = function (self)
                return 'id - ' .. self.id .. ' time - ' .. self.time .. '\n'
            end
        }
    end
}

Generator = {
    new = function(min, max)
        self = {
            min = min,
            max = max,
            last_id = 1
        }
        math.randomseed(os.time())

        return {
            generate = function()
                self.last_id = self.last_id + 1

                return Process.new(self.last_id, math.random(self.min, self.max))
            end
        }
    end 
}

return Generator