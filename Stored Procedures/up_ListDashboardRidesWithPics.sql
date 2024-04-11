USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS up_ListDashboardRidesWithPics
GO

CREATE PROCEDURE up_ListDashboardRidesWithPics
	@UserID int,
	@Distance float,
	@ActivityTypeID int,
	@ActivityName varchar(500)
AS
--/******************************************************************************
--*  DBA Script: up_ListDashboardRidesWithPics
--*  Created By: Jason Codianne 
--*  Created:    01/17/2018 
--*  Schema:     dbo
--*  Purpose:    List activities within a specific radius of home.
--******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListDashboardRidesWithPics 1, 200, null, null

 --DECLARE @UserID int
 --DECLARE @Distance float
 --DECLARE @ActivityTypeID int = null
 --DECLARE @ActivityName varchar(500) = null
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
	U.FirstName + ' ' + LEFT(U.LastName, 1) AS UserFullName,
	X.ActivityID, 
	UPPER(X.ActivityName) AS ActivityName,
	X.StartLat,
	X.StartLng,
	X.StartLocation,
	X.StartName,
	X.StartAddress,
	X.StartCity,
	X.StartState,
	X.StartCountry,
	@UOMName AS UnitOfMeasureName,
	ROUND(CASE WHEN @UOM = 2 THEN R.Distance ELSE R.Distance * @UOMFactor END, 2) AS Distance,
	ROUND(CASE WHEN @UOM = 2 THEN R.Speed ELSE R.Speed * @UOMFactor END, 2) AS Speed,
	X.ActivityDate,
	FORMAT(CAST(X.ActivityDate AS datetime) + CAST(X.ActivityStartTime AS datetime), 'hh:mm tt') AS ActivityStartTime,
	FORMAT(CAST(X.ActivityEndTime AS datetime) + CAST(X.ActivityEndTime AS datetime), 'hh:mm tt') AS ActivityEndTime,
	CAST(X.ActivityDate AS datetime) + CAST(X.ActivityStartTime AS datetime) AS ActivityStartDateTime,
	REPLACE(X.ActivityNotes, '''', '') AS ActivityNotes,
	X.[Private] AS PrivateRide,
	ISNULL(X.Cancelled, 0) AS Cancelled,
	ISNULL(HasWaiver, 0) AS HasWaiver,
	ISNULL(X.IsCommunity, 0) AS IsCommunity,
	ISNULL(X.IsMultiRoute, 0) AS IsMultiRoute,
	X.CreatedDate,
	RT.RouteTypeName,
	AT.ActivityTypeName,
	ISNULL(RS.RosterCount, 0) AS RosterCount,
	ISNULL(AV.ActivityView, 0) AS ActivityView,
	ISNULL(AL.LikeCount, 0) AS LikeCount,
	CONVERT(bit, (SELECT COUNT(1) FROM ActivityLike WHERE UserID = @UserID AND ActivityID =  X.ActivityID)) AS HasUserLiked,
	CASE WHEN CONVERT(bit, (SELECT COUNT(1) FROM ActivityLike WHERE UserID = @UserID AND ActivityID =  X.ActivityID)) = 1 THEN '#B71C1C' ELSE '#000000' END AS LikedColor,
	ISNULL(C.CommentCount, 0) AS CommentCount,
	ISNULL(AP.PicturePath, '/ogmaps/blank.png') AS MapPicUrl,
	--ISNULL(dbo.GetActivityPictures(X.ActivityID), '<img src="/routepics/blank.png" style="height: 232px; object-fit: cover;" />') AS PicUrlList,
	X.TeamID,
	T.TeamName,
	CONVERT(bit, CASE WHEN X.TeamID IS NOT NULL THEN 1 ELSE 0 END) AS TeamHeader,
	CASE
		WHEN X.[Private] = 1 AND X.TeamID IS NOT NULL THEN 'Private Team Ride'
		WHEN X.[Private] = 0 AND X.TeamID IS NOT NULL THEN 'Public Team Ride'
		WHEN X.[Private] = 1 AND X.TeamID IS NULL THEN 'Private Ride'
		WHEN X.[Private] = 0 AND X.TeamID IS NULL THEN 'Public Ride'
	END AS ViewStatus,
	CONVERT(bit, CASE WHEN X.Cancelled = 1 THEN 0 ELSE CASE WHEN UR.ResponseTypeID IS NOT NULL THEN 0 ELSE 1 END END) AS ShowQuickResponse,
	CASE
		WHEN UR.ResponseTypeID = 1 THEN 'bg-faded-success'
		WHEN UR.ResponseTypeID = 3 THEN 'bg-faded-warning'
		WHEN UR.ResponseTypeID = 4 THEN 'bg-faded-danger'
		ELSE ''
	END AS UserResponseColor,
	CONVERT(bit, X.IsPromoted) AS IsPromoted,
	CONVERT(bit, CASE WHEN L.LocalShopName IS NOT NULL THEN 1 ELSE 0 END) AS ShowLocalShop,
	L.LocalShopName,
	L.LocalShopRouteName,
	Picture.ActivityPictureID,
	Picture.IsMap,
	Picture.PicturePath
FROM (SELECT *, geography::Point(StartLat, StartLng, 4326) AS GeoPt FROM Activity) X
	INNER JOIN ActivityRoute R ON X.ActivityID = R.ActivityID
		AND R.IsPrimary = 1
	INNER JOIN ActivityPicture Picture ON X.ActivityID = Picture.ActivityID
	LEFT OUTER JOIN ActivityPicture AP ON X.ActivityID = AP.ActivityID
		AND AP.IsMap = 1
	INNER JOIN UserProfile U ON X.UserID = U.UserID
	INNER JOIN RouteType RT ON X.RouteTypeID = RT.RouteTypeID
	INNER JOIN ActivityType AT ON X.ActivityTypeID = AT.ActivityTypeID
	LEFT OUTER JOIN Team T ON X.TeamID = T.TeamID
	LEFT OUTER JOIN (SELECT ActivityID, COUNT(UserID) AS RosterCount FROM ActivityRoster WHERE ResponseTypeID = 1 GROUP BY ActivityID) RS ON X.ActivityID = RS.ActivityID
	LEFT OUTER JOIN (SELECT ActivityID, COUNT(ActivityID) AS ActivityView FROM ActivityView GROUP BY ActivityID) AV ON X.ActivityID = AV.ActivityID
	LEFT OUTER JOIN (SELECT ActivityID, UserID, ResponseTypeID FROM ActivityRoster) UR ON X.ActivityID = UR.ActivityID
		AND UR.UserID = @UserID
	LEFT OUTER JOIN (SELECT ActivityID, COUNT(UserID) AS LikeCount FROM ActivityLike GROUP BY ActivityID) AL ON X.ActivityID = AL.ActivityID
	LEFT OUTER JOIN (SELECT ActivityID, COUNT(ActivityDiscussionID) AS CommentCount FROM ActivityDisuccsionThreads GROUP BY ActivityID) C ON X.ActivityID = C.ActivityID
	LEFT OUTER JOIN LocalShop L ON X.UserID = L.OwnerID
WHERE ( 
		(
			CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) >= GETDATE()
			AND CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) <= DATEADD(D, 6, GETDATE())
			AND GeoPt.STDistance(@CurrentLocation) < @Radius --(@Distance * @MetersPerMile)
		)
		OR (X.IsPromoted = 1 AND NOT EXISTS(SELECT 1 FROM ActivityRoster WHERE ActivityID = X.ActivityID AND UserID = @UserID))
	)
	AND X.ActivityTypeID = COALESCE(@ActivityTypeID, X.ActivityTypeID)
	AND (@ActivityName IS NULL OR X.ActivityName LIKE '%' + @ActivityName + '%')
	AND (
			X.[Private] = 0
			OR X.TeamID IN (SELECT DISTINCT T.TeamID FROM Team T LEFT OUTER JOIN TeamMember TM ON T.TeamID = TM.TeamID WHERE (TM.UserID = @UserID OR T.OwnerUserID = @UserID))
			OR @UserID IN (SELECT DISTINCT UserID FROM ActivityRoster WHERE ActivityID = X.ActivityID)
			OR @UserID = X.UserID
		)
ORDER BY IsPromoted DESC, ActivityStartDateTime