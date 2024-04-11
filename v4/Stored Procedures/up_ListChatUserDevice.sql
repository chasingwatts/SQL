USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListChatUserDevice
GO

CREATE PROCEDURE up_ListChatUserDevice
	@ActivityID int
AS

/******************************************************************************
*  Script Name:  	up_ListChatUserDevice
*  Created By:  	Jason 
*  Created Date:  	2024-03-26
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_ListChatUserDevice 10
  
-- ============================================================================

SELECT DISTINCT * FROM ( 
	SELECT DISTINCT 
		D.*
	FROM ActivityChat C
		INNER JOIN UserDevice D ON C.CreatedBy = D.UserID
		INNER JOIN UserNotification N ON C.CreatedBy = N.UserID
	WHERE C.ActivityID = 10
		AND D.DeviceID IS NOT NULL
		AND N.ActivityDiscussionApp = 1
	UNION ALL
	SELECT 
		D.*
	FROM Activity A
		INNER JOIN UserDevice D ON A.UserID = D.UserID
	WHERE A.ActivityID = @ActivityID
) X