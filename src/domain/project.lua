--!strict
local types = require(script.Parent.utils.types)

type ProjectData = types.ProjectMetaData
type ProjectProxy = types.ProjectProxy

local function DEFAULT_PROJECT_DATA(): ProjectData
	return {
		-- Core metadata
		Name = "New Project",
		Description = "",
		CreationDate = DateTime.now(),
		LastWorked = nil,

		-- Time statistics
		TotalTime = 0,
		Sessions = 0,
		AverageSessionLength = 0,
		LongestSession = 0,
		FirstSessionDate = nil,
		ActiveDays = 0,

		-- Organization
		Tags = {},
	}
end

local project_metatable = {
	__index = function(table: ProjectProxy, key)
		-- nothing really happens here, it's just the getter
		return table._content[key]
	end,

	__newindex = function(table: ProjectProxy, key, value)
		-- this is the setter, so i'm gonna put here everything i want if i want to reflect the changes IMMEDIATELY somewhere
		-- for example, i could fire a signal when this changes
		--[[
			local old = self._content[key]

			if old ~= value then
				self._content[key] = value
				-- fire change signal
				end
		]]
		table._content[key] = value
	end,
}

export type Project =
	typeof(setmetatable({ _content = {} :: ProjectData } :: ProjectProxy, project_metatable))
	& ProjectData

local module = {}
function module:new(overrides: ProjectData?)
	local content = DEFAULT_PROJECT_DATA()
	local project = setmetatable({ _content = content } :: ProjectProxy, project_metatable)
	if overrides then
		for key, value in pairs(overrides) do -- i normally do not ever use pairs or ipairs but the linter keeps crying
			content[key] = value
		end
	end
	return project
end

function module:serialize(project: Project): ProjectData
	return (project)._content
end

return module
