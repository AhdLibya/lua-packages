local ViewPort = {}

function ViewPort.RelativeToCamera(model: Model , view: ViewportFrame)
	local camera = Instance.new("Camera")
	model:PivotTo(CFrame.new(Vector3.zero))
	local cframe = model:GetPivot()
	camera.CFrame = CFrame.new(cframe.Position + (cframe.LookVector * 7), cframe.Position)
	model:PivotTo(model:GetPivot()* CFrame.Angles(0 , math.rad(20) , 0))
	camera.CameraSubject = model.PrimaryPart or model:FindFirstChildOfClass("BasePart")
	camera.Parent = view
	view.CurrentCamera = camera
	return camera
end

return ViewPort
