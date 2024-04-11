USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_ListDiscussionThreadsByActivity
GO

CREATE PROCEDURE dbo.up_ListDiscussionThreadsByActivity
	@ActivityID int,
	@UserID int
AS
/******************************************************************************
*  DBA Script: up_ListDiscussionThreadsByActivity
*  Created By: Jason Codianne 
*  Created:    5/25/2018 
*  Schema:     dbo
*  Purpose:    
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListDiscussionThreadsByActivity 2194, 1
  
-- ============================================================================


;WITH Discussion AS (
    SELECT 
		ActivityDiscussionID, 
		DiscussionParentID AS DiscussionParentID, 
		ActivityID, 
		UserID, 
		ActivityComment,
		CommentDate,
		0 AS DiscussionLevel,
		CAST(ActivityDiscussionID AS VARCHAR(255)) AS DiscussionPath
    FROM ActivityDisuccsionThreads 
    WHERE DiscussionParentID IS NULL 
		AND ActivityID = @ActivityID

    UNION ALL

    SELECT 
		T.ActivityDiscussionID, 
		T.DiscussionParentID,
		T.ActivityID, 
		T.UserID, 
		T.ActivityComment,
		T.CommentDate,
		DiscussionLevel + 1,
		CAST(DiscussionPath + '.' + CAST(T.ActivityDiscussionID AS VARCHAR(255)) AS VARCHAR(255))
    FROM ActivityDisuccsionThreads T
    INNER JOIN discussion D ON D.ActivityDiscussionID = T.DiscussionParentID
)

SELECT 
	D.*, 
	U.FirstName,
	U.LastName,
	MyComment = CONVERT(bit, CASE WHEN D.UserID = @UserID THEN 1 ELSE 0 END)
FROM Discussion D
	INNER JOIN UserProfile U ON D.UserID = U.UserID
ORDER BY DiscussionPath