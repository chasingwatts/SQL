USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListRosterByActivity
GO

CREATE PROCEDURE up_ListRosterByActivity
	@ActivityID int
AS

-- EXEC up_ListRosterByActivity 10

SELECT
	R.ActivityID,
	R.ResponseTypeID,
	R.GroupLevel,
	RT.ResponseTypeName,
	RT.ResponseColor,
	R.ActivityRosterID,
	R.CreatedBy AS UserID,
	U.FirstName,
	U.LastName
FROM ActivityRoster R 
	LEFT OUTER JOIN ResponseType RT ON R.ResponseTypeID = RT.ResponseTypeID
	LEFT OUTER JOIN UserProfile U ON R.CreatedBy = U.UserID
WHERE R.ActivityID = @ActivityID