
PinBallEnabled = false
multiplier = 1

local function help(sender_id, sender_name, message, variable)
	MP.SendChatMessage(sender_id,"PinBall command list")

	for k,v in pairs(commands) do
		local usage = v.usage or ""
		MP.SendChatMessage(sender_id,"/pinball "..k.." "..usage..", "..v.tooltip.."")
	end
end

local function enable(sender_id, sender_name, message, variable)
	if variable and variable == "true" then
		PinBallEnabled = true
		MP.SendChatMessage(-1,"PinBall Physics enabled")
	elseif variable and variable == "false" then
		PinBallEnabled = false
		MP.SendChatMessage(sender_id,"PinBall Physics disabled")
	else
		PinBallEnabled = true
		MP.SendChatMessage(sender_id,"PinBall Physics enabled")
	end
	MP.TriggerClientEvent(-1, "PinBallPhysics_enable", variable or "true")
end

local function disable(sender_id, sender_name, message, variable)
	if variable and variable == "true" then
		PinBallEnabled = false
		MP.SendChatMessage(sender_id,"PinBall Physics disabled")
	elseif variable and variable == "false" then
		PinBallEnabled = true
		MP.SendChatMessage(sender_id,"PinBall Physics enabled")
	else
		PinBallEnabled = false
		MP.SendChatMessage(sender_id,"PinBall Physics disabled")
	end
	MP.TriggerClientEvent(-1, "PinBallPhysics_disable", variable or "true")
end

local function toggle(sender_id, sender_name, message)
	if PinBallEnabled then
		disable(sender_id, sender_name, message)
	else
		enable(sender_id, sender_name, message)
	end
end

local function setMultiplier(sender_id, sender_name, message, variable)
	local tempMultiplier = tonumber(variable)
	if type(tempMultiplier) == "number" then
		multiplier = tempMultiplier
		MP.SendChatMessage(sender_id,"set PinBall multiplier to "..variable.."")
		MP.TriggerClientEvent(-1, "PinBallPhysics_multiplier", variable)
	else
		MP.SendChatMessage(sender_id,"no number")
	end
end

commands = {
	["help"] = {
		["function"] = help,
		--["usage"] = "lists all commands",
		["tooltip"] = "lists all commands"
	},
	["enable"] = {
		["function"] = enable,
		["tooltip"] = "Enables the pinBall Physics",
		["usage"] = "true or false"
	},
	["disable"] = {
		["function"] = disable,
		["tooltip"] = "Disables the pinBall Physics",
		["usage"] = "true or false"
	},
	["toggle"] = {
		["function"] = toggle,
		["tooltip"] = "toggles the pinBall Physics"
	},
	["multiplier"] = {
		["function"] = setMultiplier,
		["tooltip"] = "multiplier for the pinBall Collisions"
	}
}

function PinBallPhysicsChatHandler(sender_id, sender_name, message)
	if string.sub(message,1,8) == "/pinball" then
		local commandstringraw = string.sub(message,10)
		local commandstring, variable = string.match(commandstringraw,"^(.+) (.+)$")
		local commandStringFinal = commandstring or commandstringraw

		if commands[commandStringFinal] then
			commands[commandStringFinal]["function"](sender_id, sender_name, message ,variable)
		else
			MP.SendChatMessage(sender_id,"command not found, type /pinball help for a list of PinBall commands")
		end
		return 1
	elseif string.sub(message,1,5) == "/help" then
		MP.SendChatMessage(sender_id,"type /pinball help for a list of PinBall commands")
		return 1
	end
end

function requestState(playerID)
	MP.TriggerClientEvent(playerID, "PinBallPhysics_enable", tostring(PinBallEnabled))
	MP.TriggerClientEvent(playerID, "PinBallPhysics_multiplier", tostring(multiplier))
end

MP.RegisterEvent("onChatMessage", "PinBallPhysicsChatHandler")
MP.RegisterEvent("onPlayerJoin", "requestState")