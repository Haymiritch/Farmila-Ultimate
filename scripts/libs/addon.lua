
function isInAnyVehicle()
	return getVehicle() ~= 0
end

function sendSpawnRequest()
	bitStream.new():sendRPC(129)
end

function sendDialogResponse(id, button, list, input)
	print("send dialog response:", id, button, list, input)
	local bs = bitStream.new()
	bs:writeUInt16(id)
	bs:writeUInt8(button)
	bs:writeUInt16(list)
	bs:writeUInt8(input:len())
	bs:writeString(input)
	bs:sendRPC(62)
end

function sendClickTextdraw(id)
	assert(type(id) == "number", "number expected, got "..type(id))
	local bs = bitStream.new()
	bs:writeUInt16(id)
	bs:sendRPC(83)
end

function sendPickedUpPickup(id)
	assert(type(id) == "number", "number expected, got "..type(id))
	local bs = bitStream.new()
	bs:writeUInt32(id)
	bs:sendRPC(131)
end

function sendVehicleEnter(id, passenger)
	assert(type(id) == "number", "number expected, got "..type(id))
	local bs = bitStream.new()
	bs:writeUInt16(id)
	bs:writeBool8(passenger)
	bs:sendRPC(26)
end

function sendVehicleExit(id)
	assert(type(id) == "number", "number expected, got "..type(id))
	local bs = bitStream.new()
	bs:writeUInt16(id)
	bs:sendRPC(154)
end

function sendTargetUpdate(object, vehicle, player, actor)
	local bs = bitStream.new()
	bs:writeUInt16(object)
	bs:writeUInt16(vehicle)
	bs:writeUInt16(player)
	bs:writeUInt16(actor)
	bs:sendRPC(168)
end

function sendInput(text)
	assert(type(text) == "string", "string expected, got "..type(text))
	local bs = bitStream.new()
	if text:sub(1, 1) == "/" then
		bs:writeUInt32(text:len())
		bs:writeString(text)
		bs:sendRPC(50)
	else
		bs:writeUInt8(text:len())
		bs:writeString(text)
		bs:sendRPC(101)
	end
end


function bitStream:readString8()
	return self:readString(self:readUInt8())
end

function bitStream:writeString8(value)
	assert(type(value) == "string", "string expected, got "..type(value))
	self:writeUInt8(len(value))
	self:writeString(value)
end

function bitStream:readBool8()
	return (self:readUInt8() ~= 0)
end

function bitStream:writeBool8(value)
	self:writeUInt8(value and 1 or 0)
end

function bitStream:writeArray(value)
	assert(type(value) == "table", "table expected, got "..type(value))
	for _, byte in ipairs(value) do
		assert(type(byte) == "number", "number expected, got "..type(byte))
		self:writeUInt8(byte)
	end
end


---------------- TASKS ----------------

local count = 0
local tasks = {}


function wait(time)
	coroutine.yield(time / 1000)
end

function newTask(f, halted, ...)
	assert(type(f) == "function", "function expected, got "..type(f))
	count = count + 1
	tasks[count] = {
		id = count,
		f = coroutine.create(f),
		wake_time = type(halted) == "number" and os.clock() + halted / 1000 or os.clock(),
		halted = type(halted) == "boolean" and halted or false,
		args = {...},

		isAlive = function(self)
			return tasks[self.id] ~= nil
		end,
		isHalted = function(self)
			return self.halted
		end,
		halt = function(self)
			self.halted = true
		end,
		resume = function(self)
			self.halted = false
		end,
		kill = function(self)
			tasks[self.id] = nil
		end
	}
	return tasks[count]
end

function clearTasks()
	tasks = {}
end


registerHandler("onUpdate", function()
	for id, task in pairs(tasks) do
		if not task.halted and task.wake_time <= os.clock() then
			if coroutine.status(task.f) == "dead" then
				tasks[id] = nil
			else
				local resumed, result = coroutine.resume(task.f, table.unpack(task.args))
				if not resumed then
					error(result, 2)
				elseif result then
					task.wake_time = os.clock() + result
				end
			end
		end
	end
end)