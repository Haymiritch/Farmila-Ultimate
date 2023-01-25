local events = require('samp.events')
local vector3d = require('vector3d')
local ffi = require('ffi')
require('addon')

local slap = {
	state = false,
	interiors = {},
	max_diffrence = 1.5,
	spawn_pos = vector3d(0.0, 0.0, 0.0),
	speed = {
		current = 0.2,
		min = 0.2,
		max = 1.3
	},
	multiplier = {
		value = 1.2, 
		tick_counter = 0,
		every_ticks = 2
	},
	points = {
		target = vector3d(0.0, 0.0, 0.0),
		highest = vector3d(0.0, 0.0, 0.0)
	},
	move_forward = {
		state = false,
		tick_counter = 0,
		for_ticks = 15,
		multiplier = 0.15
	},
	height_damage = {
		[0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 5, [5] = 0, [6] = 5, [7] = 5, [8] = 5, [9] = 5, [10] = 19, [11] = 21, [12] = 23, [13] = 25, [14] = 28, [15] = 29, [16] = 31, [17] = 33, [18] = 35, [19] = 36, [20] = 38, [21] = 40, [22] = 41, [23] = 42, [24] = 44, [25] = 45, [26] = 46
	}
}

function slap.speed.reset()
	slap.speed.current = slap.speed.min
end

function slap.speed.calculate()
	return slap.speed.current * -1 / 3
end

function slap.speed.multiply()
	slap.speed.current = slap.speed.current * slap.multiplier.value
end

function slap.multiplier.reset()
	slap.multiplier.tick_counter = 0
end

function slap.multiplier.tick()
	slap.multiplier.tick_counter = slap.multiplier.tick_counter + 1
end

function slap.move_forward.tick()
	slap.move_forward.tick_counter = slap.move_forward.tick_counter + 1
end

function slap.move_forward.calculate()
	local current_pos = vector3d(getPosition())
	local angle = getRotation() * (math.pi / 180) * -1
	local new_pos = {
		x = current_pos.x + math.sin(angle) * slap.move_forward.multiplier, 
		y = current_pos.y + math.cos(angle) * slap.move_forward.multiplier, 
		z = current_pos.z
	}
	map_height = slap.getHeightForCoords(new_pos)
	interior_height = slap.getInteriorHeightForCoords(new_pos)
	if interior_height then
		if interior_height >= new_pos.z then
			new_pos.z = interior_height
		end
	end
	if map_height > new_pos.z then
		new_pos.z = map_height
	end
	return new_pos
end

function slap.move_forward.reset()
	slap.move_forward.state = false
	slap.move_forward.tick_counter = 0
end

function slap.loadHMAP()
	local path = getPath('slapfix/SAmin.hmap')
	local file, error = io.open(path, 'rb')
	if error then os.exit(1) end
	local size = file:seek('end')
	file:seek('set')
	slap.HMAP = ffi.new('uint16_t[?]', size)
	ffi.copy(slap.HMAP, file:read(size), size)
	file:close()
end

function slap.getHeightForCoords(pos)
	if (pos.x < -3000.0 or pos.x > 3000.0 or pos.y > 3000.0 or pos.y < -3000.0) then return 1 end
	local GRID = {x = math.floor(pos.x) + 3000, y = (math.floor(pos.y) - 3000) * -1}
	local data_pointer = (math.floor(GRID.y / 3) * 2000) + math.floor(GRID.x / 3)
	local height = slap.HMAP[data_pointer] / 100 + 1
	return height ~= 1 and height or 0
end


function slap.loadInteriors()
	local path = getPath('slapfix/interiors.txt')
	local file, error = io.open(path, 'r')
	if error then os.exit(1) end
	for interior in file:lines() do
		local min_x, min_y, max_x, max_y, height, name = interior:match('(.+);(.+);(.+);(.+);(.+);(.+)')
		min_x, min_y, max_x, max_y, height = tonumber(min_x), tonumber(min_y), tonumber(max_x), tonumber(max_y), tonumber(height)
		table.insert(slap.interiors, 
			{
				min = {x = math.min(min_x, max_x), y = math.min(min_y, max_y)},
				max = {x = math.max(min_x, max_x), y = math.max(min_y, max_y)},
				height = height,
				name = name
			}
		)
	end
	print(('loaded %d interiors'):format(#slap.interiors))
end

function slap.getInteriorHeightForCoords(pos)
	local height = -128
	for _, interior in pairs(slap.interiors) do
		if interior.min.x <= pos.x and interior.max.x >= pos.x and interior.min.y <= pos.y and interior.max.y >= pos.y and interior.height - 0.5 <= pos.z and interior.height > height then
			height = interior.height
			print(('finded new interior height %f (%s)'):format(interior.height, interior.name))
		end
	end
	return height ~= -128 and height or nil
end

function slap.process()
	while true do
		if slap.state or slap.move_forward.state then
			local current_pos = vector3d(getPosition())
			if slap.move_forward.state then -- move forward after falling
				slap.move_forward.tick()
				local new_pos = slap.move_forward.calculate()
				if getDifference(current_pos.z, new_pos.z) > slap.max_diffrence then
					slap.move_forward.reset()
					slap.speed.reset()
					if current_pos.z > new_pos.z then -- downhill
						print('downhill forward...')
						slap.points.target = {x = new_pos.x, y = new_pos.y, z = new_pos.z}
						slap.points.highest = {x = new_pos.x, y = new_pos.y, z = current_pos.z}
						slap.state = true
					else --  elevation
						print('elevation forward...')
					end
				else
					setPosition(new_pos.x, new_pos.y, new_pos.z)
				end
				if slap.move_forward.tick_counter == slap.move_forward.for_ticks then
					slap.move_forward.reset()
				end
			elseif getDifference(current_pos.z, slap.points.target.z) < 0.3 then -- stop falling
				slap.speed.reset()
				local height = math.floor(slap.points.highest.z) - math.floor(slap.points.target.z)
				if slap.points.target.z ~= 0 then
					local damage = slap.height_damage[math.floor(height)]
					if damage and getHealth() - damage > 0 then
						setHealth(getHealth() - damage)
						sendGiveTakeDamage(true, getID(), damage, 54, 3)
					else
						runCommand('!kill')
						--[[
						if bug with setHealth(0) will be fixed...
						setHealth(0)
						sendGiveTakeDamage(true, getID(), 100, 54, 3)
						sendDeathNotification(54, 65535)
						]]
					end
					if height >= 3.7 and height <= 10.7 then
						slap.move_forward.state = true
					end
				end
				setPosition(slap.points.target.x, slap.points.target.y, slap.points.target.z)
				slap.state = false
			else -- falling
				slap.multiplier.tick()
				if slap.speed.current < slap.speed.max and slap.multiplier.tick_counter % slap.multiplier.every_ticks == 0 then
					slap.speed.multiply()
				end	
				if slap.multiplier.tick_counter == slap.multiplier.every_ticks then
					slap.multiplier.reset()
				end
				local new_height = current_pos.z - slap.speed.current
				setPosition(current_pos.x, current_pos.y, new_height > slap.points.target.z and new_height or slap.points.target.z)
			end
			updateSync()
		end
		wait(50)
	end
end

function onLoad()
	slap.loadInteriors()
	slap.loadHMAP()
	print(' SlapFix by dimiano loaded!')
	print(' * https://www.blast.hk/members/497470/')
	print(' * https://t.me/dimianosamp/')
	newTask(slap.process, false)
end

function events.onSetSpawnInfo(team, skin, _, pos, rotation, weapons, ammo)
	slap.spawn_pos = vector3d(pos.x, pos.y, pos.z)
end

function events.onSetPlayerPos(pos)
	local current_pos = vector3d(getPosition())
	if getDistanceBetweenCoords3d(slap.spawn_pos, pos) < 1 then
		print('teleport to spawn pos detected')
	elseif getDistanceBetweenCoords2d(current_pos, pos) < 0.2 and current_pos.z < pos.z then -- slap
		print('slap detected')
		slap.speed.reset()
		slap.move_forward.reset()
		slap.points.highest = pos
		if not slap.state then
			slap.state = true
			slap.points.target = current_pos
		end
		local map_height = slap.getHeightForCoords(pos)
		if pos.z > map_height then
			slap.points.target.z = map_height
		end
		local interior_height = slap.getInteriorHeightForCoords(pos)
		if interior_height then
			if interior_height > slap.points.target.z then
				slap.points.target.z = interior_height
			end
		end
	elseif pos.z - 1 > slap.getHeightForCoords(pos) then -- teleport in air
		print('teleport in air detected')
		slap.speed.reset()
		slap.move_forward.reset()
		slap.points.highest = pos
		slap.points.target = {x = pos.x, y = pos.y, z = slap.getHeightForCoords(pos)}
		local interior_height = slap.getInteriorHeightForCoords(pos)
		if interior_height then
			if interior_height > slap.points.target.z then
				slap.points.target.z = interior_height
			end
		end
		if not slap.state then
			slap.state = true
		end
	end
end

function events.onSendPlayerSync(data)
	if slap.state then 
		data.moveSpeed.z = slap.speed.calculate()
	elseif slap.move_forward.state then
		data.moveSpeed.x = 0.02
		data.moveSpeed.y = 0.02
	end
end

function getDistanceBetweenCoords2d(coords1, coords2)
	return math.sqrt((coords2.x - coords1.x) ^ 2 + (coords2.y - coords1.y) ^ 2)
end

function getDistanceBetweenCoords3d(coords1, coords2)
	return math.sqrt((coords2.x - coords1.x) ^ 2 + (coords2.y - coords1.y) ^ 2 + (coords2.z - coords1.z) ^ 2)
end

function getDifference(num1, num2)
	return math.abs(math.abs(num1) - math.abs(num2))
end

function sendGiveTakeDamage(take, playerid, damage, weapon, bodypart)
	bs = bitStream.new()
	bs:writeBool(take)
	bs:writeUInt16(playerid)
	bs:writeFloat(damage)
	bs:writeUInt32(weapon)
	bs:writeUInt32(bodypart)
	bs:sendRPC(115)
end

function sendDeathNotification(reason, killerid)
	bs = bitStream.new()
	bs:writeUInt8(reason)
	bs:writeUInt16(killerid)
	bs:sendRPC(53)
end