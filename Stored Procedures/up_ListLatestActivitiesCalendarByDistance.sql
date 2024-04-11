USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_ListLatestActivitiesCalendarByDistance
GO

CREATE PROCEDURE dbo.up_ListLatestActivitiesCalendarByDistance
	@UserID int,
	@Distance float,
	@ActivityTypeID int
AS
/******************************************************************************
*  DBA Script: up_ListLatestActivitiesByDistance
*  Created By: Jason Codianne 
*  Created:    01/17/2018 
*  Schema:     dbo
*  Purpose:    List activities within a specific radius of home.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListLatestActivitiesCalendarByDistance 1, 160, null
  
-- ============================================================================ 

DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 

IF @ActivityTypeID = 0
	SET @ActivityTypeID = null

IF @UserID = 0
BEGIN
	SELECT TOP 100
		X.UserID AS ActivityUserID,
		U.FirstName AS UserFirstName,
		U.LastName AS UserLastName,
		X.ActivityID, 
		UPPER(X.ActivityName) AS ActivityName,
		ROUND(GeoPt.STDistance(@CurrentLocation)/@MetersPerMile, 0) AS DistanceFromHomeBase,
		X.StartLat,
		X.StartLng,
		CASE WHEN LEN(X.StartLocation) > 35 THEN LEFT(X.StartLocation, 35) + '...' ELSE X.StartLocation END AS StartLocation,
		X.ActivityDate,
		YEAR(X.ActivityDate) AS ActivityYear,
		Month(X.ActivityDate) AS ActivityMonth,
		DATENAME(month, X.ActivityDate) AS ActivityMonthName,
		CONVERT(varchar(4), YEAR(X.ActivityDate)) + ' ' + DATENAME(month, X.ActivityDate) AS ActivityYearMonth,
		R.Distance,
		CAST(X.ActivityDate AS datetime) + CAST(X.ActivityStartTime AS datetime) AS ActivityStartDateTime,
		CASE WHEN X.ActivityStartTime = X.ActivityEndTime THEN CAST(X.ActivityDate AS datetime) + CAST(DATEADD(HH, 2, X.ActivityStartTime) AS datetime) ELSE CAST(X.ActivityDate AS datetime) + CAST(X.ActivityEndTime AS datetime) END AS ActivityEndDateTime,
		X.ActivityStartTime AS ActivityStartTimeSpan,
		FORMAT(CONVERT(datetime, X.ActivityStartTime), 'hh:mm tt') AS ActivityStartTime,
		FORMAT(CONVERT(datetime, X.ActivityEndTime), 'hh:mm tt') AS ActivityEndTime,
		REPLACE(X.ActivityNotes, '''', '') AS ActivityNotes,
		X.[Private] AS PrivateRide,
		X.ActivityTypeID,
		X.CreatedDate,
		'myMarker' AS Shape,
		RT.RouteTypeName,
		AT.ActivityTypeName,
		ISNULL(RS.RosterCount, 0) AS RosterCount,
		ISNULL(AV.ActivityView, 0) AS ActivityView
	FROM (
		SELECT *, geography::Point(StartLat, StartLng, 4326) AS GeoPt FROM Activity
	) X
	INNER JOIN ActivityRoute R ON X.ActivityID = R.ActivityID
		AND R.IsPrimary = 1
	INNER JOIN UserProfile U ON X.UserID = U.UserID
	INNER JOIN RouteType RT ON X.RouteTypeID = RT.RouteTypeID
	INNER JOIN ActivityType AT ON X.ActivityTypeID = AT.ActivityTypeID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(UserID) AS RosterCount FROM ActivityRoster GROUP BY ActivityID
	) RS ON X.ActivityID = RS.ActivityID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(ActivityID) AS ActivityView FROM ActivityView GROUP BY ActivityID
	) AV ON X.ActivityID = AV.ActivityID
	--WHERE GeoPt.STDistance(@CurrentLocation) < (@Distance * @MetersPerMile) --20 miles
	WHERE X.[Private] = 0
		AND X.ActivityTypeID = COALESCE(@ActivityTypeID, X.ActivityTypeID)
	ORDER BY ActivityDate DESC
END
ELSE
BEGIN
	SELECT @CurrentLocation = geography::STPointFromText('POINT(' + CAST(HomeBaseLng AS VARCHAR(20)) + ' ' + CAST(HomeBaseLat AS VARCHAR(20)) + ')', 4326) 
	FROM UserProfile WHERE UserID = @UserID

	SELECT TOP 100
		X.UserID AS ActivityUserID,
		U.FirstName AS UserFirstName,
		U.LastName AS UserLastName,
		X.ActivityID, 
		UPPER(X.ActivityName) AS ActivityName,
		ROUND(GeoPt.STDistance(@CurrentLocation)/@MetersPerMile, 0) AS DistanceFromHomeBase,
		X.StartLat,
		X.StartLng,
		CASE WHEN LEN(X.StartLocation) > 35 THEN LEFT(X.StartLocation, 35) + '...' ELSE X.StartLocation END AS StartLocation,
		X.ActivityDate,
		YEAR(X.ActivityDate) AS ActivityYear,
		Month(X.ActivityDate) AS ActivityMonth,
		DATENAME(month, X.ActivityDate) AS ActivityMonthName,
		CONVERT(varchar(4), YEAR(X.ActivityDate)) + ' ' + DATENAME(month, X.ActivityDate) AS ActivityYearMonth,
		R.Distance,
		CAST(X.ActivityDate AS datetime) + CAST(X.ActivityStartTime AS datetime) AS ActivityStartDateTime,
		CASE WHEN X.ActivityStartTime = X.ActivityEndTime THEN CAST(X.ActivityDate AS datetime) + CAST(DATEADD(HH, 2, X.ActivityStartTime) AS datetime) ELSE CAST(X.ActivityDate AS datetime) + CAST(X.ActivityEndTime AS datetime) END AS ActivityEndDateTime,
		X.ActivityStartTime AS ActivityStartTimeSpan,
		FORMAT(CONVERT(datetime, X.ActivityStartTime), 'hh:mm tt') AS ActivityStartTime,
		FORMAT(CONVERT(datetime, X.ActivityEndTime), 'hh:mm tt') AS ActivityEndTime,
		REPLACE(X.ActivityNotes, '''', '') AS ActivityNotes,
		X.[Private] AS PrivateRide,
		X.ActivityTypeID,
		X.CreatedDate,
		'myMarker' AS Shape,
		RT.RouteTypeName,
		AT.ActivityTypeName,
		ISNULL(RS.RosterCount, 0) AS RosterCount,
		ISNULL(AV.ActivityView, 0) AS ActivityView,
		RC.ActivityRosterID
	FROM (
		SELECT *, geography::Point(StartLat, StartLng, 4326) AS GeoPt FROM Activity
	) X
	INNER JOIN ActivityRoute R ON X.ActivityID = R.ActivityID
		AND R.IsPrimary = 1
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
		SELECT ActivityRosterID, ActivityID, UserID FROM ActivityRoster
	) RC ON X.ActivityID = RC.ActivityID
		AND @UserID = RC.UserID
	WHERE GeoPt.STDistance(@CurrentLocation) < (@Distance * @MetersPerMile)
		AND (X.[Private] = 0
		OR X.TeamID IN (SELECT DISTINCT T.TeamID FROM Team T LEFT OUTER JOIN TeamMember TM ON T.TeamID = TM.TeamID WHERE (TM.UserID = @UserID OR T.OwnerUserID = @UserID))
		OR @UserID IN (SELECT UserID FROM ActivityRoster WHERE ActivityID = X.ActivityID)
		OR @UserID = X.UserID)
		AND X.ActivityTypeID = COALESCE(@ActivityTypeID, X.ActivityTypeID)
	ORDER BY ActivityDate DESC
END


