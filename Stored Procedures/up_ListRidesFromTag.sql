USE [trovafit_aspnet]
GO

DROP PROCEDURE up_ListRidesFromTag
GO

CREATE PROCEDURE up_ListRidesFromTag
	@TagName varchar(100),
	@UserID int,
	@Distance float
AS
/******************************************************************************
*  DBA Script: up_ListRidesFromTag
*  Created By: Jason Codianne 
*  Created:    01/17/2018 
*  Schema:     dbo
*  Purpose:    List activities with a specific tag name
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListRidesFromTag 'test', 1, 5000
  
-- ============================================================================

SET NOCOUNT ON

DECLARE @UOM int
DECLARE @UOMName varchar(10)
DECLARE @UOMFactor float
DECLARE @Radius float
DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 

IF @UserID = 0
BEGIN
	SELECT
		X.UserID AS ActivityUserID,
		U.FirstName AS UserFirstName,
		U.LastName AS UserLastName,
		U.FirstName + ' ' + u.LastName AS UserFullName,
		X.ActivityID, 
		X.ActivityName AS ActivityName,
		ROUND(GeoPt.STDistance(@CurrentLocation)/@MetersPerMile, 0) AS DistanceFromHomeBase,
		X.StartLat,
		X.StartLng,
		X.StartLocation,
		X.StartName,
		X.StartAddress,
		X.StartCity,
		X.StartState,
		X.StartCountry,
		X.ActivityDate,
		'miles' AS UnitOfMeasureName,
		CONVERT(float, R.Speed) AS Speed,
		R.Distance,
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
		ISNULL(X.IsMultiRoute, 0) AS IsMultiRoute,
		X.CreatedDate,
		RT.RouteTypeName,
		AT.ActivityTypeName,
		ISNULL(RS.RosterCount, 0) AS RosterCount,
		ISNULL(AV.ActivityView, 0) AS ActivityView,
		ISNULL(C.CommentCount, 0) AS CommentCount,
		ISNULL(C.CommentCount, 0) AS ChatView,
		ISNULL(AL.LikeCount, 0) AS LikeCount,
		'#CECECE' AS LikedColor,
		P.PicturePath AS MapPicUrl,
		NULL AS PicUrlList,
		HasUserLiked = CONVERT(bit, 0),
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
			WHEN UR.ResponseTypeID = 1 THEN 'bg-faded-success'
			WHEN UR.ResponseTypeID = 3 THEN 'bg-faded-warning'
			WHEN UR.ResponseTypeID = 4 THEN 'bg-faded-danger'
			ELSE ''
		END,
		X.IsPromoted,
		TG.ActivityTagName,
		ShowLocalShop = CONVERT(bit, CASE WHEN L.LocalShopName IS NOT NULL THEN 1 ELSE 0 END),
		L.LocalShopName,
		L.LocalShopRouteName
	FROM (
		SELECT *, geography::Point(StartLat, StartLng, 4326) AS GeoPt FROM Activity
	) X
	INNER JOIN ActivityRoute R on X.ActivityID = R.ActivityID
		AND R.IsPrimary = 1
	INNER JOIN ActivityPicture P ON X.ActivityID = P.ActivityID
		AND P.IsMap = 1
	INNER JOIN ActivityTag TG ON X.ActivityID = TG.ActivityID
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
		SELECT ActivityID, COUNT(ActivityDiscussionID) AS CommentCount FROM ActivityDisuccsionThreads GROUP BY ActivityID
	) C ON X.ActivityID = C.ActivityID
	LEFT OUTER JOIN (
		SELECT ActivityID, UserID, ResponseTypeID FROM ActivityRoster
	) UR ON X.ActivityID = UR.ActivityID
		AND UR.UserID = @UserID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(UserID) AS LikeCount FROM ActivityLike GROUP BY ActivityID
	) AL ON X.ActivityID = AL.ActivityID
	LEFT OUTER JOIN LocalShop L ON X.UserID = L.OwnerID
	WHERE TG.ActivityTagName = @TagName
		AND CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) >= GETDATE()
		AND (X.[Private] = 0
			OR X.TeamID IN (SELECT DISTINCT T.TeamID FROM Team T LEFT OUTER JOIN TeamMember TM ON T.TeamID = TM.TeamID WHERE (TM.UserID = @UserID OR T.OwnerUserID = @UserID)))
	ORDER BY ActivityDate, ActivityStartTime
END
ELSE
BEGIN
	SELECT 
		@UOM = U.UnitOfMeasureID, 
		@UOMName = M.UnitOfMeasure,
		@UOMFactor = M.MeasureFactor,
		@CurrentLocation = geography::STPointFromText('POINT(' + CAST(U.HomeBaseLng AS VARCHAR(20)) + ' ' + CAST(U.HomeBaseLat AS VARCHAR(20)) + ')', 4326) 
	FROM UserProfile U 
		INNER JOIN UnitOfMeasure M ON U.UnitOfMeasureID = M.UnitOfMeasureID
	WHERE U.UserID = @UserID
	SELECT
		X.UserID AS ActivityUserID,
		U.FirstName AS UserFirstName,
		U.LastName AS UserLastName,
		U.FirstName + ' ' + u.LastName AS UserFullName,
		X.ActivityID, 
		X.ActivityName AS ActivityName,
		ROUND(GeoPt.STDistance(@CurrentLocation)/@MetersPerMile, 0) AS DistanceFromHomeBase,
		X.StartLat,
		X.StartLng,
		X.StartLocation,
		X.StartName,
		X.StartAddress,
		X.StartCity,
		X.StartState,
		X.StartCountry,
		X.ActivityDate,
		@UOMName AS UnitOfMeasureName,
		CONVERT(float, R.Speed) AS Speed,
		R.Distance,
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
		ISNULL(X.IsMultiRoute, 0) AS IsMultiRoute,
		X.CreatedDate,
		RT.RouteTypeName,
		AT.ActivityTypeName,
		ISNULL(RS.RosterCount, 0) AS RosterCount,
		ISNULL(AV.ActivityView, 0) AS ActivityView,
		ISNULL(C.CommentCount, 0) AS CommentCount,
		ISNULL(C.CommentCount, 0) AS ChatView,
		ISNULL(AL.LikeCount, 0) AS LikeCount,
		'#CECECE' AS LikedColor,
		P.PicturePath AS MapPicUrl,
		NULL AS PicUrlList,
		HasUserLiked = CONVERT(bit, (SELECT COUNT(1) FROM ActivityLike WHERE UserID = @UserID AND ActivityID =  X.ActivityID)),
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
			WHEN UR.ResponseTypeID = 1 THEN 'bg-faded-success'
			WHEN UR.ResponseTypeID = 3 THEN 'bg-faded-warning'
			WHEN UR.ResponseTypeID = 4 THEN 'bg-faded-danger'
			ELSE ''
		END,
		X.IsPromoted,
		TG.ActivityTagName,
		ShowLocalShop = CONVERT(bit, CASE WHEN L.LocalShopName IS NOT NULL THEN 1 ELSE 0 END),
		L.LocalShopName,
		L.LocalShopRouteName
	FROM (
		SELECT *, geography::Point(StartLat, StartLng, 4326) AS GeoPt FROM Activity
	) X
	INNER JOIN ActivityRoute R on X.ActivityID = R.ActivityID
		AND R.IsPrimary = 1
	INNER JOIN ActivityPicture P ON X.ActivityID = P.ActivityID
		AND P.IsMap = 1
	INNER JOIN ActivityTag TG ON X.ActivityID = TG.ActivityID
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
		SELECT ActivityID, COUNT(ActivityDiscussionID) AS CommentCount FROM ActivityDisuccsionThreads GROUP BY ActivityID
	) C ON X.ActivityID = C.ActivityID
	LEFT OUTER JOIN (
		SELECT ActivityID, UserID, ResponseTypeID FROM ActivityRoster
	) UR ON X.ActivityID = UR.ActivityID
		AND UR.UserID = @UserID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(UserID) AS LikeCount FROM ActivityLike GROUP BY ActivityID
	) AL ON X.ActivityID = AL.ActivityID
	LEFT OUTER JOIN LocalShop L ON X.UserID = L.OwnerID
	WHERE TG.ActivityTagName = @TagName
		AND CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) >= GETDATE()
		AND GeoPt.STDistance(@CurrentLocation) < (@Distance * @MetersPerMile) --20 miles
		AND (X.[Private] = 0
			OR X.TeamID IN (SELECT DISTINCT T.TeamID FROM Team T LEFT OUTER JOIN TeamMember TM ON T.TeamID = TM.TeamID WHERE (TM.UserID = @UserID OR T.OwnerUserID = @UserID)))
	ORDER BY ActivityDate, ActivityStartTime
END
GO