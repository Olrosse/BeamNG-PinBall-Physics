local M = {}

local drawDebug = obj.debugDrawProxy

local positionoffset = v.data.nodes[v.data.refNodes[0].ref].pos

--Variables

local isEnabled = true
local forceMultiplier = 1

M.enableDebugDraw = false
M.collisionDelay = 1/30

--Variables

local abs = math.abs
local sqrt = math.sqrt
local min = math.min
local max = math.max
local physicsHZ = obj:getPhysicsFPS() or 2000
local vehicleID = obj:getId()
local carWidth = obj:getInitialWidth()
local carLength = obj:getInitialLength()
local carHeight = obj:getInitialHeight()
local vehiclerotation = quat(obj:getRotation())
local vehiclePosition = obj:getPosition() - (positionoffset:rotated(vehiclerotation))
local ownVel = obj:getVelocity()
local collisionTimer = 0

local vehiclemap = {}

local function calculateDistance(vec1, vec2)
	return sqrt((vec2.x-vec1.x)^2 + (vec2.y-vec1.y)^2 + (vec2.z-vec1.z)^2)
end

local function getCenterOfNodes()
	local front = 0
	local rear = 0
	local left = 0
	local right = 0
	local top = 0
	local bottom = 0
	for k,v in pairs(v.data.nodes) do
		if v.pos.y < front then front = v.pos.y end
		if v.pos.y > rear then rear = v.pos.y end
		if v.pos.x < left then left = v.pos.x end
		if v.pos.x > right then right = v.pos.x end
		if v.pos.z > top then top = v.pos.z end
		if v.pos.z < bottom then bottom = v.pos.z end
	end
	return vec3((left+right)/2,(front+rear)/2,(top+bottom)/2)
end

local carCenter = positionoffset-getCenterOfNodes()

local function getPosOffset()
	local data = {}
	local mass = 0
	for _,v in pairs(v.data.nodes) do
		mass = mass + v.nodeWeight
	end
	data.colTimer = 0
	data.mass = mass
	data.offset = carCenter
	data.carWidth = obj:getInitialWidth()
	data.carLength = obj:getInitialLength()
	data.carHeight = obj:getInitialHeight()
	data.vel = obj:getVelocity()
	return data
end

local function sendPosOffset(id)
	local data = getPosOffset()
	obj:queueObjectLuaCommand(id, "if PinBall then PinBall.setPosOffset(" .. tostring(vehicleID) .. ", " .. serialize(data) .. ") end")
end

local function sendPosOffsetToAll()
	local data = getPosOffset()
	BeamEngine:queueAllObjectLuaExcept("if PinBall then PinBall.setPosOffset(" .. tostring(vehicleID) .. ", " .. serialize(data) .. ") end",vehicleID)
	BeamEngine:queueAllObjectLuaExcept("if PinBall then PinBall.sendPosOffset(" .. tostring(vehicleID) .. ") end",vehicleID)
end

local function setPosOffset(id,data)
	if not vehiclemap[id] then
		vehiclemap[id] = {}
	end
	vehiclemap[id] = data
end

local detectcolor = color(255,0,0,200)

local function detectCollisions(vehicles)
	if not next(mapmgr.objectCollisionIds) then return end

	for _,vehID in pairs(mapmgr.objectCollisionIds) do
		if not vehiclemap[vehID] then
			obj:queueObjectLuaCommand(vehID,"if PinBall then PinBall.sendPosOffset(" .. tostring(vehicleID) .. ") end")
		else
			local vehData = vehicles[vehID]
			if vehData then
				local offset = vehiclemap[vehID].offset
				local rot = quatFromDir(-vehData.dirVec,vehData.dirVecUp)
				local pos = vehData.pos - offset:rotated(rot)

				local distance = calculateDistance(vehiclePosition, pos)
				if distance < ((vehiclemap[vehID].carLength+carLength)/2)*1.1 and not vehiclemap[vehID].ColState and collisionTimer < -0.2 then
					detectcolor = color(0,255,0,200)
					vehiclemap[vehID].ColState = true
					vehiclemap[vehID].vel = vehData.vel
					collisionTimer = M.collisionDelay
					ownVel = obj:getVelocity()
				end
			end
		end
	end
end

local function calculateForce(dt)
	local collisionDetected
	local mass = 0
	local totalForce = 0
	local collisionDir = vec3(0,0,0)

	for k,v in pairs(v.data.nodes) do
		mass = mass + v.nodeWeight
	end

	for ID,vehData in pairs(vehiclemap) do
		if not vehData.lastColState and vehData.ColState then
			local mapmgrData = mapmgr.objects[ID]
			local collisionForceRaw = vehData.vel - ownVel
			local collisionForce = min(100,abs(collisionForceRaw.x) + abs(collisionForceRaw.y) + abs(collisionForceRaw.z))

			local rot = quatFromDir(mapmgrData.dirVec*-1,mapmgrData.dirVecUp)
			collisionDir = collisionDir + (-((mapmgrData.pos - vehData.offset:rotated(rot)) - vehiclePosition):normalized())
			local massOffset = max(0.3,1 + ((vehData.mass-mass)*0.0001))
			local force = abs(collisionForce)*massOffset
	
			totalForce = totalForce + force
			collisionDetected = true
		end
		vehData.lastColState = vehData.ColState
		vehData.ColState = false
	end
	if collisionDetected then
		electrics.values.pinballPhysForce = totalForce*forceMultiplier
		electrics.values.collisionDirX = collisionDir.x
		electrics.values.collisionDirY = collisionDir.y
		electrics.values.collisionDirZ = collisionDir.z
	end
end

local function drawBoundingBox()
	----local detectcolor = color(0,255,0,200)
    drawDebug:drawSphere(0.1 , obj:getPosition(), color(0,255,0,200))
    drawDebug:drawSphere(0.1 , obj:getPosition() - (carCenter):rotated(quat(obj:getRotation())), detectcolor)

	--front left top
	drawDebug:drawSphere(0.1 , obj:getPosition() - (vec3(carCenter.x-(carWidth/2),carCenter.y+(carLength/2),carCenter.z-(carHeight/2))):rotated(quat(obj:getRotation())), detectcolor)
	--front right top
	drawDebug:drawSphere(0.1 , obj:getPosition() - (vec3(carCenter.x+(carWidth/2),carCenter.y+(carLength/2),carCenter.z-(carHeight/2))):rotated(quat(obj:getRotation())), detectcolor)
	--front left bottom
	drawDebug:drawSphere(0.1 , obj:getPosition() - (vec3(carCenter.x-(carWidth/2),carCenter.y+(carLength/2),carCenter.z+(carHeight/2))):rotated(quat(obj:getRotation())), detectcolor)
	--front right bottom
	drawDebug:drawSphere(0.1 , obj:getPosition() - (vec3(carCenter.x+(carWidth/2),carCenter.y+(carLength/2),carCenter.z+(carHeight/2))):rotated(quat(obj:getRotation())), detectcolor)
	--rear left top
	drawDebug:drawSphere(0.1 , obj:getPosition() - (vec3(carCenter.x-(carWidth/2),carCenter.y-(carLength/2),carCenter.z-(carHeight/2))):rotated(quat(obj:getRotation())), detectcolor)
	--rear right top
	drawDebug:drawSphere(0.1 , obj:getPosition() - (vec3(carCenter.x+(carWidth/2),carCenter.y-(carLength/2),carCenter.z-(carHeight/2))):rotated(quat(obj:getRotation())), detectcolor)
	--rear left bottom
	drawDebug:drawSphere(0.1 , obj:getPosition() - (vec3(carCenter.x-(carWidth/2),carCenter.y-(carLength/2),carCenter.z+(carHeight/2))):rotated(quat(obj:getRotation())), detectcolor)
	--rear right bottom
	drawDebug:drawSphere(0.1 , obj:getPosition() - (vec3(carCenter.x+(carWidth/2),carCenter.y-(carLength/2),carCenter.z+(carHeight/2))):rotated(quat(obj:getRotation())), detectcolor)

    drawDebug:drawSphere(0.1 , obj:getPosition() - (vec3(carCenter.x,carCenter.y+(carLength/2),carCenter.z)):rotated(quat(obj:getRotation())), detectcolor)
    drawDebug:drawSphere(0.1 , obj:getPosition() - (vec3(carCenter.x,carCenter.y-(carLength/2),carCenter.z)):rotated(quat(obj:getRotation())), detectcolor)
    drawDebug:drawSphere(0.1 , obj:getPosition() - (vec3(carCenter.x,carCenter.y,carCenter.z+(carHeight/2))):rotated(quat(obj:getRotation())), detectcolor)
    drawDebug:drawSphere(0.1 , obj:getPosition() - (vec3(carCenter.x,carCenter.y,carCenter.z-(carHeight/2))):rotated(quat(obj:getRotation())), detectcolor)
    drawDebug:drawSphere(0.1 , obj:getPosition() - (vec3(carCenter.x+(carWidth/2),carCenter.y,carCenter.z)):rotated(quat(obj:getRotation())), detectcolor)
    drawDebug:drawSphere(0.1 , obj:getPosition() - (vec3(carCenter.x-(carWidth/2),carCenter.y,carCenter.z)):rotated(quat(obj:getRotation())), detectcolor)

	detectcolor = color(255,0,0,200)
end

local lastpinballPhysForce

local function applyForce()
	if electrics.values.pinballPhysForce ~= lastpinballPhysForce then
		local force = electrics.values.pinballPhysForce
		local collisionDir = vec3(electrics.values.collisionDirX,electrics.values.collisionDirY,electrics.values.collisionDirZ)
		obj:applyClusterLinearAngularAccel(v.data.refNodes[0].ref, (collisionDir*(force))*physicsHZ, vec3(0,0,0))
	end
	lastpinballPhysForce = electrics.values.pinballPhysForce
end

local function updateGFX(dt)

	if carWidth == 0 then
		carWidth = obj:getInitialWidth()
		carLength = obj:getInitialLength()
		carHeight = obj:getInitialHeight()
		sendPosOffsetToAll()
	end

	if not isEnabled then return end

	if v.mpVehicleType and v.mpVehicleType == "R" then -- applying force on remote vehicle
		applyForce() -- TODO maybe hook into positionVE and add ping compensation?
		return -- prevent calculation from running on remote vehicle, we want to send the actual direction and velocity anyways
	end

    local vehicles = mapmgr.getObjects()

	local localVehData = vehicles[vehicleID]
	if not localVehData then return end

	vehiclerotation = quatFromDir(localVehData.dirVec*-1,localVehData.dirVecUp)
	vehiclePosition = vehicles[vehicleID].pos - ((carCenter):rotated(vehiclerotation))

	detectCollisions(vehicles)
	calculateForce(dt)
	collisionTimer = collisionTimer - dt
	if collisionTimer <= 0 and collisionTimer > -dt*2 then
		applyForce()
	end
	if M.enableDebugDraw then
		drawBoundingBox()
	end
end

local function setEnabled(state)
	isEnabled = state or true
end

local function setforceMultiplier(numnber)
	forceMultiplier = numnber or 1
end

M.setEnabled = setEnabled
M.setforceMultiplier = setforceMultiplier
M.getPosOffset = getPosOffset
M.setPosOffset = setPosOffset
M.sendPosOffset = sendPosOffset
M.updateGFX = updateGFX

return M