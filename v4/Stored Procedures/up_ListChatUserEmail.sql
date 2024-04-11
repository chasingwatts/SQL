USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListChatUserEmail
GO

CREATE PROCEDURE up_ListChatUserEmail
	@ActivityID int
AS

/******************************************************************************
*  Script Name:  	up_ListChatUserEmail
*  Created By:  	Jason 
*  Created Date:  	2024-03-26
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_ListChatUserEmail 10

-- DECLARE @ActivityID int
-- SET @ActivityID = 10
  
-- ============================================================================

SELECT DISTINCT * 
FROM ( 
	SELECT DISTINCT 
		U.*
	FROM ActivityChat C
		INNER JOIN UserProfile U ON C.CreatedBy = U.UserID
		INNER JOIN Accounts A ON U.UserID = A.Id
		INNER JOIN UserNotification N ON C.CreatedBy = N.UserID
	WHERE C.ActivityID = @ActivityID
		AND N.ActivityDiscussionEmail = 1
	UNION ALL
	SELECT 
		U.*
	FROM Activity A
		INNER JOIN UserProfile U ON A.UserID = U.UserID
	WHERE A.ActivityID = @ActivityID
) X