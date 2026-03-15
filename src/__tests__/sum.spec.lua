local ServerScriptService = game:GetService("ServerScriptService")
local jest_globals = require(ServerScriptService.Kairos.packages["jest-globals"])
local expect = jest_globals.expect
local it = jest_globals.it

it("adds 1 + 2 to equal 3", function()
	expect(1 + 2).toBe(3)
end)
