USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListRosterUserEmail
GO

CREATE PROCEDURE up_ListRosterUserEmail
	@ActivityID int
AS

/******************************************************************************
*  Script Name:  	up_ListRosterUserEmail
*  Created By:  	Jason 
*  Created Date:  	2024-03-26
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_ListRosterUserEmail 10
  
-- ============================================================================

SELECT DISTINCT * FROM ( 
	SELECT DISTINCT
		U.*
	FROM ActivityRosterGroup ARG
		LEFT OUTER JOIN ActivityRoster R ON ARG.ActivityRosterGroupID = R.ActivityRosterGroupID
		LEFT OUTER JOIN ResponseType RT ON R.ResponseTypeID = RT.ResponseTypeID
		LEFT OUTER JOIN UserProfile U ON R.CreatedBy = U.UserID
		INNER JOIN UserNotification N ON U.UserID = N.UserID
	WHERE ARG.ActivityID = @ActivityID
		AND R.ResponseTypeID <> 3 --exclude no
		AND R.ResponseTypeID IS NOT NULL
		AND ARG.IsDeleted = 0
		AND N.ActivityRosterEmail = 1
	UNION ALL
	SELECT 
		U.*
	FROM Activity A
		INNER JOIN UserProfile U ON A.UserID = U.UserID
	WHERE A.ActivityID = @ActivityID
) X