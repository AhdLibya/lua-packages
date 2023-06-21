local KetFrameProvider = game:GetService("KeyframeSequenceProvider")


local function GetSequenceLength(keyframeSequence : KeyframeSequence)
	local length = 0
	for _, keyframe in keyframeSequence:GetKeyframes() do
		if keyframe.Time > length then
			length = keyframe.Time
		end
	end
	return length
end

local function GetAnimationToPlay(Id : string)
	local Anim = Instance.new("Animation")
	Anim.AnimationId = Id
	local success , KeyframeSequence = pcall(KetFrameProvider.GetKeyframeSequenceAsync, KetFrameProvider,Anim.AnimationId)
	if not success then
		warn(KeyframeSequence)
		return Anim , 0.3
	end
	return Anim , GetSequenceLength(KeyframeSequence)
end

local Animations = {}

function Animations:GetAnimationFromSequence(sequenceData: {[string]: string} , index: string)
	return GetAnimationToPlay( sequenceData[index] )
end

function Animations:PlayAnimations(Id: string , Animator: Animator? , Priority: Enum.AnimationPriority)
	if not Animator then
		error(`Animator Expacted got {typeof(Animator)}` , 1)
	end
	if Animator:IsA("Humanoid") then
		local template = Animator:FindFirstAncestorOfClass("Animator")
		if not template then
			template = Instance.new("Animator")
			template.Name = Animator
		end
		Animator = template :: Animator
		template = nil
	end
	local Animation , Length = GetAnimationToPlay(Id)
	local Track = Animator:LoadAnimation(Animation)
	Track.Priority = Priority
	Track:Play()
	return Track , Length
end

function Animations:BuildAnimationTrack(id , humanoid)
	local Animation , Length = GetAnimationToPlay(id)
	local track = Animations:GetAnimator(humanoid):LoadAnimation(Animation)
	return track , Length
end

function Animations:GetAnimator(Humanoid: Humanoid)
	local Animator = Humanoid:FindFirstChildOfClass('Animator')
	if Animator then return Animator end
	Animator = Instance.new('Animator')
	Animator.Parent = Humanoid
	return Animator
end

return Animations
