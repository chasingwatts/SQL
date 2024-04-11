USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS up_ListShopUserLocations
GO

CREATE PROCEDURE up_ListShopUserLocations
	@OwnerID int,
	@StartDate date,
	@EndDate date
AS
/******************************************************************************
*  Script Name:  	up_ListShopUserLocations
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2021-05-28
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_ListShopUserLocations 1, '12/01/2022', '01/28/2023'
  
-- ============================================================================

SELECT
	DISTINCT 
	U.HomeBaseZip,
	U.HomeBaseLat,
	U.HomeBaseLng,
	CONVERT(varchar, U.HomeBaseLat) + ',' + CONVERT(varchar, U.HomeBaseLng) AS FieldLocation,
	COUNT(R.UserID) AS RosterCount
FROM Activity A
	INNER JOIN ActivityRoster R ON A.ActivityID = R.ActivityID
	INNER JOIN UserProfile U ON R.UserID = U.UserID
WHERE A.UserID = @OwnerID
	AND A.ActivityDate BETWEEN @StartDate AND @EndDate
GROUP BY 
	U.HomeBaseZip,
	U.HomeBaseLat,
	U.HomeBaseLng