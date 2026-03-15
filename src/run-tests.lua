local test = script.Parent.tests
local jest = require(script.Parent.packages.jest)
local runcli = jest.runCLI

local process_service_exists, process_service = pcall(function(...)
	return game:GetService("ProcessService")
end)

local status, result = runcli(test, {
	verbose = false,
	ci = false,
}, { test })

if status == "Rejected" then
	print(result)
end

if status == "Resolved" and result.results.numFailedTestSuites == 0 and result.results.numFailedTests == 0 then
	if process_service_exists then
		process_service:ExitAsync(0)
	end
end

if process_service_exists then
	process_service:ExitAsync(1)
end

return nil
