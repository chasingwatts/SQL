USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListFriendsCountByRadius
GO

CREATE PROCEDURE up_ListFriendsCountByRadius
	@UserID int,
	@Distance float
AS
/******************************************************************************
*  DBA Script: up_ListFriendsCountByRadius
*  Created By: Jason Codianne 
*  Created:    03/04/2022 
*  Schema:     dbo
*  Purpose:    List friends count within a specific radius of home.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListFriendsCountByRadius 1, 100
-- ============================================================================

DECLARE @UOM int
DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 

SELECT 
	@CurrentLocation = geography::Point(U.HomeBaseLat, U.HomeBaseLng, 4326), 
	@UOM = UnitOfMeasureID
FROM UserProfile U WHERE U.UserID = @UserID

SELECT 
	COUNT(X.UserID) AS FriendCount
FROM (SELECT *, geography::Point(HomeBaseLat, HomeBaseLng, 4326) AS GeoPt FROM UserProfile) X
INNER JOIN UserProfile U ON X.UserID = U.UserID
WHERE GeoPt.STDistance(@CurrentLocation) < (@Distance * @MetersPerMile) 
	AND X.CreatedDate >= DATEADD(d, -7, GETDATE())

GO


