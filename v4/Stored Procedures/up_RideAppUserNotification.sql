USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_RideAppUserNotification
GO

CREATE PROCEDURE up_RideAppUserNotification
	@ActivityID int
AS
/******************************************************************************
*  DBA Script: up_RideAppUserNotification
*  Created By: Jason Codianne 
*  Created:    03/26/2024 
*  Schema:     dbo
*  Purpose:    List activities within a specific radius of home.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_RideAppUserNotification 10
  
-- ============================================================================

--DECLARE @ActivityID int
--SET @ActivityID = 10

DECLARE @ActivityName varchar(200)
DECLARE @ActivityDate date
DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 


SELECT 
	@ActivityName = ActivityName, 
	@ActivityDate = ActivityDate,
	@CurrentLocation = geography::Point(StartLat, StartLng, 4326) 
FROM Activity 
WHERE ActivityID = @ActivityID

SELECT DISTINCT 
	X.UserID, 
	X.DefaultRadius, 
	X.Email,
	@ActivityID AS ActivityID,
	@ActivityName AS ActivityName,
	@ActivityDate AS ActivityDate
FROM ( 
	SELECT 
		P.UserID, 
		P.DefaultRadius,
		A.Email,
		geography::Point(HomeBaseLat, HomeBaseLng, 4326) AS GeoPt 
	FROM UserProfile P
		INNER JOIN Accounts A ON P.UserID = A.Id
		INNER JOIN UserNotification N ON P.UserID = N.UserID
	WHERE HomeBaseLat IS NOT NULL AND HomeBaseLng IS NOT NULL
		AND (N.NewRideApp = 1)
) X
WHERE GeoPt.STDistance(@CurrentLocation) < (X.DefaultRadius * @MetersPerMile)



