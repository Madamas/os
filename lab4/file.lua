local File = {
    new = function(name, extension, size)
        return {
            extension = extension,
            start = 0,
            name = name,
            size = size,
            date_created = os.time(),

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