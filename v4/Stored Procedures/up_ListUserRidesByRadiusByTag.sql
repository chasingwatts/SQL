USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListUserRidesByRadiusByTag
GO

CREATE PROCEDURE up_ListUserRidesByRadiusByTag
	@UserID int,
	@Radius float,
	@TagName varchar(50)
AS
--/******************************************************************************
--*  DBA Script: up_ListUserRidesByRadiusByTag
--*  Created By: Jason Codianne 
--*  Created:    10/30/2023 
--*  Schema:     dbo
--*  Purpose:    List activities within a specific radius of home.
--******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListUserRidesByRadiusByTag 1, 200, 'ride'

 --DECLARE @UserID int
 --DECLARE @Radius float
 --DECLARE @TagName varchar(100)
 --SET @UserID = 1
 --SET @Radius = 2000
 --SET @TagName = 'test tag 9'


-- ============================================================================

SET NOCOUNT ON

DECLARE @UOM int
DECLARE @UOMName varchar(10)
DECLARE @UOMFactor float
DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 

SELECT 
	@CurrentLocation = geography::Point(U.HomeBaseLat, U.HomeBaseLng, 4326), 
	@UOM = UnitOfMeasureID
FROM UserProfile U WHERE U.UserID = @UserID

SELECT
	A.ActivityID,
	A.ActivityTypeID,
	AT.ActivityTypeName,
	AT.ActivityTypeIcon,
	AT.ActivityTypeColor,
	A.UserID,
	U.FirstName AS UserFirstName,
	U.LastName AS UserLastName,
	A.ActivityName,
	A.ActivityDate,
	A.ActivityStartTime,
	A.ActivityEndTime,
	A.StartName,
	A.StartAddress,
	A.StartCity,
	A.StartState,
	A.StartCountry,
	A.StartLat,
	A.StartLng,
	A.StartW3W,
	ISNULL(ROUND((@CurrentLocation.STDistance(A.ActivityGeoPt)) * 0.0006213712, 2), 0) AS DistanceToRide,
	A.ActivityNotes,
	A.EventLink,
	A.IsPrivate,
	A.IsCancelled,
	A.IsPromoted,
	A.IsGroup,
	A.HasWaiver,
	A.IsCommunity,
	A.IsDrop,
	A.IsLightsRequired,
	A.ParentActivityID,
	A.TeamID AS HubID,
	H.HubName,
	HT.HubTypeName,
	CASE
		WHEN A.IsPrivate = 1 AND A.TeamID > 0 THEN 'Private ' + HT.HubTypeName + ' Ride'
		WHEN A.IsPrivate = 0 AND A.TeamID > 0 THEN 'Public ' + HT.HubTypeName + ' Ride'
		WHEN A.IsPrivate = 1 AND A.TeamID = 0 THEN 'Private Ride'
		WHEN A.IsPrivate = 0 AND A.TeamID = 0 THEN 'Public Ride'
		ELSE 'Let''s Ride'
	END AS ViewStatus,
	ISNULL(V.ViewCount, 0) AS ViewCount,
	ISNULL(L.LikeCount, 0) AS LikeCount,
	ISNULL(C.ChatCount, 0) AS ChatCount,
	ISNULL(R.RosterCount, 0) AS RosterCount,
	CONVERT(bit, CASE WHEN UL.ActivityLikeID IS NOT NULL THEN 1 ELSE 0 END) AS UserHasLiked,
	CONVERT(bit, CASE WHEN AR.ResponseTypeID IS NOT NULL THEN 1 ELSE 0 END) AS UserInRoster,
	T.ResponseTypeName AS UserResponseName,
	T.ResponseColor AS UserResponseColor,
	AR.GroupLevel,
	A.IsDeleted,
	A.CreatedBy,
	A.CreatedDate,
	A.ModifiedBy,
	A.ModifiedDate
FROM (SELECT *, geography::Point(StartLat, StartLng, 4326) AS ActivityGeoPt FROM Activity) A
	INNER JOIN ActivityType AT ON A.ActivityTypeID = AT.ActivityTypeID
	INNER JOIN ActivityTag TG ON A.ActivityID = TG.ActivityID
	INNER JOIN UserProfile U ON A.UserID = U.UserID
	LEFT OUTER JOIN Hub H ON A.TeamID = H.HubID
	LEFT OUTER JOIN HubType HT ON H.HubTypeID = HT.HubTypeID
	LEFT OUTER JOIN (SELECT ActivityID, COUNT(ActivityViewID) AS ViewCount FROM ActivityView GROUP BY ActivityID) V ON A.ActivityID = V.ActivityID
	LEFT OUTER JOIN (SELECT ActivityID, COUNT(ActivityLikeID) AS LikeCount FROM ActivityLike GROUP BY ActivityID) L ON A.ActivityID = L.ActivityID
	LEFT OUTER JOIN (SELECT ActivityID, COUNT(ActivityChatID) AS ChatCount FROM ActivityChat WHERE IsDeleted = 0 GROUP BY ActivityID) C ON A.ActivityID = C.ActivityID
	LEFT OUTER JOIN (SELECT R.ActivityID, COUNT(R.ActivityRosterID) AS RosterCount FROM ActivityRoster R WHERE R.ResponseTypeID <> 3 GROUP BY R.ActivityID) R ON A.ActivityID = R.ActivityID
	LEFT OUTER JOIN (SELECT ActivityLikeID, ActivityID, CreatedBy FROM ActivityLike) UL ON A.ActivityID = UL.ActivityID AND UL.CreatedBy = @UserID
	LEFT OUTER JOIN ActivityRoster AR ON A.ActivityID = AR.ActivityID
		AND AR.CreatedBy = @UserID
	LEFT OUTER JOIN ResponseType T ON AR.ResponseTypeID = T.ResponseTypeID
WHERE A.IsDeleted = 0
	AND CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) >= GETDATE()
	AND CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) <= DATEADD(D, 6, GETDATE())
	AND ActivityGeoPt.STDistance(@CurrentLocation) < @Radius * @MetersPerMile
	AND TG.ActivityTagName = @TagName
	AND (
		A.[IsPrivate] = 0  --not private
			OR A.TeamID IN (SELECT DISTINCT H.HubID FROM Hub H LEFT OUTER JOIN HubMember HM ON H.HubID = HM.HubID WHERE (HM.UserID = @UserID)) --in assoc team
			OR @UserID IN (SELECT DISTINCT CreatedBy FROM ActivityRoster WHERE ActivityID = A.ActivityID) --on the roster
			OR @UserID IN (SELECT InviteUserID FROM ActivityInvite WHERE ActivityID = A.ActivityID) --invited
			OR @UserID = A.UserID --created ride
			OR (SELECT Role FROM Accounts WHERE id = @UserID) = 0 --admin role
	)
ORDER BY IsPromoted DESC