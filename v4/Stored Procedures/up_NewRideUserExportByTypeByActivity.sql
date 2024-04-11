USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_NewRideUserExportByTypeByActivity
GO

CREATE PROCEDURE up_NewRideUserExportByTypeByActivity
	@NotificationType int,
	@ActivityID int
AS
/******************************************************************************
*  DBA Script: up_NewRideUserExportByTypeByActivity
*  Created By: Jason Codianne 
*  Created:    01/17/2018 
*  Schema:     dbo
*  Purpose:    List users in radius of activity.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_NewRideUserExportByTypeByActivity 1, 6

-- DECLARE @NotificationType int  -- 1 = email, 2 = device
-- DECLARE @ActivityID int
-- SET @ActivityID = 6
-- SET @NotificationType = 1
-- ============================================================================

DECLARE @ActivityName varchar(200)
DECLARE @ActivityDate date
DECLARE @CurrentLocation geography; 

SELECT 
	@CurrentLocation = geography::STPointFromText('POINT(' + CAST(StartLng AS VARCHAR(20)) + ' ' + CAST(StartLat AS VARCHAR(20)) + ')', 4326),
	@ActivityName = ActivityName, 
	@ActivityDate = ActivityDate
FROM Activity 
WHERE ActivityID = @ActivityID

SELECT DISTINCT 
	X.UserID,  
	X.DeviceID, 
	X.Email,
	@ActivityID AS ActivityID,
	@ActivityName AS ActivityName,
	@ActivityDate AS ActivityDate,
	GeoPt.STDistance(@CurrentLocation) AS CurrentLocation
INTO #UserExport
FROM ( 
	SELECT 
		P.UserID, 
		P.DefaultRadius,
		D.DeviceID,
		U.Email,
		geography::Point(HomeBaseLat, HomeBaseLng, 4326) AS GeoPt 
	FROM UserProfile P
		LEFT OUTER JOIN UserDevice D ON P.UserID = D.UserID
		LEFT OUTER JOIN Accounts U ON P.UserID = U.Id
		INNER JOIN UserNotification N ON P.UserID = N.UserID
	WHERE N.NewRideApp = 1
) X
WHERE GeoPt.STDistance(@CurrentLocation) < (X.DefaultRadius * 1609.344) 

IF @NotificationType = 1
	BEGIN
		SELECT DISTINCT UserID, Email, ActivityID, ActivityName, ActivityDate FROM #UserExport
	END
ELSE
	BEGIN
		SELECT DISTINCT UserID, DeviceID, ActivityID, ActivityName, ActivityDate FROM #UserExport
	END

DROP TABLE #UserExport