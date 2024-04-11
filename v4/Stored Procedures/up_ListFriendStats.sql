USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListFriendStats
GO

CREATE PROCEDURE up_ListFriendStats
	@UserID int
AS

/******************************************************************************
*  Script Name:  	up_ListFriendStats
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2024-03-29
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_ListFriendStats 1
  
-- ============================================================================

SELECT
	R.CreatedBy AS UserID,
	COUNT(R.ActivityRosterID) AS RideCount,
	CONVERT(int, SUM(ROUND(RTE.Distance, 0))) AS RideDistance,
	COUNT(F.FriendCount) AS FriendCount
FROM ActivityRosterGroup ARG
	LEFT OUTER JOIN ActivityRoute RTE ON ARG.ActivityRouteID = RTE.ActivityRouteID
	LEFT OUTER JOIN ActivityRoster R ON ARG.ActivityRosterGroupID = R.ActivityRosterGroupID
	LEFT OUTER JOIN ResponseType RT ON R.ResponseTypeID = RT.ResponseTypeID
	LEFT OUTER JOIN UserProfile U ON R.CreatedBy = U.UserID
	LEFT OUTER JOIN (
		SELECT UserID, COUNT(FollowingID) AS FriendCount FROM UserFollowing
		WHERE IsConfirmed = 1
		GROUP BY UserID
	) F ON R.CreatedBy = F.UserID
WHERE R.CreatedBy = @UserID
	AND ARG.IsDeleted = 0
GROUP BY R.CreatedBy

