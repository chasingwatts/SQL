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
	COUNT(RS.ActivityRosterID) AS RideCount,
	CONVERT(int, SUM(ROUND(R.Distance, 0))) AS RideDistance,
	MAX(F.FriendCount) AS FriendCount
FROM Activity A	
	LEFT OUTER JOIN ActivityRoute R ON A.ActivityID = R.ActivityID
	LEFT OUTER JOIN ActivityRoster RS ON A.ActivityID = RS.ActivityID
	LEFT OUTER JOIN ResponseType RT ON RS.ResponseTypeID = RT.ResponseTypeID
	LEFT OUTER JOIN UserProfile U ON R.CreatedBy = U.UserID
	LEFT OUTER JOIN (
		SELECT UserID, COUNT(FollowingID) AS FriendCount FROM UserFollowing
		WHERE IsConfirmed = 1
		GROUP BY UserID
	) F ON R.CreatedBy = F.UserID
WHERE R.CreatedBy = @UserID
	AND A.IsDeleted = 0
GROUP BY R.CreatedBy

