DROP PROCEDURE IF EXISTS up_ListUsersRideTogether
GO

CREATE PROCEDURE up_ListUsersRideTogether
	@UserID int
AS

/******************************************************************************
*  Script Name:  	up_ListUsersRideTogether
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2023-03-31
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_ListUsersRideTogether 1
  
-- ============================================================================

WITH cRideFriends AS (
SELECT TOP 20
		u1.UserID AS User1ID,
		CONCAT(u1.FirstName, ' ', u1.LastName) AS User1FullName,
		u2.UserID AS User2ID,
		CONCAT(u2.FirstName, ' ', u2.LastName) AS User2FullName,
		COUNT(*) AS NumActivitiesTogether,
		MAX(A.ActivityID) AS LastRideID
	FROM ActivityRoster ar1
		JOIN ActivityRoster ar2 ON ar1.ActivityID = ar2.ActivityID 
			AND ar1.UserID != ar2.UserID
		JOIN UserProfile u1 ON ar1.UserID = u1.UserID
		JOIN UserProfile u2 ON ar2.UserID = u2.UserID
		JOIN Activity A ON ar1.ActivityID = A.ActivityID
	WHERE ar1.ResponseTypeID IN (1, 3)
		AND ar2.ResponseTypeID IN (1, 3)
		AND u1.UserID = @UserID
	GROUP BY 
		u1.UserID,
		CONCAT(u1.FirstName, ' ', u1.LastName),
		u2.UserID,
		CONCAT(u2.FirstName, ' ', u2.LastName)
	ORDER BY NumActivitiesTogether DESC
)

SELECT 
	ROW_NUMBER() OVER(ORDER BY X.User1ID) AS RideTogetherID,
	X.User1ID, 
	X.User1FullName, 
	X.User2ID, 
	X.User2FullName, 
	X.NumActivitiesTogether, 
	X.LastRideID,
	A.ActivityName,
	A.ActivityDate
FROM cRideFriends X
INNER JOIN Activity A ON X.LastRideID = A.ActivityID
ORDER BY X.NumActivitiesTogether DESC