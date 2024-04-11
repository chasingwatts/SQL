USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS up_ListFriendsByDistance
GO

CREATE PROCEDURE up_ListFriendsByDistance
	@UserID int,
	@Distance float
AS
/******************************************************************************
*  DBA Script: up_ListFriendsByDistance
*  Created By: Jason Codianne 
*  Created:    03/04/2022 
*  Schema:     dbo
*  Purpose:    List friends within a specific radius of home.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListFriendsByDistance 1, 100
-- ============================================================================


DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 
SELECT @CurrentLocation = geography::STPointFromText('POINT(' + CAST(HomeBaseLng AS VARCHAR(20)) + ' ' + CAST(HomeBaseLat AS VARCHAR(20)) + ')', 4326) 
FROM UserProfile WHERE UserID = @UserID

SELECT 
	X.UserID,
	X.FirstName,
	X.LastName,
	X.DisplayName,
	X.HomeBaseZip,
	X.CreatedBy, 
	X.CreatedDate, 
	X.ModifiedBy, 
	X.ModifiedDate
FROM (SELECT *, geography::Point(HomeBaseLat, HomeBaseLng, 4326) AS GeoPt FROM UserProfile) X
INNER JOIN UserProfile U ON X.UserID = U.UserID
WHERE GeoPt.STDistance(@CurrentLocation) < (@Distance * @MetersPerMile) 
