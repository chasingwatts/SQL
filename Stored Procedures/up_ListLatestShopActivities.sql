USE [trovafit_aspnet]
GO

DROP PROCEDURE up_ListLatestShopActivities
GO

CREATE PROCEDURE up_ListLatestShopActivities
	@ShopID int,
	@UserID int
AS
/******************************************************************************
*  DBA Script: [up_ListLatestShopActivities]
*  Created By: Jason Codianne 
*  Created:    01/17/2018 
*  Schema:     dbo
*  Purpose:    List activities within a specific radius of home.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListLatestShopActivities 1, 1
  
 --DECLARE @UserID int
 --SET @UserID = 1
-- ============================================================================

SET NOCOUNT ON

SELECT
	A.UserID AS ActivityUserID,
	U.FirstName AS UserFirstName,
	U.LastName AS UserLastName,
	U.FirstName + ' ' + LEFT(U.LastName, 1) AS UserFullName,
	A.ActivityID, 
	UPPER(A.ActivityName) AS ActivityName,
	A.StartLat,
	A.StartLng,
	A.StartLocation,
	A.StartName,
	A.StartAddress,
	A.StartCity,
	A.StartState,
	A.StartCountry,
	A.ActivityDate,
	FORMAT(CONVERT(datetime, A.ActivityStartTime), 'hh:mm tt') AS ActivityStartTime,
	FORMAT(CONVERT(datetime, A.ActivityEndTime), 'hh:mm tt') AS ActivityEndTime,
	CAST(A.ActivityDate AS datetime) + CAST(A.ActivityStartTime AS datetime) AS ActivityStartDateTime,
	U.UnitOfMeasureID,
	M.UnitOfMeasure AS UnitOfMeasureName,
	R.Distance,
	REPLACE(A.ActivityNotes, '''', '') AS ActivityNotes,
	ISNULL(A.[Private], 0) AS PrivateRide,
	ISNULL(A.Cancelled, 0) AS Cancelled,
	ISNULL(A.HasWaiver, 0) AS HasWaiver,
	ISNULL(A.IsCommunity, 0) AS IsCommunity,
	A.CreatedDate,
	RT.RouteTypeName,
	AT.ActivityTypeName,
	ISNULL(RS.RosterCount, 0) AS RosterCount,
	ISNULL(AV.ActivityView, 0) AS ActivityView,
	ISNULL(AL.LikeCount, 0) AS LikeCount,
	HasUserLiked = CONVERT(bit, (SELECT COUNT(1) FROM ActivityLike WHERE UserID = @UserID AND ActivityID =  A.ActivityID)),
	CASE WHEN CONVERT(bit, (SELECT COUNT(1) FROM ActivityLike WHERE UserID = @UserID AND ActivityID =  A.ActivityID))  = 1 THEN '#B71C1C' ELSE '#000000' END AS LikedColor,
	ISNULL(C.ActivityChat, 0) AS CommentCount,
	ISNULL(C.ActivityChat, 0) AS ChatView,
	A.TeamID,
	T.TeamName,
	TeamHeader = 
		CONVERT(bit, CASE
			WHEN A.TeamID IS NOT NULL THEN 1 ELSE 0
		END),
	ViewStatus = 
		CASE
			WHEN A.[Private] = 1 AND A.TeamID IS NOT NULL THEN 'Private Team Ride'
			WHEN A.[Private] = 0 AND A.TeamID IS NOT NULL THEN 'Public Team Ride'
			WHEN A.[Private] = 1 AND A.TeamID IS NULL THEN 'Private Ride'
			WHEN A.[Private] = 0 AND A.TeamID IS NULL THEN 'Public Ride'
		END,
	ShowQuickResponse = CONVERT(bit, CASE WHEN A.Cancelled = 1 THEN 0 ELSE CASE WHEN UR.ResponseTypeID IS NOT NULL THEN 0 ELSE 1 END END),
	UserResponseColor = 
		CASE
			WHEN UR.ResponseTypeID = 1 THEN '#10a500'
			WHEN UR.ResponseTypeID = 3 THEN '#f9d543'
			WHEN UR.ResponseTypeID = 4 THEN 'Red'
			ELSE 'White'
		END,
	CONVERT(bit, A.IsPromoted) AS IsPromoted,
	A.IsMultiRoute
FROM Activity A
	INNER JOIN LocalShopUsers LU ON LU.UserID = A.UserID
	INNER JOIN LocalShop L ON LU.LocalShopID = L.LocalShopID
	INNER JOIN ActivityRoute R ON A.ActivityID = R.ActivityID
		AND R.IsPrimary = 1
	INNER JOIN UserProfile U ON A.UserID = U.UserID
	INNER JOIN UnitOfMeasure M ON U.UnitOfMeasureID = M.UnitOfMeasureID
	INNER JOIN RouteType RT ON A.RouteTypeID = RT.RouteTypeID
	INNER JOIN ActivityType AT ON A.ActivityTypeID = AT.ActivityTypeID
	LEFT OUTER JOIN Team T ON A.TeamID = T.TeamID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(UserID) AS RosterCount FROM ActivityRoster WHERE ResponseTypeID = 1 GROUP BY ActivityID -- yes only
	) RS ON A.ActivityID = RS.ActivityID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(ActivityID) AS ActivityView FROM ActivityView GROUP BY ActivityID
	) AV ON A.ActivityID = AV.ActivityID
	LEFT OUTER JOIN (
		SELECT ActivityID, UserID, ResponseTypeID FROM ActivityRoster
	) UR ON A.ActivityID = UR.ActivityID
		AND UR.UserID = @UserID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(UserID) AS LikeCount FROM ActivityLike GROUP BY ActivityID
	) AL ON A.ActivityID = AL.ActivityID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(ActivityDiscussionID) AS ActivityChat FROM ActivityDisuccsionThreads GROUP BY ActivityID
	) C ON A.ActivityID = C.ActivityID
WHERE L.LocalShopID = @ShopID --A.UserID = @UserID
	AND (CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) >= GETDATE()
	AND CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) <= DATEADD(D, 14, GETDATE()))
	AND (A.[Private] = 0
		OR A.TeamID IN (SELECT DISTINCT T.TeamID FROM Team T LEFT OUTER JOIN TeamMember TM ON T.TeamID = TM.TeamID WHERE (TM.UserID = @UserID OR T.OwnerUserID = @UserID))
		OR @UserID IN (SELECT UserID FROM ActivityRoster WHERE ActivityID = A.ActivityID)
		OR @UserID = A.UserID)
ORDER BY IsPromoted DESC, CAST(A.ActivityDate AS datetime) + CAST(A.ActivityStartTime AS datetime)