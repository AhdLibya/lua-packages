local CFrames = {}

function CFrames.angleBetween(A: CFrame , B: CFrame)
	local Rotatin = A:ToObjectSpace(B)
	local _ ,_ ,_, xx , yx ,zx, xy , yy , zy ,xz , yz , zz = Rotatin:GetComponents()
	local sinAxis = Vector3.new(yz - zy , zx - xz ,xy - yx)
	local cos = xx + yy + zz - 1
	local sin = sinAxis.Magnitude
	return math.atan2(cos , sin);
end

function CFrames.GetDirectionalRootJointCframe(
	humanoidRootPart: BasePart, 
	originalM6dC0: CFrame, 
	moveDirection: Vector3, 
	momentumFactor: number, 
	minMomentum: number, 
	maxMomentum: number, 
	dt: number): CFrame
	local direction = CFrames.VectorToObjectSpace(humanoidRootPart.CFrame, moveDirection)
	local momentum = CFrames.VectorToObjectSpace(humanoidRootPart.CFrame , humanoidRootPart.AssemblyLinearVelocity) * momentumFactor
	momentum = Vector3.new(
		math.clamp(math.abs(momentum.X), minMomentum, maxMomentum),
		0,
		math.clamp(math.abs(momentum.Z), minMomentum, maxMomentum)
	)
	local x = direction.X * momentum.X
	local z = direction.Z * momentum.Z
	local angles = CFrame.fromEulerAnglesXYZ(-z , -x , 0)

	return (humanoidRootPart.RootJoint:: Motor6D).C0:Lerp(originalM6dC0 *angles, dt * 16)
end

function CFrames.VectorToObjectSpace(Cframe: CFrame , vector: Vector3)
	return (Cframe:Inverse() - Cframe:Inverse().Position) * vector
end

return CFrames
