USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListHubStatsUserLocations
GO

CREATE PROCEDURE up_ListHubStatsUserLocations
	@HubID int
AS
/******************************************************************************
*  Script Name:  	up_ListHubStatsUserLocations
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2021-05-28
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_ListHubStatsUserLocations 9
  
-- ============================================================================

SELECT
	DISTINCT 
	U.UserID,
	U.FirstName,
	U.LastName,
	U.HomeBaseCity,
	U.HomeBaseState,
	U.HomeBaseLat,
	U.HomeBaseLng,
	CONVERT(varchar, U.HomeBaseLat) + ',' + CONVERT(varchar, U.HomeBaseLng) AS FieldLocation
FROM Activity A
	INNER JOIN ActivityRoster R ON A.ActivityID = R.ActivityID
	INNER JOIN UserProfile U ON R.CreatedBy = U.UserID
WHERE A.TeamID = @HubID

GO


