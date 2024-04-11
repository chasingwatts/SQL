USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_RidePushUserNotification
GO

CREATE PROCEDURE up_RidePushUserNotification
	@ActivityID int
AS
/******************************************************************************
*  DBA Script: up_RidePushUserNotification
*  Created By: Jason Codianne 
*  Created:    01/17/2018 
*  Schema:     dbo
*  Purpose:    List activities within a specific radius of home.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_RidePushUserNotification 10
  
-- ============================================================================

--DECLARE @ActivityID int
--SET @ActivityID = 2318

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
	X.DeviceID, 
	@ActivityID AS ActivityID,
	@ActivityName AS ActivityName,
	@ActivityDate AS ActivityDate
FROM ( 
	SELECT 
		P.UserID, 
		P.DefaultRadius,
		D.DeviceID,
		geography::Point(HomeBaseLat, HomeBaseLng, 4326) AS GeoPt 
	FROM UserProfile P
		LEFT OUTER JOIN UserDevice D ON P.UserID = D.UserID
		INNER JOIN UserNotification N ON P.UserID = N.UserID
	WHERE HomeBaseLat IS NOT NULL AND HomeBaseLng IS NOT NULL
		AND (N.NewRideApp = 1)
) X
WHERE GeoPt.STDistance(@CurrentLocation) < (X.DefaultRadius * @MetersPerMile) --20 miles
GO


