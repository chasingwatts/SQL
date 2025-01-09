USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_SearchRides
GO

CREATE PROCEDURE up_SearchRides
	@UserID int,
	@StartLat float,
	@StartLng float,
	@Radius float,
	@ActivityName varchar(200) = NULL,
	@StartDate date = NULL,
	@EndDate date = NULL,
	@ActivityTypeID int = NULL,
	@DifficultyLevelID int = NULL,
	@MinDistance float = NULL,
	@MaxDistance float = NULL
AS
--/******************************************************************************
--*  DBA Script: up_SearchRides
--*  Created By: Jason Codianne 
--*  Created:    03/10/2024 
--*  Schema:     dbo
--*  Purpose:    List activities within a specific search criteria.
--******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_SearchRides null, 29.4564, -95.46546, 100, null, '01/10/2025', '01/12/2025', null, null, null, null

 --DECLARE @UserID varchar(100)
 --DECLARE @Radius float
 --SET @UserID = 1
 --SET @Radius = 2000


-- ============================================================================

SET NOCOUNT ON

DECLARE @UOM int
DECLARE @UOMName varchar(10)
DECLARE @UOMFactor float
DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 

SET @CurrentLocation = geography::Point(@StartLat, @StartLng, 4326)

IF @UserID IS NULL
	SET @UserID = 0

IF @ActivityName IS NOT NULL	
	SET @ActivityName = '%' + @ActivityName + '%'

IF @StartDate IS NULL
	SET @StartDate = CONVERT(varchar, GETDATE(), 101)

IF @EndDate IS NULL
	SET @EndDate = DATEADD(Y, 1, GETDATE())

IF @MinDistance IS NULL
	SET @MinDistance = 0

IF @MaxDistance IS NULL
	SET @MaxDistance = 500

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
		WHEN A.IsPrivate = 1 AND (A.TeamID IS NOT NULL AND A.TeamID > 0) THEN 'Private ' + HT.HubTypeName + ' Ride'
		WHEN A.IsPrivate = 0 AND (A.TeamID IS NOT NULL AND A.TeamID > 0) THEN 'Public ' + HT.HubTypeName + ' Ride'
		WHEN A.IsPrivate = 1 AND (A.TeamID IS NULL OR A.TeamID = 0) THEN 'Private Ride'
		WHEN A.IsPrivate = 0 AND (A.TeamID IS NULL OR A.TeamID = 0) THEN 'Public Ride'
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
	LEFT OUTER JOIN ActivityRoute RT ON A.ActivityID = RT.ActivityID
WHERE A.IsDeleted = 0
	AND ActivityGeoPt.STDistance(@CurrentLocation) < (@Radius * @MetersPerMile)
	AND A.ActivityName LIKE COALESCE(@ActivityName, A.ActivityName)
	AND A.ActivityTypeID = COALESCE(@ActivityTypeID, A.ActivityTypeID)
	AND A.ActivityDate BETWEEN @StartDate AND @EndDate
	AND RT.DifficultyLevelID = COALESCE(@DifficultyLevelID, RT.DifficultyLevelID)
	AND RT.Distance BETWEEN @MinDistance AND @MaxDistance
	AND (
		A.[IsPrivate] = 0  --not private
			OR A.TeamID IN (SELECT DISTINCT H.HubID FROM Hub H LEFT OUTER JOIN HubMember HM ON H.HubID = HM.HubID WHERE (HM.UserID = @UserID)) --in assoc team
			OR @UserID IN (SELECT DISTINCT CreatedBy FROM ActivityRoster WHERE ActivityID = A.ActivityID) --on the roster
			OR @UserID IN (SELECT InviteUserID FROM ActivityInvite WHERE ActivityID = A.ActivityID) --invited
			OR @UserID = A.UserID --created ride
			OR (SELECT Role FROM Accounts WHERE id = @UserID) = 0 --admin role
	)
ORDER BY IsPromoted DESC
