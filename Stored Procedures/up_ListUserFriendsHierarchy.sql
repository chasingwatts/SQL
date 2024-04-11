DROP PROCEDURE dbo.up_ListUserFriendsHierarchy
GO

CREATE PROCEDURE dbo.up_ListUserFriendsHierarchy
	@UserID int
AS
/******************************************************************************
*  DBA Script: up_ListUserFriendsHierarchy
*  Created By: Jason Codianne 
*  Created:     
*  Schema:     dbo
*  Purpose:    
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListUserFriendsHierarchy 1
  
-- ============================================================================


;WITH cteFriends (FID, FriendName, UserParent) AS
(
	SELECT
		UserID AS FID,
		CONVERT(varchar, FirstName + ' ' + LastName) AS FriendName,
		NULL AS UserParent
	FROM UserProfile
	WHERE UserID = @UserID
	UNION ALL
	SELECT
		UC.ConnectionUserID AS FID,
		CONVERT(varchar, U.FirstName + ' ' + U.LastName) AS FriendName,
		UC.UserID AS UserParent
	FROM UserConnection UC
		INNER JOIN UserProfile U ON UC.ConnectionUserID = U.UserID
	WHERE UC.UserID = @UserID
	AND (UC.ConnectionConfirmed = 1 AND UC.ConnectionIgnored = 0)
)

SELECT * FROM cteFriends 

