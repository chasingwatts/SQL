USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_ListSuggestedFriends
GO

CREATE PROCEDURE dbo.up_ListSuggestedFriends
	@UserID int
AS
/******************************************************************************
*  DBA Script: up_ListSuggestedFriends
*  Created By: Jason Codianne 
*  Created:    02/27/2018 
*  Schema:     dbo
*  Purpose:    List friends of friends for suggestion
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListSuggestedFriends 1
  
-- ============================================================================
SET NOCOUNT ON

--DECLARE @UserID int
--SET @UserID = 1

SELECT DISTINCT TOP 10 
	C.UserConnectionID,
	C.UserID,
	C.ConnectionUserID,
	C.ConnectionConfirmed,
	P.FirstName,
	P.LastName,
	P.HomeBaseZip,
	P.Private
FROM UserConnection C
	INNER JOIN UserProfile P ON C.ConnectionUserID = P.UserID
WHERE C.UserID IN (SELECT ConnectionUserID AS MyFriendsID FROM UserConnection UC WHERE UC.UserID = @UserID AND UC.ConnectionConfirmed = 1 AND UC.ConnectionIgnored = 0)
	AND C.ConnectionUserID NOT IN (SELECT ConnectionUserID AS MyFriendsID FROM UserConnection UC WHERE UC.UserID = @UserID AND UC.ConnectionConfirmed = 1 AND UC.ConnectionIgnored = 0)
	AND C.ConnectionUserID <> @UserID