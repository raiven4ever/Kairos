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

local binary_search = require(script.Parent.utils.math.binary_search)
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

function module:set_projects(project_list: { Project })
	module.original_list = project_list
	--[[
	TODO: when this function is fired, set working list to a copy of the new original list, then reapply all the filters
	]]
end

function module:is_in_original_list(name: string)
	local list = module.original_list

	return if binary_search(list, name) then true else false
end

function module:add(project_data: ProjectMetaData)
	assert(project_data, "project_data cannot be nil")
	if module:is_in_original_list(project_data.Name) then
		return
	end

	local new_project = project_module:new(project_data)
	module:set_projects(add(module.original_list, new_project))
end

function module:remove(project_name: string)
	local project_to_remove = binary_search(module.original_list, project_name)
	assert(project_to_remove, "Project '" .. project_name .. "' not found in original list")

	module:set_projects(remove(module.original_list, project_to_remove))
end

function module:edit(project_name_to_edit: string, new_attributes: ProjectMetaData)
	-- for future reference, let it be a principle that you must get the project from its name.
	local project_to_edit = binary_search(module.original_list, project_name_to_edit)
	-- names have to be available, otherwise everything goes, for now
	local project_with_new_name_exists = binary_search(module.original_list, new_attributes.Name)
	assert(
		project_to_edit and not project_with_new_name_exists,
		"Edit failed: project does not exist or the new name is already in use"
	)

	-- the consequences of my actions. every single time i edit a field, it would fire a signal. i now know for future references that
	-- this is a bad idea. now, a work around on this is to re-set the original list to its copy with the old project removed and the
	-- new version appended

	local project_to_edit_data = project_module:serialize(project_to_edit)

	for field, new_value in new_attributes do
		project_to_edit_data[field] = new_value
	end

	local project_list_to_set = remove(module.original_list, project_to_edit)
	project_list_to_set = add(project_list_to_set, project_module:new(project_to_edit_data))

	module:set_projects(project_list_to_set)
end

--[[
TODO:
-	add filter function
-	remove filter function
-	apply filters function
]]

return module
