USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_CheckUserInRide
GO

CREATE PROCEDURE up_CheckUserInRide
	@ActivityID int,
	@UserID int
AS

/******************************************************************************
*  Script Name:  	up_CheckUserInRide
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2024-05-31
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_CheckUserInRide 449, 33
  
-- ============================================================================

SELECT CONVERT(int, CASE WHEN SUM(UserID) > 0 THEN 1 ELSE 0 END) AS IsInRide 
FROM ( 
	SELECT
		'Invite' AS UserSource,
		A.ActivityID,
		ISNULL(I.InviteUserID, 0) AS UserID
	FROM Activity A
		LEFT OUTER JOIN ActivityInvite I ON A.ActivityID = I.ActivityID
	WHERE A.ActivityID = @ActivityID

	UNION ALL

	SELECT
		'Roster' AS UserSource,
		A.ActivityID,
		ISNULL(R.CreatedBy, 0) AS UserID
	FROM Activity A
		LEFT OUTER JOIN ActivityRoster R ON A.ActivityID = R.ActivityID
	WHERE A.ActivityID = @ActivityID

	UNION ALL

	SELECT 
		'Activity' AS UserSource,
		A.ActivityID,
		ISNULL(A.UserID, 0)
	FROM Activity A
	WHERE A.ActivityID = @ActivityID

	UNION ALL 

	SELECT 
		'Admin' AS UserSource,
		@ActivityID AS ActivityID,
		CASE WHEN [Role] = 0 THEN 33 ELSE 0 END AS UserID
	FROM Accounts
	WHERE id = @UserID
) X
WHERE X.UserID = @UserID