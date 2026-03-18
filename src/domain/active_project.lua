--!strict

local project_module = require(script.Parent.project)

local types = require(script.Parent.utils.types)
local duration_module = require(script.Parent.utils.time.duration)

type Project = project_module.Project
type DateTimeData = types.DateTimeData
type Duration = types.Duration

local module = {
	-- project
	current_project = nil :: project_module.Project?,

	-- time keeping
	start_time = DateTime.now(), -- starts immediately when module is requires (i have a bad feeling about this)
	-- end_time, but no need for symmetry yet
}

function module:start_project(project: Project)
	assert(not module.current_project and project, "A project is already running or project is nil")

	module.current_project = project
end

function module:end_project()
	local start_time = module.start_time
	local project = module.current_project
	assert(project and start_time, "Project or start_time is nil")

	local function different_dates(date1: DateTime, date2: DateTime): boolean
		local date1_data = date1:ToLocalTime() :: DateTimeData
		local date2_data = date2:ToLocalTime() :: DateTimeData

		return date1_data.Year ~= date2_data.Year
			or date1_data.Month ~= date2_data.Month
			or date1_data.Second ~= date2_data.Second
	end

	-- core metadata
	local last_worked = DateTime.now()

	-- needed data but are not metadata
	local session_duration = duration_module:get(start_time, last_worked)

	-- time statistics
	local total_time = project.TotalTime + session_duration.TotalSeconds
	local sessions = project.Sessions + 1
	local average_session_length = total_time / sessions
	local longest_session = math.max(project.LongestSession, session_duration.TotalSeconds)
	local first_session_date = if not project.FirstSessionDate then DateTime.now() else project.FirstSessionDate
	local active_days = if different_dates(project.LastWorked, last_worked)
		then project.ActiveDays + math.max(1, session_duration.Days)
		else project.ActiveDays

	-- modify project
	project.TotalTime = total_time
	project.Sessions = sessions
	project.AverageSessionLength = average_session_length
	project.LongestSession = longest_session
	project.FirstSessionDate = first_session_date
	project.ActiveDays = active_days

	module.current_project = nil
end

function module:session_duration()
	assert(module.start_time, "start_time is not initialized")

	local duration = duration_module:get(DateTime.now(), module.start_time)
	return duration
end

return module
