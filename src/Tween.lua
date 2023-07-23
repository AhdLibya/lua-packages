local TweenService = game:GetService("TweenService")

export type TweenGroupObject = {
	Goal: {};
	Duration: number;
	Style: Enum.EasingStyle?;
	Direction: Enum.EasingDirection?;
}

local DEFAULT_PROPERTYS = {
	Style = Enum.EasingStyle.Linear;
	Direction = Enum.EasingDirection.Out;
}

local function Reconcile(tbl, Template)
    for key, value in pairs(Template) do
        if tbl[key] then continue end
        tbl[key] = value
    end
end

local Tween = {}



function Tween.TweenObjects(objects: {[Instance]: TweenGroupObject})
	local tweens = {}
	for object , property in objects do
		task.spawn(Reconcile , property , DEFAULT_PROPERTYS)
		local tween = TweenService:Create(object,
			TweenInfo.new(property.Duration,
			property.Style,
			property.Direction),
			property.Goal
		)
		tweens[object] = tween;
		tween:Play()
		tween.Completed:Once(function(playbackState)
			if playbackState == Enum.PlaybackState.Completed then
				tween:Destroy()
				tweens[object] = nil
			end
		end)
		task.wait(property.Duration)
	end
	for object: Instance , tween: Tween in tweens do
		tween:Destroy()
		tweens[object] = nil
	end
	table.clear(tweens)
end



return Tween