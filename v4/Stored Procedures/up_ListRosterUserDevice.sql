USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListRosterUserDevice
GO

CREATE PROCEDURE up_ListRosterUserDevice
	@ActivityID int
AS

/******************************************************************************
*  Script Name:  	up_ListRosterUserDevice
*  Created By:  	Jason 
*  Created Date:  	2024-03-26
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_ListRosterUserDevice 10
  
-- ============================================================================

SELECT DISTINCT * FROM ( 
	SELECT DISTINCT
		D.*
	FROM ActivityRosterGroup ARG
		LEFT OUTER JOIN ActivityRoster R ON ARG.ActivityRosterGroupID = R.ActivityRosterGroupID
		LEFT OUTER JOIN ResponseType RT ON R.ResponseTypeID = RT.ResponseTypeID
		LEFT OUTER JOIN UserProfile U ON R.CreatedBy = U.UserID
		LEFT OUTER JOIN UserDevice D ON U.UserID = D.UserID
		INNER JOIN UserNotification N ON U.UserID = N.UserID
	WHERE ARG.ActivityID = @ActivityID
		AND R.ResponseTypeID <> 3 --exclude no
		AND R.ResponseTypeID IS NOT NULL
		AND ARG.IsDeleted = 0
		AND D.DeviceID IS NOT NULL
		AND N.ActivityRosterApp = 1
	UNION ALL
	SELECT 
		D.*
	FROM Activity A
		INNER JOIN UserDevice D ON A.UserID = D.UserID
	WHERE A.ActivityID = @ActivityID
) X