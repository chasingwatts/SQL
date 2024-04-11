USE [trovafit_aspnet]
GO

DROP PROCEDURE up_ListLatestActivitiesByDistance
GO

CREATE PROCEDURE up_ListLatestActivitiesByDistance
	@UserID int,
	@Distance float
AS

-- ============================================================================
-- Testing Parms
-- EXEC up_ListLatestActivitiesByDistance 1, 100

 --DECLARE @UserID int
 --DECLARE @Distance int
 --SET @UserID = 1
 --SET @Distance = 200
-- ============================================================================

SET NOCOUNT ON

DECLARE @UOM int
DECLARE @UOMName varchar(10)
DECLARE @UOMFactor float
DECLARE @Radius float
DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 

SELECT 
	@UOM = U.UnitOfMeasureID, 
	@UOMName = M.UnitOfMeasure,
	@UOMFactor = M.MeasureFactor,
	@CurrentLocation = geography::STPointFromText('POINT(' + CAST(U.HomeBaseLng AS VARCHAR(20)) + ' ' + CAST(U.HomeBaseLat AS VARCHAR(20)) + ')', 4326) 
FROM UserProfile U 
	INNER JOIN UnitOfMeasure M ON U.UnitOfMeasureID = M.UnitOfMeasureID
WHERE U.UserID = @UserID

--set conversion to meters
IF @UOM = 3 --km
BEGIN
	SET @Radius = @Distance * 1000
END
ELSE --mi
BEGIN
	SET @Radius = @Distance * @MetersPerMile
END

SELECT
	X.UserID AS ActivityUserID,
	U.FirstName AS UserFirstName,
	U.LastName AS UserLastName,
	X.ActivityID, 
	X.ActivityName AS ActivityName,
	ROUND(GeoPt.STDistance(@CurrentLocation)/@MetersPerMile, 0) AS DistanceFromHomeBase,
	X.StartLat,
	X.StartLng,
	--CASE WHEN LEN(X.StartLocation) > 35 THEN LEFT(X.StartLocation, 35) + '...' ELSE X.StartLocation END AS StartLocation,
	X.StartLocation,
	X.StartName,
	X.StartAddress,
	X.StartCity,
	X.StartState,
	X.StartCountry,
	X.ActivityDate,
	YEAR(X.ActivityDate) AS ActivityYear,
	Month(X.ActivityDate) AS ActivityMonth,
	DATENAME(month, X.ActivityDate) AS ActivityMonthName,
	CONVERT(varchar(4), YEAR(X.ActivityDate)) + ' ' + DATENAME(month, X.ActivityDate) AS ActivityYearMonth,
	ROUND(CASE 
		WHEN @UOM = 2 THEN AR.Distance --default to mi
		ELSE AR.Distance * @UOMFactor
	END, 2) AS Distance,
	CAST(X.ActivityDate AS datetime) + CAST(X.ActivityStartTime AS datetime) AS ActivityStartDateTime,
	CASE WHEN X.ActivityStartTime = X.ActivityEndTime THEN CAST(X.ActivityDate AS datetime) + CAST(DATEADD(HH, 2, X.ActivityStartTime) AS datetime) ELSE CAST(X.ActivityDate AS datetime) + CAST(X.ActivityEndTime AS datetime) END AS ActivityEndDateTime,
	X.ActivityStartTime AS ActivityStartTimeSpan,
	FORMAT(CONVERT(datetime, X.ActivityStartTime), 'hh:mm tt') AS ActivityStartTime,
	FORMAT(CONVERT(datetime, X.ActivityEndTime), 'hh:mm tt') AS ActivityEndTime,
	REPLACE(X.ActivityNotes, '''', '') AS ActivityNotes,
	X.[Private] AS PrivateRide,
	ISNULL(X.Cancelled, 0) AS Cancelled,
	ISNULL(X.HasWaiver, 0) AS HasWaiver,
	ISNULL(X.IsCommunity, 0) AS IsCommunity,
	X.CreatedDate,
	'myMarker' AS Shape,
	RT.RouteTypeName,
	AT.ActivityTypeName,
	ISNULL(RS.RosterCount, 0) AS RosterCount,
	ISNULL(AV.ActivityView, 0) AS ActivityView,
	ISNULL(AL.LikeCount, 0) AS LikeCount,
	HasUserLiked = CONVERT(bit, (SELECT COUNT(1) FROM ActivityLike WHERE UserID = @UserID AND ActivityID =  X.ActivityID)),
	ISNULL(C.ActivityChat, 0) AS ChatView,
	X.TeamID,
	T.TeamName,
	TeamHeader = 
		CONVERT(bit, CASE
			WHEN X.TeamID IS NOT NULL THEN 1 ELSE 0
		END),
	ViewStatus = 
		CASE
			WHEN X.[Private] = 1 AND X.TeamID IS NOT NULL THEN 'Private Team Ride'
			WHEN X.[Private] = 0 AND X.TeamID IS NOT NULL THEN 'Public Team Ride'
			WHEN X.[Private] = 1 AND X.TeamID IS NULL THEN 'Private Ride'
			WHEN X.[Private] = 0 AND X.TeamID IS NULL THEN 'Public Ride'
		END,
	ShowQuickResponse = CONVERT(bit, CASE WHEN X.Cancelled = 1 THEN 0 ELSE CASE WHEN UR.ResponseTypeID IS NOT NULL THEN 0 ELSE 1 END END),
	UserResponseColor = 
		CASE
			WHEN UR.ResponseTypeID = 1 THEN '#10a500'
			WHEN UR.ResponseTypeID = 3 THEN '#f9d543'
			WHEN UR.ResponseTypeID = 4 THEN 'Red'
			ELSE 'White'
		END,
	X.IsPromoted
FROM (
	SELECT *, geography::Point(StartLat, StartLng, 4326) AS GeoPt FROM Activity
) X
INNER JOIN ActivityRoute AR ON X.ActivityID = AR.ActivityID
	AND AR.IsPrimary = 1
INNER JOIN UserProfile U ON X.UserID = U.UserID
INNER JOIN RouteType RT ON X.RouteTypeID = RT.RouteTypeID
INNER JOIN ActivityType AT ON X.ActivityTypeID = AT.ActivityTypeID
LEFT OUTER JOIN Team T ON X.TeamID = T.TeamID
LEFT OUTER JOIN (
	SELECT ActivityID, COUNT(UserID) AS RosterCount FROM ActivityRoster WHERE ResponseTypeID = 1 GROUP BY ActivityID
) RS ON X.ActivityID = RS.ActivityID
LEFT OUTER JOIN (
	SELECT ActivityID, COUNT(ActivityID) AS ActivityView FROM ActivityView GROUP BY ActivityID
) AV ON X.ActivityID = AV.ActivityID
LEFT OUTER JOIN (
	SELECT ActivityID, UserID, ResponseTypeID FROM ActivityRoster
) UR ON X.ActivityID = UR.ActivityID
	AND UR.UserID = @UserID
LEFT OUTER JOIN (
	SELECT ActivityID, COUNT(UserID) AS LikeCount FROM ActivityLike GROUP BY ActivityID
) AL ON X.ActivityID = AL.ActivityID
LEFT OUTER JOIN (
	SELECT ActivityID, COUNT(ActivityDiscussionID) AS ActivityChat FROM ActivityDisuccsionThreads GROUP BY ActivityID
) C ON X.ActivityID = C.ActivityID
WHERE (
		(
			CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) >= DATEADD(HH, -6, GETDATE())
			AND CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) <= DATEADD(D, 6, GETDATE())
			AND GeoPt.STDistance(@CurrentLocation) < @Radius --(@Distance * @MetersPerMile)
		)
		OR (X.IsPromoted = 1 AND NOT EXISTS(SELECT 1 FROM ActivityRoster WHERE ActivityID = X.ActivityID AND UserID = @UserID))
	)
	AND (X.[Private] = 0
		OR X.TeamID IN (SELECT DISTINCT T.TeamID FROM Team T LEFT OUTER JOIN TeamMember TM ON T.TeamID = TM.TeamID WHERE (TM.UserID = @UserID OR T.OwnerUserID = @UserID))
		OR @UserID IN (SELECT UserID FROM ActivityRoster WHERE ActivityID = X.ActivityID)
		OR @UserID = X.UserID)
ORDER BY IsPromoted DESC, ActivityStartDateTime
GO


