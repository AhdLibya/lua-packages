--!nonstrict
local function __index(t, k)
	local cases = rawget(t, 'cases')
	local func = rawget(cases , k)
	if func then
	   return func
	end
	func = cases['default'] or function()end
	rawset(t, k, func)
	return func
end
type Cases<T> = {
	default: () -> T;
	[any]: () -> T;
}
return function <T>(item: T)
	local env = setmetatable({}, {__index = __index})
	return function (cases: Cases<T>)
		env.cases = cases
		local func = env[item]
		return func()
	end
end