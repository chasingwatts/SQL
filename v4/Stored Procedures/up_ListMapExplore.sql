USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListMapExplore
GO

CREATE PROCEDURE up_ListMapExplore
	@UserID int,
	@Radius float
AS
--/******************************************************************************
--*  DBA Script: up_ListMapExplore
--*  Created By: Jason Codianne 
--*  Created:    10/30/2023 
--*  Schema:     dbo
--*  Purpose:    List activities within a specific radius of home.
--******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListMapExplore 1, 200

 --DECLARE @UserID varchar(100)
 --DECLARE @Radius float
 --SET @UserID = 1
 --SET @Radius = 200


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
	'Ride' AS ExploreType,
	A.ActivityID AS EntityID,
	A.ActivityName AS EntityName,
	A.ActivityDate AS EntityDate,
	A.StartAddress AS EntityAddress,
	A.StartCity AS EntityCity,
	A.StartState AS EntityState,
	A.StartCountry AS EntityCountry,
	A.StartLat AS EntityLat,
	A.StartLng AS EntityLng,
	A.IsPrivate AS EntityPrivate,
	CONVERT(bit, CASE WHEN UR.ResponseTypeID IS NOT NULL THEN 1 ELSE 0 END) AS EntityRosterOrConnected
FROM (SELECT *, geography::Point(StartLat, StartLng, 4326) AS ActivityGeoPt FROM Activity) A
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
			AND CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) >= GETDATE()
			AND CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) <= DATEADD(D, 6, GETDATE())
			AND ActivityGeoPt.STDistance(@CurrentLocation) < @Radius * @MetersPerMile
UNION ALL
SELECT	
	'Friend' AS ExploreType,
	U.UserID,
	U.FirstName + ' ' + U.LastName,
	U.CreatedDate,
	NULL AS EntityAddress,
	U.HomeBaseCity AS EntityCity,
	U.HomeBaseState AS EntityState,
	U.HomeBaseCountry AS EntityCountry,
	U.HomeBaseLat,
	U.HomeBaseLng,
	U.[Private],
	CONVERT(bit, CASE WHEN F.FollowingID IS NULL THEN 0 ELSE 1 END)
FROM (SELECT *, geography::Point(HomeBaseLat, HomeBaseLng, 4326) AS UserGeoPt FROM UserProfile) U
LEFT OUTER JOIN UserFollowing F ON U.UserID = F.FollowingID
	AND F.FollowingID <> @UserID --not self
WHERE U.IsDeleted = 0
	AND U.UserGeoPt.STDistance(@CurrentLocation) < @Radius * @MetersPerMile