local Process = {
    new = function(id, time) 
        return { 
            id = id,
            time = time,

            run = function(self)
                self.time = self.time - 1;
                return self.time <= 0
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

return {
    new = function(min, max)
        math.randomseed(os.time())

        return {
            min = min,
            max = max,
            last_id = 1,

            generate = function(self, number)
                if number == nil then number = 1 end


                local result = {}

                for i=1,number do
                    table.insert(result, Process.new(self.last_id, math.random(self.min, self.max)))
                    self.last_id = self.last_id + 1
                end

                return result
            end
        }
    end 
}