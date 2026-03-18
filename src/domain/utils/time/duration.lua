--!strict

export type Duration = {
	Days: number,
	Hours: number,
	Minutes: number,
	Seconds: number,
	TotalSeconds: number,
}

local module = {}

-- TODO: update based on the new functions
function module:get(from: DateTime, to: DateTime)
	local from_seconds = from.UnixTimestamp
	local to_seconds = to.UnixTimestamp
	assert(to_seconds > from_seconds, "to DateTime must be after from DateTime")

	local duration_number = to_seconds - from_seconds

	local function mod_then_divide(val: number)
		local to_return = duration_number % val
		duration_number /= val

		return to_return
	end

	local sec = mod_then_divide(60)
	local min = mod_then_divide(60)
	local hour = mod_then_divide(24)
	local day = duration_number -- what's left

	return {
		Day = day,
		Hour = hour,
		Minute = min,
		Second = sec,
	} :: Duration
end

-- TODO: function to
function module:from_seconds(amount: number)
	local total_seconds = amount

	local function mod_then_divide(val: number)
		local to_return = amount % val
		amount = math.floor(amount / val)

		return to_return
	end

	local seconds = mod_then_divide(60)
	local minutes = mod_then_divide(60)
	local hours = mod_then_divide(24)
	local days = amount

	return {
		Days = days,
		Hours = hours,
		Minutes = minutes,
		Seconds = seconds,
		TotalSeconds = total_seconds,
	} :: Duration
end

return module
