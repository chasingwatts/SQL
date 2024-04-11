USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListRosterByActivity
GO

CREATE PROCEDURE up_ListRosterByGroupByRoute
	@ActivityID int,
	@RouteID int
AS

-- EXEC up_ListRosterByGroupByRoute 21, 15

SELECT
	ARG.ActivityID,
	ARG.ActivityRosterGroupID,
	ARG.GroupName,
	ARG.GroupDescription,
	R.ResponseTypeID,
	RT.ResponseTypeName,
	RT.ResponseColor,
	R.ActivityRosterID,
	R.CreatedBy AS UserID,
	U.FirstName,
	U.LastName
FROM ActivityRosterGroup ARG
	LEFT OUTER JOIN ActivityRoster R ON ARG.ActivityRosterGroupID = R.ActivityRosterGroupID
	LEFT OUTER JOIN ResponseType RT ON R.ResponseTypeID = RT.ResponseTypeID
	LEFT OUTER JOIN UserProfile U ON R.CreatedBy = U.UserID
WHERE ARG.ActivityID = @ActivityID
	AND ARG.ActivityRouteID = @RouteID
	AND ARG.IsDeleted = 0