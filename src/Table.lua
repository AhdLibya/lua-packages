export type HashMap<k , v> = {[k]: v}
export type Dictionarie<v> = HashMap<string , v>
export type Array<v> = {[number]: v}

local types = {
	['number']   = 'IntValue';
	['string']   = 'StringValue';
	['boolean']  = 'BoolValue';
	['function'] = 'StringValue'
}

local DEFAULT_FOLDER_NAME = 'THIS_IS_THE_DEFAULT_NAME'





local function CreateValueInstance(ClassName , Name)
	local instance = Instance.new(ClassName)
	instance.Name = Name
	return instance
end

local function CreateFolder(Parent : Instance , Name : string)
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
	for key, value in pairs(T) do
		task.spawn(Create , key , value)
	end
	return Parentfolder
end

function Table.transform_to_instance(t , Name)
	local Parentfolder = Instance.new('Folder')
	Parentfolder.Name = Name or DEFAULT_FOLDER_NAME
	local function Transform(classname : string | number , value)
		if types[typeof(value)] and typeof(value) ~= 'function' then
			local subfolder = CreateFolder(Parentfolder , 'Values')
			local _value = CreateValueInstance(types[typeof(value)],tostring(classname))
			_value.Parent = subfolder
			_value.Name = classname
		elseif typeof(value) == "function" then
			local subfolder = CreateFolder(Parentfolder , 'functions')
			local func = Instance.new('RemoteFunction')
			func.Name = classname
			func.Parent = subfolder
		elseif typeof(value) == "table" then
			local subfolder = Table.transform_to_instance(value , classname or DEFAULT_FOLDER_NAME..tostring(tonumber(classname)))
			subfolder.Parent = Parentfolder
		elseif typeof(value) == "RBXScriptSignal" or "RBXScriptConnection" then
			local subfolder = CreateFolder(Parentfolder , 'Signals')
			local Signal = Instance.new('BindableEvent')
			Signal.Parent = subfolder
		end
	end
	for classname , value in pairs(t) do
		task.spawn(Transform , classname , value )
	end
	return Parentfolder
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
	assert(typeof(folder) == "Instance" and folder:IsA("Folder") , ("table expacted got (%s)"):format(typeof(data)))
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
		_tbl[key] = value
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

function Table.clone_object()
	
end

Table.create_folder_once = CreateFolder

return Table