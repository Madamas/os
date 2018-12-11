local is_empty = function(table)
	for _,_ in pairs(table) do
		return false
	end

	return true
end

local RR = {
	new = function(quantum, proclist)
		if proclist == nil then proclist = {} end
		
		return {
			quantum = quantum,
			proclist = proclist,
			proclist_len = #proclist,
			curr_proc = 0,
			curr_quant = 0,

			add_process = function(self, process)
				table.insert(self.proclist, process)
				self.proclist_len = self.proclist_len + 1
			end,

			remove_process = function(self)
				table.remove(self.proclist)
				self.proclist_len = self.proclist_len - 1
				self.curr_quant = 0
				if self.proclist_len ~= 0 then
					self.curr_proc = self.curr_proc % self.proclist_len
				end
			end,

			get_process = function(self)
				if self.curr_quant > self.quantum
					self.curr_proc = (self.curr_proc + 1) % self.proclist_len
					self.curr.curr_quant = 1
				else
					self.curr_quant = self.curr_quant + 1
				end

				return self.proclist[self.curr_proc]
			end,

			print = function (self)
				local res = ''
				for _, i in pairs(self.proclist) do
					res = res + i:print()
				end

				return res
			end

		}
	end
}

local SRTF = {
	new = function(quantum, proclist)
		if proclist == nil then proclist = {} end
		
		return {
			quantum = quantum,
			proclist = proclist,
			proclist_len = #proclist,
			curr_proc = 0,
			curr_quant = 0,
			fastest_id = nil

			add_process = function(self, process)
				table.insert(self.proclist, process)
				self.proclist_len = self.proclist_len + 1
			end,

			remove_process = function(self)
				table.remove(self.proclist)
				self.proclist_len = self.proclist_len - 1
				self.curr_quant = 0
				if self.proclist_len ~= 0 then
					self.curr_proc = self.curr_proc % self.proclist_len
				end
			end,

			get_process = function(self)
				if self.curr_quant > self.quantum
					self.curr_proc = (self.curr_proc + 1) % self.proclist_len
					self.curr.curr_quant = 1
				else
					self.curr_quant = self.curr_quant + 1
				end

				return self.proclist[self.curr_proc]
			end,

			print = function (self)
				local res = ''
				for _, i in pairs(self.proclist) do
					res = res + i:print()
				end

				return res
			end

		}
	end
}