USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS up_ListActivitiesByDistance
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
-- EXEC up_ListActivitiesByDistance 1, 30
  
-- ============================================================================


DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 
SELECT @CurrentLocation = geography::STPointFromText('POINT(' + CAST(HomeBaseLng AS VARCHAR(20)) + ' ' + CAST(HomeBaseLat AS VARCHAR(20)) + ')', 4326) FROM UserProfile WHERE UserID = 1

--SELECT @CurrentLocation

SELECT ActivityID, ActivityName, StartLocation, ROUND(GeoPt.STDistance(@CurrentLocation)/@MetersPerMile, 0) AS Distance 
FROM (
SELECT *, geography::Point(StartLat, StartLng, 4326) AS GeoPt FROM Activity
) X
WHERE GeoPt.STDistance(@CurrentLocation) < (@Distance * @MetersPerMile) --20 miles


--ALTER TABLE UserProfile
--ADD [GeoLocation] GEOGRAPHY
--GO

--UPDATE UserProfile
--SET GeoLocation = geography::STPointFromText('POINT(' + CAST(HomeBaseLng AS VARCHAR(20)) + ' ' + 
--                    CAST(HomeBaseLat AS VARCHAR(20)) + ')', 4326)
--				WHERE HomeBaseLat IS NOT NULL
--GO

--SELECT * FROM UserProfile

--Select * from sys.spatial_reference_systems
