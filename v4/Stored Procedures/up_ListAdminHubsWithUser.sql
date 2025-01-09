DROP PROCEDURE IF EXISTS up_ListAdminHubsWithUser
GO

CREATE PROCEDURE up_ListAdminHubsWithUser
	@AdminID int,
	@UserID int
AS

/******************************************************************************
*  Script Name:  	up_ListAdminHubsWithUser
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2025-01-04
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_ListAdminHubsWithUser 1, 33
  
-- ============================================================================

SELECT
    H.HubID,
    H.HubName,
	HT.HubTypeName,
    H.IsPrivate,
	@AdminID AS AdminID,
	@UserID AS UserID,
    CONVERT(bit, CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM HubMember HM 
            WHERE HM.HubID = H.HubID AND HM.UserID = @UserID
        ) THEN 1 
        ELSE 0
    END) AS UserInHub
FROM Hub H 
	INNER JOIN HubType HT ON H.HubTypeID = HT.HubTypeID
WHERE H.IsDeleted = 0
    AND EXISTS (
        SELECT 1
        FROM HubMember HM 
        WHERE HM.HubID = H.HubID AND HM.UserID = @AdminID AND HM.HubMemberRoleID = 1
    )
