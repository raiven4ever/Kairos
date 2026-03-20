--!strict
local project_module = require(script.Parent.Parent.Parent.project)

type Project = project_module.Project

return function(project_list: { Project }, name_to_find: string): Project?
	local left = 1
	local right = #project_list

	while left <= right do
		local middle = left + math.floor((right - left) / 2)
		local project = project_list[middle]
		local project_name = project_list[middle].Name :: string -- why the fuck is the linter crying?
		if project_name < name_to_find then
			left = middle + 1
		elseif project_name > name_to_find then
			right = middle - 1
		else
			return project
		end
	end

	return nil
end
