USE [trovafit_aspnet_dev]
GO

DROP PROCEDURE IF EXISTS up_ListFriendsByDistanceCount
GO

CREATE PROCEDURE up_ListFriendsByDistanceCount
	@UserID int,
	@Distance float
AS
/******************************************************************************
*  DBA Script: up_ListFriendsByDistanceCount
*  Created By: Jason Codianne 
*  Created:    03/04/2022 
*  Schema:     dbo
*  Purpose:    List friends count within a specific radius of home.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListFriendsByDistanceCount 1, 100
-- ============================================================================


DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 
SELECT @CurrentLocation = geography::STPointFromText('POINT(' + CAST(HomeBaseLng AS VARCHAR(20)) + ' ' + CAST(HomeBaseLat AS VARCHAR(20)) + ')', 4326) 
FROM UserProfile WHERE UserID = @UserID

SELECT 
	COUNT(X.UserID) AS UserCount
FROM (SELECT *, geography::Point(HomeBaseLat, HomeBaseLng, 4326) AS GeoPt FROM UserProfile) X
INNER JOIN UserProfile U ON X.UserID = U.UserID
WHERE GeoPt.STDistance(@CurrentLocation) < (@Distance * @MetersPerMile) 

--SELECT [ExpireDate], CAST([ExpireDate] as date) FROM ActivityFeeler