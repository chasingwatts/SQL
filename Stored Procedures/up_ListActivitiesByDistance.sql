USE [trovafit_aspnet]
GO

DROP PROCEDURE up_ListActivitiesByDistance
GO

CREATE PROCEDURE up_ListActivitiesByDistance
	@UserID int,
	@Distance float
AS
/******************************************************************************
*  DBA Script: up_ListActivitiesByDistance
*  Created By: Jason Codianne 
*  Created:    01/17/2018 
*  Schema:     dbo
*  Purpose:    List activities within a specific radius of home.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListActivitiesByDistance 1, 160
  
-- ============================================================================


DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 
SELECT @CurrentLocation = geography::STPointFromText('POINT(' + CAST(HomeBaseLng AS VARCHAR(20)) + ' ' + CAST(HomeBaseLat AS VARCHAR(20)) + ')', 4326) 
FROM UserProfile WHERE UserID = @UserID

--SELECT @CurrentLocation

SELECT 
	X.ActivityID, 
	REPLACE(X.ActivityName, '''', '') AS ActivityName,
	ROUND(GeoPt.STDistance(@CurrentLocation)/@MetersPerMile, 0) AS DistanceFromHomeBase,
	X.StartLat,
	X.StartLng,
	X.StartLocation,
	X.StartName,
	X.StartAddress,
	X.StartCity,
	X.StartState,
	X.StartCountry,
	X.ActivityDate,
	R.Distance,
	FORMAT(CONVERT(datetime, X.ActivityStartTime), 'hh:mm tt') AS ActivityStartTime,
	FORMAT(CONVERT(datetime, X.ActivityEndTime), 'hh:mm tt') AS ActivityEndTime,
	REPLACE(X.ActivityNotes, '''', '') AS ActivityNotes,
	X.CreatedDate
FROM (
SELECT *, geography::Point(StartLat, StartLng, 4326) AS GeoPt FROM Activity
) X
INNER JOIN ActivityRoute R ON X.ActivityID = R.ActivityID
	AND R.IsPrimary = 1
WHERE ActivityDate >= GETDATE()
	--AND GeoPt.STDistance(@CurrentLocation) < (@Distance * @MetersPerMile) --20 miles
	AND Private = 0
ORDER BY ActivityDate 
