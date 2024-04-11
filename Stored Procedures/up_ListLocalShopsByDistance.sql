USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_ListLocalShopsByDistance
GO

CREATE PROCEDURE dbo.up_ListLocalShopsByDistance
	@UserID int,
	@Distance float
AS
/******************************************************************************
*  DBA Script: up_ListLocalShopsByDistance
*  Created By: Jason Codianne 
*  Created:    01/17/2018 
*  Schema:     dbo
*  Purpose:    List shops within a specific radius of home.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListLocalShopsByDistance 1, 200
  
-- ============================================================================
SET NOCOUNT ON

--DECLARE @UserID int
--DECLARE @Distance float

--SET @UserID = 1
--SET @Distance = 500

DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 
SELECT @CurrentLocation = geography::STPointFromText('POINT(' + CAST(HomeBaseLng AS VARCHAR(20)) + ' ' + CAST(HomeBaseLat AS VARCHAR(20)) + ')', 4326) 
FROM UserProfile WHERE UserID = @UserID

SELECT
	L.LocalShopID, 
	L.LocalShopName, 
	L.LocalShopRouteName, 
	L.OwnerID, 
	P.FirstName,
	P.LastName,
	L.LocalShopAddress, 
	L.LocalShopAddress2, 
	L.LocalShopCity, 
	L.LocalShopState, 
	L.LocalShopZip, 
	L.LocalShopCountry, 
	ISNULL(L.LocalShopPhone, '---') AS LocalShopPhone, 
	ISNULL(L.LocalShopEmail, '---') AS LocalShopEmail, 
	ISNULL(L.LocalShopUrl, '---') AS LocalShopUrl, 
	L.LocalShopFacebookUrl, 
	L.LocalShopLogoUrl,
	L.LocalShopLat,
	L.LocalShopLng
FROM (
	SELECT 
		L.LocalShopID, 
		L.LocalShopName, 
		L.LocalShopRouteName, 
		L.OwnerID, 
		L.LocalShopAddress, 
		L.LocalShopAddress2, 
		L.LocalShopCity, 
		L.LocalShopState, 
		L.LocalShopZip, 
		L.LocalShopCountry, 
		L.LocalShopPhone, 
		L.LocalShopEmail, 
		L.LocalShopUrl, 
		L.LocalShopFacebookUrl, 
		L.LocalShopLogoUrl, 
		L.LocalShopLat,
		L.LocalShopLng,
		geography::Point(L.LocalShopLat, L.LocalShopLng, 4326) AS GeoPt 
	FROM LocalShop L
) L
INNER JOIN UserProfile P ON L.OwnerID = P.UserID
WHERE GeoPt.STDistance(@CurrentLocation) < (@Distance * @MetersPerMile)
ORDER BY L.LocalShopName