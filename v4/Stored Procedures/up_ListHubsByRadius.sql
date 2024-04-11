USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListHubsByRadius
GO

CREATE PROCEDURE up_ListHubsByRadius
	@UserID int,
	@Radius float
AS
--/******************************************************************************
--*  DBA Script: up_ListHubsByRadius
--*  Created By: Jason Codianne 
--*  Created:    10/30/2023 
--*  Schema:     dbo
--*  Purpose:    List hubs within a specific radius of home.
--******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListHubsByRadius 1, 200

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

SELECT 
	@CurrentLocation = geography::Point(U.HomeBaseLat, U.HomeBaseLng, 4326), 
	@UOM = UnitOfMeasureID
FROM UserProfile U WHERE U.UserID = @UserID

SELECT
	[HubID]
      ,[HubTypeID]
      ,[HubName]
      ,[HubRouteName]
      ,[HubLat]
      ,[HubLng]
      ,[HubAddress]
      ,[HubAddress2]
      ,[HubCity]
      ,[HubState]
      ,[HubZip]
      ,[HubCountry]
      ,[HubPhone]
      ,[HubEmail]
      ,[HubUrl]
      ,[HubLogoUrl]
      ,[HubSocialUrl]
      ,[IsPrivate]
      ,[IsDeleted]
      ,[CreatedBy]
      ,[CreatedDate]
      ,[ModifiedBy]
      ,[ModifiedDate]
FROM (SELECT *, geography::Point(HubLat, HubLng, 4326) AS HubGeoPt FROM Hub) H
WHERE H.IsDeleted = 0
	AND HubGeoPt.STDistance(@CurrentLocation) < @Radius * @MetersPerMile
ORDER BY H.HubName
