--!strict
local sift = require(script.Parent.Parent.packages.sift)

local project = require(script.Parent.project)
local types = require(script.Parent.utils.types)

local sort = sift.Array.sort
local filter = sift.Array.filter
local levenshtein_similarity = require(script.Parent.utils.math.levenshtein_similarity)

type Project = project.Project
type ProjectField = types.ProjectField

--[[
TODO: modify this such that it when projects_list_changes, it changes modified_list automatically, and when modified_list changes,
something happens
]]
local module = {
	projects_list = {} :: { Project },
	modified_list = {} :: { Project },
}

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

	module.modified_list = sort(module.modified_list, function(first_project, second_project): boolean
		return score(first_project) < score(second_project)
	end)
end

function module:filter(predicate: (value: Project, _: number, _: { Project }) -> boolean)
	module.modified_list = filter(module.modified_list, predicate)
end

function module:sort(metadatum: ProjectField)
	assert(metadatum ~= "Tags", "Cannot sort by 'Tags' field")

	local function by_attribute_type(first_project: Project, second_project: Project): boolean
		local first_attribute = first_project[metadatum]
		local second_attribute = second_project[metadatum]

		if not (first_attribute and second_attribute) then
			return not second_attribute -- if first ~= nil and second == nil
		end

		local typeof_result = typeof(first_attribute)

		assert(
			typeof_result == typeof(second_attribute) and typeof_result ~= "table",
			"Project attributes must be of the same non-table type for sorting"
		)

		if typeof_result == "DateTime" then
			local first_datetime = first_attribute :: DateTime
			local second_datetime = second_attribute :: DateTime

			return first_datetime.UnixTimestamp < second_datetime.UnixTimestamp
		else
			return first_attribute < second_attribute
		end
	end

	module.modified_list = sort(module.modified_list, by_attribute_type)
end

function module:reset()
	module.modified_list = sift.Array.copy(module.projects_list)
end

return module
