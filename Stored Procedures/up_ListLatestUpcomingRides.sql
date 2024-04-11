USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_ListLatestUpcomingRides
GO

CREATE PROCEDURE dbo.up_ListLatestUpcomingRides
	@UserID int,
	@Distance float
AS
/******************************************************************************
*  DBA Script: up_ListLatestUpcomingRides
*  Created By: Jason Codianne 
*  Created:    01/17/2018 
*  Schema:     dbo
*  Purpose:    List activities within a specific radius of home.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListLatestUpcomingRides 1, 50
  
-- ============================================================================
--DECLARE @UserID int
--DECLARE @Distance float

--SET @UserID = 1
--SET @Distance = 50

DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 
SELECT @CurrentLocation = geography::STPointFromText('POINT(' + CAST(HomeBaseLng AS VARCHAR(20)) + ' ' + CAST(HomeBaseLat AS VARCHAR(20)) + ')', 4326) 
FROM UserProfile WHERE UserID = @UserID

--SELECT @CurrentLocation

SELECT
	X.ActivityID, 
	X.ActivityName,
	X.ActivityDate,
	X.ActivityStartTime
FROM (
	SELECT *, geography::Point(StartLat, StartLng, 4326) AS GeoPt FROM Activity
) X
	--INNER JOIN UserProfile U ON X.UserID = U.UserID
	--INNER JOIN RouteType RT ON X.RouteTypeID = RT.RouteTypeID
	--INNER JOIN ActivityType T ON X.ActivityTypeID = T.ActivityTypeID
	--INNER JOIN SpeedRange SR ON X.SpeedRangeID = SR.SpeedRangeID
WHERE GeoPt.STDistance(@CurrentLocation) < (@Distance * @MetersPerMile) --20 miles
	AND CONVERT(datetime, X.ActivityDate) + CONVERT(datetime, X.ActivityStartTime) > GETDATE()
	AND CONVERT(datetime, X.ActivityDate) + CONVERT(datetime, X.ActivityStartTime) <= DATEADD(D, 7, GETDATE())
	AND X.Private = 0
ORDER BY X.ActivityDate 
