USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS dbo.up_ListFeelersByDistance
GO

CREATE PROCEDURE dbo.up_ListFeelersByDistance
	@UserID int,
	@Distance float
AS
/******************************************************************************
*  DBA Script: up_ListFeelersByDistance
*  Created By: Jason Codianne 
*  Created:    01/22/2021 
*  Schema:     dbo
*  Purpose:    List feelers within a specific radius of home.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC dbo.up_ListFeelersByDistance 1, 100
-- ============================================================================


DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 
SELECT @CurrentLocation = geography::STPointFromText('POINT(' + CAST(HomeBaseLng AS VARCHAR(20)) + ' ' + CAST(HomeBaseLat AS VARCHAR(20)) + ')', 4326) 
FROM UserProfile WHERE UserID = @UserID

SELECT 
	X.ActivityFeelerID, 
	X.UserID, 
	X.FeelerTitle, 
	X.FeelerDescription, 
	X.FeelerUrl, 
	X.FeelerLocationName,
	X.FeelerLat,
	X.FeelerLng,
	X.ProposedDate, 
	X.[ExpireDate],
	X.CreatedBy, 
	X.CreatedDate, 
	X.ModifiedBy, 
	X.ModifiedDate,
	U.FirstName,
	U.LastName,
	CASE WHEN X.UserID = @UserID THEN '#377d22' ELSE 'AliceBlue' END AS OwnerColor
FROM (SELECT *, geography::Point(FeelerLat, FeelerLng, 4326) AS GeoPt FROM ActivityFeeler) X
INNER JOIN UserProfile U ON X.UserID = U.UserID
WHERE CAST([ExpireDate] as date) >= GETDATE()
	AND GeoPt.STDistance(@CurrentLocation) < (@Distance * @MetersPerMile) 
ORDER BY ProposedDate 

--SELECT [ExpireDate], CAST([ExpireDate] as date) FROM ActivityFeeler