USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_NotificationNewRideApp
GO

CREATE PROCEDURE up_NotificationNewRideApp
	@ActivityID int
AS
/******************************************************************************
*  DBA Script: up_NotificationNewRideApp
*  Created By: Jason Codianne 
*  Created:    01/17/2018 
*  Schema:     dbo
*  Purpose:    List users within a specific radius of an activity.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_NotificationNewRideApp 31691
-- DECLARE @ActivityID int
-- SET @ActivityID = 30834
-- ============================================================================

DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography
DECLARE @OwnerID int

SELECT 
	@CurrentLocation = geography::Point(StartLat, StartLng, 4326),
	@OwnerID = A.UserID
FROM Activity A
WHERE ActivityID = @ActivityID

SELECT DISTINCT 
	'Area' AS UserType,
	@ActivityID AS ActivityID,
	X.UserID,
	X.FirstName,
	X.LastName,
	X.InApp
FROM ( 
	SELECT 
		P.UserID, 
		P.FirstName,
		P.LastName,
		P.DefaultRadius,
		'App' AS InApp,
		geography::Point(HomeBaseLat, HomeBaseLng, 4326) AS GeoPt 
	FROM UserProfile P
		INNER JOIN UserNotification N ON P.UserID = N.UserID
	WHERE (HomeBaseLat IS NOT NULL AND HomeBaseLng IS NOT NULL)
		AND N.NewRideApp = 1
) X
WHERE GeoPt.STDistance(@CurrentLocation) < (X.DefaultRadius * @MetersPerMile) 
	AND X.UserID <> @OwnerID
ORDER BY 1

