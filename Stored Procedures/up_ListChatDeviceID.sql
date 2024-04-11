USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_ListChatDeviceID
GO

CREATE PROCEDURE dbo.up_ListChatDeviceID
	@ActivityID int,
	@UserID int
AS
/******************************************************************************
*  DBA Script: dbo.up_ListChatDeviceID
*  Created By: Jason Codianne 
*  Created:    9/28/2018 
*  Schema:     dbo
*  Purpose:    
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC dbo.up_ListChatDeviceID 2249, 52
  
-- ============================================================================

SELECT
	R.ActivityDiscussionID,
	R.ActivityID,
	R.UserID,
	R.DiscussionParentID,
	R.ActivityComment,
	R.CommentDate,
	P.FirstName,
	P.LastName,
	P.FirstName + ' ' + P.LastName AS FullName,
	A.ActivityName,
	D.DeviceID
FROM ActivityDisuccsionThreads R
	INNER JOIN Activity A ON R.ActivityID = A.ActivityID
	INNER JOIN UserNotification N ON R.UserID = N.UserID
	LEFT OUTER JOIN UserDevice D ON R.UserID = D.UserID
	INNER JOIN UserProfile P ON R.UserID = P.UserID
WHERE R.ActivityID = @ActivityID
	AND N.ActivityDiscussionApp = 1 
ORDER BY R.ActivityDiscussionID, R.DiscussionParentID