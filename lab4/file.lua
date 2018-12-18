local File = {
    new = function(name, extension, size)
        local ts = os.time()

        return {
            extension = extension,
            start = 0,
            name = name,
            size = size,
            date_created = ts,
            -- date_modified = ts,

            -- update_file = function(self, size)
            --     self.size = size
            --     self.date_modified = os.time()
            -- end,

            print = function (self)
                print('\nFile name',self.name)
                print('Initial cluster address',self.start)
                print('File size',self.size)
                print(os.date('Created at: %c', self.date_created))
            end
        }
    end
}

return File