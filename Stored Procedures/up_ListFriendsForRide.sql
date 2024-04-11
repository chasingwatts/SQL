--USE [trovafit_aspnet]
--GO

--/****** Object:  StoredProcedure [db_owner].[up_ListFriendsForRide]    Script Date: 11/18/2022 7:55:45 PM ******/
--DROP PROCEDURE up_ListFriendsForRide
--GO

--/****** Object:  StoredProcedure [db_owner].[up_ListFriendsForRide]    Script Date: 11/18/2022 7:55:45 PM ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO


--CREATE PROCEDURE up_ListFriendsForRide
--	@UserID int,
--	@ActivityID int
--AS
--/******************************************************************************
--*  DBA Script: up_ListFriendsForRide
--*  Created By: Jason Codianne 
--*  Created:    05/25/2020 
--*  Schema:     dbo
--*  Purpose:    List friends near user with roster count
--******************************************************************************/
---- ============================================================================
---- Testing Parms
---- EXEC up_ListFriendsForRide 1, 8413
  
---- ============================================================================

DECLARE @UserID int
DECLARE @ActivityID int

SET @UserID = 1
SET @ActivityID = 8413

SELECT
	C.ConnectionUserID AS UserID,
	U.FirstName,
	U.LastName,
	U.HomeBaseZip
FROM UserConnection C
	INNER JOIN UserProfile U ON C.ConnectionUserID = U.UserID
	--LEFT OUTER JOIN (
	--	SELECT UserID, COUNT(ActivityID) AS UserRosterCount FROM ActivityInvite WHERE InviteUserID = @UserID GROUP BY UserID
	--) R ON C.ConnectionUserID = R.UserID
WHERE C.UserID = @UserID
	AND C.ConnectionConfirmed = 1
	AND C.ConnectionIgnored = 0
	AND C.ConnectionUserID NOT IN (SELECT UserID FROM ActivityInvite WHERE ActivityID = @ActivityID) --not already invited
	AND C.ConnectionUserID NOT IN (SELECT UserID FROM ActivityRoster WHERE ActivityID = @ActivityID) --not already on roster
ORDER BY U.LastName
GO


