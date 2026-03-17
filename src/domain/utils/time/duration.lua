--!strict

export type Duration = {
	Day: number,
	Hour: number,
	Minute: number,
	Second: number,
	Millisecond: number,
}

local module = {}

function module:get(from: DateTime, to: DateTime)
	local from_millis = from.UnixTimestampMillis
	local to_millis = to.UnixTimestampMillis
	assert(to_millis > from_millis, "to DateTime must be after from DateTime")

	local duration_number = to_millis - from_millis

	local function mod_then_divide(val: number)
		local to_return = duration_number % val
		duration_number /= val

		return to_return
	end

	local ms = mod_then_divide(1000)
	local sec = mod_then_divide(60)
	local min = mod_then_divide(60)
	local hour = mod_then_divide(24)
	local day = duration_number -- what's left

	return {
		Day = day,
		Hour = hour,
		Minute = min,
		Second = sec,
		Millisecond = ms,
	} :: Duration
end

return module
