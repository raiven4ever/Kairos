--!strict

local function levenshtein(s: string, t: string): number
	local m = #s
	local n = #t
	local dp = {}
	-- initialize matrix
	for i = 0, m do
		dp[i] = {}
		for j = 0, n do
			dp[i][j] = 0
		end
	end
	-- deletion cost
	for i = 1, m do
		dp[i][0] = i
	end
	-- insertion cost
	for j = 1, n do
		dp[0][j] = j
	end
	for j = 1, n do
		for i = 1, m do
			local substitution_cost
			if string.sub(s, i, i) == string.sub(t, j, j) then
				substitution_cost = 0
			else
				substitution_cost = 1
			end

			dp[i][j] = math.min(
				dp[i - 1][j] + 1, -- deletion
				dp[i][j - 1] + 1, -- insertion
				dp[i - 1][j - 1] + substitution_cost -- substitution
			)
		end
	end

	return dp[m][n]
end
return levenshtein
