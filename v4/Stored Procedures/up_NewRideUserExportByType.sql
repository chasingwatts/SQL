--USE [trovafit_aspnet]
--GO

--DROP PROCEDURE up_NewRideNotification
--GO

--CREATE PROCEDURE up_NewRideNotification
--	@ActivityID int
--AS
/******************************************************************************
*  DBA Script: up_NewRideEmail
*  Created By: Jason Codianne 
*  Created:    01/17/2018 
*  Schema:     dbo
*  Purpose:    List users in radius of activity.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_NewRideNotification 2218
  
-- ============================================================================

DECLARE @NotificationType int  -- 1 = email, 2 = device
DECLARE @ActivityID int
SET @ActivityID = 6
SET @NotificationType = 1

DECLARE @ActivityName varchar(200)
DECLARE @ActivityDate date
DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 


SELECT @CurrentLocation = geography::STPointFromText('POINT(' + CAST(StartLng AS VARCHAR(20)) + ' ' + CAST(StartLat AS VARCHAR(20)) + ')', 4326) FROM Activity WHERE ActivityID = @ActivityID
SELECT @ActivityName = ActivityName, @ActivityDate = ActivityDate FROM Activity WHERE ActivityID = @ActivityID

SELECT DISTINCT 
	X.UserID, 
	X.DefaultRadius, 
	X.DeviceID, 
	X.Email,
	@ActivityID AS ActivityID,
	@ActivityName AS ActivityName,
	@ActivityDate AS ActivityDate,
	GeoPt.STDistance(@CurrentLocation) AS CurrentLocation,
	X.DefaultRadius,
	X.DefaultRadius * @MetersPerMile AS Radius
FROM ( 
	SELECT 
		P.UserID, 
		P.DefaultRadius,
		D.DeviceID,
		U.Email,
		geography::Point(HomeBaseLat, HomeBaseLng, 4326) AS GeoPt 
	FROM UserProfile P
		LEFT OUTER JOIN UserDevice D ON P.UserID = D.UserID
		INNER JOIN Accounts U ON P.UserID = U.Id
		INNER JOIN UserNotification N ON P.UserID = N.UserID
	WHERE N.NewRideApp = 1
) X
WHERE GeoPt.STDistance(@CurrentLocation) < (X.DefaultRadius * @MetersPerMile) 
