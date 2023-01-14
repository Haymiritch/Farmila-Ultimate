local events = require('libs.samp.events')
local vector3d = require('libs.vector3d')
require('addon')

local slap = {
	state = false,
	speed = {
		current = 0.2,
		min = 0.2,
		max = 1.5
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

slap.speed.reset = function()
	slap.speed.current = slap.speed.min
end

slap.speed.calculate = function()
	return slap.speed.current * -1 / 3
end

slap.speed.multiply = function()
	slap.speed.current = slap.speed.current * slap.multiplier.value
end

slap.multiplier.reset = function()
	slap.multiplier.tick_counter = 0
end

slap.multiplier.tick = function()
	slap.multiplier.tick_counter = slap.multiplier.tick_counter + 1
end

slap.move_forward.tick = function()
	slap.move_forward.tick_counter = slap.move_forward.tick_counter + 1
end

slap.move_forward.calculate = function()
	local current_pos = vector3d(getPosition())
	local angle = getRotation() * (math.pi / 180) * -1
	return {
		x = current_pos.x + math.sin(angle) * slap.move_forward.multiplier, 
		y = current_pos.y + math.cos(angle) * slap.move_forward.multiplier, 
		z = current_pos.z
	}
end

slap.move_forward.reset = function()
	slap.move_forward.state = false
	slap.move_forward.tick_counter = 0
end

slap.fall = function()
	while true do
		if slap.state or slap.move_forward.state then
			local current_pos = vector3d(getPosition())
			if slap.move_forward.state then -- move forward after falling
				slap.move_forward.tick()
				local new_pos = slap.move_forward.calculate()
				setPosition(new_pos.x, new_pos.y, new_pos.z)
				if slap.move_forward.tick_counter == slap.move_forward.for_ticks then
					slap.move_forward.reset()
				end
			elseif current_pos.z <= slap.points.target.z then -- stop falling
				slap.speed.reset()
				setPosition(slap.points.target.x, slap.points.target.y, slap.points.target.z)
				local height = slap.points.highest.z - slap.points.target.z
				local damage = slap.height_damage[math.floor(height)]
				if damage and getHealth() - damage > 0 then
					setHealth(getHealth() - damage)
				else
					runCommand('!kill')
				end
				if height >= 4.0 and height <= 10.0 then
					slap.move_forward.state = true
				end
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
	newTask(slap.fall, false)
end

function events.onSetPlayerPos(pos)
	local current_pos = vector3d(getPosition())
	if getDistanceBetweenCoords2d(current_pos, pos) < 0.2 and current_pos.z < pos.z then -- slap
		slap.speed.reset()
		slap.move_forward.reset()
		slap.points.highest = pos
		if not slap.state then
			slap.state = true
			slap.points.target = current_pos
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
