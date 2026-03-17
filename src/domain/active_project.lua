--!strict
local RunService = game:GetService("RunService")

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
	-- TODO: if project last worked date is not the same as today's date, adjust days active for this project
end

function module:switch_project(project: Project)
	assert(module.current_project and project, "No project is currently running or new project is nil")

	module.current_project = project
end

function module:end_project()
	assert(module.current_project, "No project is currently running")

	module.current_project = nil
	-- TODO: if duration is more than a day, for freaks, adjust days active for this project
	-- TODO: adjust total time worked after
end

function module:session_duration()
	assert(module.start_time, "start_time is not initialized")

	local duration = duration_module:get(DateTime.now(), module.start_time)
	return duration
end

return module
