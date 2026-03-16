export type DateTimeData = { -- the fact that this is not a type is fucking stupid
	Year: number,
	Month: number,
	Day: number,
	Hour: number,
	Minute: number,
	Second: number,
	Millisecond: number,
}

export type ProjectRecord = { [string]: (string | number | { string })? }

export type ProjectMetaData = {
	-- Core metadata
	Name: string,
	Description: string,
	CreationDate: DateTime,
	LastWorked: DateTime?,

	-- Time statistics
	TotalTime: number,
	Sessions: number,
	AverageSessionLength: number,
	LongestSession: number,
	FirstSessionDate: DateTime?,
	ActiveDays: number,

	-- Organization
	Tags: { string },
}

export type ProjectField =
	(
		"Name"
		| "Description"
		| "CreationDate"
		| "LastWorked"
		| "TotalTime"
		| "Sessions"
		| "AverageSessionLength"
		| "LongestSession"
		| "FirstSessionDate"
		| "ActiveDays"
		| "Tags"
	)
	| string

export type ProjectProxy = {
	_content: ProjectMetaData,
}

return nil
