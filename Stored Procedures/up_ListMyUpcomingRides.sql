USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_ListMyUpcomingRides
GO

CREATE PROCEDURE dbo.up_ListMyUpcomingRides
	@UserID int
AS
/******************************************************************************
*  DBA Script: up_ListMyUpcomingRides
*  Created By: Jason Codianne 
*  Created:    01/17/2018 
*  Schema:     dbo
*  Purpose:    List activities within a specific radius of home.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListMyUpcomingRides 1
  
-- ============================================================================
SET NOCOUNT ON

--DECLARE @UserID int
--SET @UserID = 1

DECLARE @Distance float
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
	DISTINCT 
	A.ActivityID,
	A.ActivityName,
	A.StartLocation,
	A.StartName,
	A.StartAddress,
	A.StartCity,
	A.StartState,
	A.StartCountry,
	ROUND(CASE WHEN @UOM = 2 THEN R.Distance ELSE R.Distance * @UOMFactor END, 2) AS Distance,
	ROUND(CASE WHEN @UOM = 2 THEN R.Speed ELSE R.Speed * @UOMFactor END, 2) AS Speed,
	M.UnitOfMeasure,
	A.ActivityDate,
	FORMAT(CONVERT(datetime, A.ActivityStartTime), 'hh:mm tt') AS ActivityStartTime,
	FORMAT(CONVERT(datetime, A.ActivityEndTime), 'hh:mm tt') AS ActivityEndTime,
	AT.ActivityTypeName,
	RT.RouteTypeName,
	A.UserID AS ActivityUserID,
	U.FirstName,
	U.LastName,
	ISNULL(AR.ResponseTypeID, 0) AS ResponseTypeID,
	A.[Private],
	ISNULL(A.IsCommunity, 0) AS IsCommunity,
	ISNULL(A.Cancelled, 0) AS Cancelled,
	ISNULL(RS.RosterCount, 0) AS RosterCount,
	ISNULL(AV.ActivityView, 0) AS ActivityView,
	ISNULL(C.ActivityChat, 0) AS ChatView,
	A.TeamID,
	T.TeamName,
	TeamHeader = CONVERT(bit, CASE WHEN A.TeamID IS NOT NULL THEN 1 ELSE 0 END),
	ViewStatus = 
		CASE
			WHEN A.[Private] = 1 AND A.TeamID IS NOT NULL THEN 'Private Team Ride'
			WHEN A.[Private] = 0 AND A.TeamID IS NOT NULL THEN 'Public Team Ride'
			WHEN A.[Private] = 1 AND A.TeamID IS NULL THEN 'Private Ride'
			WHEN A.[Private] = 0 AND A.TeamID IS NULL THEN 'Public Ride'
		END,
	UserResponseColor = 
		CASE
			WHEN AR.ResponseTypeID = 1 THEN 'bg-faded-success'
			WHEN AR.ResponseTypeID = 3 THEN 'bg-faded-warning'
			WHEN AR.ResponseTypeID = 4 THEN 'bg-faded-danger'
			ELSE ''
		END
FROM Activity A
	INNER JOIN ActivityRoute R ON A.ActivityID = R.ActivityID
		AND R.IsPrimary = 1
	LEFT OUTER JOIN ActivityRoster AR ON A.ActivityID = AR.ActivityID
	INNER JOIN ActivityType AT ON A.ActivityTypeID = AT.ActivityTypeID
	INNER JOIN RouteType RT ON A.RouteTypeID = RT.RouteTypeID
	LEFT OUTER JOIN Team T ON A.TeamID = T.TeamID
	INNER JOIN UserProfile U ON A.UserID = U.UserID
	INNER JOIN UnitOfMeasure M ON U.UnitOfMeasureID = M.UnitOfMeasureID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(UserID) AS RosterCount FROM ActivityRoster WHERE ResponseTypeID = 1 GROUP BY ActivityID
			) RS ON A.ActivityID = RS.ActivityID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(ActivityID) AS ActivityView FROM ActivityView GROUP BY ActivityID
	) AV ON A.ActivityID = AV.ActivityID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(ActivityDiscussionID) AS ActivityChat FROM ActivityDisuccsionThreads GROUP BY ActivityID
	) C ON A.ActivityID = C.ActivityID
WHERE CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) >= GETDATE()
	AND (AR.UserID = @UserID AND AR.ResponseTypeID <> 4)
UNION ALL
SELECT 
	DISTINCT 
	A.ActivityID,
	A.ActivityName,
	A.StartLocation,
	A.StartName,
	A.StartAddress,
	A.StartCity,
	A.StartState,
	A.StartCountry,
	ROUND(CASE WHEN @UOM = 2 THEN R.Distance ELSE R.Distance * @UOMFactor END, 2) AS Distance,
	ROUND(CASE WHEN @UOM = 2 THEN R.Speed ELSE R.Speed * @UOMFactor END, 2) AS Speed,
	M.UnitOfMeasure,
	A.ActivityDate,
	FORMAT(CONVERT(datetime, A.ActivityStartTime), 'hh:mm tt') AS ActivityStartTime,
	FORMAT(CONVERT(datetime, A.ActivityEndTime), 'hh:mm tt') AS ActivityEndTime,
	AT.ActivityTypeName,
	RT.RouteTypeName,
	A.UserID AS ActivityUserID,
	U.FirstName,
	U.LastName,
	4 AS ResponseTypeID,
	A.[Private],
	ISNULL(A.IsCommunity, 0) AS IsCommunity,
	ISNULL(A.Cancelled, 0) AS Cancelled,
	ISNULL(RS.RosterCount, 0) AS RosterCount,
	ISNULL(AV.ActivityView, 0) AS ActivityView,
	ISNULL(C.ActivityChat, 0) AS ChatView,
	A.TeamID,
	T.TeamName,
	TeamHeader = CONVERT(bit, CASE WHEN A.TeamID IS NOT NULL THEN 1 ELSE 0 END),
	ViewStatus = 
		CASE
			WHEN A.[Private] = 1 AND A.TeamID IS NOT NULL THEN 'Private Team Ride'
			WHEN A.[Private] = 0 AND A.TeamID IS NOT NULL THEN 'Public Team Ride'
			WHEN A.[Private] = 1 AND A.TeamID IS NULL THEN 'Private Ride'
			WHEN A.[Private] = 0 AND A.TeamID IS NULL THEN 'Public Ride'
		END,
	UserResponseColor = 'bg-faded-accent'
FROM Activity A
	INNER JOIN ActivityRoute R ON A.ActivityID = R.ActivityID
		AND R.IsPrimary = 1
	INNER JOIN ActivityType AT ON A.ActivityTypeID = AT.ActivityTypeID
	INNER JOIN RouteType RT ON A.RouteTypeID = RT.RouteTypeID
	LEFT OUTER JOIN Team T ON A.TeamID = T.TeamID
	INNER JOIN UserProfile U ON A.UserID = U.UserID
	INNER JOIN UnitOfMeasure M ON U.UnitOfMeasureID = M.UnitOfMeasureID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(UserID) AS RosterCount FROM ActivityRoster WHERE ResponseTypeID = 1 GROUP BY ActivityID
			) RS ON A.ActivityID = RS.ActivityID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(ActivityID) AS ActivityView FROM ActivityView GROUP BY ActivityID
	) AV ON A.ActivityID = AV.ActivityID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(ActivityDiscussionID) AS ActivityChat FROM ActivityDisuccsionThreads GROUP BY ActivityID
	) C ON A.ActivityID = C.ActivityID
WHERE CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) >= GETDATE()
	AND (A.UserID = @UserID)
	AND A.UserID NOT IN (SELECT UserID FROM ActivityRoster WHERE ActivityID = A.ActivityID)
ORDER BY 10
GO