export type HashMap<k , v> = {[k]: v}
export type Dictionarie<v> = HashMap<string , v>
export type Array<v> = {[number]: v}

local types = {
	['number']   = 'IntValue';
	['string']   = 'StringValue';
	['boolean']  = 'BoolValue';
}

local DEFAULT_FOLDER_NAME = 'THIS_IS_THE_DEFAULT_NAME'





local function CreateValueInstance(ClassName , Name)
	local instance = Instance.new(ClassName)
	instance.Name = Name
	return instance
end

local function get_folder(Parent : Instance , Name : string)
	local subfolder 
	local alreadyCreated = Parent:FindFirstChild(Name) and Parent:FindFirstChild(Name):IsA('Folder')
	if alreadyCreated then 
		subfolder = Parent:FindFirstChild(Name)
	else 
		subfolder = Instance.new('Folder')
		subfolder.Name = Name
		subfolder.Parent = Parent
	end
	return subfolder :: Folder
end


local Table = {}


function Table.create_folder_value<T>(T: T , Name: string) 
	local Parentfolder = Instance.new('Folder')
	Parentfolder.Name = Name or DEFAULT_FOLDER_NAME
	local function Create(key , value)
		if types[typeof(value)] then
			local _value  = CreateValueInstance(types[typeof(value)] , tostring(key))
			_value.Value  = value
			_value.Parent = Parentfolder
		elseif typeof(value) == "table" then
			local subfolder = Table.create_folder_value(value , key)
			subfolder.Parent = Parentfolder
		end
	end
	for key, value in (T:: any) do
		task.spawn(Create , key , value)
	end
	return Parentfolder
end

function Table.transform_to_vlaue_base_instance(tbl: Dictionarie<any> , Name: string)
	local container = Instance.new("StringValue")
	container.Name = Name
	Table.for_each(tbl , function(key, value)
		if typeof(value) == "table" then
			local sub_value = Table.transform_to_vlaue_base_instance(value , key)
			sub_value.Parent = container
		else
			container:SetAttribute(key , value)
		end
	end)
	container.Value = game.HttpService:JSONEncode(tbl)
	return container
end

function Table.transform_to_folder_instance(tbl: Dictionarie<any> , Name)
	local Parentfolder = Instance.new('Folder')
	Parentfolder.Name = Name or "Folder"
	for instance_name , value in tbl do
		local class_name = types[typeof(value)]
		if class_name then
			local instance = Instance.new(class_name)
			instance.Name = instance_name
			instance.Parent = Parentfolder
		elseif typeof(value) == "table" then
			local sub_folder = Table.transform_to_folder_instance(value , instance_name)
			sub_folder.Parent = Parentfolder
		end
	end
	return Parentfolder
end

function Table.transform(instance: Instance)
	local tbl = {}
	Table.for_each(instance:GetAttributes() , function(name , value)
		tbl[name] = value
	end)
	Table.for_each(instance:GetChildren() , function(_ , child)
		local index = tonumber(child.Name) or child.Name
		tbl[index] = Table.transform(child)
	end)
	return tbl
end

function Table.to_instance_props(instance : Instance , Props : Dictionarie<any>)
	assert(typeof(Props) == "table" , ("table expacted got (%s)"):format(typeof(Props)))
	for propname , propvalue in pairs(Props) do
		instance[propname] = propvalue
	end
end

function Table.table_to_attribute(instance : Instance , Props : Dictionarie<any>)
	for name , value in pairs(Props) do
		instance:SetAttribute(name , value)
	end
end

function Table.update_values(folder: Folder , data: Dictionarie<any>)
	assert(typeof(folder) == "Instance" and folder:IsA("Folder") , ("Folder expacted got (%s)"):format(typeof(data)))
	assert(typeof(data) == "table" , ("table expacted got (%s)"):format(typeof(data)))
	for name , value in data do
		local child = folder:FindFirstChild(name)
		if not child then continue end
		if child:IsA("Folder") and typeof(value) == "table" then
			task.spawn(Table.update_values , child , value)
		elseif child:IsA("ValueBase") and typeof(value) ~= "table"  then
			child.Value = value
		end
	end
end

function Table.for_each<k , v>(t: {[k]: v} , func: (key: k , value: v) -> ())
	for key , value in t do
		func(key , value)
	end
end

function Table.filter<k , v>(tbl: HashMap<k , v> , predicate: (Key: k , value: v) -> ())
	local _tbl = {}
	for key , value in tbl do
		if not predicate(key , value) then continue end
		if typeof(key) == "number" then
			_tbl[#_tbl+1] = value
		else
			_tbl[key] = value
		end
	end
	return _tbl
end

function Table.map<k , v>(tbl: {[k]: v} , mapfunc: (key: k ,val: v) -> v)
	local _tbl = {}
	for key , value in tbl do
		_tbl[key] = mapfunc(key , value)
	end
	return _tbl
end

function Table.get_key_changed<v>(new: Dictionarie<v> , old: Dictionarie<v>)
	local keys = {} :: {string}
	for name , value in old  do
		if value ~= new[name] then
			keys[#keys+1] =  name
		end
	end
	return keys
end

function Table.hash_size<k , v>(HashMap: HashMap<k ,v>)
	local len = 0
	for _ , _ in HashMap do
		len += 1
	end
	return len
end

function Table.clone_object<T>(t: T):  T
	local copy = {}
	for key, value in (t:: any) do
		if typeof(value) == "table" then
			copy[key] = Table.clone_object(value)
		else
			copy[key] = value
		end
	end
	return copy :: any
end



function Table.make_readonly<T>(object: T): T
	local Proxy = setmetatable({} , {
		__index = function(self , key)
			return (object :: any)[key]
		end,
		__newindex = function()
			error("Cannot modify read only table")
		end,
	})
	return table.freeze(Proxy) :: any
end


function Table.dictionarie_to_array<T>(dictionarie: Dictionarie<T>)
	local array = {}
	for _, value in dictionarie do
		if typeof(value) == "table" then
			array[#array+1] = Table.clone_object(value)
			continue
		end
		array[#array+1] = value
	end
	return array :: Array<T>
end

Table.create_folder_once = get_folder

return Table