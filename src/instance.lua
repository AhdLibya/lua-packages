local function ClearInstance(ts: number , p_Instance: Instance)
	task.delay(ts or .1 ,function()
		if not p_Instance then return end
		p_Instance:Destroy()
	end)
end

local function parsePath(pathStr)
	local pathArray = string.split(pathStr, "/")
	for idx = #pathArray, 1, -1 do
		if pathArray[idx] == "" then
			table.remove(pathArray, idx)
		end
	end
	return pathArray
end

local function GetValue(path, root)
	root = root or game
	local instance = parsePath(path)
	local first, last = instance[1], instance[#instance]
	if first == last then return root[last] end
	local nextRoot = root[first]
	if nextRoot == nil then return nil end
	return GetValue(table.concat(instance, "/", 2), nextRoot)
end

local function Import(filePath)
	local module = GetValue(filePath)
	if typeof(module) == "Instance" and module:IsA("ModuleScript") then return require(module) end
	error(`{filePath} is not valid`)
end


local function DisconnectEvents(Listenr: RBXScriptConnection | {RBXScriptConnection})
	if typeof(Listenr) == "RBXScriptConnection" then
		Listenr:Disconnect()
	elseif typeof(Listenr) == "table" then
		for _ , connection in Listenr do
			if typeof(connection) == "RBXScriptConnection" or typeof(connection.Disconnect) == "function" then
				connection:Disconnect()
			end
		end
		table.clear(Listenr)
	end
end

local function load_modules(parent: Instance , deep: boolean)
	local children = deep == true and parent:GetDescendants() or parent:GetChildren()
	for _ , module in children do
		if not module:IsA("ModuleScript") then continue end
		require(module)
	end
end

local c_Instance = {}

c_Instance.ClearInstance 	= ClearInstance
c_Instance.GetValue		 	= GetValue
c_Instance.Import 			= Import
c_Instance.DisconnectEvents = DisconnectEvents
c_Instance.load_modules 	= load_modules

return c_Instance
