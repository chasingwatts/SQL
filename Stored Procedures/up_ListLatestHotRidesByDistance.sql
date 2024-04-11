USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_ListLatestHotRidesByDistance
GO

CREATE PROCEDURE dbo.up_ListLatestHotRidesByDistance
	@UserID int,
	@Distance float,
	@HotCount int = 10
AS
/******************************************************************************
*  DBA Script: up_ListLatestHotRidesByDistance
*  Created By: Jason Codianne 
*  Created:    01/17/2018 
*  Schema:     dbo
*  Purpose:    List activities within a specific radius of home.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListLatestHotRidesByDistance 1, 160, 1
  
-- ============================================================================


DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 
SELECT @CurrentLocation = geography::STPointFromText('POINT(' + CAST(HomeBaseLng AS VARCHAR(20)) + ' ' + CAST(HomeBaseLat AS VARCHAR(20)) + ')', 4326) 
FROM UserProfile WHERE UserID = @UserID

--SELECT @CurrentLocation

SELECT TOP 4
	X.UserID AS ActivityUserID,
	U.FirstName AS UserFirstName,
	U.LastName AS UserLastName,
	X.ActivityID, 
	REPLACE(X.ActivityName, '''', '') AS ActivityName,
	ROUND(GeoPt.STDistance(@CurrentLocation)/@MetersPerMile, 0) AS DistanceFromHomeBase,
	X.StartLat,
	X.StartLng,
	CASE WHEN LEN(X.StartLocation) > 35 THEN LEFT(X.StartLocation, 35) + '...' ELSE X.StartLocation END AS StartLocation,
	X.ActivityDate,
	X.Distance,
	X.[Private],
	FORMAT(CONVERT(datetime, X.ActivityStartTime), 'hh:mm tt') AS ActivityStartTime,
	FORMAT(CONVERT(datetime, X.ActivityEndTime), 'hh:mm tt') AS ActivityEndTime,
	REPLACE(X.ActivityNotes, '''', '') AS ActivityNotes,
	X.CreatedDate,
	'myMarker' AS Shape,
	RT.RouteTypeName,
	AT.ActivityTypeName,
	ISNULL(RS.RosterCount, 0) AS RosterCount,
	ISNULL(AV.ActivityView, 0) AS ActivityView,
	ViewStatus = 
		CASE
			WHEN X.[Private] = 1 AND X.TeamID IS NOT NULL THEN 'Private Team Ride'
			WHEN X.[Private] = 0 AND X.TeamID IS NOT NULL THEN 'Public Team Ride'
			WHEN X.[Private] = 1 AND X.TeamID IS NULL THEN 'Private Ride'
			WHEN X.[Private] = 0 AND X.TeamID IS NULL THEN 'Public Ride'
		END,
	ShowQuickResponse = CONVERT(bit, CASE WHEN UR.ResponseTypeID IS NOT NULL THEN 0 ELSE 1 END)
FROM (
	SELECT *, geography::Point(StartLat, StartLng, 4326) AS GeoPt FROM Activity
) X
INNER JOIN UserProfile U ON X.UserID = U.UserID
INNER JOIN RouteType RT ON X.RouteTypeID = RT.RouteTypeID
INNER JOIN ActivityType AT ON X.ActivityTypeID = AT.ActivityTypeID
LEFT OUTER JOIN (
	SELECT ActivityID, COUNT(UserID) AS RosterCount FROM ActivityRoster GROUP BY ActivityID
) RS ON X.ActivityID = RS.ActivityID
LEFT OUTER JOIN (
	SELECT ActivityID, COUNT(ActivityID) AS ActivityView FROM ActivityView GROUP BY ActivityID
) AV ON X.ActivityID = AV.ActivityID
LEFT OUTER JOIN (
	SELECT ActivityID, UserID, ResponseTypeID FROM ActivityRoster
) UR ON X.ActivityID = UR.ActivityID
	AND UR.UserID = @UserID
WHERE CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) >= GETDATE()
	AND GeoPt.STDistance(@CurrentLocation) < (@Distance * @MetersPerMile) --20 miles
	--AND RosterCount > @HotCount
	AND (X.[Private] = 0
		OR X.TeamID IN (SELECT DISTINCT T.TeamID FROM Team T LEFT OUTER JOIN TeamMember TM ON T.TeamID = TM.TeamID WHERE (TM.UserID = @UserID OR T.OwnerUserID = @UserID)))
	AND ActivityView > 0
ORDER BY ActivityView DESC 