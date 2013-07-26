
//Smooth tweening script.
//This is unused at the moment, but will be used once I get it right

function LerpVectorSmooth(p,from,to)
	local diff = to - from
	local diffnorm = diff:Normalize()
	local result = LerpVector(p,from,to)
	result.x = LerpVector(math.EaseInOut(p,1.0-diffnorm.x,1.0-diffnorm.x),from,to).x
	result.y = LerpVector(math.EaseInOut(p,1.0-diffnorm.y,1.0-diffnorm.y),from,to).y
	result.z = LerpVector(math.EaseInOut(p,1.0-diffnorm.z,1.0-diffnorm.z),from,to).z
	return result
end

function LerpAngleSmooth(p,from,to)
	local diff = Angle(0,0,0)
	diff.p = math.AngleDifference(to.p,from.p)
	diff.y = math.AngleDifference(to.y,from.y)
	diff.r = math.AngleDifference(to.r,from.r)
	local diffnorm = diff:Forward()
	local result = LerpAngle(p,from,to)
	result.p = LerpAngle(math.EaseInOut(p,1.0-diffnorm.y,1.0-diffnorm.y),from,to).p
	result.y = LerpAngle(math.EaseInOut(p,1.0-diffnorm.z,1.0-diffnorm.z),from,to).y
	result.r = LerpAngle(math.EaseInOut(p,1.0-diffnorm.x,1.0-diffnorm.x),from,to).r
	return result
end