USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS dbo.up_NewFeelerNotification
GO

CREATE PROCEDURE dbo.up_NewFeelerNotification
	@FeelerID int
AS
/******************************************************************************
*  DBA Script: up_NewFeelerNotification
*  Created By: Jason Codianne 
*  Created:    01/17/2018 
*  Schema:     dbo
*  Purpose:    
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_NewFeelerNotification 16
  
-- ============================================================================

--DECLARE @FeelerID int
--SET @FeelerID = 11

DECLARE @FeelerTitle varchar(200)
DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 


SELECT @CurrentLocation = geography::STPointFromText('POINT(' + CAST(FeelerLng AS VARCHAR(20)) + ' ' + CAST(FeelerLat AS VARCHAR(20)) + ')', 4326) FROM ActivityFeeler WHERE ActivityFeelerID = @FeelerID
SELECT @FeelerTitle = FeelerTitle FROM ActivityFeeler WHERE ActivityFeelerID = @FeelerID

SELECT DISTINCT 
	X.UserID, X.DefaultRadius, X.DeviceID, X.Email,
	@FeelerID AS ActivityFeelerID,
	@FeelerTitle AS FeelerTitle
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
		AND (N.NewRideApp = 1)
		AND (D.DeviceID IS NOT NULL AND D.DeviceID <> '')
) X
WHERE GeoPt.STDistance(@CurrentLocation) < (X.DefaultRadius * @MetersPerMile) --20 miles
