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
	local tbl = {} :: {[string]: table}
	for _ , module in children do
		if not module:IsA("ModuleScript") then continue end
		tbl[module.Name] = require(module)
	end
	return tbl
end

local function  find_or_create_folder(Parent: Instance , Name: string)
	local instance = Parent:FindFirstChild(Name) :: Folder
	if not instance then
		instance = Instance.new("Folder")
		instance.Name = Name
		instance.Parent = Parent
	end
	return instance
end

local function for_children(parent: Instance , callback : (instance: Instance) -> ())
	local children =  parent:GetChildren()
	for _ , instance in children do
		task.spawn(callback , instance)
	end
end


return {
	clear_instance 			= ClearInstance;
	get_value				= GetValue;
	import 					= Import;
	disconnect_events		= DisconnectEvents;
	load_modules 			= load_modules;
	find_or_create_folder 	= find_or_create_folder;
	for_children 			= for_children;
}
