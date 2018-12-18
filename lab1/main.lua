local RR = require('planners').RR
local SRTF = require('planners').SRTF
local generator = require('processor')

local Dispatch = {
    new = function (proc_time, interact, background, log_file)
        return {
            int = interact,
            int_time = 0.8 * proc_time,
            bg = background,
            bg_time = 0.2 * proc_time,
            log_file = log_file,
            mode = 0,
            uptime = 0,

            interactive = function (self, log)
                local time = 0
                log:write('Interactive process\n')
                log:write(self.uptime, ' ', time, ' ', self.int:print())

                while time < self.int_time and self.int.proclist_len ~= 0 do
                    local curr_proc = self.int:get_process()
                    local flag = curr_proc:run()
                    if flag then self.int:remove_process() end

                    time = time + 1
                    self.uptime = self.uptime + 1

                    log:write(self.uptime, ' ', time, ' ', self.int:print())
                end
                log:write('---------------------\n')
            end,

            background = function (self, log)
                local time = 0
                log:write('Background process\n')
                log:write(self.uptime, ' ', time, ' ', self.bg:print())

                while time < self.bg_time and self.bg.proclist_len ~= 0 do
                    local curr_proc = self.bg:get_process()

                    if curr_proc:run() then self.bg:remove_process() end

                    time = time + 1
                    self.uptime = self.uptime + 1

                    log:write(self.uptime, ' ', time, ' ', self.bg:print())
                end
                log:write('---------------------\n')
            end,

            run = function(self)
                print('State')
                print('Interactive time', self.int_time, '\nInteractive processses\n', self.int:print(), '\n')
                print('Background time', self.bg_time, '\nBackground processses\n', self.bg:print(), '\n')

                local file = io.open(self.log_file, 'w')

                while self.bg.proclist_len ~= 0 or self.int.proclist_len ~= 0 do
                    if self.mode and self.int.proclist_len ~= 0 then
                        self.interactive(self, file)
                        self.mode = not self.mode
                    elseif self.bg.proclist_len ~= 0 then
                        self.background(self, file)
                        self.mode = not self.mode
                    end
                end

                print('\nWork', self.uptime, '\n')
            end
        }
    end
}

gen = generator.new(3, 5)
interact = RR.new(2, gen:generate(4))
background = SRTF.new(gen:generate(2))
disp = Dispatch.new(10, interact, background, 'log.log')
disp:run()