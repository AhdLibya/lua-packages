local TweenService			= game:GetService("TweenService")
local UserInputService		= game:GetService("UserInputService")


local function ClearInstance(ts: number , p_Instance: Instance)
	task.delay(ts or .1 ,function()
		if not p_Instance then return end
		p_Instance:Destroy()
	end)
end


local function GetGuiToMousePosition(frame: GuiObject , offsetFromMouse: number) : UDim2
	local offset = Vector2.new(frame.AbsoluteSize.X / 2, frame.AbsoluteSize.Y / 2)
	local mousePosition = UserInputService:GetMouseLocation()
	local screenWidth, screenHeight = workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y
	return (UDim2.fromScale(mousePosition.X / screenWidth, mousePosition.Y / screenHeight)
	- UDim2.new(0, offset.X / screenWidth - offsetFromMouse, 0, offset.Y / screenHeight - (offsetFromMouse * .5)))
end

local Module = {}

function Module.UpdateToMousePosition(GuiObject: GuiObject , offset: number , mode)
	local Position = GetGuiToMousePosition(GuiObject , offset or 10)
	if mode then
		local tween = TweenService:Create(GuiObject, TweenInfo.new(0.1), {
			Position = Position,
		})
		tween:Play()
		ClearInstance(.3 , tween)
		return
	end
	GuiObject.Position = Position
end


return Module
