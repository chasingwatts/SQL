USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListUserRidesByRadiusBySwipe
GO

CREATE PROCEDURE up_ListUserRidesByRadiusBySwipe
	@UserID int
AS
--/******************************************************************************
--*  DBA Script: up_ListUserRidesByRadiusBySwipe
--*  Created By: Jason Codianne 
--*  Created:    10/30/2023 
--*  Schema:     dbo
--*  Purpose:    List upcoming activities that user has swiped away.
--******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListUserRidesByRadiusBySwipe 1

 --DECLARE @UserID int
 --SET @UserID = 1


-- ============================================================================

SET NOCOUNT ON

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
	A.ActivityNotes,
	A.EventLink,
	A.IsPrivate,
	A.IsCancelled,
	A.IsPromoted,
	A.HasWaiver,
	A.IsCommunity,
	A.IsDrop,
	A.IsLightsRequired,
	A.ParentActivityID,
	A.TeamID AS HubID,
	H.HubName,
	HT.HubTypeName,
	CASE
		WHEN A.IsPrivate = 1 AND A.TeamID IS NOT NULL THEN 'Private ' + HT.HubTypeName + ' Ride'
		WHEN A.IsPrivate = 0 AND A.TeamID IS NOT NULL THEN 'Public ' + HT.HubTypeName + ' Ride'
		WHEN A.IsPrivate = 1 AND A.TeamID IS NULL THEN 'Private Ride'
		WHEN A.IsPrivate = 0 AND A.TeamID IS NULL THEN 'Public Ride'
		ELSE 'Let''s Ride'
	END AS ViewStatus,
	ISNULL(V.ViewCount, 0) AS ViewCount,
	ISNULL(L.LikeCount, 0) AS LikeCount,
	ISNULL(C.ChatCount, 0) AS ChatCount,
	ISNULL(R.RosterCount, 0) AS RosterCount,
	CONVERT(bit, CASE WHEN UL.ActivityLikeID IS NOT NULL THEN 1 ELSE 0 END) AS UserHasLiked,
	CONVERT(bit, CASE WHEN UR.ResponseTypeID IS NOT NULL THEN 1 ELSE 0 END) AS UserInRoster,
	UR.ResponseTypeName AS UserResponseName,
	UR.ResponseColor AS UserResponseColor,
	A.IsDeleted,
	A.CreatedBy,
	A.CreatedDate,
	A.ModifiedBy,
	A.ModifiedDate
FROM (SELECT *, geography::Point(StartLat, StartLng, 4326) AS ActivityGeoPt FROM Activity) A
INNER JOIN ActivityType AT ON A.ActivityTypeID = AT.ActivityTypeID
INNER JOIN ActivitySwipe S ON A.ActivityID = S.ActivityID
INNER JOIN UserProfile U ON A.UserID = U.UserID
LEFT OUTER JOIN Hub H ON A.TeamID = H.HubID
LEFT OUTER JOIN HubType HT ON H.HubTypeID = HT.HubTypeID
LEFT OUTER JOIN (SELECT ActivityID, COUNT(ActivityViewID) AS ViewCount FROM ActivityView GROUP BY ActivityID) V ON A.ActivityID = V.ActivityID
LEFT OUTER JOIN (SELECT ActivityID, COUNT(ActivityLikeID) AS LikeCount FROM ActivityLike GROUP BY ActivityID) L ON A.ActivityID = L.ActivityID
LEFT OUTER JOIN (SELECT ActivityID, COUNT(ActivityChatID) AS ChatCount FROM ActivityChat GROUP BY ActivityID) C ON A.ActivityID = C.ActivityID
LEFT OUTER JOIN (
	SELECT G.ActivityID, COUNT(R.ActivityRosterID) AS RosterCount
	FROM ActivityRosterGroup G
		LEFT OUTER JOIN ActivityRoster R ON G.ActivityRosterGroupID = R.ActivityRosterGroupID
	WHERE R.ResponseTypeID <> 3 --no
	GROUP BY G.ActivityID) R ON A.ActivityID = R.ActivityID
LEFT OUTER JOIN (SELECT ActivityLikeID, ActivityID, CreatedBy FROM ActivityLike) UL ON A.ActivityID = UL.ActivityID AND UL.CreatedBy = @UserID
LEFT OUTER JOIN (
	SELECT
		G.ActivityID,
		G.GroupName,
		R.ResponseTypeID,
		T.ResponseTypeName,
		T.ResponseColor,
		R.CreatedBy AS UserID
	FROM ActivityRosterGroup G
		LEFT OUTER JOIN ActivityRoster R ON G.ActivityRosterGroupID = R.ActivityRosterGroupID
		LEFT OUTER JOIN ResponseType T ON R.ResponseTypeID = T.ResponseTypeID
) UR ON A.ActivityID = UR.ActivityID AND UR.UserID = @UserID
WHERE A.IsDeleted = 0
	AND S.IsDeleted = 0
	AND CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) >= GETDATE()
ORDER BY IsPromoted DESC
