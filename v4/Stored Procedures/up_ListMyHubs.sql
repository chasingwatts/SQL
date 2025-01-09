USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListMyHubs
GO

CREATE PROCEDURE up_ListMyHubs
	@UserID int
AS
--/******************************************************************************
--*  DBA Script: up_ListMyHubs
--*  Created By: Jason Codianne 
--*  Created:    10/30/2023 
--*  Schema:     dbo
--*  Purpose:    List hubs for user.
--******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListMyHubs 1

 --DECLARE @UserID varchar(100)
 --DECLARE @Radius float
 --SET @UserID = 1
 --SET @Radius = 200


-- ============================================================================

SET NOCOUNT ON

SELECT
	H.HubID, 
	H.HubTypeID, 
	H.HubName, 
	H.HubRouteName, 
	H.HubLat, 
	H.HubLng, 
	H.HubAddress, 
	H.HubAddress2, 
	H.HubCity, 
	H.HubState, 
	H.HubZip, 
	H.HubCountry, 
	H.HubPhone, 
	H.HubEmail, 
	H.HubUrl, 
	H.HubLogoUrl, 
	H.HubSocialUrl, 
	H.IsPrivate, 
	H.IsDeleted, 
	H.CreatedBy, 
	H.CreatedDate, 
	H.ModifiedBy, 
	H.ModifiedDate
FROM Hub H 
	LEFT OUTER JOIN HubMember HM ON H.HubID = HM.HubID
WHERE H.IsDeleted = 0
	AND (HM.UserID = @UserID AND HM.HubMemberRoleID = 1)
ORDER BY H.HubName
