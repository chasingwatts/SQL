USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS up_NewRideAppNotification
GO

CREATE PROCEDURE up_NewRideAppNotification
	@ActivityID int
AS
/******************************************************************************
*  DBA Script: up_NewRideAppNotification
*  Created By: Jason Codianne 
*  Created:    01/17/2018 
*  Schema:     dbo
*  Purpose:    List activities within a specific radius of home.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_NewRideAppNotification 30843
  
-- ============================================================================

--DECLARE @ActivityID int
--SET @ActivityID = 2318

DECLARE @ActivityName varchar(200)
DECLARE @ActivityDate date
DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 


SELECT @CurrentLocation = geography::STPointFromText('POINT(' + CAST(StartLng AS VARCHAR(20)) + ' ' + CAST(StartLat AS VARCHAR(20)) + ')', 4326) FROM Activity WHERE ActivityID = @ActivityID
SELECT @ActivityName = ActivityName, @ActivityDate = ActivityDate FROM Activity WHERE ActivityID = @ActivityID

--SELECT @CurrentLocation
--SELECT * FROM Activity WHERE ActivityID = @ActivityID 

SELECT DISTINCT 
	X.UserID, X.DefaultRadius, 
	X.Email,
	@ActivityID AS ActivityID,
	@ActivityName AS ActivityName,
	@ActivityDate AS ActivityDate
FROM ( 
	SELECT 
		P.UserID, 
		P.DefaultRadius,
		U.Email,
		geography::Point(HomeBaseLat, HomeBaseLng, 4326) AS GeoPt 
	FROM UserProfile P
		INNER JOIN AspNetUsers U ON P.UserID = U.Id
		INNER JOIN UserNotification N ON P.UserID = N.UserID
	WHERE HomeBaseLat IS NOT NULL AND HomeBaseLng IS NOT NULL
		AND (N.NewRideApp = 1)
) X
WHERE GeoPt.STDistance(@CurrentLocation) < (X.DefaultRadius * @MetersPerMile)
