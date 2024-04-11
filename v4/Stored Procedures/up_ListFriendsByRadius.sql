USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListFriendsByRadius
GO

CREATE PROCEDURE up_ListFriendsByRadius
	@UserID int,
	@Distance float
AS
/******************************************************************************
*  DBA Script: up_ListFriendsByRadius
*  Created By: Jason Codianne 
*  Created:    03/04/2022 
*  Schema:     dbo
*  Purpose:    List friends within a specific radius of home.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListFriendsByRadius 1, 100
-- ============================================================================

DECLARE @UOM int
DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 

SELECT 
	@CurrentLocation = geography::Point(U.HomeBaseLat, U.HomeBaseLng, 4326), 
	@UOM = UnitOfMeasureID
FROM UserProfile U WHERE U.UserID = @UserID

SELECT 
	X.*
FROM (SELECT *, geography::Point(HomeBaseLat, HomeBaseLng, 4326) AS GeoPt FROM UserProfile) X
INNER JOIN UserProfile U ON X.UserID = U.UserID
WHERE GeoPt.STDistance(@CurrentLocation) < (@Distance * @MetersPerMile) 

--SELECT [ExpireDate], CAST([ExpireDate] as date) FROM ActivityFeeler
GO


