local Tbl = require(script.Parent.Tables)

local function CreatePart(SpawnCframe: CFrame, Size: Vector3)
	local HitBox        = Instance.new("Part")
	HitBox.Size         = Size
	HitBox.Color        = Color3.new(1,0,0)
	HitBox.CFrame       = SpawnCframe
	HitBox.CanCollide   = false
	HitBox.Transparency = .5
	HitBox.Anchored     = true
	return HitBox
end

local HitBoxInstances = {
	
	Basic = function(SpawnCframe: CFrame)
		return CreatePart(SpawnCframe , Vector3.new(4,1,4))
	end;
	
	Miduim = function(SpawnCframe: CFrame)
		return CreatePart(SpawnCframe , Vector3.new(4, 5 , 5))
	end,
	
	Large = function(SpawnCframe: CFrame)
		return CreatePart(SpawnCframe , Vector3.new(4 , 5 , 10))
	end,

	Custom = function(SpawnCframe: CFrame , sizeVector: Vector3)
		return CreatePart(SpawnCframe , sizeVector)
	end
}


local HitBoxs = {
	HitBoxType = {
		Basic  = "Basic";
		Miduim = "Medium";
		Large  = "Large";
		Custom = "Custom"
	}
}

function HitBoxs:GetHitResult( Part: BasePart , IgnoreList: {Instance?} )
	IgnoreList = IgnoreList or {}
	local OverLapPrams = OverlapParams.new()
	OverLapPrams.FilterType = Enum.RaycastFilterType.Exclude
	OverLapPrams.FilterDescendantsInstances = IgnoreList
	return workspace:GetPartsInPart(Part , OverLapPrams)
end

function HitBoxs:GetHumanoids(Part: BasePart , IgnoreList)
	local Result = HitBoxs:GetHitResult(Part , IgnoreList)
	local Parents = Tbl.Filter(Result , function(_, v)
		return v.Parent:FindFirstChildOfClass("Humanoid") ~= nil
	end)
	table.clear(Result)
	local Humanoids = {}
	for _ , Ins in Parents  do
		local Humanoid = Ins.Parent.Humanoid :: Humanoid
		if Humanoid:GetState() == Enum.HumanoidStateType.Dead then continue end
		if table.find(Humanoids , Humanoid) then continue end
		Humanoids[#Humanoids+1] = Humanoid
	end
	table.clear(Parents)
	return Humanoids
end

function HitBoxs:CreateHitBox(Character: Model , Type , ...)
	Type = Type or HitBoxs.HitBoxType.Basic
	local SpawnCframe = (Character.HumanoidRootPart.CFrame * CFrame.new(0 , 0 , -2))
	local HitBox 
	if Type == HitBoxs.HitBoxType.Custom then
		HitBox = HitBoxInstances[Type](SpawnCframe , ...) :: Part
	else
		HitBox = HitBoxInstances[Type](SpawnCframe) :: Part
	end
	return HitBox
end

function HitBoxs:GetHitBoxResult( Owner: Model? , IgnoreList: {Instance} )
	return HitBoxs:GetHumanoids(
		HitBoxs:CreateHitBox(Owner , HitBoxs.HitBoxType.Basic),
		IgnoreList
	);
end



return HitBoxs
