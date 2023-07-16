local function clear_instance(instance: Instance, ts: number?)
	task.delay(ts or .1 ,function()
		if not instance then return end
		instance:Destroy()
	end)
end

local function parse_path(pathStr: string)
	local pathArray = string.split(pathStr, "/")
	for idx = #pathArray, 1, -1 do
		if pathArray[idx] == "" then
			table.remove(pathArray, idx)
		end
	end
	return pathArray
end

local function get_value(path: string, root: Instance?)
	root = root or game
	local instance = parse_path(path)
	local first, last = instance[1], instance[#instance]
	if first == last then return root[last] end
	local nextRoot = root[first]
	if nextRoot == nil then return nil end
	return get_value(table.concat(instance, "/", 2), nextRoot)
end

local function import(filePath: string)
	local module = get_value(filePath)
	if typeof(module) == "Instance" and module:IsA("ModuleScript") then return require(module) end
	error(`{filePath} is not valid`)
end


local function disconnect_events(Listenr: RBXScriptConnection | {RBXScriptConnection})
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

local function load_modules<v>(parent: Instance , deep: boolean)
	local children = deep == true and parent:GetDescendants() or parent:GetChildren()
	local tbl = {} :: {[string]: v}
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

local function find_first_child_with_attribute(instance: Instance , attribute: string , recursive: boolean?)
	local children = recursive and instance:GetDescendants() or instance:GetChildren()
	for _ , child: Instance in children do
		if child:GetAttribute(attribute) ~= nil then return child end
	end
	return nil
end

local function find_first_ancestor_with_attribute(instance: Instance , attribute: string)
	local parent = instance.Parent
	local child = nil
	while parent ~= nil and not child do
		if parent:GetAttribute(attribute) ~= nil then
			child = parent
		else
			parent = parent.Parent
		end
	end
	return child
end

return {
    clear_instance          = clear_instance;
    get_value               = get_value;
    import                  = import;
    disconnect_events       = disconnect_events;
    load_modules            = load_modules;
    find_or_create_folder   = find_or_create_folder;
    for_children            = for_children;
    find_first_child_with_attribute = find_first_child_with_attribute;
    find_first_ancestor_with_attribute = find_first_ancestor_with_attribute;
}
