--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local signal = require(ServerScriptService.Kairos.packages.signal)
local sift = require(script.Parent.Parent.packages.sift)

local project_module = require(script.Parent.project)
local types = require(script.Parent.utils.types)

local add = sift.Array.push
local filter = sift.Array.filter
local remove = sift.Array.removeValue
local sort = sift.Array.sort
local levenshtein_similarity = require(script.Parent.utils.math.levenshtein_similarity)

type Project = project_module.Project
type ProjectMetaData = types.ProjectMetaData
type ProjectField = types.ProjectField
type Signal<T...> = signal.Signal<T...>

local module = {
	original_list = {} :: { Project },
	working_list = {} :: { Project },
	working_list_changed = signal.new() :: Signal<{ Project }>,
}

function module:set_working_list(project_list: { Project }) -- fucking powerful, use with high caution
	module.working_list = project_list
	module.working_list_changed:Fire(project_list)
end

function module:search(search_term: string)
	local function score(proj: Project): number
		local NAME_SCORE_MULTIPLIER = 4
		local TAGS_SCORE_MULTIPLIER = 2
		local DESCRIPTION_SCORE_MULTIPLIER = 1

		local project_score = 0

		for _ in proj.Name:gmatch(search_term) do
			project_score += NAME_SCORE_MULTIPLIER
		end

		for _, tag in ipairs(proj.Tags) do
			if tag == search_term then
				project_score += TAGS_SCORE_MULTIPLIER
			end
		end

		project_score += levenshtein_similarity(search_term, proj.Description) * DESCRIPTION_SCORE_MULTIPLIER

		return project_score
	end

	module:set_working_list(sort(module.working_list, function(first_project, second_project): boolean
		return score(first_project) < score(second_project)
	end))
end

function module:filter(predicate: (value: Project, _: number, _: { Project }) -> boolean)
	module:set_working_list(filter(module.working_list, predicate))
end

function module:sort(metadatum: ProjectField, is_ascending: boolean)
	assert(metadatum ~= "Tags", "Cannot sort by 'Tags' field")

	local function compare(first_value: any, second_value: any)
		return if is_ascending then first_value < second_value else second_value < first_value
	end

	local function by_attribute_type(first_project: Project, second_project: Project): boolean
		local first_attribute = first_project[metadatum]
		local second_attribute = second_project[metadatum]

		if not (first_attribute and second_attribute) then
			return not second_attribute -- if first ~= nil and second == nil
			-- nil values always last no matter the case, but might change my mind idk
		end

		local typeof_result = typeof(first_attribute)

		assert(
			typeof_result == typeof(second_attribute) and typeof_result ~= "table",
			"Project attributes must be of the same non-table type for sorting"
		)

		if typeof_result == "DateTime" then
			local first_datetime = first_attribute :: DateTime
			local second_datetime = second_attribute :: DateTime

			return compare(first_datetime.UnixTimestamp, second_datetime.UnixTimestamp)
		else
			return compare(first_attribute, second_attribute)
		end
	end

	module:set_working_list(sort(module.working_list, by_attribute_type))
end

function module:reset()
	module:set_working_list(sift.Array.copy(module.original_list))
end

--[[
TODO: functions:
-	fix add projects
-	remove projects
-	edit projects
]]

function module:set_projects(project_list: { Project })
	module.original_list = project_list
	--[[
	TODO: when this function is fired, set working list to a copy of the new original list, then reapply all the filters
	]]
end

function module:add(project: Project)
	module:set_projects(add(module.original_list, project))
end

return module
