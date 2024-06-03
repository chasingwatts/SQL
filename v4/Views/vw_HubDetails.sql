USE [Mortis]
GO

DROP VIEW IF EXISTS vw_HubDetails
GO

CREATE VIEW vw_HubDetails
AS

/******************************************************************************
*  Script Name:  	vw_HubDetails
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2024-05-31
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- SELECT * FROM vw_HubDetails
  
-- ============================================================================

SELECT 
	H.HubID,
	H.HubName,
	HT.HubTypeName,
	H.HubLogoUrl,
	HM.HubMemberCount
FROM Hub H 
	LEFT OUTER JOIN HubType HT ON H.HubTypeID = HT.HubTypeID
	LEFT OUTER JOIN (
		SELECT COUNT(HM.HubMemberID) AS HubMemberCount, HM.HubID FROM HubMember HM GROUP BY HM.HubID
	) HM ON H.HubID = HM.HubID
WHERE H.IsDeleted = 0