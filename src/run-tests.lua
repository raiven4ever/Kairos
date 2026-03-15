local ServerScriptService = game:GetService("ServerScriptService")
local jest = require(ServerScriptService.Kairos.packages.jest)
local runcli = jest.runCLI

local process_service_exists, process_service = pcall(function(...)
	return game:GetService("ProcessService")
end)

local status, result = runcli(ServerScriptService.Kairos.test, {
	verbose = false,
	ci = false,
}, { ServerScriptService.Kairos.test })

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
