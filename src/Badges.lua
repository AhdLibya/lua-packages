
local BadgeService = game:GetService('BadgeService')

local Badges = {}


function Badges.AwardBadge(Player: Player , BadgeId: number)
	local _success , Info =  pcall(BadgeService.GetBadgeInfoAsync , BadgeService, BadgeId)
	if not _success then
		warn("Error While Fetching Badge Info")
		return
	end
	if Info.IsEnabled == false then 
		warn("Badge Not Enable")
		return 
	end
	local success , HasBadge = pcall(BadgeService.UserHasBadgeAsync , BadgeService , Player.UserId , BadgeId)
	if not success then  return  end
	if HasBadge then 
		warn("Already Own The Badge")
		return
	end
	local Awarded , errorMsg =  pcall(BadgeService.AwardBadge, BadgeService, Player.UserId, BadgeId)
	if not Awarded then
		warn("Error while awarding Badge:", errorMsg)
	end
end

return Badges
