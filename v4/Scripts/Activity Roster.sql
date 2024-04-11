USE [Mortis]
GO

DECLARE @ActivityID int
SET @ActivityID = 10

SELECT 
	ARG.ActivityRosterGroupID,
	ARG.ActivityID,
	ARG.GroupName,
	ARG.GroupDescription,
	AR.RouteName,
	AR.Distance,
	AR.Speed,
	DL.LevelName,
	R.ActivityRosterID,
	R.ResponseTypeID,
	RT.ResponseColor,
	RT.ResponseTypeName,
	U.UserID,
	U.FirstName,
	U.LastName
FROM ActivityRosterGroup ARG
	LEFT OUTER JOIN ActivityRoute AR ON ARG.ActivityRouteID = AR.ActivityRouteID
	LEFT OUTER JOIN DifficultyLevel DL ON AR.DifficultyLevelID = DL.DifficultyLevelID
	LEFT OUTER JOIN ActivityRoster R ON ARG.ActivityRosterGroupID = R.ActivityRosterGroupID
	LEFT OUTER JOIN ResponseType RT ON R.ResponseTypeID = RT.ResponseTypeID
	LEFT OUTER JOIN UserProfile U ON R.CreatedBy = U.UserID
WHERE ARG.ActivityID = @ActivityID
	AND ARG.IsDeleted = 0
ORDER BY ARG.GroupName, U.LastName