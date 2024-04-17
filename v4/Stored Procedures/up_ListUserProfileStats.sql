USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListUserProfileStats
GO

CREATE PROCEDURE up_ListUserProfileStats
	@UserID int
AS

/******************************************************************************
*  Script Name:  	up_ListUserProfileStats
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2024-04-14
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_ListUserProfileStats 1
  
-- ============================================================================

SELECT
	R.CreatedBy AS UserID,
	CONVERT(int, ROUND(SUM(AR.Distance), 0)) AS UserDistance,
	CONVERT(int, ROUND(AVG(AR.Speed), 0)) AS UserAvgSpeed,
	COUNT(R.ActivityRosterID) AS UserRideCount
FROM Activity A
	INNER JOIN ActivityRoster R ON A.ActivityID = R.ActivityID
	INNER JOIN ActivityRoute AR ON A.ActivityID = AR.ActivityID
WHERE R.CreatedBy = @UserID
	AND R.ResponseTypeID <> 3 --no
GROUP BY R.CreatedBy