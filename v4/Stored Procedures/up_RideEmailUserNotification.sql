USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_NotificationNewRideEmailDevice
GO

CREATE PROCEDURE up_NotificationNewRideEmailDevice
	@ActivityID int,
	@Type int -- 1: device, 2: email
AS
/******************************************************************************
*  DBA Script: up_NotificationNewRideEmailDevice
*  Created By: Jason Codianne 
*  Created:    01/17/2018 
*  Schema:     dbo
*  Purpose:    List users within a specific radius of an activity.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_NotificationNewRideEmailDevice 10
-- DECLARE @ActivityID int
-- SET @ActivityID = 30834
-- ============================================================================

DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 

SELECT 
	@CurrentLocation = geography::Point(StartLat, StartLng, 4326) 
FROM Activity A
WHERE ActivityID = @ActivityID

SELECT DISTINCT 
	X.UserID, 
	X.Email,
	@ActivityID AS ActivityID
FROM ( 
	SELECT 
		P.UserID, 
		P.DefaultRadius,
		D.DeviceID,
		A.Email,
		geography::Point(HomeBaseLat, HomeBaseLng, 4326) AS GeoPt 
	FROM UserProfile P
		LEFT OUTER JOIN UserDevice D ON P.UserID = D.UserID
		INNER JOIN Accounts A ON P.UserID = A.Id
		INNER JOIN UserNotification N ON P.UserID = N.UserID
	WHERE (HomeBaseLat IS NOT NULL AND HomeBaseLng IS NOT NULL)
		AND (N.NewRideEmail = 1)
) X
WHERE GeoPt.STDistance(@CurrentLocation) < (X.DefaultRadius * @MetersPerMile) 
ORDER BY 1


