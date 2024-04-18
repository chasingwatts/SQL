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
-- EXEC up_NotificationNewRideEmailDevice 10, 2
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
	'Area' AS UserType,
	@ActivityID AS ActivityID,
	X.UserID,
	X.FirstName,
	X.LastName,
	CASE @Type WHEN 1 THEN X.DeviceID WHEN 2 THEN X.Email END AS EmailDevice,
	CASE @Type WHEN 1 THEN 'Device' WHEN 2 THEN 'Email' END AS EmailDeviceType
FROM ( 
	SELECT 
		P.UserID, 
		P.FirstName,
		P.LastName,
		P.DefaultRadius,
		D.DeviceID,
		AA.Email,
		geography::Point(HomeBaseLat, HomeBaseLng, 4326) AS GeoPt 
	FROM UserProfile P
		LEFT JOIN UserDevice D ON P.UserID = D.UserID AND @Type = 1
		LEFT JOIN Accounts AA ON P.UserID = AA.Id AND @Type = 2
		INNER JOIN UserNotification N ON P.UserID = N.UserID
	WHERE (HomeBaseLat IS NOT NULL AND HomeBaseLng IS NOT NULL)
		AND (N.NewRideEmail = 1 AND N.NewRideApp = 1)
) X
WHERE GeoPt.STDistance(@CurrentLocation) < (X.DefaultRadius * @MetersPerMile) 
ORDER BY 1


