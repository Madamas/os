fiber = require('fiber')
yaml = require('yaml')

local function give_change(self, change)
    used = {}

    for _, tuple in pairs(self.casette) do
        num_need = math.floor(change / tuple.nominal)
        if tuple.quantity - num_need < 0 then
            used[tuple.nominal] = tuple.quantity
        else
            used[tuple.nominal] = num_need
        end

        change = change - tuple.nominal * used[tuple.nominal]
    end

    if change ~= 0 then
        return false
    end

    for idx , tuple in pairs(self.casette) do
        self.casette[idx].quantity = self.casette[idx].quantity - used[tuple.nominal]
    end

    return true
end

local function server(self)
    print('Cash fiber started')
    while true do
        ticket = self.orders:get(1)
        if ticket == nil then
            fiber.yield()
        end

        print('Recieved new ticket')
        print('Destination', ticket.destination)
        print('Price', ticket.price)
        
        self.flag[1] = true

        while self.flag[2] == true do
            print('Waiting for cash calculation')
            if self.order == 2 then
                self.flag[1] = false
                while self.order == 2 do fiber.yield() end
                self.flag[1] = true
            end
        end

        -- Critical section
        self.changes = 100 - ticket.price

        self.order = 2
        self.flag[1] = false
        fiber.yield()
        -- Critical section end
    end
end

local function bank(self)
    print('Bank fiber started')

    while true do
        self.flag[2] = true

        while self.flag[1] == true do
            if self.order == 1 then
                self.flag[2] = false
                while self.order == 1 do fiber.yield() end
                self.flag[2] = true
            end
        end

        -- Critical section
        change = self.changes
        if give_change(self, change) then
            print('Order successful.')
            print(yaml.encode(self.casette))
        else
            print('No more change left.\n Exiting...')
            print(yaml.encode(self.casette))
            self.orders:close()
        end

        self.order = 1
        self.flag[2] = false
        fiber.yield()
        -- Critical section end
    end
end

local function rand_ticket()
    num = math.random(1, 6)

    if num == 1 then
        return { destination = 'Kyiv', price = 28 }
    elseif num == 2 then
        return { destination = 'Moscow', price = 37 }
    elseif num == 3 then 
        return { destination = 'London', price = 50 }
    elseif num == 4 then
        return { destination = 'Berlin', price = 77 }
    else
        return { destination = 'Paris', price = 91 }
    end
end

local Instance = {
    orders = nil,
    changes = nil,

    start = function (self)
        self.casette = {}
        self.flag = {}

        self.flag[1] = true
        self.flag[2] = false
        self.order = 1

        self.casette = {{nominal = 50, quantity = 5},{nominal = 25, quantity = 10},{nominal = 10, quantity = 15},{nominal = 5, quantity = 25},{nominal = 2, quantity = 25},{nominal = 1, quantity = 50}}

        self.orders = fiber.channel(5)
        self.server = fiber.create(server, self)
        self.bank = fiber.create(bank, self)

        math.randomseed(os.time())

        while true do
            ticket = rand_ticket()
            flag = self.orders:put(ticket, 5)

            if flag == false then os.exit() end
        end
    end
}

Instance:start()