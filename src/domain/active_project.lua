--!strict
local RunService = game:GetService("RunService")

local project = require(script.Parent.project)
local types = require(script.Parent.utils.types)

type Project = project.Project
type DateTimeData = types.DateTimeData

local module = {
	current_project = nil :: project.Project?,
	connection = nil :: RBXScriptConnection?,
	current_session_time = 0,
}

function module:start(proj: Project)
	assert(
		proj and not module.current_project and not module.connection,
		"Project must be provided, and there must be no current project or connection"
	)

	local function modify_active_days()
		local current = DateTime.now()
		local same_day
		do
			if not proj.LastWorked then
				same_day = false
			else
				local current_local_time = current:ToLocalTime() :: DateTimeData
				local last_worked_local_time = proj.LastWorked:ToLocalTime() :: DateTimeData

				same_day = current_local_time.Day == last_worked_local_time.Day
					and current_local_time.Year == last_worked_local_time.Year
					and current_local_time.Month == last_worked_local_time.Month
			end
		end
		if not same_day then
			proj.ActiveDays += 1
		end
	end

	module.current_project = proj

	-- modify proj
	proj.Sessions += 1

	if not proj.FirstSessionDate then
		proj.FirstSessionDate = DateTime.now()
	end

	modify_active_days()

	if not proj.LastWorked then
		proj.LastWorked = DateTime.now()
	end

	module.connection = RunService.Heartbeat:Connect(function(delta_time: number)
		proj.TotalTime += delta_time
		module.current_session_time += delta_time
	end)
end

function module:terminate()
	local proj = module.current_project

	assert(proj and module.connection, "No active project or connection to terminate")
	module.connection:Disconnect()

	-- modify proj
	proj.AverageSessionLength = proj.TotalTime / proj.Sessions
	proj.LongestSession = math.max(proj.LongestSession, module.current_session_time)

	module.current_project = nil
end

return module
