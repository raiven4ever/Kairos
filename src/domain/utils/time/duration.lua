--!strict

export type Duration = {
	Days: number,
	Hours: number,
	Minutes: number,
	Seconds: number,
	TotalSeconds: number,
}

local module = {}

function module:get(from: DateTime, to: DateTime)
	local from_seconds = from.UnixTimestamp
	local to_seconds = to.UnixTimestamp
	assert(to_seconds > from_seconds, "to DateTime must be after from DateTime")

	local duration_number = to_seconds - from_seconds

	return module:from_seconds(duration_number)
end

function module:from_seconds(amount: number)
	assert(amount >= 0, "amount must be greater than or equal to 0")
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

function module:to_seconds(duration: Duration) -- this is so fucking trivial, this shouldn't be a function outside of wanting symmetry
	return duration.TotalSeconds
end

return module
