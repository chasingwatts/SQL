USE [trovafit_aspnet]
GO

DROP PROCEDURE up_NewRideEmail
GO

CREATE PROCEDURE up_NewRideEmail
	@ActivityID int
AS
/******************************************************************************
*  DBA Script: up_NewRideEmail
*  Created By: Jason Codianne 
*  Created:    01/17/2018 
*  Schema:     dbo
*  Purpose:    List users within a specific radius of an activity.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_NewRideEmail 30843
-- DECLARE @ActivityID int
-- SET @ActivityID = 30834
-- ============================================================================

DECLARE @ActivityName varchar(200)
DECLARE @ActivityDate date
DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 
DECLARE @RideCreator varchar(500)
DECLARE @IsCommunity bit

SELECT @CurrentLocation = geography::STPointFromText('POINT(' + CAST(StartLng AS VARCHAR(20)) + ' ' + CAST(StartLat AS VARCHAR(20)) + ')', 4326) FROM Activity WHERE ActivityID = @ActivityID
SELECT
	@ActivityName = A.ActivityName, 
	@ActivityDate = A.ActivityDate,
	@RideCreator = U.FirstName + ' ' + U.LastName,
	@IsCommunity = A.IsCommunity
FROM Activity A 
	INNER JOIN UserProfile U ON A.UserID = U.UserID
WHERE A.ActivityID = @ActivityID

--SELECT @CurrentLocation
--SELECT * FROM Activity WHERE ActivityID = @ActivityID 

SELECT DISTINCT 
	X.UserID, 
	X.DefaultRadius, 
	X.Email,
	@ActivityID AS ActivityID,
	@ActivityName AS ActivityName,
	@ActivityDate AS ActivityDate,
	@RideCreator AS RideCreator,
	@IsCommunity AS IsCommunity
FROM ( 
	SELECT 
		P.UserID, 
		P.DefaultRadius,
		D.DeviceID,
		U.Email,
		geography::Point(HomeBaseLat, HomeBaseLng, 4326) AS GeoPt 
	FROM UserProfile P
		LEFT OUTER JOIN UserDevice D ON P.UserID = D.UserID
		INNER JOIN AspNetUsers U ON P.UserID = U.Id
		INNER JOIN UserNotification N ON P.UserID = N.UserID
	WHERE (HomeBaseLat IS NOT NULL AND HomeBaseLng IS NOT NULL)
		AND (N.NewRideEmail = 1)
) X
WHERE GeoPt.STDistance(@CurrentLocation) < (X.DefaultRadius * @MetersPerMile) --20 miles
ORDER BY 1

 