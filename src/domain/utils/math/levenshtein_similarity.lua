--!strict

local levenshtein = require(script.Parent.levenshtein)

return function(s: string, t: string)
	return 1 - levenshtein(s, t) / math.max(#s, #t)
end
