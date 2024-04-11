DROP PROCEDURE dbo.up_ListUserGroupsHierarchy
GO

CREATE PROCEDURE dbo.up_ListUserGroupsHierarchy
	@UserID int
AS
/******************************************************************************
*  DBA Script: up_ListUserGroupsHierarchy
*  Created By: Jason Codianne 
*  Created:    04/06/2018 
*  Schema:     dbo
*  Purpose:    List user groups by hierarchy
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListUserGroupsHierarchy 1
  
-- ============================================================================

;WITH cteGroups (GID, LevelName, GroupParent) AS
(
	SELECT
		UserGroupID AS GID,
		CONVERT(varchar, GroupName) AS LevelName,
		NULL AS GroupParent
	FROM UserGroup 
	WHERE UserID = @UserID
	UNION ALL
	SELECT
		UG.UserID AS GID,
		CONVERT(varchar, U.FirstName + ' ' + U.LastName) AS LevelName,
		UG.UserGroupID
	FROM UserGroupUsers  UG
		INNER JOIN cteGroups C ON UG.UserGroupID = C.GID
		INNER JOIN UserProfile U ON UG.UserID = U.UserID
)

SELECT * FROM UserGroup
SELECT * FROM UserGroupUsers 
 