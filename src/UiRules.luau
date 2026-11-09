--!strict
--- Safety policy, not a newly measured native metric.
const UiRules = {}
UiRules.MIN_HIT = 44
function UiRules.fraction(value: number): number
	return if value ~= value or math.abs(value) == math.huge then 0 else math.clamp(value, 0, 1)
end
function UiRules.hit(value: number?): number
	return math.max(
		UiRules.MIN_HIT,
		if value and value == value and math.abs(value) < math.huge then value else UiRules.MIN_HIT
	)
end
return UiRules
